# This reads the svg files and produces a JSON file with all deparments
# and muncipalities' paths and labels
#

jsdom    = require 'jsdom'
fs       = require 'fs'
pais     = fs.readFileSync('./resources/pais.svg').toString()
depts    = fs.readFileSync('./resources/departamentos.svg').toString()
out_file = 'demo/svmap-paths.json'

## helpers
#

# This provides sequential id's
nextId = do ->
  counter = 0
  (-> "#{counter++}")

# removes `\t`, `\r`, and `\n` chars
strip = (txt)-> txt.replace /[\t|\n|\r]/g, ''

# finds the `d` attribute if the node is a `path` element. 
# if the element is a `polygon` converts its `points` atttribute to
# a path's `d` attribute
extractPath = (node)->
  switch node.nodeName 
    when 'PATH'
      path = strip(node.getAttribute 'd'  or ' ')
    when 'POLYGON'
      poly = node.getAttribute 'points'
      # converting to path (absolute `lineto`)
      path = "M #{(strip poly).replace ' ', ' L' } z" if poly

  path or null

extractTransform = (node)-> 
  matrix = node.getAttribute 'transform'
  if matrix 
    t = matrix.replace(/matrix|\(|\)/g,'')
    t = (parseFloat n for n in t.split " " )

  t or ''

extractId = (node)->
  id = node.getAttribute 'id'
  if id is '' then nextId() else id

# stores an object literal as a *JSON* file in the out_file
saveData = (obj)->
  fs.writeFileSync out_file, JSON.stringify obj
  console.log "Data saved to #{out_file}"

## Process pais.svg

#
jsdom.env pais, (err, win)->

  # queries
  nodeById    = (id)-> win.document.getElementById id

  # data to be exported
  output =
    pais:
      shadow       : extractPath( nodeById 'shadow')
      background   : extractPath( nodeById 'background')
      departamentos: {}

  # extract departamentos
  departamentos = win.document.getElementsByTagName 'g'
  for g in departamentos
    text = (g.getElementsByTagName 'text')[0]
    output.pais.departamentos[ extractId g ] =
      lbl          : text.textContent
      lblTransform : extractTransform text
      path         : extractPath (g.getElementsByTagName 'path')[0]
      municipios   : {}

  # ## Process departamentos.svg

  #
  jsdom.env depts, (err, win)->

    # look for groups sharing a key with departamentos
    for key of output.pais.departamentos
      departamento = win.document.getElementById key

      # iterate over all `path` and `poly` elements inside the departamento
      # group.
      for el in departamento.childNodes
        #skip text nodes
        continue if el.nodeName is '#text'

        # add municipio to its respective departamento 
        output.pais.departamentos[ key ].municipios[ extractId el ] =
          path: extractPath el

    saveData output

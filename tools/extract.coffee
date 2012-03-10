# This reads the svg files and produces a JSON file with all deparments
# and muncipalities' paths and labels
#

#in_file_depts = './resources/departamentos.svg'
#in_file_depts = './resources/departamentos-large-centered.svg'
in_file_depts = './resources/departamentos-large-centered-no-dispersed.svg'

jsdom    = require 'jsdom'
fs       = require 'fs'
pais     = fs.readFileSync('./resources/pais.svg').toString()
depts    = fs.readFileSync( in_file_depts ).toString()
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

# takes a path and rounds each point to one decimal place
zipPath = (path)->
  tokens = path.match /m|,|\s|\d+\.?[0-9]+/g
  ret    = []
  for token in tokens
    if !isNaN(token) and token isnt ' '
      token = parseFloat(token).toFixed 4
    ret.push token

  ret.join ''

extractId = (node)->
  id = node.getAttribute('id').substring 0, 5
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
      continue unless departamento?

      # iterate over all `path` and `poly` elements inside the departamento
      # group.
      for el in departamento.childNodes
        #skip text nodes
        continue if el.nodeName is '#text'

        # add municipio to its respective departamento 
        output.pais.departamentos[ key ].municipios[ extractId el ] =
          path: extractPath el

    saveData output

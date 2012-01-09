## SVMap

#
# * `el`: jQuery Object
# * `data`: object literal exportado desde archivos SVG y cargado como JSON
#
class SVMap
  constructor: (@div_id, @data)->
    @paper  = Raphael @div_id, 900, 470  
    @paths  = []
    @_cache = {}
    @renderPais()

  # dibuja un departamento
  # TODO add events
  renderDepartamento: (code)->
    @_cache.currentDept.remove() if @_cache.currentDept?
    @_cache[ 'currentDept' ] = @paper.set()
    departamento = @data.pais.departamentos[code]

    # shadow
    for key, municipio of departamento.municipios
      @_cache.currentDept.push @paper.path(municipio.path)
                                     .attr( fill: '#C9CBDC', stroke: 'none' )
                                     .translate 553, 53

    # background
    for key, municipio of departamento.municipios
      @_cache.currentDept.push @paper.path(municipio.path)
                                     .attr( fill:  '#8C8FAB', stroke: 'none' )
                                     .translate 551, 51

    for key, municipio of departamento.municipios
      if key.match /lago/
        attr =
          fill  : '#58A9F4'
          stroke: '#3684CC'
      else
        attr =
          stroke: '#8489BF'
          fill  : '#CFD2F1'

      @_cache.currentDept.push @paper.path(municipio.path)
                                     .attr(attr)
                                     .translate 550, 50



  renderPais: ->
    # dibujar sombra
    @paper.path(@data.pais.shadow)
          .attr
            fill  : '#C9CBDC'
            stroke: 'none'

    # dibujar background
    @paper.path(@data.pais.background)
          .attr
            fill  : '#8C8FAB'
            stroke: 'none'

    # dibujar departamentos
    for key, departamento of @data.pais.departamentos
      # Paths
      dept = @paper.path(departamento.path)
                   .attr
                     fill  : '#CFD2F1'
                     stroke: '#8489BF'

      # Labels
      matrix = Raphael.matrix.apply null, departamento.lblTransform
      lbl    = @paper.text( 0, 0, key.replace 'd', '')
                     .transform( matrix.toTransformString() )
                     .attr( fill: '#7A80BE', 'font-size': 10)

      # agregar raphael object a `paths` array
      @paths.push el: dept, lbl: lbl, key: key

  # regresa `true` si el evento es soportado
  supportsEvent: (event)->
    events = { 'click', 'dblclick', 'mouseover', 'mouseout',
              'mousemove', 'mousedown', 'mouseout' }

    events[ event ]?

  # adentro de un loop mandar la funcion `fun` y la string `key` al
  # mismo nivel de scope que el event handler
  on: (event, fun)->
    throw "Evento #{event} no soportado" unless @supportsEvent event
    for path in @paths
      {el, lbl, key} = path
      el[ event ] do (fun, key, el)-> (-> fun key, el) 

      # agregar evento al label si existe
      if lbl
        lbl[ event ] do (fun, key, el)-> (-> fun key, el) 

# Wrapper, crea el mapa y cuando el archivo `data/data.json` ha sido
# cargado ejecuta la funcion `fun`
window.SVMap = (div_id, fun)->
  $.getJSON 'data/data.json', (data)-> 
    mapa = new SVMap div_id, data
    fun mapa

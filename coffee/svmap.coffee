## SVMap

#
# * `el`: jQuery Object
# * `data`: object literal exportado desde archivos SVG y cargado como JSON
#
class SVMap
  constructor: (@div_id, @data)->
    @paper = Raphael @div_id, 900, 470  
    @paths = []

    # @renderDepartamento 'd06'
    @_initMap()

  # dibuja un departamento
  renderDepartamento: (code)->
    #TODO remove current rendered departamento 
    departamento = @data.pais.departamentos[code]
    for key, municipio of departamento.municipios
      if key.match /lago/
        attr =
          fill  : '#58A9F4'
          stroke: '#3684CC'
      else
        attr =
          stroke: '#8C8FAB'
          fill  : '#CFD2F1'
      @paper.path(municipio.path)
            .attr(attr)
            .translate 550, 75



  _initMap: ->
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
                     stroke: '#8C8FAB'

      # Labels
      matrix = Raphael.matrix.apply null, departamento.lblTransform
      lbl    = @paper.text( 0, 0, departamento.lbl)
                     .attr( fill: '#5F6495' )
                     .transform( matrix.toTransformString() )

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

## SVMap

#
# * `el`: jQuery Object
# * `data`: object literal exportado desde archivos SVG y cargado como JSON
#
class SVMap
  constructor: (@div_id, @data)->
    @paper  = Raphael @div_id, 780, 470
    @_cache = {}
    @renderPais()

  # dibuja un departamento
  # TODO add events
  renderDepartamento: (departamento)->

    @_cache.currentDept.remove() if @_cache.currentDept?
    @_cache[ 'currentDept' ] = @paper.set()

    # shadow
    for key, municipio of departamento.municipios
      @_cache.currentDept.push @paper.path(municipio.path)
                                     .attr( fill: '#C9CBDC', stroke: 'none' )
                                     .translate -3, 53

    # background
    for key, municipio of departamento.municipios
      @_cache.currentDept.push @paper.path(municipio.path)
                                     .attr( fill:  '#8C8FAB', stroke: 'none' )
                                     .translate -1, 51

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
                                     .translate(-3, 50)
                                     .attr(opacity: 0)
                                     .animate( opacity: 1 , 90 )

  renderPais: ->

    # preparar cache
    @_cache[ 'departamentos' ] = []

    # dibujar sombra
    @_cache[ 'shadow' ] = @paper.path(@data.pais.shadow)
                            .attr
                              fill  : '#C9CBDC'
                              stroke: 'none'

    # dibujar background
    @_cache[ 'background' ] = @paper.path(@data.pais.background)
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
      lbl    = @paper.text( 0, 0, departamento.lbl)
                     .transform( matrix.toTransformString() )
                     .attr( fill: '#7A80BE', 'font-size': 10)

      dept.code = key
      @_cache.departamentos.push path: dept, label: lbl, code: key

  # regresa `true` si el evento es soportado
  supportsEvent: (event)->
    events = { 'click', 'dblclick', 'mouseover', 'mouseout',
              'mousemove', 'mousedown', 'mouseout' }

    events[ event ]?

  on: (event, fun)->
    throw "Evento #{event} no soportado" unless @supportsEvent event
    for departamento in @_cache.departamentos
      # obtengo una function expression que ejecuta `fun` y pasa al departamento
      # usando una funcion anonima autoejecutable, esto es necesario por
      # que estamos asignando el handler adentro de un loop.
      handler = do (fun, departamento) -> (-> fun departamento, departamento.code)
      departamento.path[ event ]  handler
      departamento.label[ event ] handler

  hidePais: (f)->
    @_cache.shadow.hide()
    for departamento in @_cache.departamentos
      departamento.path.hide()
      departamento.label.hide()
    @_cache.background.animate opacity: 0, 100, -> f?()

  showPais: ->
    @_cache.currentDept.hide()
    @_cache.background.animate opacity: 1, 100, =>
      @_cache.shadow.show()
      for departamento in @_cache.departamentos
        departamento.path.show()
        departamento.label.show()

  showDepartamento: (code)->
    # buscar departamento, si no existe regresar
    departamento = @data.pais.departamentos[code]
    return unless departamento?
    @hidePais => @renderDepartamento departamento

# Wrapper, crea el mapa y cuando el archivo `data/data.json` ha sido
# cargado ejecuta la funcion `fun`
window.SVMap = (div_id, fun)->
  $.getJSON 'svmap-paths.json', (data)->
    mapa = new SVMap div_id, data
    fun mapa

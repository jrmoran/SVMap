## SVMap

#
# * `el`: jQuery Object
# * `data`: object literal exportado desde archivos SVG y cargado como JSON
#
class SVMap
  constructor: (@div_id, @data)->
    @paper  = Raphael @div_id, 780, 470
    @_cache = {}
    @_cache[ 'events' ] = {}
    @renderPais()

  # dibuja un departamento
  renderDepartamento: (departamento)->

    @_cache.currentDept.remove() if @_cache.currentDept?
    @_cache[ 'currentDept' ] = @paper.set()

    [x, y] = [-140, -370]

    # Tres loops son necesarios para renderizar los elementos en orden

    # shadow
    for code, municipio of departamento.municipios
      shadow = @paper.path(municipio.path)
                     .attr( fill: '#C9CBDC', stroke: 'none' )
                     .translate x + 5, y + 5

      @_cache.currentDept.push shadow

    # background
    for code, municipio of departamento.municipios
      @_cache.currentDept.push @paper.path(municipio.path)
                                     .attr( fill:  '#8C8FAB', stroke: 'none' )
                                     .translate x + 2, y + 2

    # path
    for code, municipio of departamento.municipios

      path = @paper.path(municipio.path)
                   .translate(x, y)
                   .attr(opacity: 0, stroke: '#8489BF', fill: '#CFD2F1' )
                   .animate( opacity: 1 , 90 )

      path.code = code

      @_attachEventToMunicipio path
      @_cache.currentDept.push path


  renderMunicipio: (municipio, code)->
    @_cache.currentMuni.remove() if @_cache.currentMuni?
    @_cache[ 'currentMuni' ] = @paper.set()

    # padding
    [left, top] = [100, 150]

    shadow = @paper.path( municipio.path )
                   .attr( fill: '#C9CBDC', stroke: 'none' )

    {x, y, width, height} = shadow.getBBox()

    # escale de acuerdo a las dimensiones del path
    ratio = if width < 50 and height < 50
      5
    else if width < 100 and height < 100
      3
    else if width < 200 and height < 200
      2
    else
      1

    # ajustar position
    [adjX, adjY] = [ x * -1 + left, y * -1 + top ]
    shadow.translate( adjX + 5, adjY + 5)
          .scale ratio

    @_cache.currentMuni.push shadow

    # background
    background = @paper.path( municipio.path )
                       .attr( fill:  '#8C8FAB', stroke: 'none' )
                       .translate( adjX + 2, adjY + 2)
                       .scale ratio

    @_cache.currentMuni.push background

    path = @paper.path( municipio.path )
                 .translate( adjX, adjY )
                 .scale( ratio )
                 .attr({
                   stroke: '#8489BF',
                   fill: '#CFD2F1',
                   opacity: 0 })
                 .animate( opacity: 1 , 90 )

    @_attachEventToMunicipio path
    path.code = code
    @_cache.currentMuni.push path

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
    for code, departamento of @data.pais.departamentos
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

      dept.code = code
      @_cache.departamentos.push path: dept, label: lbl, code: code

  # regresa `true` si el evento es soportado
  supportsEvent: (event)->
    events = { 'click', 'dblclick', 'mouseover', 'mouseout',
              'mousemove', 'mousedown', 'mouseout' }

    events[ event ]?

  _attachEventToMunicipio: (path)->
    attachEvent = (event, fun)->
      path[ event ] (e)->
        fun e, path, path.code

    for event, fun of @_cache.events 
      attachEvent event, fun

  on: (element, event, fun)->
    throw "Evento #{event} no soportado" unless @supportsEvent event

    switch element
      when 'departamento'
        attachEventDept = (path, event, departamento)->
          path[ event ] (e)->
            fun e, departamento, departamento.code

        for departamento in @_cache.departamentos
          attachEventDept departamento.path, event, departamento
          attachEventDept departamento.label, event, departamento


      when 'municipio'
        @_cache.events[ event ] = fun

  hidePais: (f)->
    @_cache.shadow.hide()
    for departamento in @_cache.departamentos
      departamento.path.hide()
      departamento.label.hide()
    @_cache.background.animate opacity: 0, 100, -> f?()

  showPais: ->
    @hideDepartamento()
    @hideMunicipio()
    @_cache.background.animate opacity: 1, 100, =>
      @_cache.shadow.show()
      for departamento in @_cache.departamentos
        departamento.path.show()
        departamento.label.show()

  # hides current departamento
  hideDepartamento: ->
    @_cache.currentDept?.hide()

  # hides current municipio
  hideMunicipio: ->
    @_cache.currentMuni?.hide()

  showDepartamento: (code)->
    # buscar departamento, si no existe regresar
    departamento = @data.pais.departamentos[code]
    return unless departamento?
    @hideMunicipio()
    @hidePais => @renderDepartamento departamento

  showMunicipio: (code)->
    # saltar si el municipio a mostrar y esta siendo mostrado
    if @_cache.currentMuni? and @_cache.currentMuni[2].code is code
      return

    deptCode = 'd' + code.substring(1,3)
    departamento = @data.pais.departamentos[ deptCode ]
    if departamento?
      municipio = departamento.municipios[code]
      return unless municipio?
      @hidePais()
      @hideDepartamento()
      @renderMunicipio municipio, code

# Wrapper, crea el mapa y cuando el archivo `data/data.json` ha sido
# cargado ejecuta la funcion `fun`
window.SVMap = (div_id, fun)->
  $.getJSON 'svmap-paths.json', (data)->
    mapa = new SVMap div_id, data
    fun mapa

Util =
  extend    : (target, source)-> target[k] = v for k, v of source
## SVMap

#
# * `el`: jQuery Object
# * `data`: object literal exportado desde archivos SVG y cargado como JSON
#
class SVMap
  constructor: (opts, @data)->
    @_setOptions( opts )
    @paper  = Raphael @opts.id, 780, 470
    @_cache =
      events: {}
      muniEvents: {}

    @renderPais()

  _setOptions: (opts = {})->
    @opts   =
      id:              'map'
      backgroundColor: '#8C8FAB'
      pathColor:       '#CFD2F1'
      strokeColor:     '#8489BF'
      shadowColor:     '#C9CBDC'
      textColor:       '#7A80BE'
      textSize:         10

    # grab settings from user
    Util.extend @opts, opts

    @_shadowOpts =
      fill:   @opts.shadowColor
      stroke: 'none' 

    @_backgroundOpts = 
      fill: @opts.backgroundColor
      stroke: 'none' 

    @_pathOpts = 
      opacity: 0
      stroke: @opts.strokeColor
      fill:   @opts.pathColor



  # dibuja un departamento
  renderDepartamento: (departamento, deptCode)->
    if @_cache.currentDept?
      prop.remove() for key, prop of @_cache.currentDept

    @_cache[ 'currentDept' ] =
      shadows:     @paper.set()
      backgrounds: @paper.set()
      paths:       @paper.set()

    [x, y] = [-140, -370]

    # Tres loops son necesarios para renderizar los elementos en orden

    # shadow
    for code, municipio of departamento.municipios
      shadow = @paper.path(municipio.path)
                     .attr( @_shadowOpts )
                     .translate x + 5, y + 5

      @_cache.currentDept.shadows.push shadow

    # background
    for code, municipio of departamento.municipios
      background = @paper.path(municipio.path)
                         .attr( @_backgroundOpts )
                         .translate x + 2, y + 2

      @_cache.currentDept.backgrounds.push background

    # path
    for code, municipio of departamento.municipios

      path = @paper.path(municipio.path)
                   .translate(x, y)
                   .attr( @_pathOpts )
                   .animate( opacity: 1 , 90 )

      path.code = code

      @_attachEventToMunicipio path
      @_cache.currentDept.paths.push path

    @_cache.events['departamento rendered']?(@_cache.currentDept.paths, deptCode)


  renderMunicipio: (municipio, code)->
    @_cache.currentMuni.remove() if @_cache.currentMuni?
    @_cache[ 'currentMuni' ] = @paper.set()

    # padding
    [left, top] = [100, 150]

    shadow = @paper.path( municipio.path )
                   .attr( @_shadowOpts )

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
                       .attr( @_backgroundOpts )
                       .translate( adjX + 2, adjY + 2)
                       .scale ratio

    @_cache.currentMuni.push background

    path = @paper.path( municipio.path )
                 .translate( adjX, adjY )
                 .scale( ratio )
                 .attr( @_pathOpts )
                 .animate( opacity: 1 , 90 )

    path.code = code
    @_cache.currentMuni.push path
    @_attachEventToMunicipio path

    @_cache.events['municipio rendered']?( path, code )

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
                                .attr @_backgroundOpts

    # dibujar departamentos
    for code, departamento of @data.pais.departamentos
      # Paths
      dept = @paper.path( departamento.path )
                   .attr( @_pathOpts )
                   .animate( opacity: 1, 90 )

      # Labels
      matrix = Raphael.matrix.apply null, departamento.lblTransform
      lbl    = @paper.text( 0, 0, departamento.lbl)
                     .transform( matrix.toTransformString() )
                     .attr( fill: @opts.textColor, 'font-size': @opts.textSize)

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

    for event, fun of @_cache.muniEvents 
      attachEvent event, fun

  on: (element, event, fun)->
    if event is 'rendered'
      @_cache.events[ "#{element} #{event}" ] = fun
      return

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
        @_cache.muniEvents[ event ] = fun

  hidePais: (f)->
    @_cache.shadow.hide()
    for departamento in @_cache.departamentos
      departamento.path.hide()
      departamento.label.hide()
    @_cache.background.animate opacity: 0, 100, -> f?()

  showPais: (fun)->
    @hideDepartamento()
    @hideMunicipio()
    @_cache.background.animate opacity: 1, 100, =>
      @_cache.shadow.show()
      for departamento in @_cache.departamentos
        departamento.path.show()
        departamento.label.show()

      fun?()

  # hides current departamento
  hideDepartamento: ->
    if @_cache.currentDept?
      if @_cache.currentDept?
        prop.hide() for key, prop of @_cache.currentDept

  # hides current municipio
  hideMunicipio: ->
    @_cache.currentMuni?.hide()

  showDepartamento: (code, fun)->
    # buscar departamento, si no existe regresar
    departamento = @data.pais.departamentos[code]
    return unless departamento?
    @hideMunicipio()
    @hidePais =>
      @renderDepartamento departamento, code
      fun?()

  showMunicipio: (code, fun)->
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
      fun?()

  # iterator sobre cada municipio en el actual departamento
  eachMunicipio: (fun)->
    if @_cache.currentDept?
      @_cache.currentDept.paths.forEach fun


# Wrapper, crea el mapa y cuando el archivo `data/data.json` ha sido
# cargado ejecuta la funcion `fun`
window.SVMap = (opts = {},  fun)->
  $.getJSON 'svmap-paths.json', (data)->
    mapa = new SVMap opts, data
    fun mapa

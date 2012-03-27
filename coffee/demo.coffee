updateStatus = (o)->
  $('#status').html "<em>event: </em> #{o.event}</br>
                     <em>code: \b</em> #{o.code}"

settings =
  id: 'mapa'
  # pathColor:       '#ffffff'
  # strokeColor:     '#70592B'
  # backgroundColor: '#B7B7B7'
  # shadowColor:     '#eae9e7'
  # textColor:       '#8F6B6E'
  # textSize:         10

# hoverColor = '#F2ECEC'
hoverColor = '#EAECFF'

SVMap settings, (mapa)->
  window.mapa = mapa    # exposing the map to the global scope

  $back = $('#svmap-back-btn') 
  $back.hide()

  mapa.on 'departamento', 'click', (e, departamento, code)->
    updateStatus event: 'click', code: code
    mapa.showDepartamento code
    $back.show().on 'click', -> 
      mapa.showPais -> 
        console.log 'pais shown'

  mapa.on 'departamento', 'mouseover', (e, departamento, code)->
    updateStatus event: 'mouseover', code: code
    departamento.path.attr fill: hoverColor

  mapa.on 'departamento', 'mouseout',  (e, departamento, code)->
    updateStatus event: 'mouseout', code: code
    departamento.path.attr fill  : mapa.opts.pathColor

  mapa.on 'municipio', 'mouseover', (e, municipio, code)->
    updateStatus event: 'mouseover', code: code
    municipio.attr fill: hoverColor

  mapa.on 'municipio', 'mouseout', (e, municipio, code)->
    updateStatus event: 'mouseout', code: code
    municipio.attr fill: mapa.opts.pathColor

  mapa.on 'municipio', 'click', (e, municipio, code)->
    updateStatus event: 'click', code: code
    deptCode = 'd' + code.substring(1, 3)
    mapa.showMunicipio code, -> console.log 'muni shown'

    # this is ugly, but for now it's OK
    $back.show().off('click').on 'click', -> 
      mapa.showDepartamento deptCode, -> console.log 'dept shown'
      $back.off('click').on 'click', -> mapa.showPais()

  # municipios is a set of paths
  mapa.on 'departamento', 'rendered', (municipios, deptCode)->
    console.log 'departamento rendered', deptCode
    # I can iterate over all municipios here, or use the eachMunicipio
    # method - the latter is useful when operating outside an event
    # handler
    mapa.eachMunicipio (el)-> console.log el.code

  mapa.on 'municipio', 'rendered', (municipio, code)->
    console.log 'municipio rendered', municipio, code


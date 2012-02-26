updateStatus = (o)->
  $('#status').html "<em>event: </em> #{o.event}</br>
                     <em>code: \b</em> #{o.code}"

SVMap 'mapa', (mapa)->
  window.mapa = mapa    # exposing the map to the global scope

  $back = $('#svmap-back-btn') 
  $back.hide()

  mapa.on 'departamento', 'click', (departamento, code)->
    updateStatus event: 'click', code: code
    mapa.showDepartamento code
    $back.show().on 'click', -> mapa.showPais()

  mapa.on 'departamento', 'mouseover', (departamento, code)->
    updateStatus event: 'mouseover', code: code
    departamento.path.attr fill: '#EAECFF'

  mapa.on 'departamento', 'mouseout',  (departamento, code)->
    updateStatus event: 'mouseout', code: code
    departamento.path.attr fill  : '#CFD2F1'

  mapa.on 'municipio', 'mouseover', (municipio, code)->
    updateStatus event: 'mouseover', code: code
    municipio.attr fill: '#EAECFF'

  mapa.on 'municipio', 'mouseout', (municipio, code)->
    updateStatus event: 'mouseout', code: code
    municipio.attr fill  : '#CFD2F1'

  mapa.on 'municipio', 'click', (municipio, code)->
    updateStatus event: 'click', code: code
    deptCode = 'd' + code.substring(1, 3)
    mapa.showMunicipio code

    # this is ugly, but for now it's OK
    $back.show().off('click').on 'click', -> 
      mapa.showDepartamento( deptCode )
      $back.off('click').on 'click', -> mapa.showPais()






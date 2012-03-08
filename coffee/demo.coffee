updateStatus = (o)->
  $('#status').html "<em>event: </em> #{o.event}</br>
                     <em>code: \b</em> #{o.code}"

SVMap id: 'mapa', (mapa)->
  window.mapa = mapa    # exposing the map to the global scope

  $back = $('#svmap-back-btn') 
  $back.hide()

  mapa.on 'departamento', 'click', (e, departamento, code)->
    updateStatus event: 'click', code: code
    mapa.showDepartamento code
    $back.show().on 'click', -> mapa.showPais()

  mapa.on 'departamento', 'mouseover', (e, departamento, code)->
    updateStatus event: 'mouseover', code: code
    departamento.path.attr fill: '#EAECFF'

  mapa.on 'departamento', 'mouseout',  (e, departamento, code)->
    updateStatus event: 'mouseout', code: code
    departamento.path.attr fill  : mapa.opts.pathColor

  mapa.on 'municipio', 'mouseover', (e, municipio, code)->
    updateStatus event: 'mouseover', code: code
    municipio.attr fill: '#EAECFF'

  mapa.on 'municipio', 'mouseout', (e, municipio, code)->
    updateStatus event: 'mouseout', code: code
    municipio.attr fill: mapa.opts.pathColor

  mapa.on 'municipio', 'click', (e, municipio, code)->
    updateStatus event: 'click', code: code
    deptCode = 'd' + code.substring(1, 3)
    mapa.showMunicipio code

    # this is ugly, but for now it's OK
    $back.show().off('click').on 'click', -> 
      mapa.showDepartamento( deptCode )
      $back.off('click').on 'click', -> mapa.showPais()






updateStatus = (o)->
  $('#status').html "<em>event: </em> #{o.event}</br>
                     <em>code: \b</em> #{o.code}"

SVMap 'mapa', (mapa)->
  window.mapa = mapa    # exposing the map to the global scope

  $back = $('#svmap-back-btn') 
  $back.hide().on 'click', -> mapa.showPais()

  mapa.on 'click',     (departamento, code)->
    updateStatus event: 'click', code: code
    mapa.showDepartamento code
    $back.show()

  mapa.on 'mouseover', (departamento, code)->
    updateStatus event: 'mouseover', code: code
    departamento.path.attr fill: '#EAECFF'

  mapa.on 'mouseout',  (departamento, code)->
    updateStatus event: 'mouseout', code: code
    departamento.path.attr fill  : '#CFD2F1'





updateStatus = (o)->
  $('#status').html "<em>event: </em> #{o.event}</br>
                     <em>code: \b</em> #{o.code}"

SVMap 'mapa', (mapa)->
  mapa.on 'click',     (code, el)->
    updateStatus event: 'click', code: code
    mapa.renderDepartamento code

  mapa.on 'dblclick',  (code, el)->
    updateStatus event: 'dblclick', code: code

  mapa.on 'mouseover', (code, el)->
    updateStatus event: 'mouseover', code: code
    el.attr fill: '#EAECFF'

  mapa.on 'mouseout',  (code, el)->
    updateStatus event: 'mouseout', code: code
    el.attr fill  : '#CFD2F1'



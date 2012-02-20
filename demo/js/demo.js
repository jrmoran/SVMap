(function() {
  var updateStatus;

  updateStatus = function(o) {
    return $('#status').html("<em>event: </em> " + o.event + "</br>                     <em>code: \b</em> " + o.code);
  };

  SVMap('mapa', function(mapa) {
    var $back;
    window.mapa = mapa;
    $back = $('#svmap-back-btn');
    $back.hide().on('click', function() {
      return mapa.showPais();
    });
    mapa.on('click', function(code, el) {
      updateStatus({
        event: 'click',
        code: code
      });
      mapa.showDepartamento(code);
      return $back.show();
    });
    mapa.on('dblclick', function(code, el) {
      return updateStatus({
        event: 'dblclick',
        code: code
      });
    });
    mapa.on('mouseover', function(code, el) {
      updateStatus({
        event: 'mouseover',
        code: code
      });
      return el.attr({
        fill: '#EAECFF'
      });
    });
    return mapa.on('mouseout', function(code, el) {
      updateStatus({
        event: 'mouseout',
        code: code
      });
      return el.attr({
        fill: '#CFD2F1'
      });
    });
  });

}).call(this);

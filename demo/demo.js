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
    mapa.on('click', function(departamento, code) {
      updateStatus({
        event: 'click',
        code: code
      });
      mapa.showDepartamento(code);
      return $back.show();
    });
    mapa.on('mouseover', function(departamento, code) {
      updateStatus({
        event: 'mouseover',
        code: code
      });
      return departamento.path.attr({
        fill: '#EAECFF'
      });
    });
    return mapa.on('mouseout', function(departamento, code) {
      updateStatus({
        event: 'mouseout',
        code: code
      });
      return departamento.path.attr({
        fill: '#CFD2F1'
      });
    });
  });

}).call(this);

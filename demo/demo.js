(function() {
  var updateStatus;

  updateStatus = function(o) {
    return $('#status').html("<em>event: </em> " + o.event + "</br>                     <em>code: \b</em> " + o.code);
  };

  SVMap('mapa', function(mapa) {
    var $back;
    window.mapa = mapa;
    $back = $('#svmap-back-btn');
    $back.hide();
    mapa.on('departamento', 'click', function(departamento, code) {
      updateStatus({
        event: 'click',
        code: code
      });
      mapa.showDepartamento(code);
      return $back.show().on('click', function() {
        return mapa.showPais();
      });
    });
    mapa.on('departamento', 'mouseover', function(departamento, code) {
      updateStatus({
        event: 'mouseover',
        code: code
      });
      return departamento.path.attr({
        fill: '#EAECFF'
      });
    });
    mapa.on('departamento', 'mouseout', function(departamento, code) {
      updateStatus({
        event: 'mouseout',
        code: code
      });
      return departamento.path.attr({
        fill: '#CFD2F1'
      });
    });
    mapa.on('municipio', 'mouseover', function(municipio, code) {
      updateStatus({
        event: 'mouseover',
        code: code
      });
      return municipio.attr({
        fill: '#EAECFF'
      });
    });
    mapa.on('municipio', 'mouseout', function(municipio, code) {
      updateStatus({
        event: 'mouseout',
        code: code
      });
      return municipio.attr({
        fill: '#CFD2F1'
      });
    });
    return mapa.on('municipio', 'click', function(municipio, code) {
      var deptCode;
      updateStatus({
        event: 'click',
        code: code
      });
      deptCode = 'd' + code.substring(1, 3);
      mapa.showMunicipio(code);
      return $back.show().off('click').on('click', function() {
        mapa.showDepartamento(deptCode);
        return $back.off('click').on('click', function() {
          return mapa.showPais();
        });
      });
    });
  });

}).call(this);

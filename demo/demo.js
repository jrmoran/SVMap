(function() {
  var updateStatus;

  updateStatus = function(o) {
    return $('#status').html("<em>event: </em> " + o.event + "</br>                     <em>code: \b</em> " + o.code);
  };

  SVMap({
    id: 'mapa'
  }, function(mapa) {
    var $back;
    window.mapa = mapa;
    $back = $('#svmap-back-btn');
    $back.hide();
    mapa.on('departamento', 'click', function(e, departamento, code) {
      updateStatus({
        event: 'click',
        code: code
      });
      mapa.showDepartamento(code);
      return $back.show().on('click', function() {
        return mapa.showPais(function() {
          return console.log('pais shown');
        });
      });
    });
    mapa.on('departamento', 'mouseover', function(e, departamento, code) {
      updateStatus({
        event: 'mouseover',
        code: code
      });
      return departamento.path.attr({
        fill: '#EAECFF'
      });
    });
    mapa.on('departamento', 'mouseout', function(e, departamento, code) {
      updateStatus({
        event: 'mouseout',
        code: code
      });
      return departamento.path.attr({
        fill: mapa.opts.pathColor
      });
    });
    mapa.on('municipio', 'mouseover', function(e, municipio, code) {
      updateStatus({
        event: 'mouseover',
        code: code
      });
      return municipio.attr({
        fill: '#EAECFF'
      });
    });
    mapa.on('municipio', 'mouseout', function(e, municipio, code) {
      updateStatus({
        event: 'mouseout',
        code: code
      });
      return municipio.attr({
        fill: mapa.opts.pathColor
      });
    });
    mapa.on('municipio', 'click', function(e, municipio, code) {
      var deptCode;
      updateStatus({
        event: 'click',
        code: code
      });
      deptCode = 'd' + code.substring(1, 3);
      mapa.showMunicipio(code, function() {
        return console.log('muni shown');
      });
      return $back.show().off('click').on('click', function() {
        mapa.showDepartamento(deptCode, function() {
          return console.log('dept shown');
        });
        return $back.off('click').on('click', function() {
          return mapa.showPais();
        });
      });
    });
    mapa.on('departamento', 'rendered', function(municipios, deptCode) {
      console.log('departamento rendered', deptCode);
      return mapa.eachMunicipio(function(el) {
        return console.log(el.code);
      });
    });
    return mapa.on('municipio', 'rendered', function(municipio, code) {
      return console.log('municipio rendered', municipio, code);
    });
  });

}).call(this);

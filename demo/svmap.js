(function() {
  var SVMap;

  SVMap = (function() {

    function SVMap(div_id, data) {
      this.div_id = div_id;
      this.data = data;
      this.paper = Raphael(this.div_id, 780, 470);
      this._cache = {};
      this.renderPais();
    }

    SVMap.prototype.renderDepartamento = function(departamento) {
      var attr, key, municipio, _ref, _ref2, _ref3, _results;
      if (this._cache.currentDept != null) this._cache.currentDept.remove();
      this._cache['currentDept'] = this.paper.set();
      _ref = departamento.municipios;
      for (key in _ref) {
        municipio = _ref[key];
        this._cache.currentDept.push(this.paper.path(municipio.path).attr({
          fill: '#C9CBDC',
          stroke: 'none'
        }).translate(-3, 53));
      }
      _ref2 = departamento.municipios;
      for (key in _ref2) {
        municipio = _ref2[key];
        this._cache.currentDept.push(this.paper.path(municipio.path).attr({
          fill: '#8C8FAB',
          stroke: 'none'
        }).translate(-1, 51));
      }
      _ref3 = departamento.municipios;
      _results = [];
      for (key in _ref3) {
        municipio = _ref3[key];
        if (key.match(/lago/)) {
          attr = {
            fill: '#58A9F4',
            stroke: '#3684CC'
          };
        } else {
          attr = {
            stroke: '#8489BF',
            fill: '#CFD2F1'
          };
        }
        _results.push(this._cache.currentDept.push(this.paper.path(municipio.path).attr(attr).translate(-3, 50).attr({
          opacity: 0
        }).animate({
          opacity: 1
        }, 90)));
      }
      return _results;
    };

    SVMap.prototype.renderPais = function() {
      var departamento, dept, key, lbl, matrix, _ref, _results;
      this._cache['departamentos'] = [];
      this._cache['shadow'] = this.paper.path(this.data.pais.shadow).attr({
        fill: '#C9CBDC',
        stroke: 'none'
      });
      this._cache['background'] = this.paper.path(this.data.pais.background).attr({
        fill: '#8C8FAB',
        stroke: 'none'
      });
      _ref = this.data.pais.departamentos;
      _results = [];
      for (key in _ref) {
        departamento = _ref[key];
        dept = this.paper.path(departamento.path).attr({
          fill: '#CFD2F1',
          stroke: '#8489BF'
        });
        matrix = Raphael.matrix.apply(null, departamento.lblTransform);
        lbl = this.paper.text(0, 0, departamento.lbl).transform(matrix.toTransformString()).attr({
          fill: '#7A80BE',
          'font-size': 10
        });
        dept.code = key;
        _results.push(this._cache.departamentos.push({
          path: dept,
          label: lbl,
          code: key
        }));
      }
      return _results;
    };

    SVMap.prototype.supportsEvent = function(event) {
      var events;
      events = {
        'click': 'click',
        'dblclick': 'dblclick',
        'mouseover': 'mouseover',
        'mouseout': 'mouseout',
        'mousemove': 'mousemove',
        'mousedown': 'mousedown',
        'mouseout': 'mouseout'
      };
      return events[event] != null;
    };

    SVMap.prototype.on = function(event, fun) {
      var departamento, handler, _i, _len, _ref, _results;
      if (!this.supportsEvent(event)) throw "Evento " + event + " no soportado";
      _ref = this._cache.departamentos;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        departamento = _ref[_i];
        handler = (function(fun, departamento) {
          return function() {
            return fun(departamento, departamento.code);
          };
        })(fun, departamento);
        departamento.path[event](handler);
        _results.push(departamento.label[event](handler));
      }
      return _results;
    };

    SVMap.prototype.hidePais = function(f) {
      var departamento, _i, _len, _ref;
      this._cache.shadow.hide();
      _ref = this._cache.departamentos;
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        departamento = _ref[_i];
        departamento.path.hide();
        departamento.label.hide();
      }
      return this._cache.background.animate({
        opacity: 0
      }, 100, function() {
        return typeof f === "function" ? f() : void 0;
      });
    };

    SVMap.prototype.showPais = function() {
      var _this = this;
      this._cache.currentDept.hide();
      return this._cache.background.animate({
        opacity: 1
      }, 100, function() {
        var departamento, _i, _len, _ref, _results;
        _this._cache.shadow.show();
        _ref = _this._cache.departamentos;
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          departamento = _ref[_i];
          departamento.path.show();
          _results.push(departamento.label.show());
        }
        return _results;
      });
    };

    SVMap.prototype.showDepartamento = function(code) {
      var departamento,
        _this = this;
      departamento = this.data.pais.departamentos[code];
      if (departamento == null) return;
      return this.hidePais(function() {
        return _this.renderDepartamento(departamento);
      });
    };

    return SVMap;

  })();

  window.SVMap = function(div_id, fun) {
    return $.getJSON('svmap-paths.json', function(data) {
      var mapa;
      mapa = new SVMap(div_id, data);
      return fun(mapa);
    });
  };

}).call(this);

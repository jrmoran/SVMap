(function() {
  var SVMap;

  SVMap = (function() {

    function SVMap(div_id, data) {
      this.div_id = div_id;
      this.data = data;
      this.paper = Raphael(this.div_id, 780, 470);
      this.paths = [];
      this._cache = {};
      this.renderPais();
    }

    SVMap.prototype.renderDepartamento = function(code) {
      var attr, departamento, key, municipio, _ref, _ref2, _ref3, _results;
      if (this._cache.currentDept != null) this._cache.currentDept.remove();
      this._cache['currentDept'] = this.paper.set();
      departamento = this.data.pais.departamentos[code];
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
        _results.push(this._cache.currentDept.push(this.paper.path(municipio.path).attr(attr).translate(-3, 50)));
      }
      return _results;
    };

    SVMap.prototype.renderPais = function() {
      var departamento, dept, key, lbl, matrix, _ref, _results;
      this._cache['labels'] = this.paper.set();
      this._cache['departamentos'] = this.paper.set();
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
        this._cache.labels.push(lbl);
        this._cache.departamentos.push(dept);
        _results.push(this.paths.push({
          el: dept,
          lbl: lbl,
          key: key
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
      var el, key, lbl, path, _i, _len, _ref, _results;
      if (!this.supportsEvent(event)) throw "Evento " + event + " no soportado";
      _ref = this.paths;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        path = _ref[_i];
        el = path.el, lbl = path.lbl, key = path.key;
        el[event]((function(fun, key, el) {
          return function() {
            return fun(key, el);
          };
        })(fun, key, el));
        if (lbl) {
          _results.push(lbl[event]((function(fun, key, el) {
            return function() {
              return fun(key, el);
            };
          })(fun, key, el)));
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    };

    SVMap.prototype.hidePais = function(f) {
      var prop, _i, _len, _ref;
      _ref = ['departamentos', 'shadow', 'labels'];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        prop = _ref[_i];
        this._cache[prop].hide();
      }
      return this._cache.background.animate({
        transform: 'T-780,0'
      }, 500, function() {
        return typeof f === "function" ? f() : void 0;
      });
    };

    SVMap.prototype.showPais = function() {
      var _this = this;
      this._cache.currentDept.hide();
      return this._cache.background.animate({
        transform: 'T0,0'
      }, 500, function() {
        var prop, _i, _len, _ref, _results;
        _ref = ['departamentos', 'shadow', 'labels'];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          prop = _ref[_i];
          _results.push(_this._cache[prop].show());
        }
        return _results;
      });
    };

    SVMap.prototype.showDepartamento = function(code) {
      var _this = this;
      return this.hidePais(function() {
        return _this.renderDepartamento(code);
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

(function() {
  var SVMap;

  SVMap = (function() {

    function SVMap(div_id, data) {
      this.div_id = div_id;
      this.data = data;
      this.paper = Raphael(this.div_id, 900, 470);
      this.paths = [];
      this._initMap();
    }

    SVMap.prototype.renderDepartamento = function(code) {
      var attr, departamento, key, municipio, _ref, _results;
      departamento = this.data.pais.departamentos[code];
      _ref = departamento.municipios;
      _results = [];
      for (key in _ref) {
        municipio = _ref[key];
        if (key.match(/lago/)) {
          attr = {
            fill: '#58A9F4',
            stroke: '#3684CC'
          };
        } else {
          attr = {
            stroke: '#8C8FAB',
            fill: '#CFD2F1'
          };
        }
        _results.push(this.paper.path(municipio.path).attr(attr).translate(550, 75));
      }
      return _results;
    };

    SVMap.prototype._initMap = function() {
      var departamento, dept, key, lbl, matrix, _ref, _results;
      this.paper.path(this.data.pais.shadow).attr({
        fill: '#C9CBDC',
        stroke: 'none'
      });
      this.paper.path(this.data.pais.background).attr({
        fill: '#8C8FAB',
        stroke: 'none'
      });
      _ref = this.data.pais.departamentos;
      _results = [];
      for (key in _ref) {
        departamento = _ref[key];
        dept = this.paper.path(departamento.path).attr({
          fill: '#CFD2F1',
          stroke: '#8C8FAB'
        });
        matrix = Raphael.matrix.apply(null, departamento.lblTransform);
        lbl = this.paper.text(0, 0, departamento.lbl).attr({
          fill: '#5F6495'
        }).transform(matrix.toTransformString());
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

    return SVMap;

  })();

  window.SVMap = function(div_id, fun) {
    return $.getJSON('data/data.json', function(data) {
      var mapa;
      mapa = new SVMap(div_id, data);
      return fun(mapa);
    });
  };

}).call(this);

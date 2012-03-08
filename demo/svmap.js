(function() {
  var SVMap, Util;

  Util = {
    extend: function(target, source) {
      var k, v, _results;
      _results = [];
      for (k in source) {
        v = source[k];
        _results.push(target[k] = v);
      }
      return _results;
    }
  };

  SVMap = (function() {

    function SVMap(opts, data) {
      this.data = data;
      this._setOptions(opts);
      this.paper = Raphael(this.opts.id, 780, 470);
      this._cache = {};
      this._cache['events'] = {};
      this.renderPais();
    }

    SVMap.prototype._setOptions = function(opts) {
      if (opts == null) opts = {};
      this.opts = {
        id: 'map',
        backgroundColor: '#8C8FAB',
        pathColor: '#CFD2F1',
        strokeColor: '#8489BF',
        shadowColor: '#C9CBDC',
        textColor: '#7A80BE',
        textSize: 10
      };
      Util.extend(this.opts, opts);
      this._shadowOpts = {
        fill: this.opts.shadowColor,
        stroke: 'none'
      };
      this._backgroundOpts = {
        fill: this.opts.backgroundColor,
        stroke: 'none'
      };
      return this._pathOpts = {
        opacity: 0,
        stroke: this.opts.strokeColor,
        fill: this.opts.pathColor
      };
    };

    SVMap.prototype.renderDepartamento = function(departamento) {
      var code, municipio, path, shadow, x, y, _ref, _ref2, _ref3, _ref4, _results;
      if (this._cache.currentDept != null) this._cache.currentDept.remove();
      this._cache['currentDept'] = this.paper.set();
      _ref = [-140, -370], x = _ref[0], y = _ref[1];
      _ref2 = departamento.municipios;
      for (code in _ref2) {
        municipio = _ref2[code];
        shadow = this.paper.path(municipio.path).attr(this._shadowOpts).translate(x + 5, y + 5);
        this._cache.currentDept.push(shadow);
      }
      _ref3 = departamento.municipios;
      for (code in _ref3) {
        municipio = _ref3[code];
        this._cache.currentDept.push(this.paper.path(municipio.path).attr(this._backgroundOpts).translate(x + 2, y + 2));
      }
      _ref4 = departamento.municipios;
      _results = [];
      for (code in _ref4) {
        municipio = _ref4[code];
        path = this.paper.path(municipio.path).translate(x, y).attr(this._pathOpts).animate({
          opacity: 1
        }, 90);
        path.code = code;
        this._attachEventToMunicipio(path);
        _results.push(this._cache.currentDept.push(path));
      }
      return _results;
    };

    SVMap.prototype.renderMunicipio = function(municipio, code) {
      var adjX, adjY, background, height, left, path, ratio, shadow, top, width, x, y, _ref, _ref2, _ref3;
      if (this._cache.currentMuni != null) this._cache.currentMuni.remove();
      this._cache['currentMuni'] = this.paper.set();
      _ref = [100, 150], left = _ref[0], top = _ref[1];
      shadow = this.paper.path(municipio.path).attr(this._shadowOpts);
      _ref2 = shadow.getBBox(), x = _ref2.x, y = _ref2.y, width = _ref2.width, height = _ref2.height;
      ratio = width < 50 && height < 50 ? 5 : width < 100 && height < 100 ? 3 : width < 200 && height < 200 ? 2 : 1;
      _ref3 = [x * -1 + left, y * -1 + top], adjX = _ref3[0], adjY = _ref3[1];
      shadow.translate(adjX + 5, adjY + 5).scale(ratio);
      this._cache.currentMuni.push(shadow);
      background = this.paper.path(municipio.path).attr(this._backgroundOpts).translate(adjX + 2, adjY + 2).scale(ratio);
      this._cache.currentMuni.push(background);
      path = this.paper.path(municipio.path).translate(adjX, adjY).scale(ratio).attr(this._pathOpts).animate({
        opacity: 1
      }, 90);
      this._attachEventToMunicipio(path);
      path.code = code;
      return this._cache.currentMuni.push(path);
    };

    SVMap.prototype.renderPais = function() {
      var code, departamento, dept, lbl, matrix, _ref, _results;
      this._cache['departamentos'] = [];
      this._cache['shadow'] = this.paper.path(this.data.pais.shadow).attr({
        fill: '#C9CBDC',
        stroke: 'none'
      });
      this._cache['background'] = this.paper.path(this.data.pais.background).attr(this._backgroundOpts);
      _ref = this.data.pais.departamentos;
      _results = [];
      for (code in _ref) {
        departamento = _ref[code];
        dept = this.paper.path(departamento.path).attr(this._pathOpts).animate({
          opacity: 1
        }, 90);
        matrix = Raphael.matrix.apply(null, departamento.lblTransform);
        lbl = this.paper.text(0, 0, departamento.lbl).transform(matrix.toTransformString()).attr({
          fill: this.opts.textColor,
          'font-size': this.opts.textSize
        });
        dept.code = code;
        _results.push(this._cache.departamentos.push({
          path: dept,
          label: lbl,
          code: code
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

    SVMap.prototype._attachEventToMunicipio = function(path) {
      var attachEvent, event, fun, _ref, _results;
      attachEvent = function(event, fun) {
        return path[event](function(e) {
          return fun(e, path, path.code);
        });
      };
      _ref = this._cache.events;
      _results = [];
      for (event in _ref) {
        fun = _ref[event];
        _results.push(attachEvent(event, fun));
      }
      return _results;
    };

    SVMap.prototype.on = function(element, event, fun) {
      var attachEventDept, departamento, _i, _len, _ref, _results;
      if (!this.supportsEvent(event)) throw "Evento " + event + " no soportado";
      switch (element) {
        case 'departamento':
          attachEventDept = function(path, event, departamento) {
            return path[event](function(e) {
              return fun(e, departamento, departamento.code);
            });
          };
          _ref = this._cache.departamentos;
          _results = [];
          for (_i = 0, _len = _ref.length; _i < _len; _i++) {
            departamento = _ref[_i];
            attachEventDept(departamento.path, event, departamento);
            _results.push(attachEventDept(departamento.label, event, departamento));
          }
          return _results;
          break;
        case 'municipio':
          return this._cache.events[event] = fun;
      }
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
      this.hideDepartamento();
      this.hideMunicipio();
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

    SVMap.prototype.hideDepartamento = function() {
      var _ref;
      return (_ref = this._cache.currentDept) != null ? _ref.hide() : void 0;
    };

    SVMap.prototype.hideMunicipio = function() {
      var _ref;
      return (_ref = this._cache.currentMuni) != null ? _ref.hide() : void 0;
    };

    SVMap.prototype.showDepartamento = function(code) {
      var departamento,
        _this = this;
      departamento = this.data.pais.departamentos[code];
      if (departamento == null) return;
      this.hideMunicipio();
      return this.hidePais(function() {
        return _this.renderDepartamento(departamento);
      });
    };

    SVMap.prototype.showMunicipio = function(code) {
      var departamento, deptCode, municipio;
      if ((this._cache.currentMuni != null) && this._cache.currentMuni[2].code === code) {
        return;
      }
      deptCode = 'd' + code.substring(1, 3);
      departamento = this.data.pais.departamentos[deptCode];
      if (departamento != null) {
        municipio = departamento.municipios[code];
        if (municipio == null) return;
        this.hidePais();
        this.hideDepartamento();
        return this.renderMunicipio(municipio, code);
      }
    };

    return SVMap;

  })();

  window.SVMap = function(opts, fun) {
    if (opts == null) opts = {};
    return $.getJSON('svmap-paths.json', function(data) {
      var mapa;
      mapa = new SVMap(opts, data);
      return fun(mapa);
    });
  };

}).call(this);

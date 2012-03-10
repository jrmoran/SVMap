# SVMap

![screenshot](http://i.imgur.com/nX6cnl.png)

## Dependecias

* jQuery 1.6.1+
* RaphaelJS 2+

## Ejecutar Demo
Para correr el demo en Chrome necesitas correr un servidor local. Si
tienes instalado el interprete de python, solo haz lo siguiente

    cd demo
    python -m SimpleHTTPServer

Luego abrir `http://localhost:8000/`

## Uso

    SVMap({ id: 'mapa' }, function(mapa) {

      mapa.on('departamento', 'click', function(e, departamento, code) {
        mapa.showDepartamento(code);
      });

      mapa.on('departamento', 'mouseover', function(e, departamento, code) {
        departamento.path.attr({
          fill: '#EAECFF'
        });
      });

      mapa.on('departamento', 'mouseout', function(e, departamento, code) {
        departamento.path.attr({
          fill: mapa.opts.pathColor
        });
    });

Ver el archivo `demo/demo.js` o `coffee/demo.coffee` para mas detalles.

### Opciones por defecto

* **id**:              'map'
* **backgroundColor**: '#8C8FAB'
* **pathColor**:       '#CFD2F1'
* **strokeColor**:     '#8489BF'
* **shadowColor**:     '#C9CBDC'
* **textColor**:       '#7A80BE'
* **textSize**:         10

## Tools

Ejecuta el comando `cake` para listar tareas disponibles.

El directorio `tools` contiene scripts para diversas tareas. Estos deben
ser ejecutados desde el directorio raiz del projecto, o preferiblemente
usando el comando `cake`.

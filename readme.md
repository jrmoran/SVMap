# SVMap

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
Ver el archivo `demo/demo.js` o `coffee/demo.coffee`

## Mapas
Los archivos *ai* pueden ser editados en Adobe Illustrator. Estos son
exportados a formato *svg* siguiendo estos settings:

* SVG Profile: 1.1
* Type: SVG
* CSS Properties: Style Elements
* Decimal Places: 1
* Encoding: UTF-8

## Tools

Ejecuta el comando `cake` para listar tareas disponibles.

El directorio `tools` contiene scripts para diversas tareas. Estos deben
ser ejecutados desde el directorio raiz del projecto, o preferiblemente
usando el comando `cake`.

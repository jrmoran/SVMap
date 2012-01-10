{exec} = require 'child_process'

# deal with errors from child processes
exerr  = (err, sout,  serr)->
  process.stdout.write err  if err
  process.stdout.write sout if sout
  process.stdout.write serr if serr

task 'extract', 'Extrae datos desde los archivos SVG a formato JSON', ->
  exec 'coffee ./tools/extract.coffee', exerr

task 'watch', 'observa los archivos coffee y los compila', ->
  watch = exec 'coffee -o js/ -cw coffee/'
  watch.stdout.on 'data', (data)-> process.stdout.write data

task 'docs', 'genera documentacion desde los archivos coffee', ->
  exec 'docco tools/*.coffee coffee/*.coffee', exerr


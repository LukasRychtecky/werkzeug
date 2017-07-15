module.exports = (grunt) ->
  {suppe} = require 'grunt-suppe/suppe'

  opts =
    watch_dirs: ['bower_components/werkzeug/wzk/**/']
    var_dir: 'build'
    app_namespace: 'wzkdemo.start'
    app_compiled_output_path: 'build/app.js'
    deps_prefix: '../../../../../'


  suppe grunt, opts

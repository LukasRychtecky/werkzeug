module.exports = (grunt) ->
  bowerDir = '.bower_components'
  closureLibDir = bowerDir + '/closure-library'

  appDirs = [
    closureLibDir
    'var/wzk'
  ]

  coffeeFiles = [
    'wzk/**/*.coffee'
  ]

  appCompiledOutputPath =
    'var/wzk/app.js'

  depsPath =
    'var/wzk/deps.js'

  # from closure base.js dir to app root dir
  depsPrefix = '../'

  getCoffeeConfig = (filepath = coffeeFiles) ->
    [
      expand: true
      src: filepath
      dest: 'var/'
      ext: '.js'
    ]

  grunt.initConfig

    clean:
      app:
        options:
          force: true
        src: [
          'var/zwk/**/*.js'
        ]

    coffee:
      all:
        options:
          bare: true
        files: getCoffeeConfig()

    coffee2closure:
      app:
        files: [coffeeFiles]

    esteDeps:
      all:
        options:
          depsWriterPath: closureLibDir + '/closure/bin/build/depswriter.py'
          outputFile: depsPath
          prefix: depsPrefix
          root: appDirs

    esteBuilder:
      options:
        closureBuilderPath: closureLibDir+ '/closure/bin/build/closurebuilder.py'
        compilerPath: bowerDir + '/closure-compiler/compiler.jar'
        # needs Java 1.7+, see http://goo.gl/iS3o6
        fastCompilation: false
        depsPath: depsPath
        compilerFlags: if grunt.option('stage') == 'debug' then [
          '--output_wrapper="(function(){%output%})();"'
          '--compilation_level="ADVANCED_OPTIMIZATIONS"'
          '--warning_level="VERBOSE"'
          '--define=goog.DEBUG=true'
          '--debug=true'
          '--formatting="PRETTY_PRINT"'
        ]
        else [
            '--output_wrapper="(function(){%output%})();"'
            '--compilation_level="ADVANCED_OPTIMIZATIONS"'
            '--warning_level="VERBOSE"'
            '--define=goog.DEBUG=false'
          ]

      app:
        options:
          namespace: 'wzk'
          root: appDirs
          outputFilePath: appCompiledOutputPath

    esteUnitTests:
      options:
        basePath: closureLibDir + '/closure/goog/base.js'
      app:
        options:
          depsPath: depsPath
          prefix: depsPrefix
        src: [
          'var/wzk/**/*_test.js'
        ]

    esteWatch:
      options:
        dirs: [
          closureLibDir + '/**/'
          'wzk/**/'
          'var/wzk/**/'
        ]

      coffee: (filepath) ->
        config = getCoffeeConfig(filepath)
        grunt.config ['coffee', 'app', 'files'], config
        grunt.config ['coffee2closure', 'app', 'files'], config
        ['coffee:app', 'coffee2closure:app']

      js: (filepath) ->
        grunt.config ['esteDeps', 'all', 'src'], filepath
        grunt.config ['esteUnitTests', 'app', 'src'], filepath
        ['esteDeps:all', 'esteUnitTests:app']

    coffeelint:
      options:
        no_backticks:
          level: 'ignore'
        max_line_length:
          level: 'ignore'
        line_endings:
          value: 'unix'
          level: 'error'
        no_empty_param_list:
          level: 'warn'
      all:
        files: [
          expand: true
          src: coffeeFiles
          ext: '.js'
        ]

  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-este-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-este'
  grunt.loadNpmTasks 'grunt-este-watch'

  grunt.registerTask 'build', 'Build app.', (app = 'app') ->
    tasks = [
      "clean:#{app}"
      "coffee"
      "coffee2closure:#{app}"
      "coffeelint"
      "esteDeps"
      "esteUnitTests:#{app}"
      "esteBuilder:#{app}"
    ]
    grunt.task.run tasks

  grunt.registerTask 'run', 'Build app and run watchers.', (app = 'app') ->
    tasks = [
      "clean:#{app}"
      "coffee"
      "coffee2closure:#{app}"
      "coffeelint"
      "esteDeps"
      "esteUnitTests:#{app}"
      "esteWatch:#{app}"
    ]
    grunt.task.run tasks

  grunt.registerTask 'default', 'run:app'

  grunt.registerTask 'test', 'build:app'

module.exports = (grunt) ->
  bowerDir = 'bower_components'
  closureLibDir = bowerDir + '/closure-library'

  appDirs = [
    closureLibDir
    'var/wzk'
  ]

  coffeeFiles = [
    'wzk/**/*.coffee'
  ]

  appCompiledOutputPath =
    'var/app.js'

  depsPath =
    'var/wzk/deps.js'

  # from closure base.js dir to app root dir
  depsPrefix = '../../../../'

  getCoffeeConfig = (filepath = coffeeFiles) ->
    [
      expand: true
      src: filepath
      dest: 'var/'
      ext: '.js'
    ]

  grunt.initConfig

    clean:
      all:
        options:
          force: true
        src: [
          'var/wzk/**/*.js'
        ]

    coffee:
      all:
        options:
          bare: true
        files: [
          expand: true
          src: coffeeFiles
          dest: 'var/'
          ext: '.js'
        ]

    coffee2closure:
      all:
        files: [
          expand: true
          src: 'var/wzk/**/*.js'
          ext: '.js'
        ]

    esteDeps:
      all:
        options:
          depsWriterPath: closureLibDir + '/closure/bin/build/depswriter.py'
          outputFile: depsPath
          prefix: depsPrefix
          root: appDirs

    zuckrig:
      all:
        options:
          filter: (file) -> not /_test.js$/.test(file)
        files: [
          expand: true
          src: [
            'var/wzk/**/*.js'
          ]
          ext: '.js'
        ]


    esteBuilder:
      options:
        closureBuilderPath: closureLibDir+ '/closure/bin/build/closurebuilder.py'
        compilerPath: bowerDir + '/closure-compiler/compiler.jar'
        # needs Java 1.7+, see http://goo.gl/iS3o6
        fastCompilation: true
        root: '<%= esteDeps.all.options.root %>'
        depsPath: '<%= esteDeps.all.options.outputFile %>'
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

      all:
        options:
          namespace: '*'
          outputFilePath: appCompiledOutputPath

    esteUnitTests:
      options:
        basePath: closureLibDir + '/closure/goog/base.js'
      all:
        options:
          depsPath: '<%= esteDeps.all.options.outputFile %>'
          useReact: false
          prefix: '<%= esteDeps.all.options.prefix %>'
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
        config = getCoffeeConfig filepath
        grunt.config ['coffee', 'all', 'files'], config
        grunt.config ['zuckrig', 'all', 'files'], config
        grunt.config ['coffee2closure', 'all', 'files'], config
        ['coffee', 'zuckrig', 'coffee2closure']

      js: (filepath) ->
        grunt.config ['esteDeps', 'all', 'src'], filepath
        grunt.config ['esteUnitTests', 'all', 'src'], filepath
        ['esteDeps', 'esteUnitTests']

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
        space_operators:
          level: 'warn'
        cyclomatic_complexity:
          level: 'warn'
      all:
        files: [
          expand: true
          src: coffeeFiles
          ext: '.js'
        ]

    bump:
      options:
        bump: true
        files: ['package.json', 'bower.json']
        commitFiles: ['-a']
        commit: true
        tagName: '%VERSION%'
        tagMessage: 'Release %VERSION%'
        commitMessage: '%VERSION%'
        pushTo: 'origin'

  grunt.loadNpmTasks 'grunt-bump'
  grunt.loadNpmTasks 'grunt-contrib-clean'
  grunt.loadNpmTasks 'grunt-contrib-coffee'
  grunt.loadNpmTasks 'grunt-este-watch'
  grunt.loadNpmTasks 'grunt-coffeelint'
  grunt.loadNpmTasks 'grunt-este'
  grunt.loadNpmTasks 'grunt-este-watch'
  grunt.loadNpmTasks 'grunt-zuckrig-closure'

  grunt.registerTask 'build', 'Build app.', ->
    tasks = [
      "clean"
      "coffee"
      'zuckrig'
      "coffee2closure"
      "coffeelint"
      "esteDeps"
      "esteUnitTests"
      "esteBuilder"
    ]
    grunt.task.run tasks

  grunt.registerTask 'run', 'Build app and run watchers.', ->
    tasks = [
      "clean"
      "coffee"
      'zuckrig'
      "coffee2closure"
      "coffeelint"
      "esteDeps"
      "esteUnitTests"
      "esteWatch"
    ]
    grunt.task.run tasks

  grunt.registerTask 'default', 'run'

  grunt.registerTask 'test', 'build'

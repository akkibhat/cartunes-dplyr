module.exports = (grunt) ->
  grunt.initConfig
    pkg             : grunt.file.readJSON('package.json')
    browserify      :
      tests         :
        src         : ['tests/**/*-test.coffee']
        dest        : 'browser/tests.js'
        options     :
          transform : ['coffeeify', 'jadeify']
          alias     : ['lib/page.coffee:page']
    connect         :
      tests         :
        options     :
          port      : 9001
          base      : 'browser'
    watch           :
      tests         :
        files       : ['tests/**/*.coffee']
        tasks       : ['default']

  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-connect'
  grunt.loadNpmTasks 'grunt-contrib-watch'

  grunt.registerTask 'default', ['browserify:tests']

  grunt.registerTask 'run-tests', ['default', 'connect:tests', 'watch:tests']

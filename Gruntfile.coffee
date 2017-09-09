module.exports = (grunt) ->
  grunt.initConfig
    pkg             : grunt.file.readJSON('package.json')
    concurrent      :
      dev           :
        tasks       : ['watch', 'nodemon']
        options     : logConcurrentOutput : true
    nodemon         :
      dev           :
        script      : 'server.js'
        options     :
          cwd       : __dirname
          ext       : 'js'
          watch     : ['app']
          ignore    : ['app/public', 'app/views']
          delay     : 3
    browserify      :
      default       :
        src         : 'app-src/views/js/index.coffee'
        dest        : 'app/public/js/dist.js'
        options     :
          transform : ['coffeeify', 'jadeify']
          alias     : ['./app-src/views/js/lib/page.coffee:page']
          bundleOptions:
            debug   : true
    uglify          :
      default       :
        src         : 'app/public/js/dist.js'
        dest        : 'app/public/js/dist.min.js'
    stylus          :
      dev           :
        files       : { 'app/public/css/screen.css' : 'app-src/views/styl/screen.styl' }
        options     :
          compress  : no
          use       : [require('nib')]
      prod          :
        files       : { 'app/public/css/screen.min.css' : 'app-src/views/styl/screen.styl' }
        options     :
          compress  : yes
          use       : [require('nib')]
    jade            :
      default       :
        files       : { 'app/public/index.html' : 'app-src/views/home/index.jade' }
        options     :
          data      : (dest, src) ->
            return require './config.json'
          debug     : no
    watch           :
      views         :
        files       : ['app-src/views/js/**/*.coffee', 'app-src/views/js/**/*.jade']
        tasks       : ['javascript']
      stylus        :
        files       : ['app-src/views/styl/**/*.styl']
        tasks       : ['stylus']
      jade          :
        files       : ['app-src/views/**/*.jade']
        tasks       : ['jade']

  grunt.loadNpmTasks 'grunt-concurrent'
  grunt.loadNpmTasks 'grunt-nodemon'
  grunt.loadNpmTasks 'grunt-contrib-uglify'
  grunt.loadNpmTasks 'grunt-contrib-watch'
  grunt.loadNpmTasks 'grunt-browserify'
  grunt.loadNpmTasks 'grunt-contrib-stylus'
  grunt.loadNpmTasks 'grunt-contrib-jade'

  grunt.registerTask 'javascript', ['browserify', 'uglify']
  grunt.registerTask 'start-dev-server', ['default', 'concurrent:dev']
  grunt.registerTask 'default', ['javascript', 'stylus', 'jade']

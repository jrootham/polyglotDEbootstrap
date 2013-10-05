#  Gruntfile for base code for Polyglot

module.exports = (grunt)->
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-cafe-mocha"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-clean"
  
  grunt.registerTask "default",["clean", "coffeelint", "coffee", "cafemocha"]
  
  grunt.initConfig
    clean: ["test", "bin"]
      
    coffeelint:
      app:["*.coffee"]

    coffee:
      server-bin:
        files: [
          src: ["server/*.coffee", "!server/*.spec.coffee", "!Gruntfile.coffee"]
          dest: "server/bin/"
          cwd: "."
          expand: true
          ext: ".js"
        ]
        
      server-test:
        files: [
          src: ["server/*.spec.coffee"]
          dest: "server/test/"
          cwd: "."
          expand: true
          ext: ".spec.js"
        ]

    cafemocha:
      src: "server/test/*.js"
  


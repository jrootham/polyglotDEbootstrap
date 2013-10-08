#  Gruntfile for polyglotDE

makeItem = (name, dest, type, excludeList) ->
  src = []
  src[src.length] = "**/*" + type + ".coffee"
  for exclude in excludeList
    src[src.length] = "!**/*" + exclude + ".coffee"

  result =
    src: src
    dest: "src/" + name + "/" + dest + "/"
    cwd: "src/" + name + "/"
    expand: true
    ext: type + ".js"

  return result
  
class Group
  constructor: (name)->
    @def = new Object()
    @next name
  
  next: (name) =>
    @def[name + "Bin"] = makeItem name, "bin", "", [".spec", ".scaffold"]
    @def[name + "Spec"] = makeItem name, "test", ".spec", []
    @def[name + "Scaffold"] = makeItem name, "test", ".scaffold", []
    
    return @
    
  done: =>
    return @def
  
module.exports = (grunt)->
  grunt.loadNpmTasks "grunt-coffeelint"
  grunt.loadNpmTasks "grunt-cafe-mocha"
  grunt.loadNpmTasks "grunt-contrib-coffee"
  grunt.loadNpmTasks "grunt-contrib-clean"
  
  grunt.registerTask "default",["clean", "coffeelint", "coffee", "cafemocha"]
  
  grunt.initConfig
    clean: [
      "src/server/test/*",
      "src/server/bin/*",
      "src/common/test/*",
      "src/common/bin/*",
      "src/handbuilt/test/*",
      "src/handbuilt/bin/*"
    ]
      
    coffeelint:
      app:["src/**/*.coffee"]

    coffee:
      new Group("server")
        .next("common")
        .next("handbuilt")
        .done()
      

    cafemocha:
      src: "src/**/test/*.js" 
      options:
        reporter: "dot"
  


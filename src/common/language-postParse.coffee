
linkable = require "./linkable"

module.exports =

  NewScope: class extends linkable.Linkable
    constructor: (linkid)->
      super linkid
    
    name: "NewScope"
    


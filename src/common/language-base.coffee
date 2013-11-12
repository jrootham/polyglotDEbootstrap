# language base

linkable = require "./linkable"
program = require "./program"

module.exports =

  LanguageBase: class extends linkable.Linkable
    constructor: (linkid)->
      super linkid
      
    parse: (next, source) ->
      @.preorder (item) -> item.reached = -1
      @parseFn next, source, [], {current: null}
      
  

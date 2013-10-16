#  Test up down linkages

module.exports =
  connect: (linkable, language, program) ->
  
    linkable.Linkable::checkUp = ->
      for item in @up
        item.confirmDown @
      return true
      
    linkable.Linkable::confirmUp = (above) ->
      if -1 == @up.indexOf above
        throw new Error "Down pointer with no matching up pointer"
      return true

    linkable.Linkable::checkDown = ->
      return true
                
    language.Repeat::checkDown = ->
      @checkUp
      @argument.confirmUp @
      @argument.checkDown
      return true
      
    language.Repeat::confirmDown = (item) ->
      if item != @argument
        throw new Error "Up pointer with no matching down pointer"
      return true
      
    language.AndJoin::checkDown = ->
      @checkUp
      
      @left.confirmUp @
      @right.confirmUp @
      
      @left.checkDown
      @right.checkDown

      return true

    language.AndJoin::confirmDown = (item) ->
      if item != @left && item != @right
        throw new Error "Up pointer with no matching down pointer"
      return true
      
    language.OrJoin::checkDown = ->
      @checkUp
      
      @left.confirmUp @
      @right.confirmUp @
      
      @left.checkDown
      @right.checkDown

      return true

    language.OrJoin::confirmDown = (item) ->
      if item != @left && item != @right
        throw new Error "Up pointer with no matching down pointer"
      return true
      
    language.Production::checkDown = ->
      @checkUp
      
      @assign.confirmUp @
      @graph.confirmUp @
      if @parseTime then @parseTime.confirmUp @
      if @generate then @generate.confirmUp @
      
      @assign.checkDown
      @graph.checkDown
      if @parseTime then @parseTime.checkDown
      if @generate then @generate.checkDown

      return true

    language.Production::confirmDown = (item) ->
      if -1 == [@assign, @graph, @parseTime, @generate].indexOf item
        throw new Error "Up pointer with no matching down pointer"
      return true
            
    program.Repeat::checkDown = ->
      @checkUp
      
      for item in @list
        @item.confirmUp @
        @item.checkDown
      
      return true
      
    program.Repeat::confirmDown = (item) ->
      if -1 == @argument.indexOf item
        throw new Error "Up pointer with no matching down pointer"
      return true
      
    program.AndJoin::checkDown = ->
      @checkUp
      @left.confirmUp @
      @right.confirmUp @
      @left.checkDown
      @right.checkDown
      return true

    program.AndJoin::confirmDown = (item) ->
      if item != @left && item != right
        throw new Error "Up pointer with no matching down pointer"
      return true
      
    program.OrJoin::checkDown = ->
      @checkUp
      @argument.confirmUp @
      @argument.checkDown
      return true

    program.OrJoin::confirmDown = (item) ->
      if item != @argument
        throw new Error "Up pointer with no matching down pointer"
      return true

    program.Production::checkDown = ->
      @checkUp
      
      @assign.confirmUp @
      @graph.confirmUp @
      if @parseTime then @parseTime.confirmUp @
      if @generate then @generate.confirmUp @
      
      @assign.checkDown
      @graph.checkDown
      if @parseTime then @parseTime.checkDown
      if @generate then @generate.checkDown

      return true

    program.Production::confirmDown = (item) ->
      if -1 == [@assign, @graph, @parseTime, @generate].indexOf item
        throw new Error "Up pointer with no matching down pointer"
      return true
      


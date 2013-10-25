#
#   program branching classes for parsing and editing
#

#
#  Base classes
#

Program = require "./program-base"

Monadic = class extends Program
  constructor: (linkid, pointer, @argument) ->
    super linkid, pointer
       
Dyadic = class extends Program
  constructor: (linkid, pointer, @left, @right) ->
    super linkid, pointer
    
    
module.exports =
#
#   Define a repetition in the parse tree
#
  Repeat: class extends Program
    constructor: (linkid, pointer)->
      super linkid, pointer
      @list = []

    name: "Repeat"

    add: (item) =>
      @list.push item
      
    isComplete: =>
      result = true
      
      for item in @list
        result = result && item.isComplete()
      
      return result
      
    displayGraph: (visited, indent) ->
      result = @displayNode indent
      
      if ! visited[@linkid]
        visited[@linkid] = true
        result += "\n"

        for item in @list
          if item
            result += item.displayGraph visited, indent + "  "
          else
            result += indent + "  " + "item is null\n"
      else
        result += "...\n"
      
      return result

    preorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        fn @
        for item in @list
          item.preorderFn visited, fn

    inorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        fn @
        for item in @list
          item.preorderFn visited, fn

    postorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        for item in @list
          item.preorderFn visited, fn
        fn @

#
#  define a concatenation in the parse tree
#
  AndJoin: class extends Dyadic
  
    name: "AndJoin"

    isComplete: ->
      return @left.isComplete() && @right.isComplete()

    displayGraph: (visited, indent) ->
      result = @displayNode indent
      
      if ! visited[@linkid]
        visited[@linkid] = true
        result += "\n"

        if @left
          result += @left.displayGraph visited, indent + "  "
        else
          result += indent + "  " + "left is null\n"

        if @right
          result += @right.displayGraph visited, indent + "  "
        else
          result += indent + "  " + "right is null\n"
      else
        result += "...\n"
      
      return result

    preorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        fn @
        @left.preorderFn visited, fn
        @right.preorderFn visited, fn

    inorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        @left.inorderFn visited, fn
        fn @
        @right.inorderFn visited, fn

    postorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        @left.postorderFn visited, fn
        @right.postorderFn visited, fn
        fn @

#
#  define a choice point in the parse tree
#

  OrJoin: class extends Monadic

    name: "OrJoin"

    displayGraph: (visited, indent) ->
      result = @displayNode indent
      
      if ! visited[@linkid]
        visited[@linkid] = true
        result += "\n"

        if @argument
          result += @argument.displayGraph visited, indent + "  "
        else
          result += indent + "  " + "argument is null\n"
      else
        result += "...\n"
      
      return result

    isComplete: ->
      @argument.isComplete()

    preorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        fn @
        @argument.preorderFn visited, fn

    inorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        fn @
        @argument.inorderFn visited, fn

    postorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        @argument.postorderFn visited, fn
        fn @


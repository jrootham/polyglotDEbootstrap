# Program special cases

linkable = require "./linkable"

module.exports =

  Production: class extends linkable.Linkable
    constructor: (next, @assign, @expression, @parseTime, @generate) ->
      super next
      
    name: "Production"
    
    makeFlatItem: ->
      result = super
      result.assign = @assign.linkid
      result.expression = @expression.linkid
      result.parseTime = @parseTime.linkid
      result.generate = @generate.linkid
      return result
      
    flatten: (flat) ->
      if super flat
        @assign.flatten flat
        @expression.flatten flat
        if @parseTime then @parseTime.flatten flat
        if @assign then @generate.flatten flat
        
    preorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        fn @
        @assign.preorderFn visited, fn
        @expression.preorderFn visited, fn
        @parseTime.preorderFn visited, fn
        @generate.preorderFn visited, fn

    inorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        @assign.inorderFn visited, fn
        fn @
        @expression.inorderFn visited, fn
        @parseTime.inorderFn visited, fn
        @generate.inorderFn visited, fn

    postorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        @assign.postorderFn visited, fn
        @expression.postorderFn visited, fn
        @parseTime.postorderFn visited, fn
        @generate.postorderFn visited, fn
        fn @

    tailDisplay: (visited, indent)->
      if @assign
        result = @assign.displayGraph visited, indent + "  "
      else
        result = indent + "  " + "assign is null\n"
      
      if @expression
        result += @expression.displayGraph visited, indent + "  "
      else
        result += indent + "  " + "expression is null\n"
      
      if @parseTime
        result += @parseTime.displayGraph visited, indent + "  "
      else
        result += indent + "  " + "parseTime is null\n"
      
      if @generate
        result += @generate.displayGraph visited, indent + "  "
      else
        result += indent + "  " + "generate is null\n"
      
      return "\n" + result


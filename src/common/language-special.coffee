# special cases for language

#linkable = require "./linkable"
languageBase = require "./language-base"
program = require "./program"

#  the assignment side of the graph is connected with AndJoins and has 1
#  Symbol element

findSymbol = (graph)->
  result = null
  
  if graph.name == "Symbol"
    result = graph.value
    
  if graph.name == "AndJoin"
    result = findSymbol graph.left
    
    if !result
      result = findSymbol graph.right
    
  return result
  
module.exports =
  Production: class extends languageBase.LanguageBase
    constructor: (linkid, @assign, @expression, @parseTime, @generate) ->
      super linkid

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
        @parseTime.flatten flat
        @generate.flatten flat
        
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

    parseFn: (next, source, parseStack, scope) =>
      if source.current.index != @reached
        @reached = source.current.index
        assignProgram = @assign.parseFn next, source, parseStack, scope
        
        result = null
        
        if assignProgram
          if source.next ":="
            expressionProgram = @expression.parseFn next, source, parseStack
            
            if expressionProgram
              postParseProgram =  @parseTime.parseFn next, source, parseStack
              generateProgram = @generate.parseFn next, source, parseStack
              source.next ";"
              
              result = new program.Production next.next(), assignProgram
              , expressionProgram, postParseProgram, generateProgram
              
              assignProgram.addUp result
              expressionProgram.addUp result
              if postParseProgram then postParseProgram.addUp result
              if generateProgram then generateProgram.addUp result
      else
        result = null
                    
      return result
      

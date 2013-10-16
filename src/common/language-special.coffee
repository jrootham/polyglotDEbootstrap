# special cases for language

linkable = require "./linkable"
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
  Production: class extends linkable.Linkable
    constructor: (linkid, @assign, @graph, @parseTime, @generate) ->
      super linkid

    name: "Production"
    
    makeFlatItem: ->
      result = super
      result.assign = @assign.linkid
      result.graph = @graph.linkid
      result.parseTime = @parseTime.linkid
      result.generate = @generate.linkid
      return result
      
    flatten: (flat) ->
      if super flat
        @assign.flatten flat
        @graph.flatten flat
        @parseTime.flatten flat
        @generate.flatten flat
        
    preorder: (fn) ->
      fn @
      @assign.preorder fn
      @graph.preorder fn
      @parseTime.preorder fn
      @generate.preorder fn

    inorder: (fn) ->
      @assign.inorder fn
      fn @
      @graph.inorder fn
      @parseTime.inorder fn
      @generate.inorder fn

    postorder: (fn) ->
      @assign.postorder fn
      @graph.postorder fn
      @parseTime.postorder fn
      @generate.postorder fn
      fn @

    tailDisplay: (visited, indent)->
      if @assign
        result = @assign.displayGraph visited, indent + "  "
      else
        result = indent + "  " + "assign is null\n"
      
      if @graph
        result += @graph.displayGraph visited, indent + "  "
      else
        result += indent + "  " + "graph is null\n"
      
      if @parseTime
        result += @parseTime.displayGraph visited, indent + "  "
      else
        result += indent + "  " + "parseTime is null\n"
      
      if @generate
        result += @generate.displayGraph visited, indent + "  "
      else
        result += indent + "  " + "generate is null\n"
      
      return "\n" + result

    parse: (next, source, parseStack, table) =>
      assignProgram = @assign.parse next, source, parseStack, table
      
      result = null
      
      if assignProgram
        if source.next ":="
          graphProgram = @graph.parse next, source, parseStack, table
          
          if graphProgram
            parseTimeProgram =  @parseTime.parse next, source, parseStack, table
            generateProgram = @generate.parse next, source, parseStack, table
            source.next ";"
            
            result = new program.Production next.next(), assignProgram
            , graphProgram, parseTimeProgram, generateProgram
            
            assignProgram.addUp result
            graphProgram.addUp result
            if parseTimeProgram
              parseTimeProgram.addUp result
            if generateProgram
              generateProgram.addUp result
            
            name = findSymbol assignProgram
            table.set name, result
            
      return result
      

# Program special cases

linkable = require "./linkable"

module.exports =

  Production: class extends linkable.Linkable
    constructor: (next, @assign, @graph, @parseTime, @generate) ->
      super next
      
    name: "Production"
    
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


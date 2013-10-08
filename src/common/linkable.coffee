#
#  base class for linkable objects
#
#   And related clesses

module.exports =
  Linkable: class
    constructor: (@linkid) ->

    makeFlatItem: ->
      return {linkid: @linkid, name: @name}

    flatten: (flat) ->
      return flat.add @makeFlatItem()
      
    displayNode: (indent) ->
      return indent + @linkid + "=" + @name
      
    displayGraph: (visited, indent)->
      result = @displayNode indent
      
      if ! visited[@linkid]
        visited[@linkid] = true
        result += @tailDisplay visited, indent
      else
        result += "...\n"

#  Class to contain a flattened copy of a graph

  Flat: class
    constructor: ->
      @list = []
      @index = []
      
    add: (thing) ->
      if @index[thing.linkid]
        result = false
      else
        @list[@list.length] = thing
        @index[thing.linkid] = true
        result = true
        
      return result
      
# class to generate ids

  Next: class
    constructor: (@current) ->
    
    next: ->
      @current++
    

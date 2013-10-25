#
#  base class for linkable objects
#
#   And related clesses

module.exports =
  Linkable: class
    constructor: (@linkid) ->
      @up = []
      
    addUp: (upPointer) ->
      @up.push upPointer

    preorder: (fn) ->
      @preorderFn [], fn
                
    preorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        fn @
   
    inorder: (fn) ->
      @inorderFn [], fn
   
    inorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        fn @

    postorder: (fn) ->
      @postorderFn [], fn

    postorderFn: (visited, fn) ->
      if -1 == visited.indexOf @
        visited.push @
        fn @

    makeFlatItem: ->
      result =
        linkid: @linkid
        name: @name
        
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
    

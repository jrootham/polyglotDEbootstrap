#
#   language branching classes
#

program = require "./program"
#linkable = require "./linkable"
languageBase = require "./language-base"

#
#  Base classes
#
 
#  For single arguments

Monadic = class extends languageBase.LanguageBase
  constructor: (linkid, @argument) ->
    super linkid

  makeFlatItem: ->
    result = super
    result.argument = @argument.linkid
    return result
    
  flatten: (flat) ->
    if super flat
      @argument.flatten flat
      
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

  tailDisplay: (visited, indent)->
    if @argument
      result = @argument.displayGraph visited, indent + "  "
    else
      result = indent + "  " + "argument is null\n"
      
    return "\n" + result
       
#  For 2 arguments
    
Dyadic = class extends languageBase.LanguageBase
  constructor: (linkid, @left, @right) ->
    super linkid

  makeFlatItem: ->
    result = super
    result.left = @left.linkid
    result.right = @right.linkid
    return result
    
  flatten: (flat) ->
    if super flat
      @left.flatten flat
      @right.flatten flat
      
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

  tailDisplay: (visited, indent)->
    if @left
      result = @left.displayGraph visited, indent + "  "
    else
      result = indent + "  " + "left is null\n"
    
    if @right
      result += @right.displayGraph visited, indent + "  "
    else
      result += indent + "  " + "right is null\n"
    
    return "\n" + result
#
#  utility classes
#

ParseSave = class
  constructor: ->
    @list = []
    
  restore: =>
    item.restore for item in @list

  add: (item) =>
    @list.push item
    
  merge: (other) =>
    this.add for item in other.list
    
# Utility function that commits to a parse choice

commit = (source, parseStack) ->
  source.commit()
  current = parseStack.pop()
  
  if parseStack.length > 0
    parseStack[parseStack.length - 1].merge current

# Utility function that saves a parse choice

save = (source, parseStack) ->
  source.save()
  parseStack.push new ParseSave()

# Utility function that restores to a saved parse choice

restore = (source, parseStack) ->
  source.restore()
  (parseStack.pop()).restore()

module.exports =
#
#   Define a repetition in the parse tree
#
  Repeat: class extends Monadic

    name: "Repeat"
    
    parseFn: (next, source, parseStack, scope) =>
      if source.current.index != @reached
        @reached = source.current.index
        result = new program.Repeat next.next(), @
        
        save source, parseStack
        
        while item = @argument.parseFn next, source, parseStack, scope
          result.add item
          item.up = result
          
          commit source, parseStack
          save source, parseStack
          
        restore source, parseStack
      else
        result = null
          
      return result

#
#  define a concatenation in the parse tree
#
  AndJoin: class extends Dyadic
  
    name: "AndJoin"

    parseFn: (next, source, parseStack, scope) =>
      if source.current.index != @reached
        @reached = source.current.index
        save source, parseStack

        leftParse = @left.parseFn next, source, parseStack, scope
        rightParse = @right.parseFn next, source, parseStack, scope
        
        if leftParse && rightParse
          result = new program.AndJoin next.next(), @, leftParse,rightParse
          
          leftParse.up = result
          rightParse.up = result
          
          commit source, parseStack
        else
          result = null
          restore source, parseStack
      else
        result = null
                
      return result

#
#  define a choice point in the parse tree
#

  OrJoin: class extends Dyadic

#  parsing function
    
    name: "OrJoin"

    parseFn: (next, source, parseStack, scope) =>
      if source.current.index != @reached
        @reached = source.current.index
        save source, parseStack
              
        descendent = @left.parseFn next, source, parseStack, scope
        
        if ! descendent
          restore source, parseStack
          save source, parseStack
          @right.preorder -> @reached = -1

          descendent = @right.parseFn next, source, parseStack, scope
            
        if descendent
          commit source, parseStack
          result = new program.OrJoin next.next(), @, descendent
          descendent.up = result
        else
          restore source, parseStack
          result = null
      else
        result = null
                
      return result


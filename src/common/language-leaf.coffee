#
#   language leaf classes
#

program = require "./program-graph"
linkable = require "./linkable"

# ### Non exports
# #### base class for leaves

class Leaf extends linkable.Linkable

# Display following id and name

  tailDisplay: (visited, indent)->
    "\n"

#  apply function in preorder
  preorder: (fn) ->
    fn @

#  apply function in inorder
  inorder: (fn) ->
    fn @

#  apply function in postorder
  postorder: (fn) ->
    fn @


# #### a base class for whitespace

class White extends Leaf
  constructor: (linkid, @whitespace) ->
    super linkid
    
# Display whitespace to insert

  tailDisplay: (visited, indent)->
    ":" + @whitespace + ":\n"

# create a flat Whitespace item
    
  makeFlatItem: ->
    result = super
    result.whitespace = @whitespace
    
    return result

# #### Common functions
#  A matching function

doMatch = (next, source, pattern, flags, pointer, make) ->
  match = source.match pattern, flags
  if match
    result = make next, pointer, match
  else
    result = null
  return result
  
# ### Exports

module.exports =

# Constant

  Constant: class extends Leaf
    constructor: (linkid, @value) ->
      super linkid

    name: "Constant"
      
    parse: (next, source, parseStack) =>
      match = source.next(@value)
      if match
        result = new program.Constant next.next(), @
      else
        result = null
      return result

    tailDisplay: ->
      " " + @value + "\n"

    makeFlatItem: ->
      result = super
      result.value = @value
      
      return result
      
# Match
          
  Match: class extends Leaf
    constructor: (linkid, @pattern, @flags) ->
      super linkid
      
    name: "Match"

    makeFlatItem: ->
      result = super
      result.pattern = @pattern
      result.flags = @flags
      
      return result
          
    tailDisplay: (visited, indent)->
      ":" + @pattern + " " + @flags + "\n"

    make:  (next, pointer, value) ->
      new program.Match next.next(), pointer, value
      
    parse: (next, source, parseStack) =>
      return doMatch next, source, @pattern, @flags, @, @make

# Unsigned
  
  Unsigned: class extends Leaf
      
    name: "Unsigned"
    
    make: (next, pointer, value) ->
      new program.Unsigned next.next(), pointer, value
      
    parse: (next, source, parseStack) =>
      return doMatch next, source, "[0-9]*", "", @, @make

# Integer
  
  Integer: class extends Leaf
      
    name: "Integer"
    
    make: (next, pointer, value) ->
      new program.Integer next.next(), pointer, value
      
    parse: (next, source, parseStack) =>
      return doMatch next, source, "\-?[0-9]*", "", @, @make

# Fixed
  
  Fixed: class extends Leaf
      
    name: "Fixed"
    
    make: (next, pointer, value) ->
      new program.Fixed next.next(), pointer, value
      
    parse: (next, source, parseStack) =>
      return doMatch next, source, "-?[0-9]*(\\.[0-9]*)?", "", @, @make

# Float
  
  Float: class extends Leaf
      
    name: "Float"
    
    make: (next, pointer, value) ->
      new program.Float next.next(), pointer, value
      
    parse: (next, source, parseStack) =>
      pattern = "-?[0-9]*(\\.[0-9]*)?((e|E)-?[0-9]*)?"
      return doMatch next, source, pattern, "", @, @make


# FixedBCD
  
  FixedBCD: class extends Leaf
      
    name: "FixedBCD"
    
    make: (next, pointer, value) ->
      new program.FixedBCD next.next(), pointer, value
      
    parse: (next, source, parseStack) =>
      return doMatch next, source, "-?[0-9]*(\\.[0-9]*)?", "", @, @make


# StringType
  
  StringType: class extends Leaf
      
    name: "StringType"
    
    parse: (next, source, parseStack) =>
      return new program.StringType next.next(), @, source.toEOL()

# SingleQuotes
  
  SingleQuotes: class extends Leaf
      
    name: "SingleQuotes"
    
    parse: (next, source, parseStack) =>
      matched = source.singleQuotes()
      if matched
        result = new program.SingleQuotes next.next(), @, matched
      else
        result = null
      
      return result
      
# DoubleQuotes
  
  DoubleQuotes: class extends Leaf
      
    name: "DoubleQuotes"
    
    parse: (next, source, parseStack) =>
      matched = source.doubleQuotes()
      if matched
        result = new program.DoubleQuotes next.next(), @, matched
      else
        result = null
      
      return result


# Symbol
  
  Symbol: class extends Leaf
    constructor: (linkid, @pattern = "([A-Z]|[a-z]|_)([A-Z]|[a-z]|[0-9]|_)*") ->
      super linkid
      
    name: "Symbol"
    
    tailDisplay: (visited, indent)->
      ":" + @pattern + ":\n"
      
    makeFlatItem: ->
      result = super
      result.pattern = @pattern
      return result

    make: (next, pointer, value) ->
      new program.Symbol next.next(), pointer, value
      
    parse: (next, source, parseStack) =>
      return doMatch next, source, @pattern, "", @, @make


# OptionalWhite
  
  OptionalWhite: class extends White
      
    name: "OptionalWhite"
      
    parse: (next, source, parseStack) =>
      match = source.match "\\s*"
      return new program.OptionalWhite next.next(), @

# RequiredWhite
 
  RequiredWhite: class extends White
      
    name: "RequiredWhite"
    
    make: (next, pointer, value) ->
      new program.RequiredWhite next.next(), pointer
      
    parse: (next, source, parseStack) =>
      return doMatch next, source, "\\s*", "", @, @make


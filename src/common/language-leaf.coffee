#
#   language leaf classes
#

program = require "./program"
#linkable = require "./linkable"
languageBase = require "./language-base"

# ### Non exports

#  standard pattern for symbols

standard = "([A-Z]|[a-z]|_)([A-Z]|[a-z]|[0-9]|_)*"
 
# #### base class for leaves

class Leaf extends languageBase.LanguageBase
  constructor: (linkid) ->
    super linkid
    
# Display following id and name

  tailDisplay: (visited, indent)->
    "\n"

# #### a base class for whitespace

class White extends Leaf
  constructor: (linkid, @whitespace, @pattern = "\\s*") ->
    super linkid
    
# Display whitespace to insert

  tailDisplay: (visited, indent)->
    ":" + @pattern + ":" + @whitespace + ":\n"

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
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        match = source.next(@value)
        if match
          result = new program.Constant next.next(), @
        else
          result = null
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
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        result = doMatch next, source, @pattern, @flags, @, @make
      else
        result = null
        
      return result
      
# Unsigned
  
  Unsigned: class extends Leaf
      
    name: "Unsigned"
    
    make: (next, pointer, value) ->
      new program.Unsigned next.next(),pointer, value
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        result = doMatch next, source, "[0-9]*", "", @, @make
      else
        result = null
        
      return result

# Integer
  
  Integer: class extends Leaf
      
    name: "Integer"
    
    make: (next, pointer, value) ->
      new program.Integer next.next(), pointer, value
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        result = doMatch next, source, "\-?[0-9]*", "", @, @make
      else
        result = null
        
      return result

# Fixed
  
  Fixed: class extends Leaf
      
    name: "Fixed"
    
    make: (next, pointer, value) ->
      new program.Fixed next.next(), pointer, value
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        result = doMatch next, source, "-?[0-9]*(\\.[0-9]*)?", "", @, @make
      else
        result = null
        
      return result
# Float
  
  Float: class extends Leaf
      
    name: "Float"
    
    make: (next, pointer, value) ->
      new program.Float next.next(), pointer, value
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        pattern = "-?[0-9]*(\\.[0-9]*)?((e|E)-?[0-9]*)?"
        result = doMatch next, source, pattern, "", @, @make
      else
        result = null
        
      return result


# FixedBCD
  
  FixedBCD: class extends Leaf
      
    name: "FixedBCD"
    
    make: (next, pointer, value) ->
      new program.FixedBCD next.next(), pointer, value
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        result = doMatch next, source, "-?[0-9]*(\\.[0-9]*)?", "", @, @make
      else
        result = null
        
      return result


# StringType
  
  StringType: class extends Leaf
      
    name: "StringType"
    
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        result = new program.StringType next.next(), @, source.toEOL()
      else
        result = null
        
      return result

# SingleQuotes
  
  SingleQuotes: class extends Leaf
      
    name: "SingleQuotes"
    
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        matched = source.singleQuotes()
        if matched
          result = new program.SingleQuotes next.next(), @, matched
        else
          result = null
      else
        result = null
        
      return result
      
# DoubleQuotes
  
  DoubleQuotes: class extends Leaf
      
    name: "DoubleQuotes"
    
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        matched = source.doubleQuotes()
        if matched
          result = new program.DoubleQuotes next.next(), @, matched
        else
          result = null
      else
        result = null
        
      return result


# Symbol
  
  Symbol: class extends Leaf
    constructor: (linkid, up, @pattern = standard) ->
      super linkid, up
      
    name: "Symbol"
    
    tailDisplay: (visited, indent)->
      ":" + @pattern + ":\n"
      
    makeFlatItem: ->
      result = super
      result.pattern = @pattern
      return result

    make: (next, pointer, value) ->
      new program.Symbol next.next(), pointer, value
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        result = doMatch next, source, @pattern, "", @, @make
      else
        result = null
        
      return result


# OptionalWhite
  
  OptionalWhite: class extends White
      
    name: "OptionalWhite"
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        match = source.match @pattern
        result = new program.OptionalWhite next.next(), @
      else
        result = null
        
      return result

# RequiredWhite
 
  RequiredWhite: class extends White
      
    name: "RequiredWhite"
    
    make: (next, pointer, value) ->
      new program.RequiredWhite next.next(), pointer
      
    parseFn: (next, source, parseStack, table) =>
      if source.current.index != @reached
        @reached = source.current.index
        result = doMatch next, source, @pattern, "", @, @make
      else
        result = null
        
      return result


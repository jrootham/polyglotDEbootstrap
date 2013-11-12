#
#   Leaf program classes
#

Program = require "./program-base"

class Leaf extends Program
  constructor: (linkid, pointer) ->
    super linkid, pointer

  isComplete: ->
    return true
    
class Value extends Leaf
  constructor: (linkid, pointer, @value) ->
    super linkid, pointer
  
  tailDisplay: (visited, indent) =>
    return ":" + @value + "\n"
    
class Numeric extends Value
  constructor: (linkid, pointer, value) ->
    super linkid, pointer, +value

class White extends Leaf

  tailDisplay: (visited, indent) =>
    return ":" + @pointer.whitespace + "\n"
    
module.exports =
  Constant: class extends Leaf

    name: "Constant"
  
    tailDisplay: (visited, indent) =>
      return ":" + @pointer.value + "\n"
      
  Unsigned: class extends Numeric

    name: "Unsigned"
    
  Integer: class extends Numeric

    name: "Integer"
    
  Fixed: class extends Numeric

    name: "Fixed"
    
  Float: class extends Numeric

    name: "Float"
    
  FixedBCD: class extends Numeric

    name: "FixedBCD"
    
  StringType: class extends Value

    name: "StringType"
    
  SingleQuotes: class extends Value

    name: "SingleQuotes"
    
  DoubleQuotes: class extends Value

    name: "DoubleQuotes"
    
  Symbol: class extends Value

    name: "Symbol"
    
    tailDisplay: (visited, indent) =>
      return @value.item.name
    
    symbolName: =>
      return @value.item.name

  Match: class extends Value

    name: "Match"
    
  OptionalWhite: class extends White

    name: "OptionalWhite"
    
  RequiredWhite: class extends White

    name: "RequiredWhite"
    

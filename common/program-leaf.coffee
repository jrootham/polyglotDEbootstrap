#
#   Leaf program classes
#

Program = require "./program"

class Leaf extends Program
  constructor: (linkid, pointer) ->
    super linkid, pointer

  displayGraph: (visited, indent) ->
    result = @displayNode indent
    
    if ! visited[@linkid]
      visited[@linkid] = true
      result += "\n"
    else
      result += "...\n"
    
    return result
 
  isComplete: ->
    return true
    
  preorder: (fn) ->
    fn @
 
  inorder: (fn) ->
    fn @
 
  postorder: (fn) ->
    fn @

class Value extends Leaf
  constructor: (linkid, pointer, @value) ->
    super linkid, pointer

  displayGraph: (visited, indent) ->
    result = @displayNode indent
    
    if ! visited[@linkid]
      visited[@linkid] = true
      result += ":" + @value + "\n"
    else
      result += "...\n"
    
    return result
    
class Numeric extends Value
  constructor: (linkid, pointer, value) ->
    super linkid, pointer, +value

class White extends Leaf

  displayGraph: (visited, indent) ->
    result = @displayNode indent
    
    if ! visited[@linkid]
      visited[@linkid] = true
      result += ":" + @pointer.whitespace + "\n"
    else
      result += "...\n"
    
    return result
    
module.exports =
  Constant: class extends Leaf

    name: "Constant"
  
    displayGraph: (visited, indent) ->
      result = @displayNode indent
      
      if ! visited[@linkid]
        visited[@linkid] = true
        result += ":" + @pointer.value + "\n"
      else
        result += "...\n"
      
      return result
      
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
    
  Match: class extends Value

    name: "Match"
    
  OptionalWhite: class extends White

    name: "OptionalWhite"
    
  RequiredWhite: class extends White

    name: "RequiredWhite"
    

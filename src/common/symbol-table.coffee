#  Symbol table

module.exports = class SymbolTable
  constructor: ->
    @table = new Object()
    
  insert: (name) =>
    @table[name] = false
    
  set: (name, value) =>
    @table[name] = value
    
  isInserted: (name) =>
    return @table[name] != undefined

  isSet: (name) =>
    return (@isInserted name) && @table[name] != false
    

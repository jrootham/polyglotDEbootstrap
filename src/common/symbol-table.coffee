#  Symbol table

module.exports = class SymbolTable
  constructor: ->
    @table = new Object()
    
  insert: (name) =>
    @table[name] = null
    
  set: (name, value) =>
    @table[name] = value
    
  get: (name) =>
    @table[name]
    
  isInserted: (name) =>
    return @table[name] != undefined

  isSet: (name) =>
    return (@isInserted name) && @table[name] != null
    

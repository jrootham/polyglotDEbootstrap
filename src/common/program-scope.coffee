#  Scope object

linkable = require "./linkable"

localGet = (local, name) ->
  temp = local.table.filter (item)-> item.name == name
  if temp.length == 0
    result = undefined
  else
    result =
      scope: local
      item: temp[0]
  return result

chainedGet = (current, name) ->
  result = localGet current, name
  if result == undefined
    if current.chain != null
      result = chainedGet current.chain, name
  return result
        
module.exports =
  Scope: class extends linkable.Linkable
  
    constructor: (linkid, @chain) ->
      super linkid
      @table = []
      
    insert: (name) =>
      item = localGet @, name
      if undefined == item
        item =
          name:name
          set:false
          value:null
        @table.push item
      result =
        scope: @
        item: item
      
    set: (name, value, definition) =>
      item = @insert name
      item.set = true
      item.value = value
      item.definition = definition
      return item
      
    get: (name) =>
      return chainedGet @, name
      
    unset: (name) =>
      temp = @get(name)
      if temp != undefined
        temp.item.set = false
        temp.item.value = null
        temp.definition = undefined
      return temp
      
    remove: (current, name) =>
      index = 0
      result = undefined
      for item in current.table
        if item.name == name
          result = item
          break
        index++
      if index < current.table.length
        current.table.splice index, 1
      return result
      
    isInserted: (name) =>
      return undefined != @get name

    isSet: (name) =>
      temp = @get name
      return (temp != undefined) && temp.item.set


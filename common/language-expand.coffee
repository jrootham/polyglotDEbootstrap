
# language-expand

branch = require "./language-branch"
leaf = require "./language-leaf"

make = (id, expanded, maker) ->
  if ! expanded[id]
    result = maker()
    expanded[id] = result
  else
    result = expanded[id]
  return result
  
connect = (id, link, expanded) ->
  factory[link[id].name] id, link, expanded

factory =
  Repeat: (id, link, expanded) ->
    return make id, expanded, ->
      result = new branch.Repeat id, null
      result.argument = connect link[id].argument, link, expanded
      return result

  AndJoin: (id, link, expanded) ->
    return make id, expanded, ->
      result = new branch.AndJoin id, null, null
      result.left = connect link[id].left, link, expanded
      result.right = connect link[id].right, link, expanded
      return result
    
  OrJoin: (id, link, expanded) ->
    return make id, expanded, ->
      result = new branch.OrJoin id, null, null
      result.left = connect link[id].left, link, expanded
      result.right = connect link[id].right, link, expanded
      return result

  Constant: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.Constant id, link[id].value

  Unsigned: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.Unsigned id

  Integer: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.Integer id

  Fixed: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.Fixed id

  Float: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.Float id

  FixedBCD: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.FixedBCD id

  StringType: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.StringType id

  SingleQuotes: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.SingleQuotes id

  DoubleQuotes: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.DoubleQuotes id
      
  Symbol: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.Symbol id, link[id].pattern

  Match: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.Match id, link[id].pattern, link[id].flags

  OptionalWhite: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.OptionalWhite id, link[id].whitespace

  RequiredWhite: (id, link, expanded) ->
    return make id, expanded, ->
      return new leaf.RequiredWhite id, link[id].whitespace

module.exports =
  expand: (list) ->
    link = []
    for item in list
      link[item.linkid] = item
    
    expanded = []
    
#  First item in the list is the root of the graph

    return factory[list[0].name] list[0].linkid, link, expanded
    

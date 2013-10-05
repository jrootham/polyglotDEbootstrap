#
#   test scaffolding
#

module.exports =

#  Test for uniqueness of ids in a graph

  unique: ->
    idList = []
    elementList = []
    
    return (element) ->
      if elementList.indexOf(element) == -1
        elementList.push element
        if idList[element.linkid] != undefined
          throw new Error "Collision " + element.linkid
        else
          idList[element.linkid] = true


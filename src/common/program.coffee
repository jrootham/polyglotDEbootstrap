#
#   Base class for program graph
#

linkable = require "./linkable"

module.exports = class Program extends linkable.Linkable
  constructor: (linkid, @pointer) ->
    super linkid
  


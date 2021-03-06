#
#   language graph classes
#
#   This is a glue file for namespace management

branch = require "./language-branch"
leaf = require "./language-leaf"
expand = require "./language-expand"
special = require "./language-special"
postParse = require "./language-postParse"

module.exports =
  Repeat: branch.Repeat
  AndJoin: branch.AndJoin
  OrJoin: branch.OrJoin
  Constant: leaf.Constant
  Unsigned: leaf.Unsigned
  Integer: leaf.Integer
  Fixed: leaf.Fixed
  Float: leaf.Float
  FixedBCD: leaf.FixedBCD
  StringType: leaf.StringType
  SingleQuotes: leaf.SingleQuotes
  DoubleQuotes: leaf.DoubleQuotes
  Symbol: leaf.Symbol
  Match: leaf.Match
  OptionalWhite: leaf.OptionalWhite
  RequiredWhite: leaf.RequiredWhite
  Production: special.Production

  expand: expand.expand
  
  NewScope: postParse.NewScope
  

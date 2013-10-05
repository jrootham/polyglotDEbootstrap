#
#   Build a parsing tree and confirm its structure
#

should = require("chai").should()

language = require "../bin/language"
linkable = require "../bin/linkable"
scaffold = require "./test.scaffold"

unique = scaffold.unique
next = new linkable.Next 0

describe "Test language graph construction", ->
  
  u = new language.Unsigned next.next()
  i = new language.Integer next.next()
  f = new language.Fixed next.next()
  l = new language.Float next.next()
  b = new language.FixedBCD next.next()
  s = new language.StringType next.next()
  d = new language.DoubleQuotes next.next()
  q = new language.SingleQuotes next.next()
  y = new language.Symbol next.next()
  m = new language.Match next.next(), "[a-z]"
  p = new language.OptionalWhite next.next(), "s"
  r = new language.RequiredWhite next.next(), "n"
  c = new language.Constant next.next(), "foo"
  
  rp = new language.Repeat next.next(), i

  o1 = new language.OrJoin next.next(), u, rp
  o2 = new language.OrJoin next.next(), f, l
  o3 = new language.OrJoin next.next(), b, s
  o4 = new language.OrJoin next.next(), d, q
  o5 = new language.OrJoin next.next(), y, m
  o6 = new language.OrJoin next.next(), p, r
  
  a1 = new language.AndJoin next.next(), c, o1
  a2 = new language.AndJoin next.next(), o2, o3
  a3 = new language.AndJoin next.next(), o4, o5
  a4 = new language.AndJoin next.next(), o6, a1
  
  a5 = new language.AndJoin next.next(), a1, a2
  a6 = new language.AndJoin next.next(), a3, a4
 
  root = new language.AndJoin next.next(), a5, a6
  
  it "root is AndJoin", ->
    root.should.be.an.instanceof language.AndJoin

  it "with left an AndJoin", ->
    left = root.left
    left.should.be.an.instanceof language.AndJoin
    
  it "with left left an AndJoin", ->
    left = root.left
    left = left.left
    left.should.be.an.instanceof language.AndJoin
  
  it "with left left left a Constant", ->
    left = root.left
    left = left.left
    constant = left.left
    constant.should.be.an.instanceof language.Constant
  
  it "with value foo", ->
    left = root.left
    left = left.left
    constant = left.left
    constant.value.should.equal "foo"
  
  it "with left left right an OrJoin", ->
    left = root.left
    left = left.left
    orjoin = left.right
    orjoin.should.be.an.instanceof language.OrJoin
  
  it "with left left right left an Unsigned", ->
    left = root.left
    left = left.left
    orjoin = left.right
    left = orjoin.left
    left.should.be.an.instanceof language.Unsigned
  
  it "with left left right right a Repeat", ->
    left = root.left
    left = left.left
    orjoin = left.right
    right = orjoin.right
    right.should.be.an.instanceof language.Repeat
  
  it "with left left right right argument am Integer", ->
    left = root.left
    left = left.left
    orjoin = left.right
    right = orjoin.right
    argument = right.argument
    argument.should.be.an.instanceof language.Integer
  
  it "with left right left left a Fixed", ->
    left = root.left
    right = left.right
    left = right.left
    left = left.left
    left.should.be.an.instanceof language.Fixed
  
  it "with left right left right a Float", ->
    left = root.left
    right = left.right
    left = right.left
    right = left.right
    right.should.be.an.instanceof language.Float
  
  it "with left right right left a FixedBCD", ->
    left = root.left
    right = left.right
    right = right.right
    left = right.left
    left.should.be.an.instanceof language.FixedBCD
  
  it "with left right right right a StringType", ->
    left = root.left
    right = left.right
    right = right.right
    right = right.right
    right.should.be.an.instanceof language.StringType
  
  it "with right left left left a DoubleQuotes", ->
    right = root.right
    left = right.left
    left = left.left
    left = left.left
    left.should.be.an.instanceof language.DoubleQuotes
  
  it "with right left left right a SingleQuotes", ->
    right = root.right
    left = right.left
    left = left.left
    right = left.right
    right.should.be.an.instanceof language.SingleQuotes
  
  it "with right left right left a Symbol", ->
    right = root.right
    left = right.left
    right = left.right
    left = right.left
    left.should.be.an.instanceof language.Symbol
  
  it "with right left right right a Match", ->
    right = root.right
    left = right.left
    right = left.right
    right = right.right
    right.should.be.an.instanceof language.Match
  
  it "with right right left left an OptionalWhite", ->
    right = root.right
    right = right.right
    left = right.left
    left = left.left
    left.should.be.an.instanceof language.OptionalWhite
  
  it "with right right left right a RequiredWhite", ->
    right = root.right
    right = right.right
    left = right.left
    right = left.right
    right.should.be.an.instanceof language.RequiredWhite
  
  it "The graph elements should have unique ids (throws if not)", ->
    root.preorder unique()
    

#
#   Build a parsing tree and confirm its structure
#

should = require("chai").should()

language = require "../bin/language"
linkable = require "../bin/linkable"
scaffold = require "./test.scaffold"

unique = scaffold.unique
next = new linkable.Next 1

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
  u.addUp o1
  rp.addUp o1
  
  o2 = new language.OrJoin next.next(), f, l
  f.addUp o2
  l.addUp o2
  
  o3 = new language.OrJoin next.next(), b, s
  b.addUp o3
  s.addUp o3
  
  o4 = new language.OrJoin next.next(), d, q
  d.addUp o4
  q.addUp o4
  
  o5 = new language.OrJoin next.next(), y, m
  y.addUp o5
  m.addUp o5

  o6 = new language.OrJoin next.next(), p, r
  p.addUp o6
  r.addUp o6
  
  a1 = new language.AndJoin next.next(), c, o1
  c.addUp a1
  o1.addUp a1
  
  a2 = new language.AndJoin next.next(), o2, o3
  o2.addUp a2
  o3.addUp a2
  
  a3 = new language.AndJoin next.next(), o4, o5
  o4.addUp a3
  o5.addUp a3

  a4 = new language.AndJoin next.next(), o6, a1
  o6.addUp a4
  a1.addUp a4
  
  a5 = new language.AndJoin next.next(), a1, a2
  a1.addUp a5
  a2.addUp a5
  
  a6 = new language.AndJoin next.next(), a3, a4
  a3.addUp a6
  a4.addUp a6
 
  root = new language.AndJoin next.next(), a5, a6
  a5.addUp root
  a6.addUp root
  
  it "root is AndJoin", ->
    root.should.be.an.instanceof language.AndJoin

  it "with left an AndJoin", ->
    left = root.left
    left.should.be.an.instanceof language.AndJoin
    
  it "with left.up root", ->
    up = root.left.up
    up.should.contain root

  it "with left left an AndJoin", ->
    left = root.left.left
    left.should.be.an.instanceof language.AndJoin
  
  it "with left left left a Constant", ->
    constant = root.left.left.left
    constant.should.be.an.instanceof language.Constant
  
  it "with value foo", ->
    constant = root.left.left.left
    constant.value.should.equal "foo"
  
  it "with left left right an OrJoin", ->
    orjoin = root.left.left.right
    orjoin.should.be.an.instanceof language.OrJoin
  
  it "with left left right left an Unsigned", ->
    unsigned = root.left.left.right.left
    unsigned.should.be.an.instanceof language.Unsigned
  
  it "with left left right right a Repeat", ->
    repeat = root.left.left.right.right
    repeat.should.be.an.instanceof language.Repeat
  
  it "with left left right right argument am Integer", ->
    integer = root.left.left.right.right.argument
    integer.should.be.an.instanceof language.Integer
  
  it "with left right left left a Fixed", ->
    fixed = root.left.right.left.left
    fixed.should.be.an.instanceof language.Fixed
  
  it "with left right left right a Float", ->
    float = root.left.right.left.right
    float.should.be.an.instanceof language.Float
  
  it "with left right right left a FixedBCD", ->
    fixedBCD = root.left.right.right.left
    fixedBCD.should.be.an.instanceof language.FixedBCD
  
  it "with left right right right a StringType", ->
    stringType = root.left.right.right.right
    stringType.should.be.an.instanceof language.StringType
  
  it "with right left left left a DoubleQuotes", ->
    double = root.right.left.left.left
    double.should.be.an.instanceof language.DoubleQuotes
  
  it "with right left left right a SingleQuotes", ->
    single = root.right.left.left.right
    single.should.be.an.instanceof language.SingleQuotes
  
  it "with right left right left a Symbol", ->
    symbol = root.right.left.right.left
    symbol.should.be.an.instanceof language.Symbol
  
  it "with right left right right a Match", ->
    match = root.right.left.right.right
    match.should.be.an.instanceof language.Match
  
  it "with right right left left an OptionalWhite", ->
    optional = root.right.right.left.left
    optional.should.be.an.instanceof language.OptionalWhite
  
  it "with right right left right a RequiredWhite", ->
    required = root.right.right.left.right
    required.should.be.an.instanceof language.RequiredWhite
  
  it "The graph elements should have unique ids (throws if not)", ->
    root.preorder unique()
    

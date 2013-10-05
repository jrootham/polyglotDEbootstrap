#
#   Build a parsing graph and parse input
#    validate the resulting graph
#

should = require("chai").should()

Source = require "../bin/source"
language = require "../bin/language"
linkable = require "../bin/linkable"
scaffold = require "./test.scaffold"

unique = scaffold.unique

next = new linkable.Next 1
dynext = new linkable.Next 1
otherNext = new linkable.Next 1

parseStack = []

u = new language.Unsigned next.next()
rw1 = new language.RequiredWhite next.next(), "s"
a1 = new language.AndJoin next.next(), u, rw1

i = new language.Integer next.next()
rw2 = new language.RequiredWhite next.next(), "s"
a2 = new language.AndJoin next.next(), i, rw2

f = new language.Fixed next.next()
rw3 = new language.RequiredWhite next.next(), "s"
a3 = new language.AndJoin next.next(), f, rw3

l = new language.Float next.next()
rw4 = new language.RequiredWhite next.next(), "s"
a4 = new language.AndJoin next.next(), l, rw4

b = new language.FixedBCD next.next()
rw5 = new language.RequiredWhite next.next(), "s"
a5 = new language.AndJoin next.next(), b, rw5

c = new language.Constant next.next(), "foo"
p = new language.OptionalWhite next.next(), ""
a6 = new language.AndJoin next.next(), c, p

y = new language.Symbol next.next()
rw7 = new language.RequiredWhite next.next(), "s"
a7 = new language.AndJoin next.next(), y, rw7

m = new language.Match next.next(), "[a-z]", ""
s = new language.StringType next.next()
a8 = new language.AndJoin next.next(), m, s
t1 = new language.Constant next.next(), "\nfoo"
a8p1 = new language.AndJoin next.next(), a8, t1

d = new language.DoubleQuotes next.next()
q = new language.SingleQuotes next.next()
a9 = new language.AndJoin next.next(), d, q

a11 = new language.AndJoin next.next(), a1, a2
a12 = new language.AndJoin next.next(), a3, a4
a13 = new language.AndJoin next.next(), a5, a6
a14 = new language.AndJoin next.next(), a7, a8p1

o1 = new language.OrJoin next.next(), a11, a12
o2 = new language.OrJoin next.next(), a13, a14

o3 = new language.OrJoin next.next(), o1, o2
o4 = new language.OrJoin next.next(), o3, a9

root = new language.Repeat next.next(), o4

text = "123 -345 67.89 1.23e5 54.33 foo thing_1 "
text += "abcdef\nfoo\"a string\"'another string'"

source = new Source text
original = root.parse dynext, source, parseStack

flat = new linkable.Flat()
root.flatten flat
list = flat.list

other = language.expand list

source = new Source text
copy = other.parse otherNext, source, parseStack

test = (name, parsed) ->
  describe "Test graph construction " + name, ->

    it "The graph should be complete", ->
      parsed.isComplete().should.equal true
      
    it "the ids should be unique (throws if not)", ->
      parsed.preorder unique()
    
    it "there should be 5 items in the list", ->
      parsed.list.length.should.equal 5
    
    describe "the first", ->
      it "leftmost should be Unsigned", ->
        name = parsed.list[0].argument.argument.argument.left.left.name
        name.should.equal "Unsigned"
        
      it "leftmost value 123", ->
        value = parsed.list[0].argument.argument.argument.left.left.value
        value.should.equal 123
        
      it "the next item is RequiredWhite", ->
        name = parsed.list[0].argument.argument.argument.left.right.name
        name.should.equal "RequiredWhite"
        
      it "after leftmost the insertion characters s", ->
        pointer = parsed.list[0].argument.argument.argument.left.right.pointer
        pointer.whitespace.should.equal "s"
        
      it "rightmost should be Integer", ->
        name = parsed.list[0].argument.argument.argument.right.left.name
        name.should.equal "Integer"
        
      it "rightmost value -345", ->
        value = parsed.list[0].argument.argument.argument.right.left.value
        value.should.equal -345

    describe "the second", ->
      debugger
      it "leftmost should be Fixed", ->
        name = parsed.list[1].argument.argument.argument.left.left.name
        name.should.equal "Fixed"
        
      it "leftmost value 67.89", ->
        value = parsed.list[1].argument.argument.argument.left.left.value
        value.should.equal 67.89
        
      it "rightmost should be Float", ->
        name = parsed.list[1].argument.argument.argument.right.left.name
        name.should.equal "Float"
        
      it "rightmost value 123000", ->
        value = parsed.list[1].argument.argument.argument.right.left.value
        value.should.equal 123000

    describe "the third", ->
      it "leftmost should be FixedBCD", ->
        name = parsed.list[2].argument.argument.argument.left.left.name
        name.should.equal "FixedBCD"
        
      it "leftmost value 54,33", ->
        value = parsed.list[2].argument.argument.argument.left.left.value
        value.should.equal 54.33
        
      it "the third rightmost should be Constant", ->
        name = parsed.list[2].argument.argument.argument.right.left.name
        name.should.equal "Constant"
        
      it "rightmost value foo", ->
        pointer = parsed.list[2].argument.argument.argument.right.left.pointer
        pointer.value.should.equal "foo"

      it "trailing item is OptionalWhite", ->
        name = parsed.list[2].argument.argument.argument.right.right.name
        name.should.equal "OptionalWhite"
        
      it "trailing item insertion characters none", ->
        pointer = parsed.list[2].argument.argument.argument.right.right.pointer
        pointer.whitespace.should.equal ""

    describe "the fourth", ->
      it "the fourth leftmost should be Symbol", ->
        name = parsed.list[3].argument.argument.argument.left.left.name
        name.should.equal "Symbol"
        
      it "leftmost value thing_1", ->
        value = parsed.list[3].argument.argument.argument.left.left.value
        value.should.equal "thing_1"
        
      it "middle should be Match", ->
        name = parsed.list[3].argument.argument.argument.right.left.left.name
        name.should.equal "Match"
        
      it "middle value a", ->
        value = parsed.list[3].argument.argument.argument.right.left.left.value
        value.should.equal "a"

      it "rightmost should be StringType", ->
        name = parsed.list[3].argument.argument.argument.right.left.right.name
        name.should.equal "StringType"
        
      it "rightmost value bcdef", ->
        value = parsed.list[3].argument.argument.argument.right.left.right.value
        value.should.equal "bcdef"

    describe "the fifth", ->
      it "leftmost should be DoubleQuote", ->
        parsed.list[4].argument.left.name.should.equal "DoubleQuotes"
        
      it "leftmost value thing_1", ->
        parsed.list[4].argument.left.value.should.equal "a string"

      it "rightmost should be SingleQuotes", ->
        name = parsed.list[4].argument.right.name
        name.should.equal "SingleQuotes"
        
      it "rightmost value bcdef", ->
        parsed.list[4].argument.right.value.should.equal "another string"

test "original", original
test "copy", copy


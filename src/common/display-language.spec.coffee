#  Test display language graph

should = require("chai").should()

language = require "../bin/language"
linkable = require "../bin/linkable"

describe "language display", ->
  it "Constant", ->
    next = new linkable.Next(1)
    item = new language.Constant next.next(), "foo"
    display = item.displayGraph [], ""
    display.should.equal "1=Constant foo\n"

  it "Unsigned", ->
    next = new linkable.Next(1)
    item = new language.Unsigned next.next()
    display = item.displayGraph [], ""
    display.should.equal "1=Unsigned\n"

  it "Integer", ->
    next = new linkable.Next(1)
    item = new language.Integer next.next()
    display = item.displayGraph [], ""
    display.should.equal "1=Integer\n"

  it "Fixed", ->
    next = new linkable.Next(1)
    item = new language.Fixed next.next()
    display = item.displayGraph [], ""
    display.should.equal "1=Fixed\n"

  it "Float", ->
    next = new linkable.Next(1)
    item = new language.Float next.next()
    display = item.displayGraph [], ""
    display.should.equal "1=Float\n"

  it "FixedBCD", ->
    next = new linkable.Next(1)
    item = new language.FixedBCD next.next()
    display = item.displayGraph [], ""
    display.should.equal "1=FixedBCD\n"

  it "StringType", ->
    next = new linkable.Next(1)
    item = new language.StringType next.next()
    display = item.displayGraph [], ""
    display.should.equal "1=StringType\n"

  it "SingleQuotes", ->
    next = new linkable.Next(1)
    item = new language.SingleQuotes next.next()
    display = item.displayGraph [], ""
    display.should.equal "1=SingleQuotes\n"

  it "DoubleQuotes", ->
    next = new linkable.Next(1)
    item = new language.DoubleQuotes next.next()
    display = item.displayGraph [], ""
    display.should.equal "1=DoubleQuotes\n"

  it "Symbol", ->
    next = new linkable.Next(1)
    item = new language.Symbol next.next()
    display = item.displayGraph [], ""
    display.should.equal "1=Symbol:([A-Z]|[a-z]|_)([A-Z]|[a-z]|[0-9]|_)*:\n"

  it "Match", ->
    next = new linkable.Next(1)
    item = new language.Match next.next(), "[a-z]", "g"
    display = item.displayGraph [], ""
    display.should.equal "1=Match:[a-z] g\n"

  it "OptionalWhite", ->
    next = new linkable.Next(1)
    item = new language.OptionalWhite next.next(), "s"
    display = item.displayGraph [], ""
    display.should.equal "1=OptionalWhite:\\s*:s:\n"

  it "RequiredWhite", ->
    next = new linkable.Next(1)
    item = new language.RequiredWhite next.next(), "+"
    display = item.displayGraph [], ""
    display.should.equal "1=RequiredWhite:\\s*:+:\n"

  describe "Repeat", ->
    it "null", ->
      next = new linkable.Next(1)
      item = new language.Repeat next.next(), null
      display = item.displayGraph [], ""
      display.should.equal "1=Repeat\n  argument is null\n"

    it "not null", ->
      next = new linkable.Next(1)
      thing = new language.Constant next.next(), "foo"
      item = new language.Repeat next.next(), thing
      display = item.displayGraph [], ""
      display.should.equal "2=Repeat\n  1=Constant foo\n"

  describe "AndJoin", ->
    it "both null", ->
      next = new linkable.Next(1)
      item = new language.AndJoin next.next(), null, null
      display = item.displayGraph [], ""
      display.should.equal "1=AndJoin\n  left is null\n  right is null\n"

    it "left null", ->
      next = new linkable.Next(1)
      thing = new language.Constant next.next(), "foo"
      item = new language.AndJoin next.next(), null, thing
      display = item.displayGraph [], ""
      display.should.equal "2=AndJoin\n  left is null\n  1=Constant foo\n"

    it "right null", ->
      next = new linkable.Next(1)
      thing = new language.Constant next.next(), "foo"
      item = new language.AndJoin next.next(), thing, null
      display = item.displayGraph [], ""
      display.should.equal "2=AndJoin\n  1=Constant foo\n  right is null\n"

    it "neither null", ->
      next = new linkable.Next(1)
      thing = new language.Constant next.next(), "foo"
      item = new language.AndJoin next.next(), thing, thing
      display = item.displayGraph [], ""
      display.should.equal "2=AndJoin\n  1=Constant foo\n  1=Constant...\n"

  it "OrJoin", ->
    next = new linkable.Next(1)
    item = new language.OrJoin next.next(), null, null
    display = item.displayGraph [], ""
    display.should.equal "1=OrJoin\n  left is null\n  right is null\n"

  describe "Production", ->
    it "all filled", ->
      next = new linkable.Next(1)
      a = new language.Symbol next.next()
      e = new language.Constant next.next(), "foo"
      p = new language.Constant next.next(), "^"
      g = new language.Constant next.next(), "=>"
      item = new language.Production next.next(), a, e, p, g
      a.addUp item
      e.addUp item
      p.addUp item
      g.addUp item
      display = item.displayGraph [], ""
      text = "5=Production\n  1=Symbol:([A-Z]|[a-z]|_)([A-Z]|[a-z]|[0-9]|_)*:\n"
      text+= "  2=Constant foo\n  3=Constant ^\n  4=Constant =>\n"
      display.should.equal text
      
    it "All null", ->
      next = new linkable.Next(1)
      item = new language.Production next.next(), null, null, null, null
      display = item.displayGraph [], ""
      text = "1=Production\n  assign is null\n  expression is null\n"
      text+= "  parseTime is null\n  generate is null\n"
      display.should.equal text
      


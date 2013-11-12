# tests for Scope

should = require("chai").should()

Source = require "../bin/source"
linkable = require "../bin/linkable"
language = require "../bin/language"
program = require "../bin/program"
upDown = require "./up-down.scaffold"

upDown.connectLinkable linkable
upDown.connectLanguage language
upDown.connectProgram program

next = new linkable.Next 1

describe "Testing Scope object", ->
  it "new table should be empty", ->
    table = new program.Scope next.next(), null
    Object.keys(table.table).length.should.equal 0
    
  it "new table should not contain a symbol", ->
    table = new program.Scope next.next(), null
    table.isInserted("foo").should.equal false
    
  it "inserted symbol should be inserted", ->
    table = new program.Scope next.next(), null
    table.insert "foo"
    table.isInserted("foo").should.equal true
    
  it "inserted symbol should not be set", ->
    table = new program.Scope next.next(), null
    table.insert "foo"
    table.isSet("foo").should.be.false
    
  it "set symbol should be set", ->
    table = new program.Scope next.next(), null
    table.set "foo", 1
    table.isSet("foo").should.be.true
    
  it "set symbol should have a value", ->
    table = new program.Scope next.next(), null
    table.set "foo", 1
    table.get("foo").item.value.should.equal 1

  it "unset symbol should not be set", ->
    table = new program.Scope next.next(), null
    table.set "foo", 1
    table.get("foo").item.value.should.equal 1
    table.unset "foo"
    table.isInserted("foo").should.be.true
    table.isSet("foo").should.be.false
  
  it "removed symbol should not be inserted", ->
    table = new program.Scope next.next(), null
    table.insert "foo"
    table.isInserted("foo").should.be.true
    table.remove table, "foo"
    table.isInserted("foo").should.be.false
    
  it "symbol set in outer scope should have a value from inner scope", ->
    outer = new program.Scope next.next(), null
    inner = new program.Scope next.next(), outer
    outer.set "foo", 1
    inner.get("foo").item.value.should.equal 1
    inner.get("foo").scope.should.equal outer

describe "simple scope set", ->
  source = new Source "name := foo =>"
  languageNext = new linkable.Next(1)
  programNext = new linkable.Next(1)
  
  symbol = new language.Symbol languageNext.next()
  white = new language.OptionalWhite languageNext.next(), "s"
  noWhite = new language.OptionalWhite languageNext.next(), ""
  constant = new language.Constant languageNext.next(), "foo"
  pt = new language.Constant languageNext.next(), "^"
  gen = new language.Constant languageNext.next(), "=>"

  a1 = new language.AndJoin languageNext.next(), noWhite, symbol
  noWhite.addUp a1
  symbol.addUp a1
  
  a2 = new language.AndJoin languageNext.next(), a1, white
  a1.addUp a2
  white.addUp a2
  
  a3 = new language.AndJoin languageNext.next(), white, constant
  white.addUp a3
  constant.addUp a3

  assign = new language.Production languageNext.next(), a2, a3, pt, gen
  a2.addUp assign
  a3.addUp assign
  pt.addUp assign
  gen.addUp assign
  
  assign.preorder (item) -> item.reached = -1
  
  scope =
    current: new program.Scope programNext.next(), null
  
  debugger
  
  root = assign.parseFn programNext, source, [], scope
  
  describe "check up links", ->
    it "for language", ->
      assign.checkDown().should.be.true
      
    it "for program", ->
      root.checkDown().should.be.true

###
  describe "name should point at right parse graph", ->
    it "should point at a constant", ->
      graph = table.get("name")
      graph.name.should.equal "Production"
      graph.expression.name.should.equal "AndJoin"
      graph.expression.left.name.should.equal "OptionalWhite"
      graph.expression.right.name.should.equal "Constant"
      graph.expression.right.pointer.value.should.equal "foo"
###


# tests for SymbolTable

should = require("chai").should()

Source = require "../bin/source"
linkable = require "../bin/linkable"
language = require "../bin/language"
program = require "../bin/program"
SymbolTable = require "../bin/symbol-table"
upDown = require "./up-down.scaffold"

upDown.connect linkable, language, program

describe "Testing symbol table object", ->
  it "new table should be empty", ->
    table = new SymbolTable()
    Object.keys(table.table).length.should.equal 0
    
  it "new table should not contain a symbol", ->
    table = new SymbolTable()
    table.isInserted("foo").should.equal false
    
  it "inserted symbol should be inserted", ->
    table = new SymbolTable()
    table.insert "foo"
    table.isInserted("foo").should.equal true
    
  it "inserted symbol should not be set", ->
    table = new SymbolTable()
    table.insert "foo"
    table.isSet("foo").should.be.false
    
  it "set symbol should be set", ->
    table = new SymbolTable()
    table.set "foo", 1
    table.isSet("foo").should.be.true
    
  it "set symbol should be set", ->
    table = new SymbolTable()
    table.set "foo", 1
    table.get("foo").should.equal 1

describe "simple symbol table set", ->
  source = new Source "name := foo"
  
  table = new SymbolTable()
  
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
  
  root = assign.parse programNext, source, [], table
  
  describe "check up links", ->
    it "for language", ->
      assign.checkDown().should.be.true
      
    it "for program", ->
      root.checkDown().should.be.true

  describe "name should point at right parse graph", ->
    it "should point at a constant", ->
      graph = table.get("name")
      graph.name.should.equal "Production"
      graph.graph.name.should.equal "AndJoin"
      graph.graph.left.name.should.equal "OptionalWhite"
      graph.graph.right.name.should.equal "Constant"
      graph.graph.right.pointer.value.should.equal "foo"
      

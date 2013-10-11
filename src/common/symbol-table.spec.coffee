# tests for SymbolTable

should = require("chai").should()

SymbolTable = require "../bin/symbol-table"

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


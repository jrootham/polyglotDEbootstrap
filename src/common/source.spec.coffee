# tests for Source

should = require("chai").should()

Source = require "../bin/source"

describe "Testing source object", ->
  describe "Simple starting tests", ->
    source = new Source "foobar"
    
    describe "should start at the beginning", ->

      it "line should not move", ->
        {line, column} = source.getLocation()
        line.should.equal 1

      it "column should not move", ->
        {line, column} = source.getLocation()
        column.should.equal 1
      
  describe "Simple next tests", ->
    source = new Source "foobar"

    it "should succeed in getting starting string", ->
      source.next("foo").should.equal true
    
    it "should skip starting string ", ->
      source.next("foo").should.equal false
    
    it "should fail in getting a too long string", ->
      source.next("baroo").should.equal false
    
    it "should succeed in getting next string", ->
      source.next("bar").should.equal true
    

  describe "Simple moving tests", ->
    source = new Source "foobar"
    source.next "foo"
    {line, column} = source.getLocation()
      
    it "line should not move", ->
      line.should.equal 1
      
    it "column should move", ->
      column.should.equal 4
    
  describe "should not move on fail", ->
    source = new Source "foobar"
    source.next "foo"
    source.next "foo"
    {line, column} = source.getLocation()
      
    it "line should not move", ->
      line.should.equal 1
      
    it "column should not move", ->
      column.should.equal 4
    
  describe "Simple match tests", ->
    source = new Source "foobar"

    describe "should succeed in getting starting string", ->
      match = source.match("f[a-z]o")
      it "should return the matched string", ->
        match.should.equal "foo"

      {line, column} = source.getLocation()
      
      it "line should not move", ->
        line.should.equal 1
      it "column should move", ->
        column.should.equal 4
    
  describe "Moving match tests", ->
    source = new Source "foobar"
    match = source.match("f[a-z]o")

    describe "should move past starting string", ->
      it "should skip starting string ", ->
        match = source.match("f[a-z]o")
        should.equal match, null
      
    describe "should move past starting string", ->
      {line, column} = source.getLocation()
      it "line should not move", ->
        line.should.equal 1
      it "column should not move", ->
        column.should.equal 4
    
  describe "More moving match tests", ->
    source = new Source "foobar"
    match = source.match("f[a-z]o")

    describe "should succeed in getting next string", ->
      match = source.match("ba[a-z]")
      it "should return the matched string", ->
        match.should.equal "bar"

    describe "should move past starting string", ->
      {line, column} = source.getLocation()
      
      it "line should not move", ->
        line.should.equal 1
      
      it "column should move", ->
        column.should.equal 7

  describe "Save/restore tests", ->
    source = new Source "foobar"
    source.save()
    match = source.next "foo"
    source.restore()
    
    {line, column} = source.getLocation()
    
    it "line should not move", ->
      line.should.equal 1
    
    it "column should revert", ->
      column.should.equal 1
      
  describe "Counting lines tests", ->
    source = new Source "foo\nbar\n\nhoowawdiddy\nthe end"
    match = source.next "foo\nbar"
    
    describe "getting first", ->
      {line, column} = source.getLocation()
      
      it "line should move", ->
        line.should.equal 2
      
      it "column should move", ->
        column.should.equal 4

    match = source.match "\\s*"
    
    describe "getting second", ->
      {line, column} = source.getLocation()
      
      it "line should move", ->
        line.should.equal 4
      
      it "column should move", ->
        column.should.equal 1
          
    match = source.match "\\w*"
    
    describe "getting third", ->
      {line, column} = source.getLocation()
      
      it "line should move", ->
        line.should.equal 4
      
      it "column should move", ->
        column.should.equal 12
          
    match = source.match "\\sthe"
    
    describe "getting fourth", ->
      {line, column} = source.getLocation()
      
      it "line should move", ->
        line.should.equal 5
      
      it "column should move", ->
        column.should.equal 4
        
  describe "Matching with flags", ->
    source = new Source "FOOBAR"
    match = source.match "foo", "i"

    it "Should find a match", ->
      match.should.equal "FOO"
      
  describe "Restore should remove a save", ->
    source = new Source "FOOBAR"
    source.save()
    match = source.match "foo", "i"
    source.save()
    match = source.match "bar", "i"
    source.commit()
    source.restore()

    {line, column} = source.getLocation()
    
    describe "getting saved state", ->
      {line, column} = source.getLocation()
      it "line should not move", ->
        line.should.equal 1
      
      it "column should not move", ->
        column.should.equal 1
       
  describe "find a newline terminated string", ->
    source = new Source "foo bar\nhoo foo\nthe end"
    first = source.toEOL()
    second = source.toEOL()
    skip = source.next "\n"
    third = source.toEOL()
    skip = source.next "\n"
    fourth = source.toEOL()
    
    it "first should match" , ->
      first.should.equal "foo bar"
    
    it "second should be empty", ->
      second.should.equal ""
      
    it "third should match", ->
      third.should.equal "hoo foo"
      
    it "fourth should match", ->
      fourth.should.equal "the end"
      
  describe "parse double quotes", ->
    source = new Source '"foo\\\""'
    first = source.doubleQuotes()
    
    it "first should match", ->
      first.should.equal "foo\""
      
  describe "parse double quotes with escapes", ->
    source = new Source '"\\b\\t\\n\\t\\r\\v"'
    first = source.doubleQuotes()
    
    it "first should match", ->
      first.should.equal "\b\t\n\t\r\v"

  describe "parse double quotes with octal escape 304", ->
    source = new Source '"\\304 "'
    first = source.doubleQuotes()
    
    it "first should match", ->
      first.should.equal "\xc4 "

  describe "parse double quotes with octal escape 377", ->
    source = new Source '"\\377 "'
    first = source.doubleQuotes()
    
    it "first should match", ->
      first.should.equal "\xff "

  describe "parse double quotes with octal escapes 77", ->
    source = new Source '"\\77 "'
    first = source.doubleQuotes()
    
    it "first should match", ->
      first.should.equal "\x3f "

  describe "parse double quotes with octal escape 7", ->
    source = new Source '"\\7"'
    first = source.doubleQuotes()
    
    it "first should match", ->
      first.should.equal "\x07"

  describe "parse double quotes with hex escapes", ->
    source = new Source '"\\xe8\\xE8\\x8"'
    first = source.doubleQuotes()
    
    it "first should match", ->
      first.should.equal "\xe8\xe8\x08"

  describe "parse double quotes with unicode escapes", ->
    source = new Source '"\\ue800\\uE80\\uE8\\u8"'
    first = source.doubleQuotes()
    
    it "first should match", ->
      first.should.equal "\ue800\u0e80\u00e8\u0008"

  describe "fail double quotes", ->
    source = new Source "'foo'"
    first = source.doubleQuotes()
    
    it "first should fail", ->
      should.equal first, null

  describe "parse single quotes", ->
    source = new Source "'foo'"
    first = source.singleQuotes()
    
    it "first should match", ->
      first.should.equal "foo"

###
  describe "quote parse errors", ->
    describe "mismatched quotes", ->
      source = new Source "'foo\n"
      should.throw source.singleQuotes(), Error

  describe "quote parse errors", ->
    describe "mismatched quotes", ->
      source = new Source "'foo"
      should.throw source.singleQuotes(), Error
###



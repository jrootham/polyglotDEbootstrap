#
#  test parsing classes
#

should = require("chai").should()

language = require "../bin/language"
Source = require "../bin/source"
linkable = require "../bin/linkable"

next = new linkable.Next 1
dyNext = new linkable.Next 1
parseStack = []

describe "Test parsing classes", ->
  describe "Test Constant", ->
    source = new Source "foobar"
    parser = new language.Constant next.next(), "foo"
    
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "second should be null", ->
      should.equal second, null
      
  describe "Test Unsigned", ->
    source = new Source "123bar-345"
    parser = new language.Unsigned next.next()
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "first value should be 123", ->
      first.value.should.equal 123
      
    it "second should be null", ->
      should.equal second, null
      
  describe "Test Integer", ->
    source = new Source "123bar-345"
    parser = new language.Integer next.next()
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    other = new language.Constant next.next(), "bar"
    other.parse dyNext, source, parseStack
    third = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "first value should be 123", ->
      first.value.should.equal 123
      
    it "second should be null", ->
      should.equal second, null

    it "third value should be -345", ->
      third.value.should.equal -345
          
  describe "Test Fixed", ->
    source = new Source "123.34bar-345.bar567"
    parser = new language.Fixed next.next()
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    other = new language.Constant next.next(), "bar"
    other.parse dyNext, source, parseStack
    third = parser.parse dyNext, source, parseStack
    other.parse dyNext, source, parseStack
    fourth = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "first value should be 123.34", ->
      first.value.should.equal 123.34
      
    it "second should be null", ->
      should.equal second, null

    it "third value should be -345", ->
      third.value.should.equal -345
      
    it "fourth value should be 567", ->
      fourth.value.should.equal 567
      
  describe "Test FixedBCD", ->
    source = new Source "123.34bar-345.bar567"
    parser = new language.FixedBCD next.next()
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    other = new language.Constant next.next(), "bar"
    other.parse dyNext, source, parseStack
    third = parser.parse dyNext, source, parseStack
    other.parse dyNext, source, parseStack
    fourth = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "first value should be 123.34", ->
      first.value.should.equal 123.34
      
    it "second should be null", ->
      should.equal second, null

    it "third value should be -345", ->
      third.value.should.equal -345
      
    it "fourth value should be 567", ->
      fourth.value.should.equal 567
      
  describe "Test Float", ->
    source = new Source "123.34e2b-345.b567b7.8E-2"
    parser = new language.Float next.next()
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    other = new language.Constant next.next(), "b"
    other.parse dyNext, source, parseStack
    third = parser.parse dyNext, source, parseStack
    other.parse dyNext, source, parseStack
    fourth = parser.parse dyNext, source, parseStack
    other.parse dyNext, source, parseStack
    fifth = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "normal format", ->
      first.value.should.equal 12334
      
    it "not a number", ->
      should.equal second, null

    it "negative with trailing decimal", ->
      third.value.should.equal -345
      
    it "no trailing decimal", ->
      fourth.value.should.equal 567
      
    it "capital E negative exponent", ->
      fifth.value.should.equal 0.078

  describe "Test Match", ->
    source = new Source "foobar"
    parser = new language.Match next.next(), "f[a-z]o"
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "matched", ->
      first.value.should.equal "foo"
      
    it "mismatch", ->
      should.equal second, null

  describe "Test newline terminated string", ->
    source = new Source "foobar\nbarfoo"
    parser = new language.StringType next.next()
    skip = new language.Constant  next.next(),"\n"
    first = parser.parse dyNext, source, parseStack
    skip.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "matched", ->
      first.value.should.equal "foobar"
      
    it "mismatch", ->
      second.value.should.equal "barfoo"

  describe "Test single quotes", ->
    source = new Source "'foobar'a"
    parser = new language.SingleQuotes next.next()
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "matched", ->
      first.value.should.equal "foobar"

    it "mismatch", ->
      should.equal second, null

  describe "Test double quotes", ->
    source = new Source '"foobar"a'
    parser = new language.DoubleQuotes next.next()
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "matched", ->
      first.value.should.equal "foobar"

    it "mismatch", ->
      should.equal second, null

  describe "Test optional white", ->
    source = new Source 'f \v\t\r\na'
    parser = new language.OptionalWhite next.next(), "s"
    first = parser.parse dyNext, source, parseStack
    skip = new language.Constant next.next(), "f"
    skipped = skip.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    match = new language.Constant next.next(), "a"
    matched = match.parse dyNext, source, parseStack
        
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "skipped should be complete", ->
      skipped.isComplete().should.be.true

    it "second should be complete", ->
      second.isComplete().should.be.true
      
    it "second should point at the parser", ->
      second.pointer.should.equal parser

    it "matched should be complete", ->
      matched.isComplete().should.be.true

  describe "Test required white", ->
    source = new Source ' f\nb'
    parser = new language.RequiredWhite  next.next(), 'n'
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    skip = new language.Constant next.next(), "f"
    skipped = skip.parse dyNext, source, parseStack
    third = parser.parse dyNext, source, parseStack
    skip2 = new language.Constant next.next(), "b"
    skipped2 = skip2.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "mismatch", ->
      should.equal second, null

    it "skipped should be complete", ->
      skipped.isComplete().should.be.true
      
    it "third should be complete", ->
      third.isComplete().should.be.true

    it "skipped2 should be complete", ->
      skipped2.isComplete().should.be.true

  describe "Test symbol", ->
    source = new Source 'foobar_42a _FB22 98'
    parser = new language.Symbol next.next()
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    skip = new language.RequiredWhite next.next(), 's'
    skip1 = skip.parse dyNext, source, parseStack
    third = parser.parse dyNext, source, parseStack
    skip2 = skip.parse dyNext, source, parseStack
    fourth = parser.parse dyNext, source, parseStack
        
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser

    it "matched opening alpha", ->
      first.value.should.equal "foobar_42a"

    it "blank mismatch", ->
      should.equal second, null

    it "matched opening _", ->
      third.value.should.equal "_FB22"

    it "leading digit mismatch", ->
      should.equal fourth, null
      
  describe "Test AndJoin", ->
    source = new Source "foobarbarfoofoobar"
    foo = new language.Constant next.next(), "foo"
    bar = new language.Constant next.next(), "bar"
    parser = new language.AndJoin next.next(), foo, bar
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    skip = bar.parse dyNext, source, parseStack
    third = parser.parse dyNext, source, parseStack
    skip = foo.parse dyNext, source, parseStack
    fourth = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser
    
    it "first left should point at the left expression", ->
      first.left.pointer.should.equal foo

    it "first right should point at the right expression", ->
      first.right.pointer.should.equal bar
   
    it "left mismatch should fail", ->
      should.equal second, null
      
    it "right mismatch should fail", ->
      should.equal third, null
      
    it "fourth should be complete", ->
      fourth.isComplete().should.be.true

  describe "Test OrJoin", ->
    source = new Source "foobarafoo"
    foo = new language.Constant next.next(), "foo"
    bar = new language.Constant next.next(), "bar"
    a = new language.Constant next.next(), "a"
    parser = new language.OrJoin next.next(), foo, bar
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    third = parser.parse dyNext, source, parseStack
    skip = a.parse dyNext, source, parseStack
    fourth = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser
    
    it "first argument should point at the foo expression", ->
      first.argument.pointer.should.equal foo

    it "second should be complete", ->
      second.isComplete().should.be.true
            
    it "second argument should point at the bar expression", ->
      second.argument.pointer.should.equal bar

    it "mismatch should fail", ->
      should.equal third, null
      
    it "fourth should be complete", ->
      fourth.isComplete().should.be.true

    it "fourth argument should point at the foo expression", ->
      fourth.argument.pointer.should.equal foo

  describe "Test Repeat", ->
    source = new Source "foofoobarfoo"
    foo = new language.Constant next.next(), "foo"
    bar = new language.Constant next.next(), "bar"
    parser = new language.Repeat next.next(), foo
    first = parser.parse dyNext, source, parseStack
    second = parser.parse dyNext, source, parseStack
    skip = bar.parse dyNext, source, parseStack
    third = parser.parse dyNext, source, parseStack
    fourth = parser.parse dyNext, source, parseStack
    
    it "first should be complete", ->
      first.isComplete().should.be.true
      
    it "first should point at the parser", ->
      first.pointer.should.equal parser
    
    it "first list should be 2 long", ->
      first.list.length.should.equal 2

    it "first list[0] should be foo", ->
      first.list[0].pointer.should.equal foo
   
    it "first list[1] should be foo", ->
      first.list[1].pointer.should.equal foo
   
    it "mismatch should be complete", ->
      second.isComplete().should.be.true

    it "mismatch should make 0 length list", ->
      second.list.length.should.equal 0
      
    it "third list should be 1 long", ->
      third.list.length.should.equal 1

    it "third list[0] should be foo", ->
      third.list[0].pointer.should.equal foo
      
    it "mismatch should make 0 length list", ->
      fourth.list.length.should.equal 0
      
      
      

#
#		Source module
#
#   Deliver source text to the parser

# clone utility function

clone = (object) -> JSON.parse JSON.stringify object

module.exports = class Source
  constructor: (@text) ->

# current is the cursor

    @current =
      index: 0
      line: 1
      column: 1

    @minimum = clone @current   # Minimum location for error reporting
    @maximum = clone @current   # Maximum location for error reporting
        
    @stack = []                 # Stack for save, restore


#
#  next matches a fixed string target
#  returns
#    success/fail
#  skips the string in the source text
#

  next: (target) =>
    length = target.length

    if target == @text.substr(@current.index, length)
      result = true
      @updateCurrent target
    else
      result = false
    
    return result

#
#  match matches a regex
#   returns
#     success/fail
#     string matched
#   skips matched string
#

  match: (expression, flags="") =>
    
    tail = @text.substr @current.index
    regex = new RegExp "^"+expression, "m"+flags
    located = regex.exec(tail)
    
    if located
      matched = located[0]
      @updateCurrent matched
    else
      matched = null
      
    return matched
    
#
# toEOL gets the uninterpreted string from the current index to the
# next newline or end of file (does not absorb the newline)
#

  toEOL: =>
    tail = @text.substr @current.index
    regex = new RegExp "^.*$", "m"
    located = regex.exec(tail)
    
    if located
      matched = located[0]
    else
      matched = tail
    
    @updateCurrent matched

    return matched
    
#
#   The next set of functions cope with quoted strings
#

# static object to map escapes
  escapes =
    b: '\b'
    n: '\n'
    f: '\f'
    r: '\r'
    t: '\t'
    v: '\v'

#  Get the next character
#  only useful in quoted text context

  nextChar = (text, current) ->
    if current.index > text.length
      throw new Error "At line " + current.line + " column " + current.column

    current.column++
    result = text.charAt current.index++

    if result == '\n'
      throw new Error "At line " + current.line + " column " + current.column
          
    return result
    
#  Back up a character
#  only useful in quoted text context

  backup = (current) ->
    current.column--
    current.index--
    
# map character to number

  mapChar = (thisChar) ->
    "0123456789abcdef".indexOf thisChar.toLowerCase()

# decode a number string to a character

  decode = (text, current, size, base) ->
    value = 0
    length = 0
    
    while size > length++
      charValue = mapChar nextChar text, current
      if 0 > charValue
        backup current
        break

      value *= base
      value += +charValue
  
    if value > 0x10000
      high = Math.floor ((charValue - 0x10000) / 0x400) + 0xD800
      low = (charValue - 0x10000) % 0x400 + 0xDC00
      result = String.fromCharCode high, low
    else
      result = String.fromCharCode value
      
    return result

#
#  quotes gets a quoted string
#


  quotes = (type, current, text) ->
    if type == text.charAt current.index
      nextChar text, current
      result = ""
      
      while type != (thisChar = nextChar text, current)
        
        if thisChar == '\\'
          
          thisChar = nextChar text, current

          found = escapes[thisChar]
          if found != undefined
            result += found
          else
            switch thisChar
              when 'x' then result += decode text, current, 2, 16
              when 'u' then result += decode text, current, 4, 16
              else
                if (thisChar.search /[0-7]/) >= 0
                  backup current
                  result += decode text, current, 3, 8
                else
                  result += thisChar
        else
          result += thisChar

    else
      result = null
      
    return result
 
 #
 #  single quotes
 #
  singleQuotes: => quotes "'", @current, @text
       
 #
 #  double quotes
 #
  doubleQuotes: => quotes '"', @current, @text
       
    
# getLocation returns the current line and column numbers

  getLocation: =>
    result =
      line: @current.line
      column: @current.column
      

# save saves the current location

  save: => @stack.push clone @current
    
# restore restores a previously saved location
  
  restore: => @current = @stack.pop()
    
# commit removes a previously saved location
  
  commit: =>
    @stack.pop()
    
    @minimum = clone @current if @stack.length == 0
    
#
#  update line and column, found is the string found by next or match
#  pass in @current to update
#

  updateCurrent: (found) =>
    scanIndex = 0
    while -1 != (newIndex = found.indexOf("\n", scanIndex))
      scanIndex = newIndex + 1
      @current.line++
      @current.column = 1
      
    @current.column += found.length - scanIndex
    @current.index += found.length
    
    @maximum = clone @current if @maximum.index < @current.index


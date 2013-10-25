#  Bootstrap bnfv
#

linkable = require "../../common/bin/linkable"
language = require "../../common/bin/language"
prod = require "./bnfv-production"

next = new linkable.Next(1)

module.exports =
  makeParser: ->
    return languageList()

  
production = prod.production(next)

#language := *<line>

languageList = ->
  l = line()
  result = new language.Repeat next.next(), l
  l.addUp result
  return result
  
#line := <definition> | <comment> | <blank>;

line = ->

  c = comment()
  b = blank()
  d = definition()
  o1 = new language.OrJoin next.next(), c, b
  c.addUp o1
  b.addUp o1
  result = new language.OrJoin next.next(), d, o1
  d.addUp result
  o1.addUp result
  return result
    
#
#blank := {} "\n";
#

blank = ->
  nl = new language.Constant next.next(), "\n"
  w = new language.OptionalWhite next.next(), "", "[ \\t\\v\\f]*"
  result = new language.AndJoin next.next(), w, nl
  nl.addUp result
  w.addUp result
  return result
  
## string is a true builtin, not defined in this file
#comment := {} "#" string "\n"

comment = ->
  w = new language.OptionalWhite next.next(), "", "[ \\t\\v\\f]*"
  h = new language.Constant next.next(), "#"
  st = new language.StringType next.next()
  nl = new language.Constant next.next(), "\n"
  a1 = new language.AndJoin next.next(), w, h
  w.addUp a1
  h.addUp a1
  a2 = new language.AndJoin next.next(), st, nl
  st.addUp a2
  nl.addUp a2
  result = new language.AndJoin next.next(), a1, a2
  a1.addUp result
  a2.addUp result
  return result

#definition := <def_comment> | (<production> {n}) => <production>;

definition = ->
  df = def_comment()
  w = new language.OptionalWhite next.next(), "n"
  a = new language.AndJoin next.next(), production, w
  production.addUp a
  w.addUp a
  result = new language.OrJoin next.next(), a, df
  a.addUp result
  df.addUp result
  return result
   
  
#def_comment := <production> <trailing_comment> => <production>;

def_comment = ->
  t = trailing_comment()
  result = new language.AndJoin next.next(), production, t
  production.addUp result
  t.addUp result
  return result
  
#
#trailing_comment := {c50} "#" string "\n";
#

trailing_comment = ->
  w = new language.OptionalWhite next.next(), "c50"
  h = new language.Constant next.next(), "#"
  st = new language.StringType next.next()
  n = new language.Constant next.next(), "\n"
  a1 = new language.AndJoin next.next(), w, h
  w.addUp a1
  h.addUp a1
  a2 = new language.AndJoin next.next(), st, n
  st.addUp a2
  n.addUp a2
  result = new language.AndJoin next.next(), a1, a2
  a1.addUp result
  a2.addUp result
  return result
   


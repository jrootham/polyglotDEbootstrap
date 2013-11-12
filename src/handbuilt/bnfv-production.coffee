# Production graph

language = require "../../common/bin/language"

makeOr = (next, l, r)->
  result = new language.OrJoin next.next(), l, r
  l.addUp result
  r.addUp result
  return result
  
makeAnd = (next, l, r)->
  result = new language.AndJoin next.next(), l, r
  l.addUp result
  r.addUp result
  return result
  
# special case includes := and ;
#production:={}<name>{s}":="{s}<production_expression> <parse> <generate> ";"

module.exports =
  production: (next) ->
    w = new language.OptionalWhite next.next(), ""
    sw = new language.OptionalWhite next.next(), "s"
    n = new language.Symbol next.next()
    e = productionExpression(next)
    p = postParse(next)
    g = generate(next)
    a1 = makeAnd next, w, n
    a2 = makeAnd next, a1, sw
    result = new language.Production next.next(), a2, e, p, g
    a2.addUp result
    e.addUp result
    p.addUp result
    g.addUp result
    return result

#productionExpression := {s} <expression>

productionExpression = (next) ->
  w = new language.OptionalWhite next.next(), "s"
  e = expression(next)
  return makeAnd next, w, e
  
#postParse := {sw} "^" {s} *<postParseStatement>;

postParse = (next) ->
  sw = new language.OptionalWhite next.next(), "sw"
  w = new language.OptionalWhite next.next(), "s"
  e = new language.Constant next.next(), "^"
  p = postParseStatement(next)
  r = new language.Repeat next.next(), p
  p.addUp r
  a1 = makeAnd next, sw, e
  a2 = makeAnd next, w, r
  return makeAnd next, a1,a2

# <newScope>

postParseStatement = (next) ->
  return newScope next
  
newScope = (next) ->
  s = new language.newScope next.next()
  w = new language.OptionalWhite next.next(), ""
  return makeAnd next, s, w
  
  
#generate := {sw} "=>" {} *<generateStatement>;

generate = (next) ->
  sw = new language.OptionalWhite next.next(), "sw"
  w = new language.OptionalWhite next.next(), "s"
  e = new language.Constant next.next(), "=>"
  g = generateStatement(next)
  r = new language.Repeat next.next(), g
  g.addUp r
  a1 = makeAnd next, sw, e
  a2 = makeAnd next, w, r
  return makeAnd next, a1, a2

# placeholder

generateStatement = (next) ->
  return new language.Constant "bar"
  
#
#
## syntax definition part
#
#expression := <or_expression> | <or_term>;

expression = (next) ->
  result = new language.OrJoin next.next(), null, null
  oe = orExpression next, result
  ot = orTerm next, result
  result.left = oe
  result.right = ot
  oe.addUp result
  ot.addUp result
  return result
  
#or_expression := <expression> {s} "|" {s} <or_term>;

orExpression = (next, expression) ->
  w = new language.OptionalWhite next.next(), "s"
  b = new language.Constant next.next(), "|"
  ot = orTerm next, expression
  a1 = makeAnd next, expression, w
  a2 = makeAnd next, b, w
  a3 = makeAnd next, a2, ot
  return makeAnd next, a1, a3
  
#orTerm := <and_expression> | <primary>

orTerm = (next, expression) ->
  p = primary next, expression
  ae = andExpression next, expression, p
  return makeOr next, ae, p
  
#
#andExpression := <expression> [s] <primary>;

andExpression = (next, expression, primary) ->
  w = new language.RequiredWhite next.next(), "s"
  a1 = makeAnd next, expression, w
  return makeAnd next, a1, primary

#
#baseExpression := <name_expression> | <constant_expression> | <builtin>
#  | <paren_expression>;

baseExpression = (next, expression) ->
  n = nameExpression next
  c = constantExpression next
  b = builtin next
  p = parenExpression next, expression
  o1 = makeOr next, n, c
  o2 = makeOr next, b, p
  return makeOr next, o1, o2
  
#primary := <repeatExpression> | <baseExpression>

primary = (next, expression) ->
  be = baseExpression next, expression
  re = repeatExpression next, be
  return makeOr next, re, be
  
#repeatExpression := "*" ({} <baseExpression>);

repeatExpression = (next, baseExpression) ->
  w = new language.OptionalWhite next.next(), ""
  s = new language.Constant next.next(), "*"
  a = makeAnd next, w, baseExpression
  return makeAnd next, s, a
  
#name_expression := "<" <name> ">";

nameExpression = (next) ->
  l = new language.Constant next.next(), "<"
  n = name next
  r = new language.Constant next.next(), ">"
  a = makeAnd next, l, n
  return makeAnd next, a, r
  
#name := symbol;

name = (next) ->
  return new language.Symbol next.next()
  
#parenExpression := "(" {} <expression> {}  ")";

parenExpression = (next, expression) ->
  l = new language.Constant next.next(), "("
  r = new language.Constant next.next(), ")"
  w = new language.OptionalWhite next.next(), ""
  a1 = makeAnd next, l, w
  a2 = makeAnd next, expression, w
  a3 = makeAnd next, a2, r
  return makeAnd next, a1, a3
  
# single_quotes and double_quotes are builtins not defined in this file
#constantExpression := single_quotes | double_quotes;

constantExpression = (next) ->
  s = new language.SingleQuotes next.next()
  d = new language.DoubleQuotes next.next()
  return makeOr next, s, d
  
#
## builtins
#
#builtin := <unsigned> | <integer> | <fixed> | <float> | <fixed_bcd> |
# <symbol> | <match>;
#

builtin = (next) ->
  u = unsigned next
  i = integer next
  f = fixed next
  l = float next
  b = fixedBCD next
  s = symbol next
  m = match next
  o1 = makeOr next, u, i
  o2 = makeOr next, f, l
  o3 = makeOr next, b, s
  o4 = makeOr next, m, o3
  o5 = makeOr next, o1, o2
  return makeOr next, o4, o5
  
#unsigned := "unsigned" <bits>;

unsigned = (next) ->
  return new language.Constant next.next(), "unsigned"

#integer := "integer" <bits>;

integer = (next) ->
  return new language.Constant next.next(), "integer"

#fixed := "fixed" <float_bits>;

fixed = (next) ->
  return new language.Constant next.next(), "fixed"

#float := "float" <float_bits>;

float = (next) ->
  return new language.Constant next.next(), "float"

#fixedBCD := "fixedBCD" <fixed_digits>;

fixedBCD = (next) ->
  return new language.Constant next.next(), "fixedBCD"

#symbol := "symbol" <scope> <namespace> <symbol_regex>;

symbol = (next) ->
  return new language.Constant next.next(), "symbol"

#match := "match" <regex>
# incomplete

match = (next) ->
  s = new language.Constant next.next(), "/"
  return makeAnd next, s, s
  
#
#bits := <bit_count> | "";
#bit_count := <number>;
#
#number := match "/[0-9]*/";
#
#float_bits := <bit_count> <exponent_bit_count> | "";
#exponent_bit_count := <number>;
#
#fixed_digits := <total_digits> <fraction_digits> | "";
#total_digits := <number>;
#fraction_digits := <number> | "";
#
#regex := "/" <string> "/";		#  Special case builtin
#
#scope := "global";
#
#namespace := "";
#
#symbol_regex := <regex> | "";
#
## Parse time actions
#
#parse_statement := {} "(" {} <parse_action> {} ")" {w};
#
#parse_action := <insert> | <is_inserted> | <is_type> | <type_equals>
# | <make_type> | <set> | <is_set>;
#
#insert := "insert" [s] <item>;
#is_inserted := <item> [s] "is_inserted";
#is_type := <item> [s] "is_type" [s] <type>;
#type_equals := <left_item> [s] "type_equals" [s] <right_item>;
#make_type := "make_type" [s] <type>;
#set := <item> [s] "set" [s] <value>;
#is_set := "is_set" [s] <item>;
#
#item := <local_name> | """" <name> """"";
## local_name must be a name used in the current production
#local_name := local_name;
#
#<type> := <name>;
#<left_item> := <item>;
#<right_item> := <item>;
#<value> := <string>;   #  This is not complete
#
##  Code generation
#
#generate_statement := {s} <generation> {} | {s} "<" <descend> ">" {};
#
#descend := symbol;   #  must be a name in the current production

#generation := <generate_action> *([s] <generate_action>);
#generate_action := <generate_constant> | <generate_dynamic>;
#


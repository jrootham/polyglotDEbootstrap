#  Bootstrap bnfv
#

linkable = require "../bin/linkable"
language = require "../../common/bin/language"

next = linkable.Next(1)

module.exports =
  makeParser: ->
    return languageList
  
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
  result = new language.OrJoin d, o1
  d.addUp result
  o1.addUp result
  return result
  
  
# temporary

comment = ->
  return new language.Constant "#"
  
blank = ->
  return new language.Constant " "
  
definition = ->
  return new language.Constant ":="
  

#
#blank := {} "\n";
#
## string is a true builtin, not defined in this file
#comment := {} "#" string "\n"
#
#trailing_comment := {c50} "#" string "\n";
#
#definition := (<def> {n}) | <def_comment> => <definition>;
#def_comment := <def> <trailing_comment> => <def>;
#def := (<syntax> | <syntax_parse> | <syntax_generate> | <syntax_both>) ";";
#
#syntax := {} <name> {s}  ":=" {s} <def_expression>;
#
#syntax_parse := <syntax> <parse>;
#syntax_generate := <syntax> <generate>;
#syntax_both := <syntax> <parse> <generate>;
#
#parse := {sw} "^" {s} *<parse_statement>;
#generate := {sw} "=>" {s}*<generate_statement>;
#
## syntax definition part
#
#expression := <or_expression> | <or_term>;
#or_expression := <expression> {s} "|" {s} <or_term>;
#or_term := <and_expression> | <primary>
#
#and_expression := <expression> [s] <primary>;
#primary := <repeat_expression> | <base_expression>
#
#repeat_expression := "*" ({} <base_expression>);
#
#base_expression := <name_expression> | <constant_expression> | <builtin>
#  | <paren_expression>;
#name_expression := "<" <name> ">";
#name := symbol global;
#paren_expression := "(" {} <expression> {}  ")";
# single_quotes and double_quotes are builtins not defined in this file
#constant_expression := single_quotes | double_quotes;
#
## builtins
#
#builtin := <unsigned> | <integer> | <fixed> | <float> | <fixed_bcd> |<symbol>;
#
#unsigned := "unsigned" <bits>;
#integer := "integer" <bits>;
#fixed := "fixed" <float_bits>;
#float := "float" <float_bits>;
#fixed_bcd := "fixed_bcd" <fixed_digits>;
#symbol := "symbol" <scope> <namespace> <symbol_regex>;
#match := "match" <regex>
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
#generate_statement := "(" {} <generation> {} ")" | "<" <descend> ">";
#
#descend := <local_name>;
#generation := <generate_action> *([s] <generate_action>);
#generate_action := <generate_constant> | <generate_dynamic>;
#generate_constant := <quoted_string>;
#generate_dynamic := <local_name>;
#

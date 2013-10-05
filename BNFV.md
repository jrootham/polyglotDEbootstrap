editor
======

Generalized editor system
-------------------------

The generalized editor system is designed to support editing and code generation 
(compiling) for any language that can be described with a variant of Backus Naur Format (BNFV).

The BNFV description looks like this:

Comments

  All source needs comments, we are using the simplest system.  All lines that start with # are comments.

Items in *italics* are variables.  

Regular text items are literals.  

BNFV looks like this:

Structure

The general structure of a production is:
  
*production* := *BNFV expression* [ ^ *compile time action* ] [ => { *code to generate* } ]] ;

White space is in general not significant, so newlines may be inserted.

The first production is the root of the parse tree (and the starting point for the emitted code).

BNFV expressions 

Parentheses group items.  

An *item* followed by a \* is repeated 0 or more times.  

*items* separated by spaces are concatenated.

*items* separated by | means one of them.  

A reference to a production is surrounded by \< \>.  

A literal *item* is surrounded by " ".  An empty item is represented by "".

Syntacticly marginal whitespace is represented by [] or {}.  [] requires at least 1 whitespace character to parse
correctly.  {} does not.  The contents describe the whitespace that is to be inserted on output.  The options are:

+ s a space
+ t a tab
+ n a newline
+ i indent to current level
+ + increase the current level and indent
+ - decrease the current level and indent
+ c *n* skip to column *n* unless we are already past it, in which case insert a tab

These can be combined, the most likely combinations are ni, n+ and n-.

  If any brace brackets in the code to generate are paired they do not need to be escaped.  Only if a } appears 
  before a matching { will it need to be escaped by \\}.
  
  The currently available compile time actions are:
    + \< insert *item*\>
    + \< *item* isInserted\> trigger an compile time error if not true
    + \< *item* isType *type*\>  type is a production defining a type (see Builtins) trigger an compile time error if not true
    + \< *item1* typeEquals *item2*\> trigger an compile time error if not true
    + \< makeType *type*\> force the production to be of type *type*

Builtins
  
  Some expressions are built in special cases, these may have parameters, possibly [optional].  These may appear only 
by themselves on the right side of :=.

    1.  unsigned  [ *bits* ]
    
    2.  integer   [ *bits]* 
    
    3.  fixed [ *bits  exponent-bits* ]
    
    4.  float [ *bits exponent-bits* ]
    
    5.  fixed-bcd [ *digits* [ *fraction-digits* ]]
    
    6.  string
    
    7.  symbol  [ */matching regex/* ] *scope* [ *namespace* ]
    
    Yes, I am willing to support COBOL.
    
    The matching regex defaults to /([A-Z]|[a-z])([A-Z]|[a-z]|[0-9]|-|_)*/

    The scope is one of a small set.  This list will extend as new languages arrive.
    
      1. global - all symbols go into one symbol table.
    
    
    The namespace specifies which one of a set of symbol tables the symbol goes into.
    
    


  


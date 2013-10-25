# test the bnfv handbuilt

bnfv = require "../bin/bnfv-simpler"
Source = require "../../common/bin/source"
linkable = require "../../common/bin/linkable"
language = require "../../common/bin/language"
program = require "../../common/bin/program"
scaffold = require "../../common/test/test.scaffold"
upDown = require "../../common/test/up-down.scaffold"

unique = scaffold.unique

upDown.connectLinkable linkable
upDown.connectLanguage language
upDown.connectProgram program

next = new linkable.Next 1

parser = bnfv.makeParser()

text = "# commment then blank\n   \nabc := foo;\ndef:=foo;# comment\n"
text += "_g1 := foo ^ =>\n"

source = new Source text

result = parser.parse next, source

describe "Test handbuilt parser", ->
  it "parser ids should be unique (throws if not)", ->
    parser.preorder unique()

  it "parser up pointers should be valid (throws if not)", ->
    parser.checkDown

  it "result ids should be unique (throws if not)", ->
    result.preorder unique()

  it "result up pointers should be valid (throws if not)", ->
    result.checkDown


# test the bnfv handbuilt

bnfv = require "../bin/bnfv-simpler"

parser = bnfv.makeParser()

console.log parser.displayGraph [], ""


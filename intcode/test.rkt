#lang intcode

// rules
rule: 1 -> @+@
rule: 2 -> @*@
rule: 99 -> @exit@

// our data
data: 1,9,10,3,2,3,11,0,99,30,40,50

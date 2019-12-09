#lang reader "intcode.rkt"

// rules
rule: 1 -> '(+)' from 2 3 then send to 4
rule: 2 -> '(*)' from 2 3 then send to 3

// our data
data: 1,9,10,3,2,3,11,0,99,30,40,50

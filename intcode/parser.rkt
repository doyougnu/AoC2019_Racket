#lang brag

program : (rule | data)*
data    : /"data:" INTEGER (/"," INTEGER)* /NEWLINE
rule    : /"rule:" INTEGER /"->" RKT /"from" INTEGER INTEGER /"send" /"to" INTEGER /NEWLINE

#lang brag

program : (rule | data)*
data    : /"data:" INTEGER (/"," INTEGER)*
rule    : /"rule:" INTEGER /"->" RKT /"from" INTEGER INTEGER /"send" /"to" INTEGER

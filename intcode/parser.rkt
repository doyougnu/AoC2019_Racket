#lang brag

program : (intcode-rule | intcode-data)*
intcode-data    : /"data:" INTEGER (/"," INTEGER)*
intcode-rule    : /"rule:" INTEGER /"->" RKT

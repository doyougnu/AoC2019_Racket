#lang racket

(require "parser.rkt" "tokenizer.rkt" brag/support)

;; line comment
(parse-to-datum (apply-tokenizer-maker make-tokenizer "// a line comment\n"))

;; sequence of data
(parse-to-datum (apply-tokenizer-maker make-tokenizer "data: 1,2,3,3,4,5\n"))

;; a rule
(parse-to-datum
 (apply-tokenizer-maker
  make-tokenizer
  "rule: 2 -> '(*)' from 2 3 send to 3\n"))

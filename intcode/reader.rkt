#lang racket

(require "tokenizer.rkt" "parser.rkt")

(define (read-syntax path port)
  (datum->syntax #f `(module intcode-mod intcode/expander
                       ,(parse path (make-tokenizer port)))))
(provide read-syntax)

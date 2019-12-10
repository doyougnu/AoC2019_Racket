#lang racket

(require syntax/strip-context
         racket/syntax
         "parser.rkt"
         "tokenizer.rkt")


(define (read-syntax path port)
  (datum->syntax #f `(module intcode-mod "expander.rkt"
                       ,(parse path (make-tokenizer port)))))
(provide read-syntax)

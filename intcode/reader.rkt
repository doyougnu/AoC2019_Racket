#lang racket

(require syntax/strip-context
         racket/syntax
         intcode/parser
         intcode/tokenizer)


(define (read-syntax path port)
  (datum->syntax #f `(module intcode-mod intcode/expander
                       ,(parse path (make-tokenizer port)))))
(provide read-syntax)

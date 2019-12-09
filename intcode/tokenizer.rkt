#lang racket
(require brag/support
         racket/contract
         "lexer.rkt")

(define (make-tokenizer ip [path #f])
  (port-count-lines! ip)
  (lexer-file-path path)
  (define (next-token) (intcode-lexer ip))
  next-token)
(provide make-tokenizer)

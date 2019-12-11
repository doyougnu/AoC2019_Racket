#lang racket
(require brag/support)

(define-lex-abbrev reserved-terms (:or "rule:" "->" "from" "send" "to" "then"))
(define-lex-abbrev digits (:+ (char-set "0123456789")))

(define intcode-lexer
  (lexer-srcloc
   ["\n" (token 'NEWLINE lexeme #:skip? #t)]
   [whitespace (token lexeme #:skip? #t)]
   [(from/to "//" "\n") (token lexeme #:skip? #t)]
   [digits (token 'INTEGER (string->number lexeme))]
   [(:or "," "data:") lexeme]
   [(from/to "@" "@")
    (token 'RKT (trim-ends "@" lexeme "@"))]
   [reserved-terms (token lexeme lexeme)]
   [(eof) (void)]))

(provide intcode-lexer)

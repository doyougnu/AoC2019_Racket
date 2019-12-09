#lang racket
(require brag/support)

(define-lex-abbrev reserved-terms (:or "rule:" "->" "from" "send" "to" "then"))

(define intcode-lexer
  (lexer-srcloc
   ["\n" (token 'NEWLINE lexeme)]
   [whitespace (token lexeme #:skip? #t)]
   [(from/to "//" "\n") (token lexeme #:skip? #t)]
   [numeric (token 'INTEGER (string->number lexeme))]
   [(:or "," "data:") lexeme]
   [(from/to "'" "'") (token 'RKT
                             (trim-ends "'" lexeme "'"))]
   [reserved-terms (token lexeme lexeme)]
   [(eof) (void)]))

(provide intcode-lexer)

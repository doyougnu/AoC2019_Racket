#lang racket

(require racket/syntax)

(define-syntax-rule (intcode-mb (program PARSE-TREE ...))
  (#%module-begin
   (begin
     PARSE-TREE
     ...
     (displayln *data*))))
(provide (rename-out [intcode-mb #%module-begin]))
(provide #%app #%datum)

;; we doing this imperatively because the problem lends itself to that easily
;; and frankly I need to practice it. I'm too abused by haskell this could be
;; functional by constructing the hash table first, then passing around the data
;; for each intcode set
(define *funcs* (make-hasheqv))
(define *data* (void))

;; (define-syntax (rule stx)
;;   (syntax-case stx ()
;;     [(rule n f left-arg right-arg output-num)
;;      #'(set-rule! n (string->symbol f) left-arg right-arg output-num)]))
(define (rule n f left-arg right-arg output)
  (hash-set! *funcs* n '(apply f (data-get left-arg) (data-get right-arg))))
(provide rule)

;; (define-syntax (set-rule! stx)
;;   (syntax-case stx ()
;;     [(set-rule! n f left-arg right-arg output-num)
;;      (hash-set! *funcs* #'n
;;                 #'(f (data-get left-arg) (data-get right-arg)))]))
(define (set-rule! n f l r . args)
  (hash-set! *funcs* n (apply f (data-get l) (data-get r))))

(define (data-get i)
  (hash-ref *funcs* i))

(define (data . ds)
  (set! *data* (list->vector ds)))
(provide data)

;; (define-syntax-rule (program rule-or-data ...)
;;   (begin
;;     (void rule-or-data ...)
;;     (displayln *data*)
;;     (displayln *funcs*)))
;; (provide program)

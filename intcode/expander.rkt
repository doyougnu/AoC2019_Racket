#lang racket

(require racket/match racket/syntax threading)
(define-syntax-rule (intcode-mb (program PARSE-TREE ...))
  (#%module-begin
   PARSE-TREE ...
   (run *data*)
   ;; print the final result
   (get-data 0)))
(provide (rename-out [intcode-mb #%module-begin]) #%app #%datum)

(define-namespace-anchor ns-anc)
(define ns (namespace-anchor->namespace ns-anc))
;; we doing this imperatively because the problem lends itself to that easily
;; and frankly I need to practice it. I'm too abused by haskell this could be
;; functional by constructing the hash table first, then passing around the data
;; for each intcode set
(define *funcs* (make-hasheqv))
(define *data* (void))

(define (intcode-rule n f)
  (hash-set! *funcs* n (read (open-input-string f))))
(provide intcode-rule)

(define (set-rule! n f )
  hash-set! *funcs* n `,f)

(define (set-data! i v)
  (vector-set! *data* i v))

(define (get-rule i)
  (hash-ref *funcs* i))

(define (get-data i)
  (vector-ref *data* i))

(define (intcode-data . ds)
  (set! *data* (list->vector ds)))
(provide intcode-data)

(define (compute f left-arg right-arg output)
  (let* ([func (get-rule f)]
         [result (eval `(,func (get-data ,left-arg) (get-data ,right-arg)) ns)])
    (set-data! output result)))

(define (run program)
  (match program
    ;; when we see a 99 we end the program
    [(vector 99 rest ...) 'end]
    [(vector f l-arg r-arg output rest ...) (begin
                                              (compute f l-arg r-arg output)
                                              ;; notice that we cannot just call
                                              ;; rest here because thats a list
                                              ;; and I bet coerican is expensive
                                              (run (vector-drop program 4)))]))

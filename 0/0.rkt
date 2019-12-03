#lang racket

(require threading)
(require racket/stream)

;;;;;;;;;;; Thoughts
;; this could be a dynamic programming problem based on the redundancy in
;; sub-problems.

;; In haskell I would stream the input file and perform a left fold strict in
;; the accumulator

;; because this is racket the strictness is done for me, I just need to lazily
;; stream the file

;; our calculation for mass is deterministic, and summation over integers is a
;; monoid so we could do this in parallel but our data probably isn't big enough
;; to warrant spinning up a pool of threads

;;;;;;;;;;;;;;;;;;;;;;;;;;; Implementation ;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;; just store the file in a constant no need for anything else
(define problem-data "data.txt")

;;;;;;;;;;;;;;;;;;;;;;;;;;; Pure functions
;; in Haskell: (+ (-2)) . (div 3) $ input

;; pretty happy to see clojure's threading macros proliferating around lisp
;; world
(define fuel-required
  ;; how do we docstring in racket?
  (λ~> (/ 3)
       floor
       (- 2)))

;;;;;;;;;;;;;;;;;;;;;;;;;; Impure
;; this works but I'm disappointed in the polymorphism available. Perhaps I'm
;; just abused by haskell, specifically the fact that there is a stream-fold and
;; fold and for forms worries me.
(define (total-fuel-requirement input-file)
  (call-with-input-file input-file
    (λ~>>
     in-lines
     sequence->stream
     (stream-fold
      (λ (total-fuel mass)
        (+ total-fuel (fuel-required (string->number mass))))
      0))))

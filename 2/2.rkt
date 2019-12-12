#lang racket

(require threading)
(require racket/stream)
(require racket/syntax)

;;;;;;;;;;; Thoughts
;; I'm just going to brute force this one to get it done I'm sure there some
;; divide and conquer algorithm to figure this out probably

;;;;;;;;;;;;;;;;;;;;; Implementation
(struct coord (x y))

;; a motion is a symbol representing direction and an integer representing
;; magnitude
(struct motion (direction magnitude)
  #:transparent)

(define (manhatten-distance coord)
  (sqrt (+ (expt coord-x 2) (expt coord-y 2))))

(define get-direction
  (λ~> (substring 0 1)))

(define get-magnitude
  (λ~> (substring 1) open-input-string read))

(define (read-motion str)
  (let ([dir (format-symbol "~a" (substring str 0 1))]
        [mag (get-magnitude str)])
    (motion dir mag)))

;;;;;;;;; these should be a macro ;;;;;;;;;;;;
(define (on-x-coord f-x c)
  (struct-copy coord c [x (f-x (coord-x c))]))

(define (on-y-coord f-y c)
  (struct-copy coord c [x (f-y (coord-x c))]))

;; well this sure looks like its a higher ordered function. I think the
;; readability is important here
(define (apply-motion crd _motion)
  (match _motion
    [(motion 'L mag) (on-x-coord (λ (x) (- mag x)) crd)]
    [(motion 'R mag) (on-x-coord (λ (x) (+ mag x)) crd)]
    [(motion 'U mag) (on-y-coord (λ (y) (+ mag y)) crd)]
    [(motion 'D mag) (on-y-coord (λ (y) (- mag y)) crd)]))

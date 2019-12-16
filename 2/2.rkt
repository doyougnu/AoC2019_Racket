#lang racket

(require threading)
(require racket/stream)
(require racket/syntax)

(module+ test
  (require rackunit))

;;;;;;;;;;; Thoughts
;; I'm just going to brute force this one to get it done I'm sure there some
;; divide and conquer algorithm to figure this out probably
;; I want to just use

;;;;;;;;;;;;;;;;;;;;; Implementation
(struct coord (x y) #:transparent)

;; a motion is a symbol representing direction and an integer representing
;; magnitude
(struct motion (direction magnitude)
  #:transparent)

(define (manhatten-distance coord)
  (+ (~> coord coord-x abs)
     (~> coord coord-y abs)))

(define get-direction
  (λ~> (substring 0 1)))

(define get-magnitude
  (λ~> (substring 1) open-input-string read))

(define/contract (read-motion str)
  (string? . -> . motion?)
  (let ([dir (format-symbol "~a" (substring str 0 1))]
        [mag (get-magnitude str)])
    (motion dir mag)))


;;;;;;;;; these should be a macro ;;;;;;;;;;;;
(define (on-x-coord f-x c)
  (struct-copy coord c [x (f-x (coord-x c))]))

(define (on-y-coord f-y c)
  (struct-copy coord c [y (f-y (coord-y c))]))

(define map-coord
  (case-lambda
   [(f l) (~>> l (on-x-coord f) (on-y-coord f))]
   [(f l r) (coord (f (coord-x l) (coord-x r)) (f (coord-y l) (coord-y r)))]))


;; I find myself writing a ton of boilerplate to do this problem... I tried
;; writing this with a list comprehension like I might in haskell but there is a
;; bunch of assumptions in for/list and in in-range and in the range functions.
;; So I decided to just hand roll my own loop. Its really quite frustrating to
;; be programming so manually
(define (smt-range from to)
  (define to-fixed (if (<= from to)
                       (add1 to)
                       (sub1 to)))
  (range from
         to-fixed
         (if (> from to) -1 1)))

(define (normalize-lists l1 l2)
  (define l1-length (length l1))
  (define l2-length (length l2))
  (define n (abs (- l1-length l2-length)))
  (cond
    [(< l1-length l2-length) (cons
                              (append (make-list n (last l1)) l1)
                              l2)]
    [(>= l1-length l2-length) (cons
                               l1
                               (append (make-list n (last l2)) l2))]))

(define (generate-coords from to)
  (match-let
      ([(coord frm-x frm-y) from]
       [(coord to-x to-y) to])
    (define xs (smt-range frm-x to-x))
    (define ys (smt-range frm-y to-y))
    (define normalized (normalize-lists xs ys))
    (zipWith coord (car normalized) (cdr normalized))))

;; well this sure looks like its a higher ordered function. I think the
;; readability is important here
(define/contract (apply-motion crd _motion)
  (coord? motion? . -> . coord?)
  (match _motion
    [(motion 'L mag) (on-x-coord (λ (x) (- x mag)) crd)]
    [(motion 'R mag) (on-x-coord (λ (x) (+ mag x)) crd)]
    [(motion 'U mag) (on-y-coord (λ (y) (+ mag y)) crd)]
    [(motion 'D mag) (on-y-coord (λ (y) (- y mag)) crd)]))

(define (scanl f seed ls)
  (match ls
    ['() '()]
    [(list h t ...)
     (let ([res (f h seed)])
       (cons res (scanl f res t)))]))

(define/contract (walk-path origin directions)
  (coord? (listof string?) . -> . (listof coord?))
  (scanl (λ (d crd) (apply-motion crd (read-motion d))) origin directions))

(define/contract (zipWith f l1 l2)
  (procedure? list? list? . -> . list?)
  (cond
    [(not (or (empty? l1) (empty? l2)))
     (match-let ([(list h1 t1 ...) l1]
                 [(list h2 t2 ...) l2])
       (cons (f h1 h2) (zipWith f t1 t2)))]
    [else null]))

(define map-pair
  ;; (procedure? pair? pair? . -> . pair?)
  (case-lambda
    [(f l) (cons (f (car l))
                 (f (cdr l)))]
    [(f l r) (cons (f (car l) (car r))
                   (f (cdr l) (cdr r)))]))

(define (compare-lines-with f pair-of-lines)
  (match-let
      ([(cons (coord lx ly) (coord rx ry)) pair-of-lines])
    (cons (f lx rx) (f ly ry))))

(define (compare-lines pair-of-lines)
  (compare-lines-with <= pair-of-lines))

(define (find-intersection 2-list-of-pairs)
  (match-let
      ([(list (cons w1-from w2-from) (cons w1-to w2-to)) 2-list-of-pairs])
    (for*/list ([w1-coord (generate-coords w1-from w1-to)]
                [w2-coord (generate-coords w2-from w2-to)]
                #:when (equal? w1-coord w2-coord))
      w2-coord)))

;; get head
;; compare line
;; compare line with acc
;; if same then continue
;; if diff then set acc, use last-pair to compute coord, then set acc
(define (find-joins pairs)
  (define hd (first pairs))
  (define initial-acc (compare-lines hd))
  (define tail (rest pairs))
  (define (go last-pr acc pairs)
    (match pairs
      ['() null]
      [(list h t ...)
       (let ([coord-diff (compare-lines h)])
         (cond [(equal? coord-diff acc)
                (go h acc t)]
               [else
                (list* (list last-pr h) (go h coord-diff t))]))]))
  (go hd initial-acc tail))

(define (solution path1 path2)
  (define origin (coord 0 0))
  (define pairs (zipWith cons
                         (walk-path origin path1)
                         (walk-path origin path2)))
  (define intersections (append-map find-intersection (find-joins pairs)))
  (apply min (map manhatten-distance intersections)))

(module+ test
  (define test '("R75" "D30" "R83" "U83" "L12" "D49" "R71" "U7" "L72"))
  (define test2 '("U62" "R66" "U55" "R34" "D71" "R55" "D58" "R83"))
  (define test3 '("U7" "R6" "D4" "L4"))
  (define test4 '("R8" "U5" "L5" "D3"))
  (solution test test2))

;;;;;;;;;;;; closing thoughts ;;;;;;;;;;;;;;;;;
;; I think my pseudo brute force approach of finding the important lines then doing coord generation was pretty goo, no idea how it scales though
;; I need to make more agressive uses of macros
;; I found racket to be missing _a lot_ of functional programming niceties like zipWith
;; even when I figured out that the variadic version of map perfrmos zip with just like in clojure it still didn't have the right behavior
;; I'm dissapointed that in-range and range failed be here, it was super annoying
;; Moving forward i'm going to use more packages and macros. Racket is programmable after all
;; I also almost started writing an optics library but turns out someone had already done this
;; this problem didn't lend itself well to a language oriented design, in the future I think I'll skip such problems as they are not interesting

#lang racket

(require racket/syntax)
(require syntax/strip-context)

;; (define (read-syntax path port)
;;   (with-syntax ([strs (port->lines port)])
;;     (strip-context
;;      #'(module intcode-mod racket
;;          (provide data)
;;          (define data `strs)))))
;; (provide read-syntax)

(define (read-syntax path port)
  (define i-datums
    (for/list ([i-str (in-lines port)])
      (dispatch i-str)))
  (strip-context
   #`(module intcode-mod racket
       #,@i-datums)))
(provide read-syntax)



;; (require (for-syntax racket/syntax))
;; (define-syntax (our-struct stx)
;;   (syntax-case stx ()
;;     [(_ id (fields ...))
;;      (with-syntax ([pred-id (format-id #'id "~a?" #'id)])
;;        #`(begin
;;            ; Define a constructor.
;;            (define (id fields ...)
;;              (apply vector (cons 'id  (list fields ...))))
;;            ; Define a predicate.
;;            (define (pred-id v)
;;              (and (vector? v)
;;                   (eq? (vector-ref v 0) 'id)))
;;            ; Define an accessor for each field.
;;            #,@(for/list ([x (syntax->list #'(fields ...))]
;;                          [n (in-naturals 1)])
;;                 (with-syntax ([acc-id (format-id #'id "~a-~a" #'id x)]
;;                               [ix n])
;;                   #`(define (acc-id v)
;;                       (unless (pred-id v)
;;                         (error 'acc-id "~a is not a ~a struct" v 'id))
;;                       (vector-ref v ix))))))]))

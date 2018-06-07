#lang racket/base

(require multiscope2)

(define-scope-escape rkt)
(define-scope c
  multiscope2/base-require-forms
  (only-in racket/base define #%app))

(c
 (define +
   (rkt
    (lambda (lhs rhs)
      (format "(~s + ~s)" lhs rhs)))))
       
(displayln (c (+ 5 (rkt (+ 2 3)))))
; => (5 + 5)

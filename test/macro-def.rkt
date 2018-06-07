#lang racket/base

(require
  multiscope2
  rackunit)

(define-scope a racket/base)

(a (define x 'a))

(a
 (define-syntax-rule (m)
   x))
(a
 (provide m))

(define-syntax-rule (m2)
  (a x))

(provide m2)

(define-syntax-rule (m3 arg)
  (a arg))
(provide m3)

(check-equal? (m3 x) 'a)
#lang racket/base

(require
  rackunit
  "macro-def.rkt")

(check-equal? (m) 'a)
(check-equal? (m2) 'a)

(define x 'b)
(check-equal? (m3 x) 'b)
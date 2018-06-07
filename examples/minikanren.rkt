#lang racket

(require
  multiscope2
  rackunit)

(define-scope-escape r)
(define-scope mk minikanren)

(mk
  (define (append l s out)
    (conde
      [(== '() l) (== s out)]
      [(fresh (a d res)
         (== `(,a . ,d) l)
         (== `(,a . ,res) out)
         (append d s res))])))

(let ([l1 '(a b)]
      [l2 '(c d e)])
  (check-equal?
    (first
      (mk (run 1 (q) (append (r l1) (r l2) q))))
    (append l1 l2)))
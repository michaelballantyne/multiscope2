#lang racket/base

(require
  multiscope2
  rackunit)

(define-scope-escape rkt)
(define-scope a racket/base)
(define-scope b racket/base racket/list)

(a (define x 'a))
(b (define x 'b))

(define-namespace-anchor anchor)
(define ns (namespace-anchor->namespace anchor))

(test-case "racket/list is visible in `b` but not `rkt` or `a`"
  (check-equal? (b (range 3)) '(0 1 2))
  (check-exn
    exn:fail?
    (lambda ()
      (eval #'(range 3) ns)))
  (check-exn
    exn:fail?
    (lambda ()
      (eval #'(rkt (range 3)) ns)))
  (check-exn
    exn:fail?
    (lambda ()
      (eval #'(a (range 3)) ns)))
  (check-exn
    exn:fail?
    (lambda ()
      (eval #'(b (rkt (range 3))) ns)))
  (check-exn
    exn:fail?
    (lambda ()
      (eval #'(b (a (range 3))) ns))))

(test-case "x is defined differently in `a` and `b`, and is not defined in `rkt`"
  (check-equal? (a x) 'a)
  (check-equal? (b x) 'b)
  (check-exn
    exn:fail?
    (lambda ()
      (eval #'x ns))))

(test-case "shadowing shadows in the scope of the binding, but no other"
  (check-equal?
    (a (let ([x 'a2])
         (list
           x
           (b x))))
    '(a2 b)))

(test-case "splicing behavior"
  (check-equal?
    (let ()
      (define y 'y-rkt)
      (a (define y 'y-a))
      (a
        (define x 'x-a)
        (list
          x
          y)))
    '(x-a y-a)))


#|
(a (define x 5))
(a x)
; x unbound


(define y 6)
; (a y) unbound

(a (define z 6))
(a z) ; 6

(define z 5)
z ; 5

(provide z)

(a
 (define-syntax-rule (m)
   x))
(a
 (provide m))

(define-syntax-rule (m2)
  (a x))

(provide m2)
|#
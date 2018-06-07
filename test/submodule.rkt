#lang racket/base

(require multiscope2)

(define-scope a racket/base)

(a (define x 'a))

(module+ test
  (require rackunit)
  (check-equal? (a x) 'a)

  (define-namespace-anchor anchor)
  (define ns (namespace-anchor->namespace anchor))

  (check-equal? (eval-syntax #'(a x) ns) 'a)
  (check-exn
   exn:fail?
   (lambda ()
     (eval-syntax #'x ns))))

(module m racket/base
  (require rackunit)
  
  (define-namespace-anchor anchor)
  (define ns (namespace-anchor->namespace anchor))
  (check-exn
   exn:fail?
   (lambda ()
     (eval '(a) ns))))

(require 'm)

(module* main racket/base
  (require rackunit)
  (define-namespace-anchor anchor)
  (define ns (namespace-anchor->namespace anchor))
  (check-exn
   exn:fail?
   (lambda ()
     (eval '(a) ns))))
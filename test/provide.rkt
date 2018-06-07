#lang racket/base

(module a racket/base
  (require multiscope2)
  (define-scope a racket/base)
  (define-scope b racket/base)

  (define x 'outer)
  (a (define x 'a))
  (b (define x 'b))
  (a (provide x))

  (define y 'outer)
  (a (define y 'a))
  (b (define y 'b))
  (b (provide y))

  (define z 'outer)
  (provide z))

(module b racket/base
  (require
    rackunit
    (submod ".." a))

  (test-case "provide should export the binding from the current scope"
    (check-equal?
      (list x y z)
      '(a b outer))))

(require 'b)

(module c racket/base
  (require multiscope2)
  
  (define-scope a racket/base)

  (a
    (define x 'b)
    (provide x))

  (module* d racket/base
    (require
      rackunit
      (submod ".."))

    (test-case "require/provide to submodule in default scope should allow access to definition in different scope"
      (check-equal?
        x
        'b))))

(require (submod "." c d))
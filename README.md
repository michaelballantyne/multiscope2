A module language for programming with multiple named scopes, orthogonal to lexical nesting.

## Examples

### Code Generation

```
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
```

Code generation functions can use the same names as forms from Racket, and staged computations can intermix references to them by entering named scopes.

### Relational programming in miniKanren

```
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

```

Relational miniKanren operators and functional froms from racket are kept in separate namespaces, allowing relations to use the same names as their functional counterparts (like `append`). Accidental reference to a non-relational operator from Racket will lead to an unbound identifier error.


## Why?

It is often convenient for forms of an embedded DSL to use some of the same identifiers as forms from racket/base (or another relevant language), but wrangling the names in a module that needs to use both the DSL and the built-in forms can be awkward.

Method overloading in object-oriented languages and typeclass based function overloading in typed functional languages partially avoid these problems, but dynamic functional languages need another solution.

Code that intermixes forms from different languages

## Usage

Use

```
(define-scope name initial-requires ...)
```

to define a scope called `name`, which will initially have the bindings available from the `initial-requires ...`. The initial requires can be any require specification, but they are expanded in an empty scope, so require forms like `submod` and `only-in` aren't available unless they are provided by an earlier initial require in the sequence. The module `multiscope2/basic-require-forms` exports the basic require forms from `racket/base`, so you can write things like:

```
(define-scope foo
  multiscope2/basic-require-forms
  (submod ".." a))
```

Within the body of the module, the scope names are bound (at phase 0) to macros that cause their argument to be evaluated within that named scope. The scope-applying macros are visible in every named scope. When scope-applications are nested, the innermost scope applies. Other than their scoping effects, the scope-application macros have the same behavior as `begin`.


Use

```
(define-scope-escape name)
```

to bind `name` as a scope-application macro that escapes outside of all scopes back to the normal module scope.

Macros that expand to uses of scope application macros should work. Scope application macros will not work properly outside of the module in which they are defined, and they will not be exported by `(provide (all-defined-out))` for that reason.

## Installation

```
raco pkg install https://github.com/michaelballantyne/multiscope2.git
```

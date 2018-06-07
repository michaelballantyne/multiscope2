#lang racket/base

(require
  (for-syntax
   racket/base
   syntax/parse
   racket/syntax
   libuuid))

(provide
 define-scope
 define-scope-escape)

(begin-for-syntax
  (define all-introducers '())

  (define (register-introducer! intro)
    (set! all-introducers (cons intro all-introducers)))
  
  (define (get-current-module-namespace-introducer)
    (define ns (variable-reference->namespace (syntax-local-eval #'(#%variable-reference))))
    (define with-ns-scopes
      (parameterize ([current-namespace ns])
        (namespace-syntax-introduce (datum->syntax #f 'foo))))
    (make-syntax-delta-introducer
     with-ns-scopes
     (datum->syntax #f 'foo)))

  (define (remove-all-scopes stx)
    (for/fold ([stx stx])
              ([introducer all-introducers])
      (introducer stx 'remove)))
  
  (define (apply-scope this-intro mod-intro stx)
    (this-intro
     (remove-all-scopes
      (mod-intro stx 'remove))
     'add))
  
  (define (make-scope-application-transformer this-introducer mod-intro)
    (syntax-parser
      [(_ body ...)
       #`(begin . #,(apply-scope this-introducer mod-intro #'(body ...)))]))

  (define (make-scope-escape-transformer mod-intro)
    (syntax-parser
      [(_ body ...)
       #`(begin . #,(mod-intro (remove-all-scopes #'(body ...)) 'add))])))

(define-syntax define-scope
  (syntax-parser
    [(_ name:id initial-imports ...)
     (define mod-intro (get-current-module-namespace-introducer))
     (define uuid (string->symbol (uuid-generate)))
     (define/syntax-parse unscoped-name
       (mod-intro #'name 'remove))
     (define/syntax-parse (scoped-imports ...)
       (apply-scope (make-interned-syntax-introducer uuid) mod-intro #'(initial-imports ...)))
     #`(begin
         (begin-for-syntax
           (define this-intro (make-interned-syntax-introducer '#,uuid))
           (register-introducer! this-intro))
         (define-syntax the-scope-macro
           (make-scope-application-transformer
            this-intro
            (make-syntax-delta-introducer
             (quote-syntax #,(mod-intro #'foo))
             (quote-syntax foo))))
         (define-syntax unscoped-name
           (make-rename-transformer
            (syntax-property (quote-syntax the-scope-macro)
                             'not-provide-all-defined
                             #t)))
         (require scoped-imports ...))]))

(define-syntax define-scope-escape
  (syntax-parser
    [(_ name:id)
     (define mod-intro (get-current-module-namespace-introducer))
     (define/syntax-parse unscoped-name
       (mod-intro #'name 'remove))
     #`(define-syntax unscoped-name
         (make-scope-escape-transformer
          (make-syntax-delta-introducer
           (quote-syntax #,(mod-intro #'foo))
           (quote-syntax foo))))]))

#lang racket

(require (only-in "jtilles/prelude.rkt"
                  difference
                  half-of
                  reciprocal))

(define-signature interval^
  (make-interval
   lower-bound
   upper-bound))

(define-signature interval-arithmetic^
  (add-interval
   mul-interval
   sub-interval
   div-interval))

(define-unit interval-arithmetic@
  (import interval^)
  (export interval-arithmetic^)
  
  (define (add-interval x y)
    (make-interval (+ (lower-bound x) (lower-bound y))
                   (+ (upper-bound x) (upper-bound y))))
  
  (define (mul-interval x y)
    (let ([p1 (* (lower-bound x) (lower-bound y))]
          [p2 (* (lower-bound x) (upper-bound y))]
          [p3 (* (upper-bound x) (lower-bound y))]
          [p4 (* (upper-bound x) (upper-bound y))])
      (make-interval (min p1 p2 p3 p4)
                     (max p1 p2 p3 p4))))
  
  (define (div-interval x y)
    (mul-interval x (recip-interval y)))
  
  (define (recip-interval x)
    (make-interval (reciprocal (upper-bound x))
                   (reciprocal (lower-bound x))))
  
  ;; Exercise 2.8
  (define (sub-interval x y)
    (let ([lbx (lower-bound x)] [ubx (upper-bound x)]
          [lby (lower-bound y)] [uby (upper-bound y)])
      (make-interval (lbx . - . uby)
                     (ubx . - . lby)))))

(define-unit pair-as-interval@
  (import)
  (export interval^)
  (define (make-interval a b) (cons a b))
  
  ;; Exercise 2.7
  (define (lower-bound x) (car x))
  (define (upper-bound x) (cdr x)))

(module+ |Exercise 2.9|
  
  (define-values/invoke-unit/infer pair-as-interval@)
  (define-values/invoke-unit/infer interval-arithmetic@)
  
  (define (width x)
    (half-of (difference (upper-bound x)
                         (lower-bound x))))
  
  (define a (make-interval 3.5 4))
  (define b (make-interval 7   13))
  
  (width a) ;= 0.25
  (width b) ;= 3
  
  (width (add-interval a b)) ;= 3.25
  (+ (width a) (width b)) ;= 3.25
  
  (width (mul-interval a b)) ;= 13.75
  (* (width a) (width b)) ;= 0.75
  )

#|
View the above by executing in a REPL:
```racket
(require (submod "." |Exercise 2.9|))
```
|#


;; Exercise 2.10
(define (div-interval x y)
  (if (= (lower-bound x) (upper-bound x))
      (error "Width of the interval must be non-zero.")
      (mul-interval x (recip-interval y))))

;; Exercise 2.11 is the nine possibilities thing.

;; Cf. "Interval by additive tolerance"
(define (make-center-width c w)
  (make-interval (- c w) (+ c w)))
(define (center i)
  (half-of (+ (lower-bound i) (upper-bound i))))
(define (width i)
  (half-of (- (upper-bound i) (lower-bound i))))

;; Exercise 2.12
#;
(define (make-center-percent c p)
  (make-interval (- c (* c p))
                 (+ c (* c p))))
(define (make-center-percent c p)
  (let ([width (* c p)])
    (make-interval (- c width) (+ c width))))
;; Existential Risk Hedging Contract

(define-data-var next-policy-id uint u0)

(define-map insurance-policies
  { policy-id: uint }
  {
    universe: (string-ascii 64),
    risk-type: (string-ascii 64),
    coverage-amount: uint,
    premium: uint,
    expiration: uint,
    status: (string-ascii 20)
  }
)

(define-public (create-policy (universe (string-ascii 64)) (risk-type (string-ascii 64))
                              (coverage-amount uint) (premium uint) (duration uint))
  (let
    ((policy-id (+ (var-get next-policy-id) u1))
     (expiration (+ block-height duration)))
    (var-set next-policy-id policy-id)
    (ok (map-set insurance-policies
      { policy-id: policy-id }
      {
        universe: universe,
        risk-type: risk-type,
        coverage-amount: coverage-amount,
        premium: premium,
        expiration: expiration,
        status: "active"
      }
    ))
  )
)

(define-public (claim-insurance (policy-id uint))
  (let
    ((policy (unwrap! (map-get? insurance-policies { policy-id: policy-id }) (err u404))))
    (asserts! (< block-height (get expiration policy)) (err u403))
    (asserts! (is-eq (get status policy) "active") (err u403))
    (ok (map-set insurance-policies
      { policy-id: policy-id }
      (merge policy { status: "claimed" })
    ))
  )
)

(define-read-only (get-policy (policy-id uint))
  (ok (unwrap! (map-get? insurance-policies { policy-id: policy-id }) (err u404)))
)

(define-read-only (is-policy-active (policy-id uint))
  (let
    ((policy (unwrap! (map-get? insurance-policies { policy-id: policy-id }) (err u404))))
    (ok (and (is-eq (get status policy) "active") (< block-height (get expiration policy))))
  )
)


;; Multiversal Scarcity Management Contract

(define-map resource-balance
  { universe: (string-ascii 64), resource: (string-ascii 64) }
  { amount: uint }
)

(define-map resource-limits
  { resource: (string-ascii 64) }
  { max-amount: uint }
)

(define-public (set-resource-limit (resource (string-ascii 64)) (max-amount uint))
  (ok (map-set resource-limits
    { resource: resource }
    { max-amount: max-amount }
  ))
)

(define-public (update-resource-balance (universe (string-ascii 64)) (resource (string-ascii 64)) (amount uint))
  (let
    (
      (current-balance (default-to u0 (get amount (map-get? resource-balance { universe: universe, resource: resource }))))
      (resource-limit (default-to u0 (get max-amount (map-get? resource-limits { resource: resource }))))
    )
    (asserts! (<= (+ amount current-balance) resource-limit) (err u401))
    (ok (map-set resource-balance
      { universe: universe, resource: resource }
      { amount: (+ amount current-balance) }
    ))
  )
)

(define-read-only (get-resource-balance (universe (string-ascii 64)) (resource (string-ascii 64)))
  (ok (default-to u0 (get amount (map-get? resource-balance { universe: universe, resource: resource }))))
)

(define-read-only (get-resource-limit (resource (string-ascii 64)))
  (ok (default-to u0 (get max-amount (map-get? resource-limits { resource: resource }))))
)


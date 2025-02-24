;; Inter-universal Value Exchange Contract

(define-data-var next-trade-id uint u0)

(define-map trades
  { trade-id: uint }
  {
    from-universe: (string-ascii 64),
    to-universe: (string-ascii 64),
    from-asset: (string-ascii 64),
    to-asset: (string-ascii 64),
    amount: uint,
    exchange-rate: uint,
    status: (string-ascii 20)
  }
)

(define-public (create-trade (from-universe (string-ascii 64)) (to-universe (string-ascii 64))
                             (from-asset (string-ascii 64)) (to-asset (string-ascii 64))
                             (amount uint) (exchange-rate uint))
  (let
    ((trade-id (+ (var-get next-trade-id) u1)))
    (var-set next-trade-id trade-id)
    (ok (map-set trades
      { trade-id: trade-id }
      {
        from-universe: from-universe,
        to-universe: to-universe,
        from-asset: from-asset,
        to-asset: to-asset,
        amount: amount,
        exchange-rate: exchange-rate,
        status: "open"
      }
    ))
  )
)

(define-public (execute-trade (trade-id uint))
  (let
    ((trade (unwrap! (map-get? trades { trade-id: trade-id }) (err u404))))
    (asserts! (is-eq (get status trade) "open") (err u403))
    (ok (map-set trades
      { trade-id: trade-id }
      (merge trade { status: "executed" })
    ))
  )
)

(define-read-only (get-trade (trade-id uint))
  (ok (unwrap! (map-get? trades { trade-id: trade-id }) (err u404)))
)

(define-read-only (get-exchange-rate (trade-id uint))
  (ok (get exchange-rate (unwrap! (map-get? trades { trade-id: trade-id }) (err u404))))
)


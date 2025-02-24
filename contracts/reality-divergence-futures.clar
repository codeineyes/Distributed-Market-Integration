;; Reality Divergence Futures Contract

(define-data-var next-future-id uint u0)

(define-map futures
  { future-id: uint }
  {
    timeline: (string-ascii 64),
    divergence-point: uint,
    prediction: (string-ascii 256),
    stake: uint,
    resolution-time: uint,
    status: (string-ascii 20)
  }
)

(define-public (create-future (timeline (string-ascii 64)) (divergence-point uint)
                              (prediction (string-ascii 256)) (stake uint) (resolution-time uint))
  (let
    ((future-id (+ (var-get next-future-id) u1)))
    (var-set next-future-id future-id)
    (ok (map-set futures
      { future-id: future-id }
      {
        timeline: timeline,
        divergence-point: divergence-point,
        prediction: prediction,
        stake: stake,
        resolution-time: resolution-time,
        status: "open"
      }
    ))
  )
)

(define-public (resolve-future (future-id uint) (outcome bool))
  (let
    ((future (unwrap! (map-get? futures { future-id: future-id }) (err u404))))
    (asserts! (>= block-height (get resolution-time future)) (err u403))
    (ok (map-set futures
      { future-id: future-id }
      (merge future {
        status: (if outcome "correct" "incorrect")
      })
    ))
  )
)

(define-read-only (get-future (future-id uint))
  (ok (unwrap! (map-get? futures { future-id: future-id }) (err u404)))
)


;; Permissions Management Contract

(define-map permissions
  { app-id: uint, user: principal }
  { role: (string-ascii 20) }
)

(define-public (grant-permission (app-id uint) (user principal) (role (string-ascii 20)))
  (let ((app (unwrap! (contract-call? .core-forge get-app app-id) (err u401))))
    (asserts! (is-eq tx-sender (get owner app)) (err u403))
    (ok (map-set permissions
      { app-id: app-id, user: user }
      { role: role }))
  )
)

(define-read-only (check-permission (app-id uint) (user principal))
  (ok (map-get? permissions {app-id: app-id, user: user}))
)

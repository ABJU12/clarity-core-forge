;; CoreForge Main Contract

;; Constants
(define-constant contract-owner tx-sender)
(define-constant err-owner-only (err u100))
(define-constant err-not-found (err u101))
(define-constant err-unauthorized (err u102))

;; Data Types
(define-map apps 
  { app-id: uint } 
  { 
    owner: principal,
    name: (string-ascii 64),
    description: (string-ascii 256),
    created-at: uint,
    status: (string-ascii 12)
  }
)

(define-data-var next-app-id uint u1)

;; Public Functions
(define-public (create-app (name (string-ascii 64)) (description (string-ascii 256)))
  (let ((app-id (var-get next-app-id)))
    (map-insert apps
      { app-id: app-id }
      {
        owner: tx-sender,
        name: name,
        description: description,
        created-at: block-height,
        status: "active"
      }
    )
    (var-set next-app-id (+ app-id u1))
    (ok app-id))
)

(define-public (update-app (app-id uint) (new-description (string-ascii 256)))
  (let ((app (unwrap! (map-get? apps {app-id: app-id}) (err err-not-found))))
    (asserts! (is-eq (get owner app) tx-sender) (err err-unauthorized))
    (ok (map-set apps
      { app-id: app-id }
      (merge app { description: new-description })))
  )
)

;; Read-only Functions
(define-read-only (get-app (app-id uint))
  (ok (map-get? apps {app-id: app-id}))
)

(define-read-only (get-owner-apps (owner principal))
  (filter map-get? apps (lambda (app) (is-eq (get owner app) owner)))
)

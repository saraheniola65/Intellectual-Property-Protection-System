;; Infringement Detection Contract
;; Manages IP infringement reporting, tracking, and dispute resolution

;; Constants
(define-constant CONTRACT-OWNER tx-sender)
(define-constant ERR-NOT-AUTHORIZED (err u500))
(define-constant ERR-CASE-NOT-FOUND (err u501))
(define-constant ERR-INVALID-INPUT (err u502))
(define-constant ERR-CASE-ALREADY-RESOLVED (err u503))
(define-constant ERR-CANNOT-REPORT-SELF (err u504))

;; Data Variables
(define-data-var next-case-id uint u1)

;; Data Maps
(define-map infringement-cases
  uint
  {
    reporter: principal,
    accused: principal,
    ip-type: (string-ascii 50),
    ip-id: uint,
    evidence: (string-ascii 1000),
    report-date: uint,
    status: (string-ascii 50),
    resolution: (optional (string-ascii 500)),
    resolution-date: (optional uint),
    severity: (string-ascii 20)
  }
)

(define-map reporter-cases principal (list 100 uint))
(define-map accused-cases principal (list 100 uint))
(define-map case-evidence uint (list 10 {evidence-type: (string-ascii 50), description: (string-ascii 500), submitted-by: principal, date: uint}))

;; Private Functions
(define-private (is-valid-ip-type (ip-type (string-ascii 50)))
  (or
    (is-eq ip-type "patent")
    (is-eq ip-type "copyright")
    (is-eq ip-type "trademark")
    (is-eq ip-type "trade-secret")
  )
)

(define-private (is-valid-status (status (string-ascii 50)))
  (or
    (is-eq status "reported")
    (is-eq status "investigating")
    (is-eq status "resolved")
    (is-eq status "dismissed")
    (is-eq status "pending-review")
  )
)

(define-private (is-valid-severity (severity (string-ascii 20)))
  (or
    (is-eq severity "low")
    (is-eq severity "medium")
    (is-eq severity "high")
    (is-eq severity "critical")
  )
)

;; Public Functions

;; Report IP infringement
(define-public (report-infringement (accused principal) (ip-type (string-ascii 50)) (ip-id uint) (evidence (string-ascii 1000)) (severity (string-ascii 20)))
  (let
    (
      (case-id (var-get next-case-id))
      (reporter-list (default-to (list) (map-get? reporter-cases tx-sender)))
      (accused-list (default-to (list) (map-get? accused-cases accused)))
    )
    (asserts! (not (is-eq tx-sender accused)) ERR-CANNOT-REPORT-SELF)
    (asserts! (is-valid-ip-type ip-type) ERR-INVALID-INPUT)
    (asserts! (> (len evidence) u0) ERR-INVALID-INPUT)
    (asserts! (is-valid-severity severity) ERR-INVALID-INPUT)

    (map-set infringement-cases case-id
      {
        reporter: tx-sender,
        accused: accused,
        ip-type: ip-type,
        ip-id: ip-id,
        evidence: evidence,
        report-date: block-height,
        status: "reported",
        resolution: none,
        resolution-date: none,
        severity: severity
      }
    )

    (map-set reporter-cases tx-sender (unwrap! (as-max-len? (append reporter-list case-id) u100) ERR-INVALID-INPUT))
    (map-set accused-cases accused (unwrap! (as-max-len? (append accused-list case-id) u100) ERR-INVALID-INPUT))
    (var-set next-case-id (+ case-id u1))

    (ok case-id)
  )
)

;; Update case status (contract owner only)
(define-public (update-case-status (case-id uint) (new-status (string-ascii 50)))
  (let
    (
      (case (unwrap! (map-get? infringement-cases case-id) ERR-CASE-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (is-valid-status new-status) ERR-INVALID-INPUT)
    (asserts! (not (or (is-eq (get status case) "resolved") (is-eq (get status case) "dismissed"))) ERR-CASE-ALREADY-RESOLVED)

    (map-set infringement-cases case-id
      (merge case { status: new-status })
    )

    (ok true)
  )
)

;; Resolve case
(define-public (resolve-case (case-id uint) (resolution (string-ascii 500)))
  (let
    (
      (case (unwrap! (map-get? infringement-cases case-id) ERR-CASE-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len resolution) u0) ERR-INVALID-INPUT)
    (asserts! (not (or (is-eq (get status case) "resolved") (is-eq (get status case) "dismissed"))) ERR-CASE-ALREADY-RESOLVED)

    (map-set infringement-cases case-id
      (merge case {
        status: "resolved",
        resolution: (some resolution),
        resolution-date: (some block-height)
      })
    )

    (ok true)
  )
)

;; Add evidence to case
(define-public (add-evidence (case-id uint) (evidence-type (string-ascii 50)) (description (string-ascii 500)))
  (let
    (
      (case (unwrap! (map-get? infringement-cases case-id) ERR-CASE-NOT-FOUND))
      (current-evidence (default-to (list) (map-get? case-evidence case-id)))
      (evidence-record {evidence-type: evidence-type, description: description, submitted-by: tx-sender, date: block-height})
    )
    (asserts! (or
      (is-eq tx-sender (get reporter case))
      (is-eq tx-sender (get accused case))
      (is-eq tx-sender CONTRACT-OWNER)
    ) ERR-NOT-AUTHORIZED)
    (asserts! (> (len evidence-type) u0) ERR-INVALID-INPUT)
    (asserts! (> (len description) u0) ERR-INVALID-INPUT)
    (asserts! (not (or (is-eq (get status case) "resolved") (is-eq (get status case) "dismissed"))) ERR-CASE-ALREADY-RESOLVED)

    (map-set case-evidence case-id
      (unwrap! (as-max-len? (append current-evidence evidence-record) u10) ERR-INVALID-INPUT))

    (ok true)
  )
)

;; Dismiss case
(define-public (dismiss-case (case-id uint) (reason (string-ascii 500)))
  (let
    (
      (case (unwrap! (map-get? infringement-cases case-id) ERR-CASE-NOT-FOUND))
    )
    (asserts! (is-eq tx-sender CONTRACT-OWNER) ERR-NOT-AUTHORIZED)
    (asserts! (> (len reason) u0) ERR-INVALID-INPUT)
    (asserts! (not (or (is-eq (get status case) "resolved") (is-eq (get status case) "dismissed"))) ERR-CASE-ALREADY-RESOLVED)

    (map-set infringement-cases case-id
      (merge case {
        status: "dismissed",
        resolution: (some reason),
        resolution-date: (some block-height)
      })
    )

    (ok true)
  )
)

;; Read-only Functions

;; Get case details
(define-read-only (get-case (case-id uint))
  (map-get? infringement-cases case-id)
)

;; Get cases by reporter
(define-read-only (get-reporter-cases (reporter principal))
  (map-get? reporter-cases reporter)
)

;; Get cases by accused
(define-read-only (get-accused-cases (accused principal))
  (map-get? accused-cases accused)
)

;; Get case evidence
(define-read-only (get-case-evidence (case-id uint))
  (map-get? case-evidence case-id)
)

;; Check if case is resolved
(define-read-only (is-case-resolved (case-id uint))
  (match (map-get? infringement-cases case-id)
    case (or (is-eq (get status case) "resolved") (is-eq (get status case) "dismissed"))
    false
  )
)

;; Get cases by IP type and ID
(define-read-only (get-cases-by-ip (ip-type (string-ascii 50)) (ip-id uint))
  ;; This would require additional indexing in a real implementation
  ;; For now, returns none as a placeholder
  none
)

;; Get next case ID
(define-read-only (get-next-case-id)
  (var-get next-case-id)
)

;; Get case count by status
(define-read-only (get-case-status-summary)
  ;; This would require additional tracking in a real implementation
  ;; Returns a placeholder response
  {reported: u0, investigating: u0, resolved: u0, dismissed: u0}
)

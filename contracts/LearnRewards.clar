;; LearnRewards Protocol
;; A decentralized education incentive system with NFT certifications

;; Constants
(define-constant MAX_CREDIT_RESERVE u1000000)
(define-constant BASE_COMPLETION_REWARD u10)
(define-constant STREAK_BONUS u2)
(define-constant MAX_STREAK_TIER u7)
(define-constant ERR_INVALID_COURSE u1)
(define-constant ERR_NO_REWARDS u2)
(define-constant ERR_RESERVE_EMPTY u3)
(define-constant BLOCKS_PER_DAY u144)
(define-constant COMMITMENT_BONUS u2)
(define-constant MIN_COMMITMENT_PERIOD u288)
(define-constant EARLY_EXIT_PENALTY u10)

;; Data Variables
(define-data-var total-credits-issued uint u0)
(define-data-var total-courses-completed uint u0)
(define-data-var platform-administrator principal tx-sender)
(define-data-var last-nft-id uint u0)

;; Data Maps
(define-map student-courses principal uint)
(define-map student-rewards principal uint)
(define-map course-enrollment-block principal uint)
(define-map learning-streak principal uint)
(define-map last-completion-block principal uint)
(define-map staked-credits principal uint)
(define-map stake-start-block principal uint)

;; NFT Data Maps
(define-map nft-ownership {id: uint} {owner: principal})
(define-map nft-metadata {id: uint} {course-duration: uint, completion-block: uint, streak-level: uint})
(define-map user-nfts principal (list 100 uint))

;; Public Functions

(define-public (enroll-course (duration uint))
  (begin
    (asserts! (> duration u0) (err ERR_INVALID_COURSE))
    (map-set course-enrollment-block tx-sender burn-block-height)
    (ok true)
  )
)

(define-public (complete-course (duration uint))
  (let ((enrollment-block (default-to u0 (map-get? course-enrollment-block tx-sender))))
    (asserts! (> enrollment-block u0) (err ERR_INVALID_COURSE))
    (asserts! (>= (- burn-block-height enrollment-block) duration) (err ERR_INVALID_COURSE))
    
    (let ((previous-completion-block (default-to u0 (map-get? last-completion-block tx-sender)))
          (streak (default-to u0 (map-get? learning-streak tx-sender)))
          (new-streak (if (< (- burn-block-height previous-completion-block) BLOCKS_PER_DAY)
                        (+ streak u1)
                        u1))
          (capped-streak (if (<= streak MAX_STREAK_TIER) streak MAX_STREAK_TIER))
          (reward-amount (+ BASE_COMPLETION_REWARD (* capped-streak STREAK_BONUS)))
          (nft-id (+ (var-get last-nft-id) u1)))
      
      ;; Update student records
      (map-set student-courses tx-sender (+ (default-to u0 (map-get? student-courses tx-sender)) u1))
      (map-set student-rewards tx-sender (+ (default-to u0 (map-get? student-rewards tx-sender)) reward-amount))
      (map-set learning-streak tx-sender new-streak)
      (map-set last-completion-block tx-sender burn-block-height)
      
      ;; Update platform stats
      (var-set total-courses-completed (+ (var-get total-courses-completed) u1))
      (var-set total-credits-issued (+ (var-get total-credits-issued) reward-amount))
      (asserts! (<= (var-get total-credits-issued) MAX_CREDIT_RESERVE) (err ERR_RESERVE_EMPTY))
      
      ;; Mint NFT certification
      (var-set last-nft-id nft-id)
      (map-set nft-ownership {id: nft-id} {owner: tx-sender})
      (map-set nft-metadata {id: nft-id} {course-duration: duration, completion-block: burn-block-height, streak-level: capped-streak})
      
      ;; Add NFT to user's collection
      (let ((user-nft-list (default-to (list) (map-get? user-nfts tx-sender))))
        (map-set user-nfts tx-sender (unwrap-panic (as-max-len? (append user-nft-list nft-id) u100)))
        (ok reward-amount)
      )
    )
  )
)

(define-public (claim-rewards)
  (let ((reward-balance (default-to u0 (map-get? student-rewards tx-sender))))
    (asserts! (> reward-balance u0) (err ERR_NO_REWARDS))
    (map-set student-rewards tx-sender u0)
    (ok reward-balance)
  )
)

;; Staking Features

(define-public (stake-credits (amount uint))
  (begin
    (asserts! (> amount u0) (err ERR_INVALID_COURSE))
    (asserts! (>= (var-get total-credits-issued) amount) (err ERR_RESERVE_EMPTY))
    (map-set staked-credits tx-sender amount)
    (map-set stake-start-block tx-sender burn-block-height)
    (var-set total-credits-issued (- (var-get total-credits-issued) amount))
    (ok amount)
  )
)

(define-public (unstake-credits)
  (let ((staked-amount (default-to u0 (map-get? staked-credits tx-sender)))
        (stake-block (default-to u0 (map-get? stake-start-block tx-sender))))
    
    (asserts! (> staked-amount u0) (err ERR_NO_REWARDS))
    
    (let ((blocks-staked (- burn-block-height stake-block))
          (penalty (if (< blocks-staked MIN_COMMITMENT_PERIOD) 
                     (/ (* staked-amount EARLY_EXIT_PENALTY) u100) 
                     u0))
          (final-amount (- staked-amount penalty)))
      
      (map-set staked-credits tx-sender u0)
      (map-set stake-start-block tx-sender u0)
      (var-set total-credits-issued (+ (var-get total-credits-issued) final-amount))
      (ok final-amount)
    )
  )
)

;; Read-Only Functions

(define-read-only (get-completed-courses (user principal))
  (default-to u0 (map-get? student-courses user))
)

(define-read-only (get-reward-balance (user principal))
  (default-to u0 (map-get? student-rewards user))
)

(define-read-only (get-learning-streak (user principal))
  (default-to u0 (map-get? learning-streak user))
)

(define-read-only (get-platform-stats)
  {
    total-courses-completed: (var-get total-courses-completed),
    total-credits-issued: (var-get total-credits-issued),
    total-nfts-issued: (var-get last-nft-id)
  }
)

;; NFT Read-Only Functions

(define-read-only (get-nft-owner (nft-id uint))
  (let ((nft-data (map-get? nft-ownership {id: nft-id})))
    (if (is-some nft-data)
        (some (get owner (unwrap-panic nft-data)))
        none
    )
  )
)

(define-read-only (get-nft-metadata (nft-id uint))
  (map-get? nft-metadata {id: nft-id})
)

(define-read-only (get-user-nfts (user principal))
  (default-to (list) (map-get? user-nfts user))
)

(define-read-only (get-nft-count)
  (var-get last-nft-id)
)

;; Private Functions

(define-private (is-platform-administrator)
  (is-eq tx-sender (var-get platform-administrator))
)
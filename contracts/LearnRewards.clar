;; LearnRewards Protocol
;; A decentralized education incentive system

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

;; Data Maps
(define-map student-courses principal uint)
(define-map student-rewards principal uint)
(define-map course-enrollment-block principal uint)
(define-map learning-streak principal uint)
(define-map last-completion-block principal uint)
(define-map staked-credits principal uint)
(define-map stake-start-block principal uint)

;; Public Functions

(define-public (enroll-course (duration uint))
  (let
    (
      (student tx-sender)
    )
    (asserts! (> duration u0) (err ERR_INVALID_COURSE))
    (map-set course-enrollment-block student burn-block-height)
    (ok true)
  )
)

(define-public (complete-course (duration uint))
  (let
    (
      (student tx-sender)
      (enrollment-block (default-to u0 (map-get? course-enrollment-block student)))
      (blocks-elapsed (- burn-block-height enrollment-block))
      (previous-completion-block (default-to u0 (map-get? last-completion-block student)))
      (streak (default-to u0 (map-get? learning-streak student)))
      (capped-streak (if (<= streak MAX_STREAK_TIER) streak MAX_STREAK_TIER))
      (reward-amount (+ BASE_COMPLETION_REWARD (* capped-streak STREAK_BONUS)))
    )
    (asserts! (and (> enrollment-block u0) (>= blocks-elapsed duration)) (err ERR_INVALID_COURSE))
    (map-set student-courses student (+ (default-to u0 (map-get? student-courses student)) u1))
    (map-set student-rewards student (+ (default-to u0 (map-get? student-rewards student)) reward-amount))
    (if (< (- burn-block-height previous-completion-block) BLOCKS_PER_DAY)
      (map-set learning-streak student (+ streak u1))
      (map-set learning-streak student u1)
    )
    (map-set last-completion-block student burn-block-height)
    (var-set total-courses-completed (+ (var-get total-courses-completed) u1))
    (var-set total-credits-issued (+ (var-get total-credits-issued) reward-amount))
    (asserts! (<= (var-get total-credits-issued) MAX_CREDIT_RESERVE) (err ERR_RESERVE_EMPTY))
    (ok reward-amount)
  )
)

(define-public (claim-rewards)
  (let
    (
      (student tx-sender)
      (reward-balance (default-to u0 (map-get? student-rewards student)))
    )
    (asserts! (> reward-balance u0) (err ERR_NO_REWARDS))
    (map-set student-rewards student u0)
    (ok reward-balance)
  )
)

;; Staking Features

(define-public (stake-credits (amount uint))
  (let
    (
      (student tx-sender)
    )
    (asserts! (> amount u0) (err ERR_INVALID_COURSE))
    (asserts! (>= (var-get total-credits-issued) amount) (err ERR_RESERVE_EMPTY))
    (map-set staked-credits student amount)
    (map-set stake-start-block student burn-block-height)
    (var-set total-credits-issued (- (var-get total-credits-issued) amount))
    (ok amount)
  )
)

(define-public (unstake-credits)
  (let
    (
      (student tx-sender)
      (staked-amount (default-to u0 (map-get? staked-credits student)))
      (stake-block (default-to u0 (map-get? stake-start-block student)))
      (blocks-staked (- burn-block-height stake-block))
      (penalty (if (< blocks-staked MIN_COMMITMENT_PERIOD) (/ (* staked-amount EARLY_EXIT_PENALTY) u100) u0))
      (final-amount (- staked-amount penalty))
    )
    (asserts! (> staked-amount u0) (err ERR_NO_REWARDS))
    (map-set staked-credits student u0)
    (map-set stake-start-block student u0)
    (var-set total-credits-issued (+ (var-get total-credits-issued) final-amount))
    (ok final-amount)
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
    total-credits-issued: (var-get total-credits-issued)
  }
)

;; Private Functions

(define-private (is-platform-administrator)
  (is-eq tx-sender (var-get platform-administrator))
)
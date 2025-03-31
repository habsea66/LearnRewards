# LearnRewards Protocol

A decentralized education incentive system that rewards continuous learning on the Stacks blockchain.

## Overview

LearnRewards Protocol is designed to incentivize and reward educational activities through a tokenized credit system. By completing courses and maintaining learning streaks, participants earn credits that can be claimed or staked for additional benefits.

## Features

- **Course Completion Rewards**: Earn base credits for completing educational courses
- **Learning Streaks**: Build a streak by completing courses regularly for bonus rewards
- **Credit Staking**: Stake earned credits to demonstrate commitment and earn bonuses
- **Achievement Tracking**: Monitor your learning progress and completed courses on-chain

## How It Works

1. **Enrollment**: Students enroll in courses by specifying the expected duration
2. **Completion**: Upon completing a course, students receive base rewards plus streak bonuses
3. **Streaks**: Maintaining a consistent learning schedule (daily completions) increases streak multipliers
4. **Claiming**: Earned credits can be claimed at any time
5. **Staking**: Optional staking of credits for longer-term commitment benefits

## Technical Details

### Reward Structure

- Base completion reward: 10 credits per course
- Streak bonus: 2 additional credits per streak tier (up to 7 tiers)
- Maximum potential reward per completion: 24 credits (10 base + 14 streak bonus)
- Total credit reserve: 1,000,000 credits

### Streak Mechanics

- Daily course completions build your streak tier
- Missing a day resets your streak to tier 1
- Each tier increases your rewards by 2 credits
- Maximum streak tier is 7 (for a 14 credit bonus)

### Staking System

- Credits can be staked to demonstrate commitment
- Minimum commitment period: 288 blocks (approximately 2 days)
- Early exit penalty: 10% of staked amount
- Successful completion of commitment period returns 100% of staked credits

## Usage

### For Students

```clarity
;; Enroll in a course with specified duration
(contract-call? .learn-rewards enroll-course u100)

;; Complete a course after required duration
(contract-call? .learn-rewards complete-course u100)

;; Check your current reward balance
(contract-call? .learn-rewards get-reward-balance tx-sender)

;; Claim your earned rewards
(contract-call? .learn-rewards claim-rewards)

;; Stake your credits for a commitment period
(contract-call? .learn-rewards stake-credits u50)

;; Unstake your credits after commitment period
(contract-call? .learn-rewards unstake-credits)
```

### For Platform Administrators

```clarity
;; View platform statistics
(contract-call? .learn-rewards get-platform-stats)
```

## Getting Started

1. Deploy the LearnRewards contract to a Stacks blockchain node
2. Enroll in your first course by calling `enroll-course`
3. Complete the course after the required duration
4. Build your streak by completing courses daily
5. Claim or stake your rewards

## Future Development

- Integration with educational content providers
- Expansion of reward tiers and specialized learning paths
- Community governance of protocol parameters
- NFT certifications for significant achievements
- Cross-platform educational credential verification

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
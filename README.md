# LearnRewards Protocol

A decentralized education incentive system that rewards continuous learning on the Stacks blockchain with verifiable NFT certifications.

## Overview

LearnRewards Protocol is designed to incentivize and reward educational activities through a tokenized credit system. By completing courses and maintaining learning streaks, participants earn credits that can be claimed or staked for additional benefits. Additionally, learners receive NFT certifications as verifiable proof of their educational achievements.

## Features

- **Course Completion Rewards**: Earn base credits for completing educational courses
- **Learning Streaks**: Build a streak by completing courses regularly for bonus rewards
- **Credit Staking**: Stake earned credits to demonstrate commitment and earn bonuses
- **Achievement Tracking**: Monitor your learning progress and completed courses on-chain
- **NFT Certifications**: Receive unique, transferable NFTs for each course completion
- **Verifiable Credentials**: Share and prove your educational achievements with blockchain-backed NFTs

## How It Works

1. **Enrollment**: Students enroll in courses by specifying the expected duration
2. **Completion**: Upon completing a course, students receive base rewards plus streak bonuses and an NFT certification
3. **Streaks**: Maintaining a consistent learning schedule (daily completions) increases streak multipliers
4. **Claiming**: Earned credits can be claimed at any time
5. **Staking**: Optional staking of credits for longer-term commitment benefits
6. **NFT Management**: Certifications can be viewed and transferred to other users

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

### NFT Certification System

- Each course completion generates a unique NFT certification
- NFTs contain metadata about the course, completion date, and streak level
- Certifications are transferable between users
- Each user can hold up to 100 certification NFTs

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

;; View your NFT certifications
(contract-call? .learn-rewards get-user-nfts tx-sender)

;; Transfer an NFT certification to another user
(contract-call? .learn-rewards transfer-nft u1 'ST1PQHQKV0RJXZFY1DGX8MNSNYVE3VGZJSRTPGZGM)
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
6. View and manage your NFT certifications

## Future Development

- Integration with educational content providers
- Expansion of reward tiers and specialized learning paths
- Community governance of protocol parameters
- Enhanced NFT metadata and visual representations
- Cross-platform educational credential verification
- Marketplace for trading educational certifications

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.
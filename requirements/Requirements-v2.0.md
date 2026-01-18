# Pinball Game v2.0 - Requirements Specification

## Document Information

- **Version**: 2.0
- **Inherits From**: Requirements v1.0 (all v1.0 requirements maintained)
- **Platform**: Mobile (iOS, Android) - Primary; Desktop support maintained
- **Last Updated**: 2024

---

## 1. Functional Requirements (Inherited from v1.0 + Enhancements)

### 1.1 Core Gameplay (Inherited)

All v1.0 core gameplay requirements (FR-1.1 through FR-1.10) are maintained and must be satisfied. See Requirements.md for complete v1.0 specifications.

**Summary of Inherited Requirements**:
- Ball physics (FR-1.1)
- Flipper controls (FR-1.2)
- Ball queue system (FR-1.3)
- Ball launching (FR-1.4)
- Playfield boundaries (FR-1.5)
- Obstacles (FR-1.6)
- Scoring system (FR-2.1)
- Game state management (FR-3.1, FR-3.2)
- UI elements (FR-4.1, FR-4.2)
- Sound effects (FR-5.1)
- Launcher system (FR-6.1, FR-6.2, FR-6.3)
- **Maze Pipe System** (v1.0 Feature - FR-1.7):
  - TileMap-based maze pipe system must guide balls through channels
  - MazePipeManager must load maze layouts from JSON files or create default paths
  - Maze pipe walls must use collision layer 4 (Walls layer)
  - Maze pipe physics: friction 0.1, bounce 0.3 (low friction for smooth ball flow)
  - Maze channel width: 2-3 tiles wide (64-96 pixels) for ball passage
  - Ball release position: (720, 150) - above maze entry
  - ObstacleSpawner must avoid spawning obstacles on maze tiles (maze-aware spawning)
- Holds system (FR-7.1)
- Ramps and rails (FR-8.1, FR-8.2)
- Game flow (FR-9.1, FR-9.2, FR-9.3)
- Debug system (FR-10.1, FR-10.2, FR-10.3)

### 1.2 v2.0 NEW Requirements: Monetization Systems

#### FR-v2.1: Currency System
- **FR-v2.1.1**: Dual currency system must exist: Coins (earnable) and Gems (premium)
- **FR-v2.1.2**: Coins must be earned from:
  - Score conversion: 1 coin per 100 points
  - Hold entry bonus: Hold point value / 10 coins
  - Daily login rewards: 100-500 coins (scaling with streak)
  - Daily challenges: 50-200 coins per challenge
  - Rewarded ads: 250 coins per ad (max 3 ads/day)
  - Battle Pass free track: 100-500 coins per tier
- **FR-v2.1.3**: Gems must be earned from:
  - Rewarded ads: 5 gems per ad (max 3 ads/day = 15 gems/day)
  - Daily login rewards: 10-50 gems (rare, high streak days)
  - Battle Pass: 5-200 gems per tier (free and premium tracks)
  - In-App Purchase: Direct purchase (see FR-v2.4)
- **FR-v2.1.4**: Currency display must be visible in-game (top-right corner)
- **FR-v2.1.5**: Currency must persist between game sessions (save system)
- **FR-v2.1.6**: CurrencyManager must track currency changes and emit signals for UI updates

#### FR-v2.2: Shop System
- **FR-v2.2.1**: Shop scene must be accessible from main menu
- **FR-v2.2.2**: Shop must display items in categories: Balls, Flippers, Ramps, Cosmetics, Specials
- **FR-v2.2.3**: Item cards must show: icon, name, stats, price, ownership status, equip status
- **FR-v2.2.4**: Purchase flow must include: item selection → confirmation dialog → currency deduction → ownership update
- **FR-v2.2.5**: Shop must check currency balance before allowing purchase
- **FR-v2.2.6**: Purchased items must be saved to player data
- **FR-v2.2.7**: Items must be purchasable with coins (common items) or gems (premium items)
- **FR-v2.2.8**: Shop must update currency display after purchase
- **FR-v2.2.9**: Item database must be loadable from JSON or Resource files

#### FR-v2.3: Upgrade System
- **FR-v2.3.1**: Ball upgrades must modify physics properties (mass, bounce, friction, damping)
- **FR-v2.3.2**: Ball upgrades must support special abilities: Magnetic attraction, Fire chain reactions, Cosmic anti-gravity
- **FR-v2.3.3**: Flipper upgrades must modify physics properties (length, rotation speed, power multiplier)
- **FR-v2.3.4**: Flipper upgrades must support special variants: Twin segment, Plasma effects, Turbo speed
- **FR-v2.3.5**: Special ramps must provide session-based effects: Multiplier, Bank Shot, Accelerator
- **FR-v2.3.6**: Upgrades must be equippable in Customize scene or Shop scene
- **FR-v2.3.7**: Equipped upgrades must apply to next game session
- **FR-v2.3.8**: Upgrades must have visual effects (particles, shaders, trails)
- **FR-v2.3.9**: Default items (Standard Ball, Standard Flipper) must be free and available to all players

#### FR-v2.4: In-App Purchase (IAP) System
- **FR-v2.4.1**: IAP system must support iOS (StoreKit) and Android (Google Play Billing)
- **FR-v2.4.2**: Gem packages must be available: 100 ($0.99), 550 ($4.99), 1200 ($9.99), 2500 ($19.99)
- **FR-v2.4.3**: Starter packs must be available: Starter Pack ($2.99), Premium Starter ($4.99)
- **FR-v2.4.4**: IAP flow must include: product selection → platform purchase dialog → receipt validation → currency grant
- **FR-v2.4.5**: Purchase receipts must be validated (server-side recommended)
- **FR-v2.4.6**: Restore purchases functionality must be available
- **FR-v2.4.7**: IAP abstraction layer must support platform-specific implementations
- **FR-v2.4.8**: Failed purchases must show error messages to user

#### FR-v2.5: Advertisement Integration
- **FR-v2.5.1**: Rewarded ads must be available: Watch for coins (250), gems (5), or extra ball
- **FR-v2.5.2**: Rewarded ads must have daily limit: 3 ads per day
- **FR-v2.5.3**: Rewarded ad button must appear after ball loss (5 second window)
- **FR-v2.5.4**: Rewarded ads must be available in shop scene
- **FR-v2.5.5**: Interstitial ads must show after game session ends (every 3rd session, 1 hour cooldown)
- **FR-v2.5.6**: Ad system must support AdMob (primary) and Unity Ads (fallback)
- **FR-v2.5.7**: Ad abstraction layer must support platform-specific implementations
- **FR-v2.5.8**: Ad rewards must be granted only after ad completion
- **FR-v2.5.9**: Ad watch count must be tracked and reset daily at midnight

#### FR-v2.6: Battle Pass System
- **FR-v2.6.1**: Battle Pass must have 30-day seasons with 50 tiers
- **FR-v2.6.2**: XP must be earned from: score (1 XP per 50 points), obstacle hits (1 XP per 10), hold entries (10 XP)
- **FR-v2.6.3**: Tiers must unlock based on XP thresholds (increasing requirements)
- **FR-v2.6.4**: Free track must be available to all players with common rewards
- **FR-v2.6.5**: Premium track must be unlockable with 100 gems per season
- **FR-v2.6.6**: Rewards must be claimable immediately upon tier unlock
- **FR-v2.6.7**: Battle Pass progress must persist between sessions
- **FR-v2.6.8**: Season must reset after 30 days with new rewards
- **FR-v2.6.9**: Battle Pass UI must show tier progression, rewards, and XP progress

#### FR-v2.7: Daily Systems
- **FR-v2.7.1**: Daily login system must track consecutive day streaks
- **FR-v2.7.2**: Daily login rewards must scale with streak (Day 1: 100 coins → Day 7: 500 coins + 50 gems + exclusive item)
- **FR-v2.7.3**: Streak must reset if player misses a day
- **FR-v2.7.4**: Daily challenges must generate 3 challenges per day
- **FR-v2.7.5**: Challenges must include: score targets, obstacle hits, hold entries, combo challenges
- **FR-v2.7.6**: Challenge progress must track automatically during gameplay
- **FR-v2.7.7**: Challenge rewards must be granted immediately upon completion
- **FR-v2.7.8**: Challenges must refresh at midnight local time

### 1.3 v2.0 NEW Requirements: Mobile Platform Support

#### FR-v2.8: Touch Controls
- **FR-v2.8.1**: Touch controls must be available for mobile platforms
- **FR-v2.8.2**: Left flipper must be controlled by touching left side of screen (bottom 20% height)
- **FR-v2.8.3**: Right flipper must be controlled by touching right side of screen (bottom 20% height)
- **FR-v2.8.4**: Ball release must be controlled by tap on "Release Ball" button
- **FR-v2.8.5**: Launcher must be controlled by hold on "Launch" button
- **FR-v2.8.6**: Touch input must respond within 1 frame (16ms at 60 FPS)
- **FR-v2.8.7**: Visual feedback must be provided for touch zones (highlight on touch)
- **FR-v2.8.8**: Keyboard controls must remain available on desktop platforms

#### FR-v2.9: Mobile UI/UX
- **FR-v2.9.1**: UI must be touch-friendly (minimum 44×44 pixel touch targets)
- **FR-v2.9.2**: UI must support portrait and landscape orientations
- **FR-v2.9.3**: Instructions label must be hidden on mobile to save screen space
- **FR-v2.9.4**: On-screen buttons must be clearly visible and accessible
- **FR-v2.9.5**: Currency display must be visible and tappable (opens shop)

### 1.4 v2.0 NEW Requirements: Data Persistence

#### FR-v2.10: Save System
- **FR-v2.10.1**: Save system must persist: currency, owned items, equipped items, Battle Pass progress, daily login streak, challenge progress
- **FR-v2.10.2**: Save file must be in JSON format at `user://pinball_save.json`
- **FR-v2.10.3**: Save data must be encrypted (optional but recommended)
- **FR-v2.10.4**: Save data must be backed up and restorable
- **FR-v2.10.5**: Save system must handle version migration (v1.0 → v2.0)
- **FR-v2.10.6**: Save system must auto-save periodically (every 30 seconds)
- **FR-v2.10.7**: Save system must save immediately on currency changes and purchases

### 1.5 v2.0 NEW Requirements: Cosmetic System

#### FR-v2.11: Visual Customization
- **FR-v2.11.1**: Ball trails must be customizable: Standard, Fire, Electric, Rainbow, Galaxy
- **FR-v2.11.2**: Table skins must be available: Classic, Neo-Noir, Cyberpunk, Nature, Space
- **FR-v2.11.3**: Flipper skins must be available (visual-only customization)
- **FR-v2.11.4**: Sound packs must be available: Classic, Sci-Fi, Nature, Electronic, Retro
- **FR-v2.11.5**: Cosmetics must not affect gameplay (visual/audio only)
- **FR-v2.11.6**: Cosmetics must be purchasable in shop
- **FR-v2.11.7**: Cosmetics must be equippable in Customize scene

---

## 2. Non-Functional Requirements (Inherited + Enhanced)

### 2.1 Performance (Inherited + Mobile Considerations)

All v1.0 performance requirements (NFR-1.1, NFR-1.2) are maintained.

**v2.0 Enhancements**:
- **NFR-v2.1.1**: Game must maintain 60 FPS on mobile devices (iOS 13+, Android 8.0+)
- **NFR-v2.1.2**: Shop scene must load within 2 seconds
- **NFR-v2.1.3**: Save/load operations must complete within 500ms
- **NFR-v2.1.4**: Particle effects must be limited (max 100 per effect) for performance
- **NFR-v2.1.5**: Special physics effects (magnetic, cosmic) must run at 30Hz instead of 60Hz on mobile

### 2.2 Usability (Enhanced)

All v1.0 usability requirements (NFR-2.1, NFR-2.2) are maintained.

**v2.0 Enhancements**:
- **NFR-v2.2.1**: Shop UI must be intuitive and easy to navigate
- **NFR-v2.2.2**: Purchase flow must be clear and have confirmation dialogs
- **NFR-v2.2.3**: Currency earning must be clearly communicated to players
- **NFR-v2.2.4**: Upgrade effects must be noticeable and explained
- **NFR-v2.2.5**: Touch controls must feel responsive and natural

### 2.3 Code Quality (Inherited)

All v1.0 code quality requirements (NFR-3.1, NFR-3.2) are maintained.

---

## 3. Platform-Specific Requirements

### 3.1 iOS Requirements

- **PLATFORM-iOS-1**: iOS 13.0 or later
- **PLATFORM-iOS-2**: StoreKit integration for IAP
- **PLATFORM-iOS-3**: AdMob SDK integration
- **PLATFORM-iOS-4**: App Store guidelines compliance
- **PLATFORM-iOS-5**: Touch controls implementation
- **PLATFORM-iOS-6**: Save data in iOS Documents directory

### 3.2 Android Requirements

- **PLATFORM-ANDROID-1**: Android 8.0 (API 26) or later
- **PLATFORM-ANDROID-2**: Google Play Billing integration
- **PLATFORM-ANDROID-3**: AdMob SDK integration
- **PLATFORM-ANDROID-4**: Google Play guidelines compliance
- **PLATFORM-ANDROID-5**: Touch controls implementation
- **PLATFORM-ANDROID-6**: Save data in Android app data directory

---

## 4. Economic Balance Requirements

### 4.1 Currency Earning Balance

- **ECON-1**: Free players must be able to earn ~450-600 gems per month through free methods
- **ECON-2**: Free players must be able to purchase 1-2 premium items per month OR Battle Pass unlock
- **ECON-3**: Common items (coins) must be fully accessible to free players
- **ECON-4**: Daily earning limits must prevent currency inflation
- **ECON-5**: Currency conversion rates must be balanced (1 gem ≈ 65 coins equivalent)

### 4.2 Item Pricing Balance

- **ECON-6**: Common ball upgrades: 500-1000 coins
- **ECON-7**: Premium ball upgrades: 50-300 gems
- **ECON-8**: Common flipper upgrades: 1000 coins
- **ECON-9**: Premium flipper upgrades: 75-200 gems
- **ECON-10**: Battle Pass premium unlock: 100 gems per season
- **ECON-11**: Cosmetics: 200-500 coins (common), 50-150 gems (premium)

### 4.3 Non-Predatory Requirements

- **ECON-12**: No pay-to-win mechanics (upgrades provide advantages but don't break balance)
- **ECON-13**: Free players must be able to achieve same gameplay results with time investment
- **ECON-14**: All items must be earnable through gameplay (no paywall-only content)
- **ECON-15**: Default items must provide complete gameplay experience

---

## 5. Security Requirements

### 5.1 Data Protection

- **SEC-1**: Save files must be encrypted (optional but recommended)
- **SEC-2**: IAP receipts must be validated (server-side recommended)
- **SEC-3**: Currency values must have checksums to prevent tampering
- **SEC-4**: Purchase records must be stored securely

### 5.2 Anti-Cheat

- **SEC-5**: Currency earning must be rate-limited
- **SEC-6**: Save file integrity must be verified
- **SEC-7**: Duplicate purchase detection must be implemented
- **SEC-8**: Ad watch limits must be enforced

---

## 6. Integration Requirements

### 6.1 v1.0 Compatibility

- **COMPAT-1**: All v1.0 gameplay mechanics must be preserved
- **COMPAT-2**: Default items (Standard Ball, Standard Flipper) must provide identical experience to v1.0
- **COMPAT-3**: Save system must support migration from v1.0 (if v1.0 had saves)

### 6.2 Platform Integration

- **INTEG-1**: IAP abstraction layer must support iOS and Android
- **INTEG-2**: Ad abstraction layer must support AdMob and Unity Ads
- **INTEG-3**: Platform detection must work correctly
- **INTEG-4**: Desktop platforms must use mock implementations for IAP/ads

---

## 7. Testing Requirements

### 7.1 Unit Testing

- **TEST-1**: CurrencyManager: Test add/spend/balance operations
- **TEST-2**: BattlePassManager: Test XP and tier progression
- **TEST-3**: SaveManager: Test save/load/encryption
- **TEST-4**: ShopManager: Test purchase flow and item ownership

### 7.2 Integration Testing

- **TEST-5**: Purchase flow end-to-end (shop → IAP → currency grant)
- **TEST-6**: Ad reward flow (watch ad → grant reward)
- **TEST-7**: Battle Pass reward claiming flow
- **TEST-8**: Upgrade equip/unequip flow

### 7.3 Platform Testing

- **TEST-9**: IAP on iOS and Android (test purchases)
- **TEST-10**: Ads on both platforms
- **TEST-11**: Save/load on different devices
- **TEST-12**: Performance on low-end mobile devices

---

*All v1.0 requirements are inherited and must be satisfied. This document adds v2.0-specific requirements for monetization, mobile platform support, and enhanced features.*

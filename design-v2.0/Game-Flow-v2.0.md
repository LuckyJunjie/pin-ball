# Pinball Game v2.0 - Game Flow and State Management

## 1. Enhanced Game Flow Overview

### 1.1 High-Level Flow (Enhanced)

```
Application Launch
  ↓
Load Main Menu Scene
  ↓
[Check Daily Login / Challenges]
  ↓
Player Selects Action:
  ├─→ [Play] → Load Main.tscn → Gameplay Flow
  ├─→ [Shop] → Load ShopScene → Shop Flow
  ├─→ [Customize] → Load CustomizeScene → Customize Flow
  ├─→ [Battle Pass] → Load BattlePassScene → Battle Pass Flow
  └─→ [Settings] → Settings Menu
```

### 1.2 Main Menu Flow (NEW)

```
1. Application Launch
   ↓
2. Load MainMenuScene.tscn
   ↓
3. Initialize Autoload Singletons:
   - SaveManager loads player data
   - CurrencyManager loads currency
   - DailyLoginManager checks daily login
   - ChallengeManager checks daily challenges
   - BattlePassManager loads Battle Pass progress
   ↓
4. Display Main Menu:
   - Show currency (coins/gems) in header
   - Show daily login button (with badge if reward available)
   - Show challenge notifications
   - Show Battle Pass progress bar
   ↓
5. Player Selects Action (see flows below)
```

### 1.3 Enhanced Gameplay Flow

```
1. Player Selects "Play" from Main Menu
   ↓
2. Load Main.tscn Scene
   ↓
3. Initialize Game Components:
   - GameManager loads equipped upgrades
   - Apply equipped ball upgrade to BallQueue
   - Apply equipped flipper upgrades
   - Check for equipped special ramps
   ↓
4. Wait for Player to Release Ball (Down Arrow / Touch)
   ↓
5. Ball Drops from Queue (with equipped ball visual)
   ↓
6. Ball Falls to Launcher Through Pipe
   ↓
7. Player Charges and Launches Ball (Space / Touch)
   ↓
8. Ball Travels Through Launcher Ramp to Playfield
   ↓
9. Gameplay Loop (Enhanced):
   - Player Controls Flippers (upgraded variants if equipped)
   - Ball Interacts with Obstacles:
     * Scores points (inherited)
     * Awards coins (NEW: 1 coin per 100 points)
     * Awards Battle Pass XP (NEW: 1 XP per 50 points)
   - Ball Interacts with Special Ramps (if equipped):
     * Multiplier Ramp: Applies score multiplier
     * Bank Shot Ramp: Guides ball to hold
     * Accelerator Ramp: Boosts ball speed
   - Ball Interacts with Holds:
     * Final scoring (inherited)
     * Awards bonus coins (NEW: points / 10)
     * Awards Battle Pass XP (NEW: 10 XP per hold)
   ↓
10. Ball Lost (Enters Hold or Falls Below Flippers)
    ↓
11. Watch Ad Button Appears (5 second window)
    ↓
12. Player Options:
    - Watch Ad for Extra Ball or Coins
    - Release Next Ball from Queue
    ↓
13. Repeat from Step 4 or End Game Session
    ↓
14. Game Session Ends (All Balls Lost)
    ↓
15. Session Summary:
    - Show coins/gems earned
    - Show Battle Pass XP earned
    - Check for interstitial ad (every 3rd session)
    ↓
16. Return to Main Menu
```

---

## 2. Shop Flow (NEW)

### 2.1 Shop Browsing Flow

```
1. Player Selects "Shop" from Main Menu
   ↓
2. Load ShopScene.tscn
   ↓
3. ShopManager Initializes:
   - Load item database
   - Load owned items from SaveManager
   - Load equipped items from GlobalGameSettings
   - Display currency (coins/gems)
   ↓
4. Player Browses Categories:
   - Balls Tab: Show ball upgrades
   - Flippers Tab: Show flipper upgrades
   - Ramps Tab: Show special ramps (session-based)
   - Cosmetics Tab: Show cosmetic items
   - Specials Tab: Show limited offers, gem packages
   ↓
5. Player Selects Item:
   - View item details (stats, price, description)
   - See "BUY" / "OWNED" / "EQUIP" button state
   ↓
6. Player Actions:
   - If not owned: Purchase flow
   - If owned: Equip flow
   - If equipped: Show "EQUIPPED" state
```

### 2.2 Purchase Flow

```
1. Player Clicks "BUY" on Item
   ↓
2. ShopManager Checks:
   - Item price (coins or gems)
   - Player currency balance
   ↓
3. If Insufficient Funds:
   - Show "Insufficient Funds" popup
   - Highlight "Buy Gems" button
   - Offer to watch ad for currency
   ↓
4. If Sufficient Funds:
   - Show purchase confirmation dialog
   - Display item preview, price, current balance
   ↓
5. Player Confirms Purchase
   ↓
6. ShopManager Processes Purchase:
   - CurrencyManager.spend_currency()
   - Mark item as owned
   - SaveManager.save_owned_items()
   ↓
7. Purchase Complete:
   - Show success animation
   - Update currency display
   - Update item card (now shows "OWNED")
   - Auto-equip option (optional)
   ↓
8. If Auto-Equip Enabled:
   - GlobalGameSettings.set_equipped_item()
   - SaveManager.save_equipped_items()
   - Item now active for next game
```

### 2.3 IAP Purchase Flow

```
1. Player Clicks "Buy Gems" Button
   ↓
2. ShopManager Shows Gem Packages:
   - Small Pack: 100 gems - $0.99
   - Medium Pack: 550 gems - $4.99 (Best Value)
   - Large Pack: 1200 gems - $9.99
   - Mega Pack: 2500 gems - $19.99
   ↓
3. Player Selects Package
   ↓
4. IAPManager Initiates Purchase:
   - iOS: StoreKit purchase flow
   - Android: Google Play Billing flow
   ↓
5. Platform Shows Native Purchase Dialog
   ↓
6. Player Confirms Purchase
   ↓
7. Platform Processes Payment
   ↓
8. IAPManager Receives Purchase Result
   ↓
9. Receipt Validation (server-side recommended)
   ↓
10. CurrencyManager Grants Gems
    ↓
11. SaveManager Saves Purchase Record
    ↓
12. ShopManager Updates Currency Display
    ↓
13. Purchase Complete (success notification)
```

---

## 3. Customize Flow (NEW)

### 3.1 Item Customization Flow

```
1. Player Selects "Customize" from Main Menu
   ↓
2. Load CustomizeScene.tscn
   ↓
3. CustomizeManager Initializes:
   - Load owned items by category
   - Load currently equipped items
   ↓
4. Display Categories:
   - Balls (with preview)
   - Flippers (with preview)
   - Trails (with preview)
   - Table Skins (with preview)
   - Flipper Skins (with preview)
   - Sound Packs (with preview)
   ↓
5. Player Selects Category
   ↓
6. Show Owned Items in Category:
   - Highlight currently equipped item
   - Show "EQUIPPED" label on active item
   ↓
7. Player Selects Item to Equip
   ↓
8. Show Item Preview:
   - Visual preview of item
   - Stats comparison (for upgrades)
   ↓
9. Player Clicks "EQUIP"
   ↓
10. CustomizeManager Equips Item:
    - GlobalGameSettings.set_equipped_item()
    - SaveManager.save_equipped_items()
    - Update UI (show "EQUIPPED" on new item)
    ↓
11. Item Now Active for Next Game Session
```

---

## 4. Battle Pass Flow (NEW)

### 4.1 Battle Pass Progression Flow

```
1. Player Selects "Battle Pass" from Main Menu
   ↓
2. Load BattlePassScene.tscn
   ↓
3. BattlePassManager Initializes:
   - Load current season data
   - Load tier progression
   - Load claimed rewards
   ↓
4. Display Battle Pass:
   - Show season info (days remaining)
   - Show current tier and XP progress
   - Show tier list (1-50)
   - Highlight current tier
   - Show locked/completed tiers
   ↓
5. Player Views Tiers:
   - Free track rewards (always visible)
   - Premium track rewards (locked if not purchased)
   ↓
6. Player Actions:
   - Scroll through tiers
   - View reward details
   - Claim unlocked rewards
   - Purchase premium track (if not owned)
```

### 4.2 XP Earning Flow (During Gameplay)

```
1. During Gameplay (obstacle hit, hold entry, etc.)
   ↓
2. GameManager Calculates XP:
   - Score-based: 1 XP per 50 points
   - Obstacle hits: 1 XP per 10 hits
   - Hold entries: 10 XP per entry
   ↓
3. GameManager Calls BattlePassManager.add_xp(amount)
   ↓
4. BattlePassManager Updates XP:
   - Add XP to current tier
   - Check if tier threshold reached
   ↓
5. If Tier Unlocked:
   - BattlePassManager.unlock_tier()
   - Emit tier_unlocked signal
   - UI shows tier unlock notification
   ↓
6. UI Updates:
   - Battle Pass XP bar updates
   - Tier indicator updates
   - Reward claim buttons appear
```

### 4.3 Reward Claiming Flow

```
1. Player Views Unlocked Tier in Battle Pass Scene
   ↓
2. Player Clicks "CLAIM" on Free Track Reward
   ↓
3. BattlePassManager Checks:
   - Tier is unlocked
   - Reward not already claimed
   ↓
4. Grant Rewards:
   - CurrencyManager grants coins/gems
   - ShopManager adds items to owned items
   - SaveManager saves Battle Pass data
   ↓
5. Reward Claimed:
   - Show reward animation
   - Update tier display (show "CLAIMED")
   - Update currency display
```

### 4.4 Premium Track Unlock Flow

```
1. Player Views Battle Pass Scene
   ↓
2. Player Clicks "UNLOCK PREMIUM" Button
   ↓
3. BattlePassManager Checks:
   - Premium not already unlocked
   - Player has 100 gems OR can purchase with IAP
   ↓
4. If Using Gems:
   - CurrencyManager.spend_gems(100)
   - BattlePassManager.unlock_premium_track()
   ↓
5. If Using IAP:
   - IAPManager initiates purchase (100 gem package)
   - After purchase, unlock premium track
   ↓
6. Premium Track Unlocked:
   - Show unlock animation
   - Premium rewards now claimable
   - Update UI (premium rewards highlighted)
```

---

## 5. Ad Reward Flow (NEW)

### 5.1 Rewarded Ad Flow

```
1. Player Loses Ball or Visits Shop
   ↓
2. "Watch Ad" Button Appears:
   - After ball loss: "Watch Ad for Extra Ball" or "Watch Ad for 250 Coins"
   - In shop: "Watch Ad for 250 Coins" or "Watch Ad for 5 Gems"
   ↓
3. AdManager Checks:
   - Can show rewarded ad (limit not reached)
   - Ad is loaded and ready
   ↓
4. Player Taps "Watch Ad" Button
   ↓
5. AdManager Shows Rewarded Ad:
   - Full-screen video ad (15-30 seconds)
   - Player watches or skips (after minimum time)
   ↓
6. Ad Completes:
   - AdManager receives completion callback
   - Determine reward type (coins/gems/extra ball)
   ↓
7. Grant Reward:
   - CurrencyManager grants currency (if coins/gems)
   - OR revive current ball (if extra ball)
   - SaveManager saves ad watch count
   ↓
8. Reward Notification:
   - UI shows reward popup ("+250 Coins!")
   - Currency display updates
   - Ad button updates (remaining count)
```

### 5.2 Interstitial Ad Flow

```
1. Game Session Ends (All Balls Lost)
   ↓
2. GameManager Checks Interstitial Conditions:
   - Is it the 3rd session since last ad?
   - Has 1 hour passed since last interstitial?
   ↓
3. If Conditions Met:
   - AdManager shows interstitial ad
   - Full-screen ad (15-30 seconds, skippable after 5s)
   ↓
4. Ad Closes:
   - AdManager receives close callback
   - Increment games_since_last_interstitial counter
   - Return to main menu or session summary
```

---

## 6. Daily Systems Flow (NEW)

### 6.1 Daily Login Flow

```
1. Application Launch or Return to Main Menu
   ↓
2. DailyLoginManager Checks:
   - Current date vs last login date
   - Whether reward claimed today
   ↓
3. If Reward Available:
   - Show daily login button with badge
   - Display streak day (e.g., "Day 3")
   ↓
4. Player Taps Daily Login Button
   ↓
5. DailyLoginManager Processes:
   - Check if consecutive day (streak continues) or reset
   - Calculate rewards for current day
   - Grant rewards (coins, gems, exclusive item on Day 7)
   ↓
6. Rewards Granted:
   - CurrencyManager adds currency
   - ShopManager adds exclusive item (if Day 7)
   - SaveManager saves login data
   ↓
7. Show Reward Animation:
   - Display rewards received
   - Update currency display
   - Show next day's reward preview
```

### 6.2 Daily Challenge Flow

```
1. Application Launch or Return to Main Menu
   ↓
2. ChallengeManager Checks:
   - Current date vs last challenge refresh date
   - Generate new challenges if new day
   ↓
3. Display Daily Challenges:
   - Show 3 challenges with progress
   - Show rewards (XP and coins)
   ↓
4. During Gameplay:
   - ChallengeManager tracks progress:
     * Score challenges: Track score
     * Obstacle challenges: Track obstacle hits
     * Hold challenges: Track hold entries
   ↓
5. When Challenge Completed:
   - ChallengeManager detects completion
   - Grant rewards (XP and coins)
   - Show completion notification
   - Mark challenge as completed
   ↓
6. Challenge Refresh:
   - At midnight local time
   - Generate 3 new challenges
   - Reset progress
```

---

## 7. Enhanced State Management

### 7.1 Game States (Enhanced)

**Inherited States** (from v1.0):
- Initializing
- Waiting for Release
- Ball at Launcher
- Playing
- Paused
- Ball Ended

**New States** (v2.0):
- Main Menu
- Shop Browsing
- Customizing
- Battle Pass Viewing
- Watching Ad
- Daily Login Claiming

### 7.2 State Transitions (Enhanced)

```
Main Menu → Playing:
  (Player selects "Play")

Playing → Main Menu:
  (Game session ends, or player pauses and quits)

Main Menu → Shop:
  (Player selects "Shop")

Shop → Main Menu:
  (Player clicks back button, or completes purchase)

Main Menu → Customize:
  (Player selects "Customize")

Customize → Main Menu:
  (Player clicks back button, or equips item)

Main Menu → Battle Pass:
  (Player selects "Battle Pass")

Battle Pass → Main Menu:
  (Player clicks back button, or claims rewards)

Playing → Watch Ad:
  (Ball lost, watch ad button appears)

Watch Ad → Playing:
  (Ad completes, ball revived or next ball released)

Playing → Interstitial Ad:
  (Game session ends, conditions met)

Interstitial Ad → Main Menu:
  (Ad closes)
```

---

## 8. Data Flow Diagrams

### 8.1 Currency Earning Flow

```
Gameplay Event (Obstacle Hit / Hold Entry)
  ↓
GameManager Calculates Currency
  ↓
CurrencyManager.add_coins(amount)
  ↓
CurrencyManager Emits currency_changed Signal
  ↓
UI Updates Currency Display
  ↓
SaveManager Saves Currency (periodic)
```

### 8.2 Upgrade Application Flow

```
Game Start
  ↓
GameManager._ready()
  ↓
GlobalGameSettings.get_equipped_items()
  ↓
Load Upgrade Data Resources
  ↓
Apply to Game Objects:
  - Ball: Apply physics + visual effects
  - Flippers: Apply physics + visual effects
  - Ramps: Activate special ramps if equipped
  ↓
Game Objects Now Have Upgrades Active
```

---

*This enhanced game flow maintains all v1.0 gameplay mechanics while adding comprehensive monetization flows that integrate seamlessly with core gameplay.*

# Pinball Game - Game Design Document v2.0

## Document Information

- **Game Title**: Pinball
- **Version**: 2.0
- **Last Updated**: 2024
- **Engine**: Godot 4.5
- **Platform**: Mobile (iOS, Android) - Primary; Desktop support maintained
- **Monetization**: In-App Purchases, Rewarded Ads, Battle Pass

---

## 1. Game Overview

### 1.1 Game Concept

Pinball v2.0 is an enhanced arcade-style pinball game that builds upon v1.0's foundation. It maintains the authentic pinball machine experience while adding monetization systems, upgrade mechanics, and mobile platform support. Players control flippers to keep a ball in play, hit obstacles to score points, and can now customize their experience through a comprehensive shop system with upgradeable balls, flippers, and ramps.

### 1.2 Game Vision

To create an engaging, physics-based pinball experience that captures the excitement of classic pinball machines while providing a sustainable monetization model. v2.0 focuses on mobile platforms with touch controls, offering players meaningful progression through upgrades and cosmetics while maintaining fair gameplay for both free and paying players.

### 1.3 Target Audience

- **Primary**: Mobile casual gamers who enjoy arcade-style games with progression
- **Secondary**: Pinball enthusiasts seeking customizable experiences
- **Tertiary**: Players who enjoy collecting and upgrading game elements
- **New**: Players seeking quick mobile gaming sessions with reward systems

### 1.4 Platform & Engine

- **Engine**: Godot Engine 4.5
- **Platform**: Mobile (iOS, Android) - Primary platform
  - **iOS**: iOS 13.0 or later, iPhone and iPad support
  - **Android**: Android 8.0 (API 26) or later
- **Secondary Platform**: Desktop (Windows, macOS, Linux) - Maintained for development/testing
- **Input**: Touch controls (primary), Keyboard support (desktop)
- **Display**: Responsive layouts supporting various screen sizes (primary: 1080x1920 mobile portrait, landscape support)

### 1.5 Core Gameplay Loop (Enhanced)

1. Game starts with balls in queue (positioned at top area)
2. Player presses Down Arrow (or touch button) to release ball from queue
3. Ball falls to launcher (positioned below queue)
4. Player charges launcher (Space key or touch) and releases to launch ball
5. Ball travels through launcher ramp to playfield
6. Ball interacts with obstacles (scores points on hit, earns currency)
7. Ball interacts with holds (scores final points, ends ball life, awards currency)
8. Ball travels through ramps and rails to bottom area
9. Player uses flippers (upgraded variants available) to hit ball back into playfield
10. When ball enters hold or falls to bottom, next ball can be released
11. **NEW**: Player earns coins from score (1 coin per 100 points)
12. **NEW**: Player earns XP toward Battle Pass progression
13. **NEW**: Player can watch rewarded ads for extra currency or ball revival
14. Repeat until all balls are used (queue refills automatically)
15. **NEW**: Between games, player can visit Shop, Customize items, or check Battle Pass progress

---

## 2. Gameplay Mechanics (Inherited from v1.0 + Enhancements)

### 2.1 Core Mechanics

All v1.0 core mechanics are preserved. See v1.0 GDD sections 2.1-2.3 for complete specifications.

#### Ball Physics (Base)
- Realistic physics-based movement using RigidBody2D
- Gravity: 980.0 units/s² (standard Earth gravity)
- Base bounce coefficient: 0.8 for realistic collisions
- Base friction: 0.3 for smooth movement
- Base mass: 0.5 units
- Damping: 0.05 linear and angular to prevent infinite bouncing
- Circular shape with 8-pixel radius
- Visual: Red circle (can be customized with upgrades)

**v2.0 Enhancement**: Ball physics can be modified by equipped ball upgrades (Heavy, Bouncy, Magnetic, Fire, Cosmic). See Upgrade-Systems.md for detailed specifications.

#### Flipper Control (Base)
- Two flippers (left and right) at the bottom of the playfield
- Rotate from rest position (45° from vertical) to pressed position (±90°)
- Only rotate when button is pressed (not automatic)
- Smooth rotation at 20.0 degrees/second
- Return to rest position when button is released
- Position: Left at x=200, Right at x=600, both at y=550
- Visual: Light blue baseball bat-shaped paddles

**v2.0 Enhancement**: Flipper upgrades available (Long, Power, Twin, Plasma, Turbo) with modified physics and visual effects. See Upgrade-Systems.md for specifications.

#### Ball Queue System
- Displays 4 standby balls positioned at top area (x=720, y=100)
- Balls stacked vertically with 25-pixel spacing
- Queued balls are frozen (physics disabled) and semi-transparent (80% opacity)
- Player presses Down Arrow (or touch button) to release ball from queue
- Ball falls naturally through visible pipe guide to launcher below
- Queue automatically refills when empty
- **v2.0 Enhancement**: Equipped ball visual is reflected in queued balls

#### Launcher System
- Launcher positioned below ball queue on right side (x=720, y=450)
- Ball falls from queue to launcher through visible pipe guide
- Launcher positions ball at launch position automatically
- Player charges launcher by holding Space key (or touch hold)
- Charge rate: 2.0 per second (0.0 to 1.0)
- Launch force: Base 500 to Max 1000 (proportional to charge)
- Launch angle: -15° toward center of playfield
- Launcher has curved ramp component to guide ball to playfield
- Visual feedback: Plunger position and charge meter

#### Obstacle System
- 8 obstacles randomly placed per game
- Sports-themed obstacle types:
  - **Basketball Hoop**: Large circular (30px radius), 20 points, high bounce (0.95)
  - **Baseball Player**: Small circular (8px radius), 5 points, medium bounce (0.8)
  - **Baseball Bat**: Rectangular (40x12px), 15 points, high bounce (0.85), random rotation
  - **Soccer Goal**: Rectangular (50x30px), 25 points, bounce (0.9), random rotation
- Obstacles avoid flipper zones and launcher area
- Minimum 50px distance from playfield walls
- Minimum 80px distance between obstacles
- 0.5-second cooldown between scoring hits
- **v2.0 Enhancement**: Obstacle hits award coins in addition to points (1 coin per 100 points)

#### Holds (Target Holes) System
- Multiple holds placed in the playfield
- Holds have varying point values (10, 15, 20, 25, 30, etc.)
- Uses Area2D for detection when ball enters
- When ball enters a hold, that ball's scoring is finalized and points are awarded
- Ball is removed and next ball is prepared
- Visual indicators show point values
- Positioned to avoid interference with flippers and main ball paths
- **v2.0 Enhancement**: Hold entry awards bonus coins (point value / 10 coins)

#### Ramps and Rails System
- Launcher ramp guides ball from launcher to playfield using curved spline
- Multiple ramps placed in playfield to guide ball movement
- Ramps guide ball toward center of playfield
- Ramps guide ball toward bottom narrow space (flipper area)
- Rails placed to guide ball movement and prevent escaping certain areas
- Bottom area has sufficient space for flippers to hit ball
- **v2.0 Enhancement**: Special ramps available (Multiplier, Bank Shot, Accelerator) that can be purchased and equipped. See Upgrade-Systems.md.

### 2.2 Scoring System (Enhanced)

#### Point Values
- **Basketball Hoops**: 20 points per hit (continuous scoring)
- **Baseball Players**: 5 points per hit (continuous scoring)
- **Baseball Bats**: 15 points per hit (continuous scoring)
- **Soccer Goals**: 25 points per hit (continuous scoring)
- **Holds**: Varying point values (10, 15, 20, 25, 30, etc.) - final scoring per ball

#### Scoring Mechanics
- Obstacle hits award points continuously (multiple hits possible per ball)
- Hold entry awards final score for that ball and ends ball life
- Ball can score from obstacles while in play
- Hold scoring finalizes the ball's total score contribution
- **v2.0 NEW**: Score converts to coins (1 coin per 100 points, rounded down)
- **v2.0 NEW**: Score contributes to Battle Pass XP (1 XP per 50 points)

#### Score Display
- Score shown in top-left corner of screen
- Updates immediately when obstacles are hit or holds are entered
- Persists during gameplay
- Resets when game restarts
- **v2.0 NEW**: Currency display shows coins and gems earned during session
- **v2.0 NEW**: Battle Pass XP bar shows progress toward next tier

### 2.3 Currency System (NEW)

#### Coins (Earnable Currency)
- **Earning Methods**:
  - Score conversion: 1 coin per 100 points
  - Hold entry bonus: Hold point value / 10 coins
  - Daily login rewards: 100-500 coins (scaling streak)
  - Daily challenges: 50-200 coins per challenge
  - Rewarded ads: 250 coins per ad (max 3 ads/day)
  - Battle Pass free track rewards: 100-500 coins per tier
- **Usage**:
  - Purchase common ball upgrades (Heavy, Bouncy): 500-1000 coins
  - Purchase common flipper upgrades (Long): 1000 coins
  - Purchase cosmetic items (trails, basic skins): 200-500 coins
  - Activate special ramps for session: 100-300 coins per ramp
- **Daily Earning Limit**: None (earn as much as you can play)

#### Gems (Premium Currency)
- **Earning Methods**:
  - Rewarded ads: 5 gems per ad (max 3 ads/day = 15 gems/day)
  - Daily login rewards: 10-50 gems (rare, high streak days)
  - Battle Pass free track: 5-25 gems per tier (rare)
  - Battle Pass premium track: 50-200 gems per tier (common)
  - In-App Purchase: 100-2500 gems per package ($0.99-$19.99)
- **Usage**:
  - Purchase premium ball upgrades (Magnetic, Fire, Cosmic): 50-300 gems
  - Purchase premium flipper upgrades (Twin, Plasma, Turbo): 75-200 gems
  - Unlock Battle Pass premium track: 100 gems per season
  - Purchase cosmetic premium items (Galaxy trail, Space table skin): 50-150 gems
  - Purchase limited-time offers and starter packs
- **Daily Earning Limit**: 15 gems from ads, additional from Battle Pass/Login

### 2.4 Battle Pass System (NEW)

#### Season Structure
- **Duration**: 30-day seasons
- **Tiers**: 50 tiers per season
- **Progression**: Earn XP from gameplay to unlock tiers
- **Rewards**: Each tier offers rewards on both Free and Premium tracks

#### Free Track Rewards
- Common ball upgrades (coins to purchase)
- Small currency amounts (100-500 coins, 5-25 gems)
- Standard cosmetic items
- Upgrade unlock tokens (allows purchase with coins)

#### Premium Track Rewards (Unlock with 100 gems)
- Exclusive ball and flipper upgrades
- Large currency amounts (500-2000 coins, 50-200 gems)
- Premium cosmetic items (exclusive trails, table skins)
- Exclusive limited-time items

#### XP Earning
- **Score-based**: 1 XP per 50 points scored
- **Obstacle hits**: 1 XP per 10 obstacle hits
- **Hold entries**: 10 XP per hold entry
- **Daily challenges**: 50-200 XP per challenge completion
- **Daily login**: 25 XP bonus

#### Season Reset
- Season ends after 30 days
- Progress resets, new season begins
- Purchased premium track items remain owned
- Unearned rewards are lost (encourages active play)

### 2.5 Daily Systems (NEW)

#### Daily Login Rewards
- **Streak System**: Consecutive day login increases rewards
- **Day 1**: 100 coins
- **Day 2**: 150 coins
- **Day 3**: 200 coins + 10 gems
- **Day 4**: 250 coins
- **Day 5**: 300 coins + 20 gems
- **Day 6**: 400 coins
- **Day 7**: 500 coins + 50 gems + exclusive item
- **Streak Reset**: Miss a day, streak resets to Day 1
- **Bonus Rewards**: Special rewards on milestone days (7, 14, 30 days)

#### Daily Challenges
- **Count**: 3 challenges per day
- **Types**:
  - Score targets: "Score 5000 points in one game" (50 XP, 100 coins)
  - Obstacle hits: "Hit 50 obstacles total" (25 XP, 50 coins)
  - Hold entries: "Enter 3 holds" (50 XP, 150 coins)
  - Combo challenges: "Hit 10 obstacles without losing ball" (75 XP, 200 coins)
- **Refresh**: New challenges at midnight local time
- **Completion**: Challenges auto-complete when conditions met
- **Rewards**: XP and coins awarded immediately upon completion

---

## 3. Game World & Level Design

### 3.1 Playfield Layout (Inherited from v1.0)

- **Dimensions**: 800x600 pixels (base resolution, scales for mobile)
- **Background**: Dark blue-gray (0.1, 0.1, 0.2, 1) - can be customized with table skins
- **Boundaries**: Four walls enclose the playfield:
  - Top wall: 800x20 pixels at y=10
  - Left wall: 20x600 pixels at x=10
  - Right wall: 20x600 pixels at x=790
  - Bottom wall: Split with 100px gap (350px left, 350px right) at y=590

**v2.0 Enhancement**: Table skins can replace background textures and wall colors, maintaining gameplay boundaries.

### 3.2 Obstacle Placement (Inherited from v1.0)

- **Placement Rules**:
  - Random placement at game start
  - Avoid flipper zones (x: 150-250, 550-650, y: 500-600)
  - Avoid launcher zone (x: 350-450, y: 550-600)
  - Minimum 50px from playfield walls
  - Minimum 80px between obstacles
- **Distribution**: Mix of all four sports-themed obstacle types

### 3.3 Boundary System (Inherited from v1.0)

- Ball cannot escape playfield boundaries
- Automatic boundary enforcement if ball escapes
- Boundary limits:
  - Left: x = 20.0
  - Right: x = 780.0
  - Top: y = 20.0
  - Bottom: y = 580.0 (ball falls through gap at y=590)

---

## 4. Game Objects & Entities

### 4.1 Ball (Enhanced)

**Base Properties (Inherited from v1.0)**:
- Type: Dynamic physics object (RigidBody2D)
- Shape: Circle (8-pixel radius)
- Base Physics:
  - Mass: 0.5
  - Gravity scale: 1.0
  - Linear damping: 0.05
  - Angular damping: 0.05
  - Bounce: 0.8
  - Friction: 0.3
- Visual: Red circle (default)
- States:
  - Queued: Frozen, semi-transparent (80% opacity)
  - Active: Physics enabled, fully opaque
  - Lost: Falls below y=800

**v2.0 Upgrade System**:
- Balls can be upgraded with purchased variants
- Upgrades modify physics properties and add special effects
- Upgrade tiers: Standard → Heavy → Bouncy → Magnetic → Fire → Cosmic
- See Upgrade-Systems.md for complete ball upgrade specifications

### 4.2 Flippers (Enhanced)

**Base Properties (Inherited from v1.0)**:
- Type: Kinematic physics object (RigidBody2D, frozen)
- Shape: Baseball bat (ConvexPolygonShape2D)
  - Narrow handle at base (12px wide)
  - Wider hitting surface at tip (28px wide)
  - Length: 64px
- Base Physics:
  - Mass: 1.0
  - Gravity scale: 0.0
  - Freeze: true (kinematic control)
  - Bounce: 0.6
  - Friction: 0.5
- Visual: Light blue baseball bat shape
- Rotation:
  - Rest angle: 45° from vertical (-45° left, +45° right)
  - Pressed angle: 90° from vertical (-90° left, +90° right)
  - Rotation speed: 20.0 degrees/second
- Position: Left at (200, 550), Right at (600, 550)

**v2.0 Upgrade System**:
- Flippers can be upgraded with purchased variants
- Upgrades modify physics properties and add visual effects
- Upgrade types: Standard → Long → Power → Twin → Plasma → Turbo
- See Upgrade-Systems.md for complete flipper upgrade specifications

### 4.3 Obstacles (Inherited from v1.0)

Sports-themed obstacles as specified in v1.0 GDD section 4.3. No v2.0 changes to obstacle types.

### 4.4 Walls (Inherited from v1.0)

Walls as specified in v1.0 GDD section 4.4. Visual customization possible through table skins in v2.0.

### 4.5 Ramps (Enhanced)

**Base Ramps (Inherited from v1.0)**:
- Type: Static boundary (StaticBody2D)
- Curved spline-based ramps guide ball movement
- Physics: Bounce 0.7, Friction 0.3

**v2.0 Special Ramps**:
- **Multiplier Ramp**: Doubles score for 10 seconds after passing through (session-based, costs 100 coins to activate)
- **Bank Shot Ramp**: Applies curved force to guide ball toward target hold (session-based, costs 200 coins to activate)
- **Accelerator Ramp**: Boosts ball speed by 50% when passing through (session-based, costs 150 coins to activate)
- See Upgrade-Systems.md for complete ramp specifications

---

## 5. User Interface (Enhanced)

### 5.1 UI Layout (Inherited from v1.0 + Additions)

**In-Game UI** (during gameplay):
- Playfield Area: 800x600 pixels (main game area)
- UI Overlay: CanvasLayer on top of playfield
- Layout Structure:
  - Score: Top-left corner (20, 20)
  - **NEW**: Currency Display: Top-right corner (shows coins and gems)
  - **NEW**: Battle Pass XP Bar: Below currency (progress to next tier)
  - Instructions: Below score (20, 70) - hidden on mobile, shown on desktop
  - **NEW**: Watch Ad Button: Bottom-center (appears after ball loss, offers revival)
  - Ball Queue: Right side of playfield (750, 300)

**Main Menu UI** (NEW):
- **Play Button**: Start game
- **Shop Button**: Open shop scene
- **Customize Button**: Open customization scene
- **Battle Pass Button**: View current season progress
- **Settings Button**: Audio, controls, account
- **Daily Login Button**: Claim daily rewards (with notification badge)

### 5.2 UI Elements (Enhanced)

#### Score Label (Inherited)
- Position: Top-left corner
- Offset: (20, 20) from top-left
- Size: 180x40 pixels
- Font Size: 32
- Color: White
- Text: "Score: {score}"
- Behavior: Updates immediately when score changes

#### Currency Display (NEW)
- Position: Top-right corner
- Offset: (20, 20) from top-right
- Size: 200x60 pixels
- Components:
  - Coin icon + "Coins: {amount}"
  - Gem icon + "Gems: {amount}"
- Font Size: 20
- Color: Gold for coins, Purple for gems
- Behavior: Updates immediately when currency changes
- Tap to open shop (mobile) or click to open shop (desktop)

#### Battle Pass XP Bar (NEW)
- Position: Below currency display
- Offset: (20, 90) from top-right
- Size: 200x20 pixels
- Visual: Progress bar showing current tier progress
- Text: "Tier {current}/{max} - {xp}/{xp_needed} XP"
- Behavior: Updates as XP is earned
- Tap/click to open Battle Pass scene

#### Watch Ad Button (NEW)
- Position: Bottom-center, appears after ball loss
- Size: 200x60 pixels
- Text: "Watch Ad for Extra Ball" or "Watch Ad for Coins"
- Visual: Button with ad icon
- Behavior: 
  - Appears for 5 seconds after ball loss
  - Disappears if player releases next ball or timeout
  - Triggers rewarded ad on tap/click
  - Shows reward amount (250 coins or extra ball)

#### Instructions Label (Inherited, Hidden on Mobile)
- Position: Below score label
- Offset: (20, 70) from top-left
- Size: 380x80 pixels
- Font Size: 16
- Color: Light gray
- Text: Control instructions (hidden on mobile, shown on desktop)
- **v2.0 Change**: Hidden on mobile to save screen space

#### Ball Queue (Inherited)
- Position: Right side of playfield
- Location: x=750, y=300 (center vertically)
- Visual: Stacked balls, semi-transparent (80% opacity)
- Spacing: 25 pixels between balls
- **v2.0 Enhancement**: Shows equipped ball visual in queued balls

### 5.3 Visual Feedback (Enhanced)

**Inherited Feedback**:
- Score updates immediately when obstacles are hit
- Ball states: Queued (semi-transparent) vs Active (fully opaque)
- Flipper activation: Visual rotation when buttons pressed
- Obstacle hits: Points awarded with cooldown

**v2.0 New Feedback**:
- Currency popups: "+{amount} Coins" or "+{amount} Gems" when earned
- Battle Pass XP popup: "+{amount} XP" when XP is earned
- Upgrade activation: Visual effects when special ball/flipper abilities activate
- Purchase confirmation: Success animation when item purchased
- Ad reward: Reward notification after watching ad

---

## 6. Controls & Input (Enhanced)

### 6.1 Input Mapping (Enhanced)

**Desktop Controls** (Inherited from v1.0):
- Left Flipper: Left Arrow key or A key
- Right Flipper: Right Arrow key or D key
- Release Ball: Down Arrow key
- Charge Launcher: Space key
- Pause: Esc key

**Mobile Touch Controls** (NEW):
- Left Flipper: Touch left side of screen (bottom 20% of screen height)
- Right Flipper: Touch right side of screen (bottom 20% of screen height)
- Release Ball: Tap "Release Ball" button (top-center)
- Charge Launcher: Hold "Launch" button (center-bottom)
- Pause: Tap pause icon (top-left corner)

**UI Controls**:
- Shop: Tap/click "Shop" button
- Customize: Tap/click "Customize" button
- Battle Pass: Tap/click "Battle Pass" button
- Watch Ad: Tap "Watch Ad" button when shown
- Purchase: Tap item card, then confirm

### 6.2 Control Scheme

**Desktop** (Inherited from v1.0):
- Flipper Controls: Press and hold to activate
- Ball Release: Single press Down Arrow
- Launcher Control: Hold Space to charge
- Pause Control: Single press Esc

**Mobile** (NEW):
- Touch Areas: Bottom 20% of screen divided into left/right zones for flippers
- Visual Feedback: Flipper zones highlight when touched
- Button Controls: On-screen buttons for ball release, launcher, pause
- Responsiveness: Touch input responds within 1 frame (16ms at 60 FPS)

### 6.3 Input Behavior

**Responsiveness** (Inherited):
- Input must respond within 1 frame (16ms at 60 FPS)
- Input actions configurable in project.godot

**v2.0 Enhancements**:
- Touch input uses Godot's touch event system
- Visual touch feedback on mobile (haptic vibration optional)
- On-screen button states (pressed/released visual feedback)

---

## 7. Progression & Scoring (Enhanced)

### 7.1 Scoring Mechanics (Enhanced)

**Inherited from v1.0**:
- Scoring Method: Points awarded when ball hits obstacles
- Point Values: Basketball hoops (20), Baseball players (5), Baseball bats (15), Soccer goals (25)
- Hold Entry: Varying point values (10, 15, 20, 25, 30, etc.)
- Cooldown: 0.5 seconds between scoring hits on same obstacle

**v2.0 Enhancements**:
- **Currency Earning**: Score converts to coins (1 coin per 100 points)
- **Battle Pass XP**: Score contributes to XP (1 XP per 50 points)
- **Hold Bonus**: Hold entry awards bonus coins (point value / 10)
- **Multiplier Effects**: Special ramps can multiply score temporarily

### 7.2 Score Display (Enhanced)

**Inherited**:
- Location: Top-left corner of screen
- Format: "Score: {number}"
- Update: Real-time updates on obstacle hits
- Reset: Score resets when game restarts

**v2.0 Additions**:
- Currency display shows coins/gems earned during session
- Battle Pass XP bar shows progress
- Score popups show "+{points} Points, +{coins} Coins, +{xp} XP"

### 7.3 Progression Elements (Enhanced)

**Inherited**:
- Ball Lives: 4 balls per queue (refills automatically)
- Challenge: Keep ball alive as long as possible to maximize score
- Skill Factor: Player skill affects score through ball control and timing

**v2.0 New Progression**:
- **Currency Progression**: Earn coins to purchase upgrades
- **Upgrade Progression**: Unlock and equip better balls/flippers/ramps
- **Battle Pass Progression**: Earn XP to unlock tier rewards
- **Daily Progression**: Complete daily challenges and login streaks
- **Collection Progression**: Collect all ball types, flipper variants, and cosmetics

---

## 8. Visual Design (Enhanced)

### 8.1 Color Scheme (Inherited + Customizable)

**Base Color Scheme** (Inherited from v1.0):
- Background: Dark blue-gray (0.1, 0.1, 0.2, 1)
- Ball: Red (1, 0.2, 0.2, 1)
- Flippers: Light blue (0.2, 0.6, 1, 1)
- Walls: Gray-blue (0.3, 0.3, 0.4, 1)
- Text: White or light gray for high contrast

**v2.0 Customization**:
- **Table Skins**: Multiple themes available (Classic, Neo-Noir, Cyberpunk, Nature, Space)
- **Ball Visuals**: Upgraded balls have unique visual effects (trails, particles, glow)
- **Flipper Skins**: Cosmetic variants available (Fire, Plasma, Cosmic themes)
- **UI Themes**: Shop and menus use consistent theme matching selected table skin

### 8.2 Art Style (Enhanced)

**Inherited**:
- Style: Simple, clean geometric shapes
- Rendering: ColorRect-based visuals for fast rendering
- Visual Hierarchy: Primary (score, active ball, flippers) → Secondary (instructions, queued balls) → Background

**v2.0 Enhancements**:
- **Upgrade Visual Effects**: Particle systems for special ball abilities (fire, magnetic, cosmic)
- **Trail Effects**: Customizable ball trails (Fire, Electric, Rainbow, Galaxy)
- **Shader Effects**: Plasma shaders for premium flippers, cosmic distortion for cosmic ball
- **UI Polish**: Rounded corners, gradients, shadows for modern mobile UI feel

### 8.3 Visual Feedback (Enhanced)

**Inherited**:
- Ball states: Opacity changes (queued vs active)
- Flipper movement: Visual rotation animation
- Score updates: Immediate text updates

**v2.0 New Feedback**:
- **Upgrade Activation**: Visual indicators when special abilities activate (magnetic field, fire trail, cosmic distortion)
- **Currency Earning**: Floating text showing "+{amount} Coins" or "+{amount} Gems"
- **Purchase Confirmation**: Success animation with particle effects
- **Battle Pass Progress**: XP bar fills with animation
- **Ad Reward**: Reward notification with icon and amount

---

## 9. Technical Overview (Enhanced)

### 9.1 Engine & Platform (Enhanced)

**Inherited**:
- Engine: Godot Engine 4.5
- Renderer: Forward Plus renderer
- Physics: Built-in Bullet-based physics engine

**v2.0 Additions**:
- **Platform**: Mobile (iOS, Android) - primary, Desktop maintained
- **IAP Integration**: StoreKit (iOS), Google Play Billing (Android)
- **Ad Integration**: Google AdMob SDK, Unity Ads SDK (abstracted)
- **Save System**: Local file system with encryption support

### 9.2 Performance Targets (Enhanced)

**Inherited**:
- Frame Rate: 60 FPS
- Input Latency: < 16ms (1 frame at 60 FPS)
- Physics: Fixed timestep at 60 FPS
- Rendering: Smooth, no stuttering

**v2.0 Mobile Considerations**:
- **Battery Optimization**: Limit particle effects and shader complexity on low-end devices
- **Memory Management**: Efficient asset loading/unloading for shop and customization scenes
- **Network Optimization**: Minimal network calls for IAP and ads (async, non-blocking)

### 9.3 Physics System (Enhanced)

**Inherited**: All v1.0 physics specifications maintained.

**v2.0 Enhancements**:
- **Special Ball Physics**: Magnetic attraction, fire chain reactions, cosmic gravity wells (see Physics-Specifications-v2.0.md)
- **Upgraded Flipper Physics**: Twin segment joints, power boost calculations (see Physics-Specifications-v2.0.md)
- **Special Ramp Physics**: Multiplier calculations, bank shot curves, accelerator boosts (see Physics-Specifications-v2.0.md)

### 9.4 Architecture (Enhanced)

**Inherited**:
- Pattern: Component-based architecture
- Communication: Signal-based event system
- Scene Structure: Modular scenes for each game element
- State Management: GameManager coordinates game state

**v2.0 Additions**:
- **Monetization Layer**: ShopManager, CurrencyManager, AdManager, BattlePassManager
- **Save Layer**: SaveManager for persistent data
- **Platform Abstraction**: IAP and ad abstraction layers for cross-platform support
- **Scene Structure**: Additional scenes (Shop, Customize, BattlePass)

---

## 10. Audio Design (Inherited)

All v1.0 audio specifications maintained. See v1.0 GDD section 10.

**v2.0 Enhancement**: Sound packs available as cosmetic purchases, allowing theme-based audio replacements (Sci-Fi pack, Nature pack, etc.).

---

## 11. Debug System (Inherited)

All v1.0 debug specifications maintained. See v1.0 GDD section 11.

**v2.0 Addition**: Debug mode can also display currency values, owned items, and Battle Pass progress for testing.

---

## 12. Monetization Systems (NEW)

### 12.1 Shop System

**Overview**: Central hub for purchasing upgrades, cosmetics, and currency.

**Categories**:
- **Balls**: Physics upgrade variants (Heavy, Bouncy, Magnetic, Fire, Cosmic)
- **Flippers**: Control upgrade variants (Long, Power, Twin, Plasma, Turbo)
- **Ramps**: Special ramp types (Multiplier, Bank Shot, Accelerator) - session-based or permanent
- **Cosmetics**: Visual customization (Ball Trails, Table Skins, Flipper Skins, Sound Packs)
- **Specials**: Limited-time offers, starter packs, gem packages

**Purchase Flow**:
1. Browse category
2. Select item
3. View stats and preview
4. Confirm purchase (coins or gems)
5. Item added to inventory
6. Auto-equip option or manual equip in Customize scene

See Monetization-Design.md for complete shop system specifications.

### 12.2 In-App Purchases

**Gem Packages**:
- Small Pack: 100 gems for $0.99
- Medium Pack: 550 gems for $4.99 (Best Value - 50 bonus gems)
- Large Pack: 1200 gems for $9.99 (200 bonus gems)
- Mega Pack: 2500 gems for $19.99 (500 bonus gems)

**Starter Packs** (One-time purchase):
- Starter Pack: 500 gems + Heavy Ball + Long Flipper for $2.99
- Premium Starter: 1000 gems + Magnetic Ball + Power Flipper for $4.99

**Battle Pass Unlock**:
- Premium Track: 100 gems per season (can purchase with IAP gems)

See Monetization-Design.md for complete IAP specifications.

### 12.3 Advertisement Integration

**Rewarded Ads**:
- **Watch for Coins**: 250 coins per ad (max 3 ads/day)
- **Watch for Gems**: 5 gems per ad (max 3 ads/day, same limit as coins)
- **Watch for Extra Ball**: Revive current ball (max 1 per game session)
- **Placement**: Button appears after ball loss, in shop, or in main menu

**Interstitial Ads**:
- **Timing**: After game session ends (when all balls lost)
- **Frequency**: Every 3rd session, minimum 1 hour between ads
- **Duration**: 15-30 seconds (skippable after 5 seconds)

See Monetization-Design.md for complete ad integration specifications.

### 12.4 Battle Pass System

**Structure**:
- 30-day seasons
- 50 tiers per season
- Free track (always available)
- Premium track (unlock with 100 gems)

**Progression**:
- Earn XP from gameplay
- Unlock tiers by reaching XP thresholds
- Claim rewards immediately upon tier unlock
- Premium track rewards require premium unlock to claim

**Rewards**:
- Free track: Common items, small currency, standard upgrades
- Premium track: Exclusive items, large currency, premium upgrades, exclusive cosmetics

See Monetization-Design.md for complete Battle Pass specifications.

---

## 13. Game Flow Summary (Enhanced)

### 13.1 Initialization (Enhanced)

1. Game loads Main Menu scene
2. **NEW**: Check daily login status, show reward claim if available
3. **NEW**: Check daily challenges, show available challenges
4. **NEW**: Load player save data (currency, owned items, equipped items, Battle Pass progress)
5. Player selects "Play" to start game
6. Game loads Main.tscn scene
7. GameManager initializes game state
8. **NEW**: GameManager loads equipped upgrades from GlobalGameSettings
9. **NEW**: Apply equipped ball/flipper/ramp upgrades to game objects
10. BallQueue creates 4 standby balls (with equipped ball visual)
11. Launcher initializes
12. ObstacleSpawner places 8 obstacles randomly
13. Holds are placed in playfield
14. Ramps and rails are placed in playfield
15. Game waits for player to release ball from queue

### 13.2 Core Gameplay Loop (Enhanced)

1. Player presses Down Arrow (or touch) to release ball from queue
2. Ball falls to launcher through visible pipe guide
3. Player charges launcher (Space key or touch) and releases to launch ball
4. Ball travels through launcher ramp to playfield
5. Ball interacts with obstacles and scores points (awards coins and XP)
6. Ball interacts with holds (scores final points, ends ball life, awards bonus coins)
7. Ball travels through ramps and rails to bottom area
8. **NEW**: Special ramps activate effects if equipped and activated
9. Player uses flippers (upgraded variants if equipped) to hit ball back into playfield
10. **NEW**: Watch Ad button appears after ball loss (5 second window)
11. When ball enters hold or falls to bottom, next ball can be released
12. **NEW**: Currency and XP earned during session
13. Queue refills automatically when empty
14. **NEW**: After all balls lost, interstitial ad may show (every 3rd session)
15. **NEW**: Return to main menu, session summary shows coins/gems/XP earned
16. Repeat or visit Shop/Customize/Battle Pass

### 13.3 State Transitions (Enhanced)

**Inherited States** (from v1.0):
- Initializing → Waiting for Release
- Waiting for Release → Ball at Launcher
- Ball at Launcher → Playing
- Playing → Paused
- Paused → Playing
- Playing → Ball Ended
- Ball Ended → Waiting for Release

**v2.0 New States**:
- Main Menu → Shop (opens shop scene)
- Main Menu → Customize (opens customization scene)
- Main Menu → Battle Pass (opens battle pass scene)
- Playing → Watch Ad (shows rewarded ad, returns to Playing with reward)
- Game End → Interstitial Ad (shows interstitial, returns to Main Menu)

---

## 14. Future Enhancements (Updated)

### 14.1 Short-term Enhancements (v2.1)

- **Leaderboards**: Online score tracking and rankings
- **Achievement System**: Unlockable achievements for milestones
- **Multi-ball Mode**: Multiple active balls simultaneously (premium upgrade)
- **Power-ups**: Temporary effects available in shop (score multiplier, slow motion)

### 14.2 Medium-term Enhancements (v2.2)

- **Multiple Playfields**: Different obstacle layouts and themes
- **Custom Obstacle Layouts**: Player-created configurations
- **Social Features**: Share scores, compare with friends
- **Cloud Save**: Cross-device progress synchronization

### 14.3 Long-term Enhancements (v3.0)

- **Campaign Mode**: Progressive levels with increasing difficulty
- **Tournament Mode**: Time-limited competitive events
- **Player vs Player**: Real-time multiplayer pinball
- **User-Generated Content**: Player-created table skins and obstacle layouts

---

## Appendix A: Design Principles (Enhanced)

1. **Physics Realism**: Authentic pinball physics for engaging gameplay (inherited)
2. **Responsiveness**: Instant input feedback for satisfying control (inherited)
3. **Visual Clarity**: Clear distinction between game elements (inherited)
4. **Accessibility**: Simple controls, visible instructions (inherited)
5. **Extensibility**: Architecture supports future feature additions (inherited)
6. **Non-Predatory Monetization**: Free players can progress without paying (NEW)
7. **Balance**: Economy balanced for both free and paying players (NEW)
8. **Mobile-First**: Touch-friendly controls and responsive layouts (NEW)
9. **Clear Value**: Paid items provide meaningful but balanced advantages (NEW)
10. **Data Persistence**: All progress saved and restorable (NEW)

---

## Appendix B: Reference Materials

- **v1.0 Design Documents**: See `../design/` directory
  - Technical-Design.md
  - Component-Specifications.md
  - Physics-Specifications.md
  - UI-Design.md
  - Game-Flow.md
- **v2.0 Design Documents**: See `design-v2.0/` directory
  - Monetization-Design.md
  - Upgrade-Systems.md
  - Component-Specifications-v2.0.md
  - Technical-Design-v2.0.md
  - Physics-Specifications-v2.0.md
  - UI-Design-v2.0.md
  - Game-Flow-v2.0.md
  - Mobile-Platform-Specs.md

---

## Version History

- **v2.0** (2024): Initial v2.0 release with monetization, mobile support, and upgrades
- **v1.0** (2024): Base game with core pinball mechanics (see `../design/GDD.md`)

---

*This document inherits all specifications from v1.0 GDD and adds v2.0 enhancements. For complete technical details, refer to the specific design documents listed in Appendix B.*

# Pinball Game v2.0 - Component Specifications

## Overview

This document specifies all components for Pinball v2.0, including enhanced v1.0 components and new monetization components. All v1.0 components are preserved with additions for upgrade support and monetization integration.

---

## 1. Enhanced v1.0 Components

### 1.1 Ball Component (Enhanced)

#### Scene: Ball.tscn
**Node Structure** (Enhanced):
```
Ball (RigidBody2D)
├── CollisionShape2D
│   └── Shape: CircleShape2D (radius: 8.0)
├── Visual (ColorRect/Sprite2D)
│   └── (Upgrade-dependent visual)
├── TrailManager (Node) - NEW
│   └── TrailLine2D (Line2D) - For trail effects
├── ParticleManager (Node) - NEW
│   └── GPUParticles2D - For special effects (fire, magnetic, cosmic)
└── UpgradeHandler (Node) - NEW
    └── Special ability handlers
```

#### Script: Ball.gd (Enhanced)

**Class**: `extends RigidBody2D`

**Inherited Properties** (from v1.0):
- All v1.0 properties maintained (respawn_y_threshold, boundaries, physics, etc.)

**New Export Variables** (v2.0):
- `upgrade_id: String = "ball_standard"` - Current ball upgrade ID
- `upgrade_data: Resource = null` - UpgradeData resource reference

**New Properties** (v2.0):
- `score_multiplier: float = 1.0` - Score multiplier (from Fire Ball or Multiplier Ramp)
- `is_burning: bool = false` - Fire Ball burn state
- `burn_duration: float = 0.0` - Remaining burn time
- `is_magnetic: bool = false` - Magnetic Ball active state
- `magnetic_force: float = 150.0` - Magnetic attraction force
- `magnetic_radius: float = 150.0` - Magnetic attraction radius
- `is_cosmic: bool = false` - Cosmic Ball active state
- `anti_gravity_strength: float = -300.0` - Anti-gravity force

**Enhanced Methods** (v2.0):
- `_ready()`: Load upgrade from GlobalGameSettings, apply upgrade effects
- `_physics_process(delta)`: Enhanced with special ability processing
- `apply_upgrade(upgrade_id: String)`: Apply ball upgrade (physics + visual)
- `apply_magnetic_attraction(delta: float)`: Magnetic attraction force calculation
- `apply_fire_chain_reaction()`: Fire Ball chain reaction detection
- `apply_cosmic_effects(delta: float)`: Cosmic Ball anti-gravity and time warp
- `start_burning(duration: float)`: Activate Fire Ball burn effect
- `update_trail()`: Update ball trail visual effect

**New Signals** (v2.0):
- `upgrade_applied(upgrade_id: String)`: Emitted when upgrade is applied
- `special_ability_activated(ability_type: String)`: Emitted when special ability activates

**Upgrade Integration**:
- On game start, Ball checks GlobalGameSettings.equipped_items["ball"]
- Loads UpgradeData resource for equipped ball
- Applies physics modifications
- Activates visual effects (trail, particles, shader)
- Enables special abilities

### 1.2 Flipper Component (Enhanced)

#### Scene: Flipper.tscn (Enhanced)
**Node Structure**:
```
Flipper (RigidBody2D)
├── CollisionShape2D
│   └── Shape: ConvexPolygonShape2D (baseball bat shape, upgrade-dependent size)
├── Visual (Polygon2D/Sprite2D)
│   └── (Upgrade-dependent visual)
├── SecondarySegment (RigidBody2D) - NEW (Twin Flipper only)
│   ├── CollisionShape2D
│   └── PinJoint2D - Connects to main flipper
├── ShaderHandler (Node) - NEW (Plasma Flipper)
│   └── ShaderMaterial for plasma effect
└── ParticleHandler (Node) - NEW
    └── GPUParticles2D - Electric sparks (Plasma Flipper)
```

#### Script: Flipper.gd (Enhanced)

**Class**: `extends RigidBody2D`

**Inherited Properties** (from v1.0):
- All v1.0 properties maintained

**New Export Variables** (v2.0):
- `upgrade_id: String = "flipper_standard"` - Current flipper upgrade ID
- `upgrade_data: Resource = null` - UpgradeData resource reference

**New Properties** (v2.0):
- `length: float = 64.0` - Flipper length (modified by Long Flipper)
- `power_multiplier: float = 1.0` - Power multiplier (Power Flipper: 1.3, Plasma: 1.2)
- `rotation_speed_multiplier: float = 1.0` - Speed multiplier (Turbo: 1.5, Plasma: 1.25)
- `secondary_segment: RigidBody2D = null` - Secondary segment (Twin Flipper)
- `secondary_angle_offset: float = 15.0` - Secondary segment angle offset

**Enhanced Methods** (v2.0):
- `_ready()`: Load upgrade from GlobalGameSettings, apply upgrade effects
- `_physics_process(delta)`: Enhanced with upgrade-specific rotation speeds and power
- `apply_upgrade(upgrade_id: String)`: Apply flipper upgrade (physics + visual)
- `create_twin_segment()`: Create secondary segment for Twin Flipper
- `update_plasma_shader()`: Update plasma shader effect (Plasma Flipper)
- `apply_power_boost(ball: RigidBody2D)`: Apply power multiplier on ball hit
- `update_particles()`: Update particle effects (electric sparks)

**Upgrade Integration**:
- On game start, Flipper checks GlobalGameSettings.equipped_items["flipper"]
- Applies to both left and right flippers
- Modifies physics properties (length, power, speed)
- Activates visual effects (shader, particles, secondary segment)

### 1.3 Ramp Component (Enhanced)

#### Scene: Ramp.tscn (Enhanced)
**Node Structure**:
```
Ramp (StaticBody2D)
├── CollisionShape2D
│   └── Shape: SegmentShape2D (curved spline-based)
├── Visual (ColorRect/Line2D)
│   └── (Upgrade-dependent visual for special ramps)
├── EffectArea (Area2D) - NEW (Special ramps only)
│   └── CollisionShape2D - Detection area
├── EffectIndicator (Node2D) - NEW
│   ├── MultiplierLabel (Label) - "×2" for Multiplier Ramp
│   ├── ArrowIndicator (Line2D) - Direction for Bank Shot Ramp
│   └── SpeedLines (GPUParticles2D) - For Accelerator Ramp
└── EffectTimer (Timer) - NEW (Multiplier Ramp only)
```

#### Script: Ramp.gd (Enhanced)

**Class**: `extends StaticBody2D`

**Inherited Properties** (from v1.0):
- Basic ramp properties maintained

**New Export Variables** (v2.0):
- `ramp_type: String = "standard"` - "standard", "multiplier", "bank_shot", "accelerator"
- `is_active: bool = false` - Whether special ramp effect is active
- `multiplier_value: float = 2.0` - Score multiplier (Multiplier Ramp)
- `multiplier_duration: float = 10.0` - Multiplier duration in seconds
- `curve_strength: float = 500.0` - Bank shot curve force
- `speed_boost: float = 1.5` - Speed multiplier (Accelerator Ramp)

**New Methods** (v2.0):
- `activate_special_effect()`: Activate special ramp for session
- `_on_ball_entered_ramp(body: RigidBody2D)`: Detect ball entry for special effects
- `apply_multiplier_effect(ball: RigidBody2D)`: Apply score multiplier to ball
- `apply_bank_shot_effect(ball: RigidBody2D)`: Apply curved force toward target hold
- `apply_accelerator_effect(ball: RigidBody2D)`: Boost ball speed
- `calculate_target_hold() -> Node2D`: Find target hold for bank shot
- `draw_trajectory_line()`: Visual guide for bank shot trajectory

**Special Ramp Integration**:
- Special ramps purchased in shop are "equipped" for session
- On game start, GameManager checks equipped special ramps
- Replaces standard ramps with special variants
- Visual indicators show active special ramps

### 1.4 MazePipeManager Component (v1.0 Feature - Preserved in v2.0)

#### Script: MazePipeManager.gd

**Class**: `extends TileMapLayer`

**Purpose**: TileMap-based maze pipe system for guiding balls through channels before reaching the launcher/playfield

**Extension**: `TileMapLayer` (Godot 4.x)

**Export Variables**:
- `default_maze_layout: String = "level_1"` - Name of default layout to load
- `tile_size: int = 32` - Tile size in pixels
- `maze_layout_data: Dictionary = {}` - Runtime maze data

**Key Methods**:
- `_ready()`: Load default maze layout on startup
- `load_maze_layout_by_name(layout_name: String)`: Load maze layout from JSON file in `levels/maze_layouts/`
- `load_maze_layout(level_data: Dictionary)`: Load maze from dictionary data
- `create_default_maze_path()`: Create default maze path programmatically if JSON not found
- `create_pipe_path(path_points: Array[Vector2i], wall_tile_id: int)`: Create pipe path from point array
- `clear_maze()`: Clear all tiles from the maze
- `is_position_in_maze(pos: Vector2) -> bool`: Check if a world position is inside a maze wall tile

**Maze Layout System**:
- JSON-based level configuration in `levels/maze_layouts/` directory
- Tile coordinate system for maze walls
- Support for vertical, horizontal, corner, and junction tiles
- Extensible for multiple level designs
- Default layout: `level_1.json` creates ball-guiding channels
- Fallback: Programmatic default path generation if JSON not found

**Scene Integration**:
- Located in `PipeGuide/MazePipe` node in `Main.tscn`
- Uses `TileSet` resource: `assets/tilesets/pipe_maze_tileset.tres`
- Replaced `CurvedPipe` StaticBody2D in v1.0

**Physics Configuration**:
- Maze pipe walls: Collision layer 4 (Walls layer)
- Physics material: friction 0.1, bounce 0.3 (low friction for smooth ball flow)
- Tile size: 32 pixels
- Maze channel width: 2-3 tiles wide for ball passage

**Ball Flow**:
- Ball released from queue at position (720, 150) - above maze entry
- Ball falls naturally with gravity through maze channels
- Maze path creates open channel (2-3 tiles wide) for ball to pass through
- Ball exits maze into main playfield area above launcher

**Integration with Other Components**:
- ObstacleSpawner uses `is_position_in_maze()` to avoid spawning obstacles on maze tiles
- BallQueue releases ball at maze entry position (720, 150)
- Launcher receives ball from maze exit

**Signals**:
- None (uses TileMapLayer signals if needed)

**File**: `scripts/MazePipeManager.gd`

**v2.0 Status**: Preserved from v1.0, no changes required for monetization systems

### 1.5 GameManager Component (Enhanced)

#### Script: GameManager.gd (Enhanced)

**New Properties** (v2.0):
- `currency_manager: Node = null` - Reference to CurrencyManager (autoload)
- `shop_manager: Node = null` - Reference to ShopManager
- `save_manager: Node = null` - Reference to SaveManager (autoload)
- `equipped_upgrades: Dictionary = {}` - Currently equipped upgrades

**Enhanced Methods** (v2.0):
- `_ready()`: Load equipped upgrades from GlobalGameSettings, initialize monetization systems
- `apply_equipped_upgrades()`: Apply equipped ball/flipper/ramp upgrades to game objects
- `_on_obstacle_hit(points: int)`: Enhanced to award coins (1 coin per 100 points)
- `_on_hold_entered(points: int)`: Enhanced to award bonus coins (points / 10)
- `award_battle_pass_xp(amount: int)`: Award XP to Battle Pass system
- `end_game_session()`: Calculate and save currency/XP earned, check for interstitial ad

**New Signals** (v2.0):
- `currency_earned(coins: int, gems: int)`: Emitted when currency is earned
- `xp_earned(amount: int)`: Emitted when Battle Pass XP is earned

### 1.6 UI Component (Enhanced)

#### Scene: UI (Enhanced)
**Node Structure**:
```
UI (CanvasLayer)
├── ScoreLabel (Label) - Inherited
├── Instructions (Label) - Inherited (hidden on mobile)
├── CurrencyDisplay (HBoxContainer) - NEW
│   ├── CoinIcon (TextureRect)
│   ├── CoinLabel (Label)
│   ├── GemIcon (TextureRect)
│   └── GemLabel (Label)
├── BattlePassBar (ProgressBar) - NEW
│   └── BattlePassLabel (Label)
├── WatchAdButton (Button) - NEW
│   └── (Appears after ball loss)
└── CurrencyPopup (Label) - NEW
    └── (Floating "+X Coins" text)
```

#### Script: UI.gd (Enhanced)

**New Methods** (v2.0):
- `update_currency_display(coins: int, gems: int)`: Update currency display
- `update_battle_pass_progress(current_tier: int, max_tier: int, xp: int, xp_needed: int)`: Update XP bar
- `show_watch_ad_button(reward_type: String)`: Show watch ad button after ball loss
- `hide_watch_ad_button()`: Hide watch ad button
- `show_currency_popup(amount: int, currency_type: String, position: Vector2)`: Show floating currency popup
- `_on_watch_ad_pressed()`: Handle watch ad button press

---

## 2. New Monetization Components

### 2.1 ShopManager Component

#### Scene: ShopScene.tscn
**Node Structure**:
```
ShopScene (Node2D)
├── CanvasLayer
│   ├── Background (ColorRect)
│   ├── HeaderContainer (HBoxContainer)
│   │   ├── BackButton (TextureButton)
│   │   ├── TitleLabel (Label)
│   │   └── CurrencyDisplay (HBoxContainer)
│   ├── TabContainer
│   │   ├── BallsTab (Tab)
│   │   ├── FlippersTab (Tab)
│   │   ├── RampsTab (Tab)
│   │   ├── CosmeticsTab (Tab)
│   │   └── SpecialsTab (Tab)
│   └── FooterContainer (HBoxContainer)
│       ├── BuyCoinsButton (Button)
│       └── BuyGemsButton (Button)
├── ItemCardContainer (ScrollContainer)
│   └── ItemGrid (GridContainer)
│       └── ItemCard instances (dynamically created)
├── PurchasePopup (PopupPanel)
│   └── PurchaseConfirmationDialog
└── ShopManager (Node)
```

#### Script: ShopManager.gd

**Class**: `extends Node`

**Properties**:
- `item_database: Dictionary = {}` - Loaded item database
- `current_category: String = "balls"` - Currently selected category
- `owned_items: Array[String] = []` - List of owned item IDs
- `equipped_items: Dictionary = {}` - Currently equipped items

**Methods**:
- `_ready()`: Load item database, load player data, initialize UI
- `load_item_database()`: Load items from JSON or Resource files
- `get_items_by_category(category: String) -> Array`: Get items for category
- `purchase_item(item_id: String) -> bool`: Attempt to purchase item
- `can_afford_item(item_id: String) -> bool`: Check if player can afford item
- `equip_item(item_id: String) -> bool`: Equip purchased item
- `get_item_data(item_id: String) -> Dictionary`: Get item data
- `is_item_owned(item_id: String) -> bool`: Check item ownership
- `is_item_equipped(item_id: String) -> bool`: Check if item is equipped
- `show_purchase_confirmation(item_id: String)`: Show confirmation dialog
- `process_purchase(item_id: String)`: Process confirmed purchase
- `update_currency_display()`: Update currency display in UI

**Signals**:
- `item_purchased(item_id: String, success: bool)`: Emitted when purchase completes
- `item_equipped(item_type: String, item_id: String)`: Emitted when item is equipped
- `currency_updated(coins: int, gems: int)`: Emitted when currency changes

### 2.2 CurrencyManager Component (Autoload)

#### Script: CurrencyManager.gd

**Class**: `extends Node` (Autoload singleton)

**Properties**:
- `coins: int = 0` - Current coin balance
- `gems: int = 0` - Current gem balance
- `coins_earned_session: int = 0` - Coins earned in current session
- `gems_earned_session: int = 0` - Gems earned in current session

**Methods**:
- `add_coins(amount: int)`: Add coins, emit signal, save data
- `add_gems(amount: int)`: Add gems, emit signal, save data
- `spend_coins(amount: int) -> bool`: Attempt to spend coins, return success
- `spend_gems(amount: int) -> bool`: Attempt to spend gems, return success
- `can_afford_coins(amount: int) -> bool`: Check if can afford coins
- `can_afford_gems(amount: int) -> bool`: Check if can afford gems
- `get_coins() -> int`: Get current coin balance
- `get_gems() -> int`: Get current gem balance
- `reset_session_earnings()`: Reset session earnings counter
- `save_currency()`: Save currency to SaveManager
- `load_currency()`: Load currency from SaveManager

**Signals**:
- `currency_changed(coins: int, gems: int)`: Emitted when currency changes
- `coins_changed(new_amount: int)`: Emitted when coins change
- `gems_changed(new_amount: int)`: Emitted when gems change

### 2.3 AdManager Component (Autoload)

#### Script: AdManager.gd

**Class**: `extends Node` (Autoload singleton)

**Properties**:
- `rewarded_ads_watched_today: int = 0` - Daily ad watch count
- `last_interstitial_time: float = 0.0` - Last interstitial ad time
- `games_since_last_interstitial: int = 0` - Game counter for interstitial
- `last_ad_watch_date: String = ""` - Date of last ad watch (for daily reset)
- `rewarded_ad_loaded: bool = false` - Whether rewarded ad is ready
- `interstitial_ad_loaded: bool = false` - Whether interstitial ad is ready

**Methods**:
- `_ready()`: Initialize ad SDK, load ads
- `initialize_ads()`: Platform-specific ad SDK initialization
- `load_rewarded_ad()`: Load rewarded ad from provider
- `show_rewarded_ad(reward_type: String) -> bool`: Show rewarded ad, return success
- `load_interstitial_ad()`: Load interstitial ad
- `show_interstitial_ad() -> bool`: Show interstitial ad if conditions met
- `can_show_rewarded_ad() -> bool`: Check if can show rewarded ad (limit not reached)
- `can_show_interstitial_ad() -> bool`: Check if can show interstitial ad (frequency/cooldown)
- `on_rewarded_ad_completed(reward_type: String, amount: int)`: Handle ad completion, grant reward
- `on_rewarded_ad_failed(error: String)`: Handle ad failure
- `on_interstitial_ad_closed()`: Handle interstitial ad close
- `reset_daily_limits()`: Reset daily ad limits at midnight
- `increment_games_counter()`: Increment game counter for interstitial timing

**Signals**:
- `rewarded_ad_completed(reward_type: String, amount: int)`: Emitted when rewarded ad completes
- `rewarded_ad_failed(error: String)`: Emitted when rewarded ad fails
- `interstitial_ad_closed()`: Emitted when interstitial ad closes

### 2.4 BattlePassManager Component (Autoload)

#### Script: BattlePassManager.gd

**Class**: `extends Node` (Autoload singleton)

**Properties**:
- `current_season: int = 1` - Current season number
- `season_start_date: String = ""` - Season start date
- `season_end_date: String = ""` - Season end date
- `current_tier: int = 0` - Current tier (0-50)
- `current_tier_xp: int = 0` - XP in current tier
- `total_xp: int = 0` - Total XP earned this season
- `premium_unlocked: bool = false` - Whether premium track is unlocked
- `claimed_tiers: Array[int] = []` - List of claimed tier numbers
- `tier_rewards: Dictionary = {}` - Tier reward data

**Methods**:
- `_ready()`: Load Battle Pass data, check season status
- `initialize_season()`: Initialize new season
- `check_season_expired() -> bool`: Check if current season has ended
- `add_xp(amount: int)`: Add XP, check for tier unlocks
- `check_tier_unlock()`: Check if enough XP to unlock next tier
- `unlock_tier(tier: int)`: Unlock tier, emit signal
- `claim_tier_reward(tier: int, track: String) -> bool`: Claim reward from tier (free/premium)
- `can_claim_tier(tier: int, track: String) -> bool`: Check if tier reward can be claimed
- `get_tier_xp_requirement(tier: int) -> int`: Get XP needed for tier
- `get_rewards_for_tier(tier: int) -> Dictionary`: Get free and premium rewards for tier
- `unlock_premium_track()`: Unlock premium track (costs 100 gems)
- `reset_season()`: Reset for new season
- `save_battle_pass_data()`: Save to SaveManager
- `load_battle_pass_data()`: Load from SaveManager

**Signals**:
- `xp_earned(amount: int, total_xp: int)`: Emitted when XP is earned
- `tier_unlocked(tier: int)`: Emitted when tier is unlocked
- `reward_claimed(tier: int, track: String, rewards: Dictionary)`: Emitted when reward is claimed
- `premium_unlocked()`: Emitted when premium track is unlocked
- `season_ended()`: Emitted when season ends

### 2.5 SaveManager Component (Autoload)

#### Script: SaveManager.gd

**Class**: `extends Node` (Autoload singleton)

**Properties**:
- `save_file_path: String = "user://pinball_save.json"` - Save file path
- `save_data: Dictionary = {}` - Current save data in memory

**Methods**:
- `_ready()`: Load save data on startup
- `save_all_data()`: Save all player data (currency, owned items, equipped items, Battle Pass, etc.)
- `load_all_data()`: Load all player data
- `save_currency(coins: int, gems: int)`: Save currency data
- `load_currency() -> Dictionary`: Load currency data
- `save_owned_items(items: Array[String])`: Save owned items list
- `load_owned_items() -> Array[String]`: Load owned items list
- `save_equipped_items(items: Dictionary)`: Save equipped items
- `load_equipped_items() -> Dictionary`: Load equipped items
- `save_battle_pass_data(data: Dictionary)`: Save Battle Pass progress
- `load_battle_pass_data() -> Dictionary`: Load Battle Pass progress
- `save_daily_login_data(data: Dictionary)`: Save daily login streak
- `load_daily_login_data() -> Dictionary`: Load daily login streak
- `save_challenge_progress(data: Dictionary)`: Save daily challenge progress
- `load_challenge_progress() -> Dictionary`: Load daily challenge progress
- `encrypt_save_data(data: Dictionary) -> String`: Encrypt save data (optional)
- `decrypt_save_data(encrypted: String) -> Dictionary`: Decrypt save data (optional)
- `backup_save()`: Create backup of save file
- `restore_save()`: Restore from backup

**Save Data Structure**:
```json
{
  "version": "2.0",
  "currency": {
    "coins": 1000,
    "gems": 50
  },
  "owned_items": ["ball_heavy", "flipper_long", ...],
  "equipped_items": {
    "ball": "ball_heavy",
    "flipper": "flipper_long"
  },
  "battle_pass": {
    "season": 1,
    "current_tier": 5,
    "current_tier_xp": 150,
    "total_xp": 500,
    "premium_unlocked": false,
    "claimed_tiers": [1, 2, 3, 4, 5]
  },
  "daily_login": {
    "current_streak": 3,
    "last_login_date": "2024-01-15",
    "reward_claimed_today": false
  },
  "challenges": {
    "daily_challenges": [...],
    "progress": {...}
  }
}
```

### 2.6 GlobalGameSettings Component (Autoload)

#### Script: GlobalGameSettings.gd

**Class**: `extends Node` (Autoload singleton)

**Properties**:
- `equipped_items: Dictionary = {}` - Currently equipped items by category
- `player_currency: Dictionary = {"coins": 0, "gems": 0}` - Player currency (deprecated, use CurrencyManager)
- `debug_mode: bool = false` - Debug mode flag
- `sound_enabled: bool = true` - Sound effects enabled
- `music_enabled: bool = true` - Background music enabled
- `volume: float = 1.0` - Master volume (0.0-1.0)

**Methods**:
- `get_equipped_ball() -> String`: Get equipped ball ID
- `get_equipped_flipper() -> String`: Get equipped flipper ID
- `set_equipped_item(category: String, item_id: String)`: Set equipped item
- `get_equipped_item(category: String) -> String`: Get equipped item ID
- `load_equipped_items()`: Load from SaveManager
- `save_equipped_items()`: Save to SaveManager

### 2.7 DailyLoginManager Component (Autoload)

#### Script: DailyLoginManager.gd

**Class**: `extends Node` (Autoload singleton)

**Properties**:
- `current_streak: int = 0` - Current login streak
- `last_login_date: String = ""` - Last login date
- `reward_claimed_today: bool = false` - Whether reward claimed today

**Methods**:
- `_ready()`: Check daily login status on startup
- `check_daily_login() -> bool`: Check if can claim daily reward
- `claim_daily_reward() -> Dictionary`: Claim daily reward, return rewards
- `get_daily_reward(day: int) -> Dictionary`: Get reward for streak day
- `is_consecutive_day(date: String) -> bool`: Check if date is consecutive
- `reset_streak()`: Reset streak to 1
- `save_daily_login_data()`: Save to SaveManager
- `load_daily_login_data()`: Load from SaveManager

### 2.8 ChallengeManager Component (Autoload)

#### Script: ChallengeManager.gd

**Class**: `extends Node` (Autoload singleton)

**Properties**:
- `daily_challenges: Array[Dictionary] = []` - Current daily challenges
- `challenge_progress: Dictionary = {}` - Progress for each challenge
- `last_challenge_refresh: String = ""` - Last challenge refresh date

**Methods**:
- `_ready()`: Generate or load daily challenges
- `generate_daily_challenges()`: Generate 3 random challenges
- `update_challenge_progress(challenge_id: String, amount: int)`: Update challenge progress
- `complete_challenge(challenge_id: String)`: Complete challenge, award rewards
- `get_challenge_by_id(challenge_id: String) -> Dictionary`: Get challenge data
- `check_challenge_completion(challenge_id: String) -> bool`: Check if challenge complete
- `refresh_challenges_if_needed()`: Refresh challenges at midnight
- `save_challenge_data()`: Save to SaveManager
- `load_challenge_data()`: Load from SaveManager

### 2.9 IAPManager Component (Autoload - Platform-Specific)

#### Script: IAPManager.gd (Abstract Base)

**Class**: `extends Node` (Autoload singleton, platform-specific implementation)

**Properties**:
- `products_loaded: bool = false` - Whether products are loaded
- `available_products: Array[Dictionary] = []` - Available IAP products

**Methods** (Abstract, implemented per platform):
- `initialize() -> void`: Initialize IAP system
- `load_products() -> void`: Load product catalog
- `purchase_product(product_id: String) -> void`: Initiate purchase
- `restore_purchases() -> void`: Restore previous purchases
- `validate_receipt(product_id: String, receipt: String) -> bool`: Validate purchase receipt

**Signals**:
- `products_loaded(products: Array)`: Emitted when products are loaded
- `purchase_completed(product_id: String, success: bool)`: Emitted when purchase completes
- `purchase_failed(product_id: String, error: String)`: Emitted when purchase fails

**Platform Implementations**:
- `IAPManagerIOS.gd`: iOS StoreKit implementation
- `IAPManagerAndroid.gd`: Android Google Play Billing implementation
- `IAPManagerMock.gd`: Mock implementation for development/testing

---

## 3. Component Integration

### 3.1 Initialization Order

1. **Autoload Singletons** (initialize first):
   - GlobalGameSettings
   - CurrencyManager
   - SaveManager
   - AdManager
   - BattlePassManager
   - DailyLoginManager
   - ChallengeManager
   - IAPManager

2. **Main Scene Components**:
   - GameManager (loads equipped items, applies upgrades)
   - BallQueue (creates balls with equipped ball visual)
   - Flippers (apply equipped flipper upgrade)
   - Ramps (check for equipped special ramps)

3. **UI Components**:
   - UI (connects to CurrencyManager, BattlePassManager)
   - ShopManager (connects to CurrencyManager, SaveManager)

### 3.2 Signal Connections

**Currency Flow**:
```
GameManager → CurrencyManager (add_coins on obstacle hit)
CurrencyManager → UI (currency_changed signal)
CurrencyManager → SaveManager (save on change)
```

**Purchase Flow**:
```
ShopManager → CurrencyManager (check can_afford, spend)
CurrencyManager → SaveManager (save after purchase)
ShopManager → GlobalGameSettings (set equipped item)
GlobalGameSettings → SaveManager (save equipped items)
```

**Battle Pass Flow**:
```
GameManager → BattlePassManager (add_xp on gameplay)
BattlePassManager → CurrencyManager (grant rewards)
BattlePassManager → SaveManager (save progress)
BattlePassManager → UI (xp_earned, tier_unlocked signals)
```

**Ad Flow**:
```
UI → AdManager (show_rewarded_ad)
AdManager → CurrencyManager (grant reward on completion)
AdManager → SaveManager (save ad watch count)
```

---

## 4. Component Testing Considerations

### 4.1 Unit Testing
- Test currency calculations (add, spend, balance checks)
- Test upgrade application (physics modifications)
- Test Battle Pass XP and tier progression
- Test save/load functionality

### 4.2 Integration Testing
- Test purchase flow end-to-end
- Test upgrade equip/unequip flow
- Test ad reward flow
- Test Battle Pass reward claiming

### 4.3 Platform Testing
- Test IAP on iOS and Android
- Test ad integration on both platforms
- Test save/load on different devices
- Test cross-platform data compatibility

---

*This component specification maintains backward compatibility with v1.0 while adding comprehensive monetization support. All v1.0 components are enhanced, not replaced, ensuring existing functionality is preserved.*

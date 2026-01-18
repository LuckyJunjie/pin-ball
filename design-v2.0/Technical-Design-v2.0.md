# Pinball Game v2.0 - Technical Design Document

## 1. Architecture Overview

### 1.1 System Architecture (Enhanced)

The v2.0 architecture builds upon v1.0's component-based design, adding a monetization layer with platform abstraction for IAP and ads.

**Architecture Layers**:
```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Shop, Customize, Battle Pass)    │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│        Gameplay Layer (v1.0)            │
│  (Ball, Flipper, Obstacle, GameManager) │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Monetization Layer (v2.0 NEW)      │
│  (Shop, Currency, Ad, BattlePass Mgrs)  │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Platform Abstraction Layer         │
│  (IAP, Ads - iOS/Android/Desktop)       │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│        Data Persistence Layer           │
│  (SaveManager - Local + Cloud ready)    │
└─────────────────────────────────────────┘
```

### 1.2 Component-Based Architecture

**Inherited from v1.0**:
- Each game element is a separate scene
- Signal-based communication
- Modular and reusable components

**v2.0 Enhancements**:
- Autoload singletons for global systems (CurrencyManager, SaveManager, etc.)
- Manager pattern for monetization systems
- Resource-based data storage (ItemData, UpgradeData)

---

## 2. Scene Structure

### 2.1 Main Scene (Main.tscn) - Enhanced

**Structure** (Inherited + Additions):
```
Main (Node2D)
├── Camera2D
├── GameManager (Enhanced with monetization integration)
├── SoundManager (Inherited)
├── Playfield (Node2D)
│   ├── Background (Sprite2D - can be themed)
│   ├── Walls (Node2D)
│   ├── BallQueue (Enhanced - shows equipped ball visual)
│   ├── Launcher (Inherited)
│   ├── ObstacleSpawner (Inherited)
│   ├── HoldSpawner (Inherited)
│   ├── RampManager (Enhanced - special ramps)
│   └── Flippers (Node2D)
│       ├── FlipperLeft (Enhanced - upgrade support)
│       └── FlipperRight (Enhanced - upgrade support)
└── UI (CanvasLayer - Enhanced)
    ├── ScoreLabel
    ├── CurrencyDisplay (NEW)
    ├── BattlePassBar (NEW)
    ├── WatchAdButton (NEW)
    └── Instructions (hidden on mobile)
```

### 2.2 New Scenes

#### ShopScene.tscn
```
ShopScene (Node2D)
├── CanvasLayer
│   ├── Background
│   ├── HeaderContainer
│   ├── TabContainer
│   ├── ItemCardContainer (ScrollContainer)
│   └── FooterContainer
└── ShopManager (Node)
```

#### CustomizeScene.tscn
```
CustomizeScene (Node2D)
├── CanvasLayer
│   ├── HeaderContainer
│   ├── CategoryTabs
│   ├── ItemPreview (Node2D)
│   └── EquippedItemsDisplay
└── CustomizeManager (Node)
```

#### BattlePassScene.tscn
```
BattlePassScene (Node2D)
├── CanvasLayer
│   ├── HeaderContainer
│   ├── SeasonInfo (Label)
│   ├── TierList (ScrollContainer)
│   └── ProgressBar
└── BattlePassUI (Node)
```

#### MainMenuScene.tscn (NEW)
```
MainMenuScene (Node2D)
├── CanvasLayer
│   ├── TitleLabel
│   ├── PlayButton
│   ├── ShopButton
│   ├── CustomizeButton
│   ├── BattlePassButton
│   ├── SettingsButton
│   └── DailyLoginButton (with badge)
└── MainMenuManager (Node)
```

---

## 3. Script Architecture

### 3.1 Autoload Singletons

**Order of Initialization** (in project.godot autoload):
1. GlobalGameSettings - Global settings and equipped items
2. CurrencyManager - Currency tracking
3. SaveManager - Data persistence
4. AdManager - Ad integration
5. BattlePassManager - Battle Pass system
6. DailyLoginManager - Daily login rewards
7. ChallengeManager - Daily challenges
8. IAPManager - In-App Purchases (platform-specific)

### 3.2 Manager Pattern

**ShopManager**:
- Handles shop UI and item database
- Coordinates with CurrencyManager for purchases
- Updates GlobalGameSettings for equipped items

**CurrencyManager**:
- Central currency tracking (coins/gems)
- Auto-saves on change
- Emits signals for UI updates

**SaveManager**:
- Centralized save/load system
- JSON-based save format
- Optional encryption support
- Backup/restore functionality

### 3.3 Data Flow

**Purchase Flow**:
```
User → ShopManager.purchase_item()
  → CurrencyManager.can_afford()
  → CurrencyManager.spend_currency()
  → SaveManager.save_owned_items()
  → GlobalGameSettings.set_equipped_item()
  → SaveManager.save_equipped_items()
  → UI update (currency display, item card)
```

**Gameplay Currency Earning**:
```
GameManager._on_obstacle_hit()
  → Calculate coins (score / 100)
  → CurrencyManager.add_coins()
  → CurrencyManager.emit currency_changed
  → UI.update_currency_display()
  → SaveManager.save_currency() (periodic)
```

**Battle Pass XP Flow**:
```
GameManager._on_obstacle_hit()
  → Calculate XP (score / 50)
  → BattlePassManager.add_xp()
  → Check tier unlock
  → BattlePassManager.emit tier_unlocked
  → UI.update_battle_pass_bar()
  → SaveManager.save_battle_pass_data()
```

---

## 4. Data Persistence

### 4.1 Save File Format

**Location**: `user://pinball_save.json`

**Structure**:
```json
{
  "version": "2.0",
  "save_timestamp": "2024-01-15T12:34:56Z",
  "currency": {
    "coins": 1000,
    "gems": 50
  },
  "owned_items": [
    "ball_heavy",
    "flipper_long",
    "cosmetic_rainbow_trail"
  ],
  "equipped_items": {
    "ball": "ball_heavy",
    "flipper": "flipper_long",
    "trail": "cosmetic_rainbow_trail",
    "table_skin": "classic",
    "sound_pack": "classic"
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
    "last_refresh_date": "2024-01-15",
    "daily_challenges": [
      {
        "id": "challenge_1",
        "type": "score",
        "target": 5000,
        "progress": 2500,
        "completed": false
      }
    ],
    "progress": {
      "challenge_1": 2500
    }
  },
  "ad_data": {
    "rewarded_ads_watched_today": 2,
    "last_ad_watch_date": "2024-01-15",
    "last_interstitial_time": 1705320000.0,
    "games_since_last_interstitial": 2
  }
}
```

### 4.2 Save/Load Implementation

**SaveManager.gd**:
```gdscript
func save_all_data():
    var data = {
        "version": "2.0",
        "save_timestamp": Time.get_datetime_string_from_system(),
        "currency": CurrencyManager.get_currency_dict(),
        "owned_items": ShopManager.get_owned_items(),
        "equipped_items": GlobalGameSettings.equipped_items,
        "battle_pass": BattlePassManager.get_save_data(),
        "daily_login": DailyLoginManager.get_save_data(),
        "challenges": ChallengeManager.get_save_data(),
        "ad_data": AdManager.get_save_data()
    }
    
    var json_string = JSON.stringify(data)
    var file = FileAccess.open(save_file_path, FileAccess.WRITE)
    file.store_string(json_string)
    file.close()

func load_all_data():
    if not FileAccess.file_exists(save_file_path):
        return false
    
    var file = FileAccess.open(save_file_path, FileAccess.READ)
    var json_string = file.get_as_text()
    file.close()
    
    var json = JSON.new()
    var error = json.parse(json_string)
    if error != OK:
        return false
    
    var data = json.get_data()
    # Load into respective managers
    CurrencyManager.load_from_dict(data.currency)
    ShopManager.load_owned_items(data.owned_items)
    GlobalGameSettings.equipped_items = data.equipped_items
    # ... etc
```

### 4.3 Encryption (Optional)

**Implementation**:
- Use Godot's Crypto class for encryption
- Encrypt save file with user-specific key
- Key stored in device secure storage (iOS Keychain, Android Keystore)
- Fallback to plaintext if encryption fails

---

## 5. Platform Integration

### 5.1 IAP Abstraction Layer

**IAPManager.gd** (Abstract Base):
```gdscript
extends Node

signal purchase_completed(product_id: String, success: bool)
signal purchase_failed(product_id: String, error: String)
signal products_loaded(products: Array)

func initialize() -> void:
    match OS.get_name():
        "iOS":
            initialize_ios()
        "Android":
            initialize_android()
        _:
            initialize_mock()

func purchase_product(product_id: String) -> void:
    match OS.get_name():
        "iOS":
            purchase_product_ios(product_id)
        "Android":
            purchase_product_android(product_id)
        _:
            purchase_product_mock(product_id)
```

**Platform Implementations**:
- `IAPManagerIOS.gd`: Uses StoreKit via GDNative plugin
- `IAPManagerAndroid.gd`: Uses Google Play Billing via GDNative plugin
- `IAPManagerMock.gd`: Mock implementation for development

### 5.2 Ad Abstraction Layer

**AdManager.gd**:
```gdscript
extends Node

var ad_provider: String = "admob"  # or "unity_ads"

func initialize_ads():
    match ad_provider:
        "admob":
            initialize_admob()
        "unity_ads":
            initialize_unity_ads()
```

**AdMob Integration**:
- Use AdMob SDK via GDNative plugin
- Rewarded ads: `loadRewardedAd()`, `showRewardedAd()`
- Interstitial ads: `loadInterstitial()`, `showInterstitial()`

**Unity Ads Integration** (Fallback):
- Use Unity Ads SDK via GDNative plugin
- Similar API to AdMob

### 5.3 Platform Detection

```gdscript
func get_platform() -> String:
    match OS.get_name():
        "iOS":
            return "ios"
        "Android":
            return "android"
        _:
            return "desktop"
```

---

## 6. Performance Considerations

### 6.1 Optimization Strategies

**Asset Loading**:
- Load shop assets asynchronously
- Use texture streaming for table skins
- Cache frequently accessed resources

**Particle Effects**:
- Limit active particles (max 100 per effect)
- Disable particles on low-end devices
- Use GPU particles for better performance

**Shader Effects**:
- Limit active shaders (max 2-3 simultaneously)
- Use simpler shaders on mobile
- Pre-compile shaders

**Physics**:
- Special ball physics (magnetic, cosmic) run at 30Hz instead of 60Hz
- Use object pooling for frequently created/destroyed objects

### 6.2 Memory Management

**Shop Scene**:
- Unload when not in use
- Lazy-load item icons
- Clear item card cache on scene exit

**Save System**:
- Periodic saves (every 30 seconds) instead of immediate
- Batch save operations
- Compress save data (optional)

---

## 7. Security Considerations

### 7.1 Anti-Cheat

**Currency Validation**:
- Server-side validation (future enhancement)
- Encrypted save files
- Checksums on currency values
- Rate limiting on currency earning

**IAP Validation**:
- Receipt validation on server (recommended)
- Purchase token verification
- Duplicate purchase detection

### 7.2 Data Protection

**Encryption**:
- Encrypt save files
- Secure storage for IAP receipts
- Encrypt network communications (if server added)

**Privacy**:
- No personal data collection
- Ad provider handles user data
- GDPR compliance (if applicable)

---

## 8. Extension Points

### 8.1 Adding New Upgrade Types

1. Create UpgradeData resource
2. Add to item database
3. Implement special ability in component script
4. Add visual effects
5. Update shop UI

### 8.2 Adding New Ad Providers

1. Create AdProvider interface
2. Implement provider-specific code
3. Add to AdManager abstraction layer
4. Configure in project settings

### 8.3 Cloud Save (Future)

1. Add cloud storage service (Firebase, Game Center, Google Play Games)
2. Extend SaveManager with cloud sync
3. Handle conflict resolution
4. Add sync status UI

---

## 9. Testing Strategy

### 9.1 Unit Tests

- CurrencyManager: Test add/spend/balance
- BattlePassManager: Test XP and tier progression
- SaveManager: Test save/load/encryption

### 9.2 Integration Tests

- Purchase flow end-to-end
- Ad reward flow
- Battle Pass reward claiming
- Upgrade equip/unequip

### 9.3 Platform Tests

- IAP on iOS and Android
- Ads on both platforms
- Save/load on different devices
- Performance on low-end devices

---

## 10. Deployment Considerations

### 10.1 Build Configuration

**iOS**:
- Configure App Store Connect for IAP products
- Set up AdMob iOS SDK
- Configure Info.plist for permissions

**Android**:
- Configure Google Play Console for IAP products
- Set up AdMob Android SDK
- Configure AndroidManifest.xml

### 10.2 Release Process

1. Build release version
2. Test IAP and ads on test devices
3. Submit to App Store / Google Play
4. Configure in-app products in stores
5. Monitor analytics and crash reports

---

*This technical design maintains v1.0's architecture while adding comprehensive monetization support with platform abstraction for maintainability and extensibility.*

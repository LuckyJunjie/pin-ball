# Pinball Game v2.0 - Technical Requirements

## Document Information

- **Version**: 2.0
- **Inherits From**: Technical-Requirements v1.0 (all v1.0 requirements maintained)
- **Platform**: Mobile (iOS, Android) - Primary; Desktop support maintained
- **Engine**: Godot 4.5

---

## 1. Platform Requirements (Enhanced)

### 1.1 Engine (Inherited)

All v1.0 engine requirements (TR-1.1.1, TR-1.1.2, TR-1.1.3) are maintained.

### 1.2 Input System (Enhanced)

**Inherited** (Desktop):
- All v1.0 input requirements (TR-1.2.1, TR-1.2.2, TR-1.2.3, TR-1.3.1-4) maintained

**v2.0 Additions** (Mobile):
- **TR-v2.1.1**: Touch input system must support iOS and Android
- **TR-v2.1.2**: Touch zones must be defined for flipper controls (bottom 20% of screen height, left/right split)
- **TR-v2.1.3**: Touch input must use Godot's touch event system (`InputEventScreenTouch`)
- **TR-v2.1.4**: Visual feedback must be provided for touch zones (highlight on press)
- **TR-v2.1.5**: On-screen buttons must have minimum 44×44 pixel touch targets
- **TR-v2.1.6**: Touch input must respond within 1 frame (16ms at 60 FPS)

---

## 2. Performance Requirements (Enhanced)

All v1.0 performance requirements (TR-2.1.1, TR-2.1.2, TR-2.1.3, TR-2.2.1-3) are maintained.

**v2.0 Mobile Additions**:
- **TR-v2.2.1**: Game must maintain 60 FPS on target mobile hardware (iOS 13+, Android 8.0+)
- **TR-v2.2.2**: Shop scene must load within 2 seconds
- **TR-v2.2.3**: Save/load operations must complete within 500ms
- **TR-v2.2.4**: Particle effects must be limited (max 100 particles per effect)
- **TR-v2.2.5**: Special physics effects (magnetic, cosmic) must run at 30Hz instead of 60Hz on mobile
- **TR-v2.2.6**: Shader effects must be limited (max 2-3 active simultaneously)

---

## 3. Physics System Requirements (Enhanced)

All v1.0 physics requirements (TR-3.1.1-3, TR-3.2.1-6, TR-3.3.1-6, TR-3.4.1-6) are maintained.

**v2.0 Enhancements**:
- **TR-v2.3.1**: Ball upgrade physics modifications must be applied correctly (mass, bounce, friction, damping)
- **TR-v2.3.2**: Magnetic ball attraction force must be calculated each frame (force: 150.0, radius: 150.0)
- **TR-v2.3.3**: Fire ball chain reaction must detect obstacles within radius (80px) and apply effects
- **TR-v2.3.4**: Cosmic ball anti-gravity must apply upward force (-300 units) and modify gravity scale (0.5)
- **TR-v2.3.5**: Twin flipper secondary segment must use PinJoint2D for connection
- **TR-v2.3.6**: Special ramp effects (multiplier, bank shot, accelerator) must apply correctly

---

## 4. Rendering Requirements (Enhanced)

All v1.0 rendering requirements (TR-4.1.1-3, TR-4.2.1-5, TR-4.3.1-3) are maintained.

**v2.0 Additions**:
- **TR-v2.4.1**: Upgrade visual effects must render correctly (particles, shaders, trails)
- **TR-v2.4.2**: Table skins must replace background textures without affecting gameplay
- **TR-v2.4.3**: Ball trails must use Line2D with proper point management (15-20 points)
- **TR-v2.4.4**: Particle systems must support up to 100 particles per effect
- **TR-v2.4.5**: Shader effects must compile and run on mobile devices

---

## 5. Architecture Requirements (Enhanced)

All v1.0 architecture requirements (TR-5.1.1-4, TR-5.2.1-4) are maintained.

**v2.0 Additions**:
- **TR-v2.5.1**: Autoload singletons must initialize in correct order (GlobalGameSettings → CurrencyManager → SaveManager → etc.)
- **TR-v2.5.2**: Manager pattern must be used for monetization systems (ShopManager, CurrencyManager, etc.)
- **TR-v2.5.3**: Platform abstraction layers must support iOS, Android, and Desktop
- **TR-v2.5.4**: Data persistence layer must use JSON format with optional encryption
- **TR-v2.5.5**: Signal-based communication must be used for monetization events

---

## 6. Memory and Resource Requirements (Enhanced)

All v1.0 memory requirements (TR-6.1.1-4, TR-6.2.1-4) are maintained.

**v2.0 Additions**:
- **TR-v2.6.1**: Shop assets must be loaded asynchronously
- **TR-v2.6.2**: Item icons must be lazy-loaded (only when displayed)
- **TR-v2.6.3**: Save data must be compressed or optimized for size
- **TR-v2.6.4**: Particle systems must be pooled for reuse
- **TR-v2.6.5**: Texture streaming must be used for large assets (table skins)

---

## 7. Audio System Requirements (Inherited)

All v1.0 audio requirements (TR-7.1.1-4, TR-7.2.1-7) are maintained.

**v2.0 Enhancement**:
- **TR-v2.7.1**: Sound packs must replace sound effects correctly (theme-based audio)

---

## 8. Debug System Requirements (Inherited)

All v1.0 debug requirements (TR-8.1.1-4, TR-8.2.1-5, TR-8.3.1-4) are maintained.

**v2.0 Addition**:
- **TR-v2.8.1**: Debug mode must also display currency values, owned items, and Battle Pass progress

---

## 9. v2.0 NEW Requirements: Monetization Systems

### 9.1 Currency System Technical Requirements

- **TR-v2.9.1**: CurrencyManager must be an autoload singleton
- **TR-v2.9.2**: Currency values must be stored as integers (no floating point)
- **TR-v2.9.3**: Currency changes must emit signals for UI updates
- **TR-v2.9.4**: Currency must be saved to SaveManager immediately on change
- **TR-v2.9.5**: Currency validation must check for negative values and prevent

### 9.2 Shop System Technical Requirements

- **TR-v2.10.1**: Item database must be loadable from JSON or Resource files
- **TR-v2.10.2**: Item cards must be dynamically generated from item database
- **TR-v2.10.3**: Purchase confirmation must use PopupPanel with confirmation dialog
- **TR-v2.10.4**: Shop scene must unload assets when not in use
- **TR-v2.10.5**: Item ownership must be checked before displaying purchase button

### 9.3 IAP System Technical Requirements

- **TR-v2.11.1**: IAPManager must use platform abstraction pattern
- **TR-v2.11.2**: iOS implementation must use StoreKit 2 (iOS 15+) or StoreKit 1 (iOS 13-14)
- **TR-v2.11.3**: Android implementation must use Google Play Billing Library 5.0+
- **TR-v2.11.4**: Receipt validation must be implemented (server-side recommended)
- **TR-v2.11.5**: Purchase records must be stored in save file
- **TR-v2.11.6**: Restore purchases must work on app reinstall
- **TR-v2.11.7**: Mock implementation must be available for desktop/development

### 9.4 Ad System Technical Requirements

- **TR-v2.12.1**: AdManager must use platform abstraction pattern
- **TR-v2.12.2**: AdMob SDK must be integrated via GDNative plugin
- **TR-v2.12.3**: Unity Ads SDK must be integrated as fallback
- **TR-v2.12.4**: Rewarded ads must be pre-loaded before showing button
- **TR-v2.12.5**: Ad watch count must be tracked and saved
- **TR-v2.12.6**: Daily ad limits must be enforced and reset at midnight
- **TR-v2.12.7**: Ad loading failures must be handled gracefully

### 9.5 Battle Pass System Technical Requirements

- **TR-v2.13.1**: BattlePassManager must be an autoload singleton
- **TR-v2.13.2**: XP must be stored as integers
- **TR-v2.13.3**: Tier progression must use XP thresholds (increasing)
- **TR-v2.13.4**: Season data must be stored with start/end dates
- **TR-v2.13.5**: Reward claiming must check tier unlock and premium status
- **TR-v2.13.6**: Season reset must create new season with new rewards

### 9.6 Save System Technical Requirements

- **TR-v2.14.1**: SaveManager must be an autoload singleton
- **TR-v2.14.2**: Save file must use JSON format
- **TR-v2.14.3**: Save data must include version number for migration
- **TR-v2.14.4**: Encryption must use Godot's Crypto class (optional)
- **TR-v2.14.5**: Backup/restore functionality must be implemented
- **TR-v2.14.6**: Save operations must be non-blocking (async recommended)
- **TR-v2.14.7**: Save file path must use `user://` directory

---

## 10. Platform-Specific Technical Requirements

### 10.1 iOS Technical Requirements

- **TR-iOS-1**: Project must be configured for iOS export in Godot
- **TR-iOS-2**: Info.plist must include required permissions (Ads, IAP)
- **TR-iOS-3**: StoreKit must be linked in Xcode project
- **TR-iOS-4**: AdMob SDK must be integrated via CocoaPods or manual integration
- **TR-iOS-5**: Save data must be stored in iOS Documents directory
- **TR-iOS-6**: App must support iOS 13.0 minimum deployment target

### 10.2 Android Technical Requirements

- **TR-ANDROID-1**: Project must be configured for Android export in Godot
- **TR-ANDROID-2**: AndroidManifest.xml must include required permissions (INTERNET, BILLING)
- **TR-ANDROID-3**: Google Play Billing must be integrated via Gradle
- **TR-ANDROID-4**: AdMob SDK must be integrated via Gradle
- **TR-ANDROID-5**: Save data must be stored in Android app data directory
- **TR-ANDROID-6**: App must support Android 8.0 (API 26) minimum SDK

---

## 11. Security Technical Requirements

- **TR-SEC-1**: Save files must be encrypted using AES-256 (optional but recommended)
- **TR-SEC-2**: IAP receipts must be validated server-side (recommended)
- **TR-SEC-3**: Currency values must use checksums to prevent tampering
- **TR-SEC-4**: Purchase tokens must be stored securely
- **TR-SEC-5**: Network communications must use HTTPS (if server added)

---

*All v1.0 technical requirements are inherited and must be satisfied. This document adds v2.0-specific technical requirements for monetization systems and mobile platform support.*

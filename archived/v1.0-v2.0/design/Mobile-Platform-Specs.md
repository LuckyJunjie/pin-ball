# Pinball Game v2.0 - Mobile Platform Specifications

## Overview

This document specifies iOS and Android platform requirements, IAP/ads integration, and cross-platform abstraction for Pinball v2.0.

## 1. iOS Platform Specifications

### 1.1 Minimum Requirements

- **iOS Version**: iOS 13.0 or later
- **Devices**: iPhone and iPad support
- **Architecture**: ARM64 (Apple Silicon support via Rosetta for development)
- **Xcode Version**: Xcode 12.0 or later (for building)

### 1.2 StoreKit Integration (IAP)

**Framework**: StoreKit 2 (iOS 15+) or StoreKit 1 (iOS 13-14)

**Product IDs**:
```
com.company.pinball.gems_small
com.company.pinball.gems_medium
com.company.pinball.gems_large
com.company.pinball.gems_mega
com.company.pinball.starter_pack
com.company.pinball.premium_starter
```

**Implementation Approach**:
- Use GDExtension plugin for StoreKit integration (Godot 4.x compatible)
- Or use Godot's native IAP plugin if available
- StoreKit 2 preferred for iOS 15+ (modern async API)
- StoreKit 1 fallback for iOS 13-14

**Purchase Flow**:
1. Request product information from App Store
2. Display products with localized prices
3. Initiate purchase via StoreKit
4. Handle purchase result (success/failure/cancelled)
5. Validate receipt with App Store (server-side recommended)
6. Grant currency to player
7. Save purchase record

**Receipt Validation**:
- Server-side validation recommended for production
- Use App Store receipt validation API
- Handle renewal subscriptions if added in future

**Restore Purchases**:
- "Restore Purchases" button in settings
- Query App Store for previous purchases
- Grant currency for valid purchases

### 1.3 AdMob Integration (iOS)

**SDK Version**: AdMob iOS SDK 9.0+ (or latest)

**Integration Method**:
- Via CocoaPods (recommended)
- Or manual framework integration
- GDExtension plugin wrapper for Godot 4.x

**Rewarded Ads**:
- Initialize GADRewardedAd
- Load ad with ad unit ID
- Show ad when ready
- Handle reward callback

**Interstitial Ads**:
- Initialize GADInterstitialAd
- Load ad with ad unit ID
- Show ad between game sessions

**Ad Unit IDs**:
- Configure in AdMob console
- Separate IDs for rewarded and interstitial
- Test IDs for development

### 1.4 Touch Controls

**Implementation**:
- Use `InputEventScreenTouch` events
- Map touch zones to flipper controls
- Bottom 20% of screen: Left/right zones for flippers
- Visual feedback on touch (highlight zones)

**Touch Zones**:
- Left Flipper: x: 0 to screen_width/2, y: screen_height*0.8 to screen_height
- Right Flipper: x: screen_width/2 to screen_width, y: screen_height*0.8 to screen_height

### 1.5 App Store Guidelines Compliance

- **Guideline 2.1** (App Completeness): Game must be fully functional
- **Guideline 3.1.1** (In-App Purchase): IAP must use StoreKit, clear pricing
- **Guideline 4.0** (Design): UI must follow iOS Human Interface Guidelines
- **Guideline 5.1.1** (Privacy): Privacy policy required if collecting data
- **Guideline 5.2.5** (Third-Party Services): Ad providers must comply with guidelines

## 2. Android Platform Specifications

### 2.1 Minimum Requirements

- **Android Version**: Android 8.0 (API 26) or later
- **Architecture**: ARMv7, ARM64, x86, x86_64
- **Gradle Version**: 7.0+ (for building)
- **Android SDK**: API 26 minimum, API 33+ target

### 2.2 Google Play Billing Integration

**Library**: Google Play Billing Library 5.0+

**Product IDs** (same as iOS):
```
com.company.pinball.gems_small
com.company.pinball.gems_medium
com.company.pinball.gems_large
com.company.pinball.gems_mega
com.company.pinball.starter_pack
com.company.pinball.premium_starter
```

**Integration Method**:
- Add dependency via Gradle
- GDExtension plugin wrapper for Godot 4.x
- Or use Godot's native IAP plugin if available

**Purchase Flow**:
1. Query product details from Google Play
2. Display products with localized prices
3. Launch billing flow
4. Handle purchase result (success/failure/cancelled)
5. Acknowledge purchase (required by Google)
6. Validate purchase token (server-side recommended)
7. Grant currency to player
8. Save purchase record

**Purchase Acknowledgment**:
- Required by Google Play Billing 5.0+
- Must acknowledge within 3 days or refund
- Call `acknowledgePurchase()` after validation

**Restore Purchases**:
- Purchases restored automatically on app launch
- Query Google Play for owned purchases
- Grant currency for valid purchases

### 2.3 AdMob Integration (Android)

**SDK Version**: AdMob Android SDK 21.0+ (or latest)

**Integration Method**:
- Add dependency via Gradle
- GDExtension plugin wrapper for Godot 4.x

**Rewarded Ads**:
- Initialize RewardedAd
- Load ad with ad unit ID
- Show ad when ready
- Handle reward callback

**Interstitial Ads**:
- Initialize InterstitialAd
- Load ad with ad unit ID
- Show ad between game sessions

**Ad Unit IDs**:
- Configure in AdMob console
- Separate IDs for rewarded and interstitial
- Test IDs for development

### 2.4 Touch Controls

**Implementation**:
- Use `InputEventScreenTouch` events (same as iOS)
- Map touch zones to flipper controls
- Bottom 20% of screen: Left/right zones for flippers

**Touch Zones**: Same as iOS specification

### 2.5 Google Play Guidelines Compliance

- **Policy: Payments** (IAP): Must use Google Play Billing for digital goods
- **Policy: Ads**: Ads must comply with AdMob policies
- **Policy: Content Rating**: Age-appropriate content rating required
- **Policy: Privacy**: Privacy policy required if collecting data
- **Policy: Data Safety**: Data safety section must be completed

## 3. Cross-Platform Abstraction

### 3.1 IAP Abstraction Layer

**Design Pattern**: Abstract base class with platform-specific implementations

```gdscript
# IAPManager.gd (Abstract base, autoload)
extends Node

signal purchase_completed(product_id: String, success: bool)
signal purchase_failed(product_id: String, error: String)
signal products_loaded(products: Array)

func _ready():
    match OS.get_name():
        "iOS":
            initialize_ios()
        "Android":
            initialize_android()
        _:
            initialize_mock()  # Desktop/development

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
- `IAPManagerIOS.gd`: Extends IAPManager, implements StoreKit calls
- `IAPManagerAndroid.gd`: Extends IAPManager, implements Google Play Billing calls
- `IAPManagerMock.gd`: Mock implementation for development/testing

### 3.2 Ad Abstraction Layer

**Design Pattern**: Similar abstraction to IAP

```gdscript
# AdManager.gd (Autoload)
extends Node

var ad_provider: String = "admob"  # or "unity_ads"

func initialize_ads():
    match OS.get_name():
        "iOS":
            initialize_admob_ios()
        "Android":
            initialize_admob_android()
        _:
            initialize_mock()

func show_rewarded_ad(reward_type: String):
    match ad_provider:
        "admob":
            show_admob_rewarded_ad(reward_type)
        "unity_ads":
            show_unity_ads_rewarded_ad(reward_type)
```

### 3.3 Platform Detection

**Godot OS Detection**:
```gdscript
func get_platform() -> String:
    match OS.get_name():
        "iOS":
            return "ios"
        "Android":
            return "android"
        "Windows", "macOS", "Linux", "FreeBSD":
            return "desktop"
        _:
            return "unknown"
```

**Conditional Compilation** (if needed):
- Use feature tags in project.godot
- Platform-specific code in separate files
- Load appropriate implementation at runtime

## 4. Build Configuration

### 4.1 iOS Build Settings

**Export Settings** (project.godot):
- Target: iOS
- Architecture: ARM64
- Minimum iOS version: 13.0
- Provisioning profile: Development/Distribution
- Bundle identifier: com.company.pinball

**Required Capabilities**:
- In-App Purchase
- Push Notifications (if added in future)
- Ad Support (for AdMob)

### 4.2 Android Build Settings

**Export Settings** (project.godot):
- Target: Android
- Min SDK: 26 (Android 8.0)
- Target SDK: 33+
- Package name: com.company.pinball
- Signing: Debug/Release keystore

**Required Permissions** (AndroidManifest.xml):
- `INTERNET` (for ads and IAP)
- `BILLING` (for Google Play Billing)
- `ACCESS_NETWORK_STATE` (for AdMob)

## 5. Testing on Platforms

### 5.1 iOS Testing

- **Simulator**: Test UI and gameplay flow
- **TestFlight**: Beta testing with real devices
- **Sandbox Testing**: Test IAP with sandbox accounts
- **Ad Testing**: Use AdMob test ad unit IDs

### 5.2 Android Testing

- **Emulator**: Test UI and gameplay flow
- **Internal Testing**: Google Play Console internal testing track
- **IAP Testing**: Test purchases with test accounts
- **Ad Testing**: Use AdMob test ad unit IDs

## 6. Deployment Considerations

### 6.1 App Store Submission (iOS)

- App Store Connect configuration
- IAP products configured in App Store Connect
- Privacy policy URL (if required)
- Age rating: 4+ (Everyone)
- Screenshots and app description
- AdMob app ID configured

### 6.2 Google Play Submission (Android)

- Google Play Console configuration
- IAP products configured in Play Console
- Privacy policy URL (required)
- Content rating: Everyone
- Screenshots and app description
- AdMob app ID configured

---

*These specifications ensure proper integration with iOS and Android platforms while maintaining cross-platform compatibility through abstraction layers.*

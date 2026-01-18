# Pinball Game v2.0 - Design Documentation

## Overview

This directory contains comprehensive design documentation for Pinball Game v2.0. Version 2.0 inherits all requirements, design principles, and gameplay mechanics from v1.0 while adding monetization systems, mobile platform support, and enhanced gameplay features.

## Document Index

### Core Design Documents

1. **[GDD-v2.0.md](GDD-v2.0.md)** - Complete Game Design Document v2.0
   - Inherits all v1.0 game design sections
   - Adds monetization overview
   - Mobile platform specifications (iOS/Android)
   - Enhanced progression and scoring systems
   - Shop, Battle Pass, and Daily Challenge systems

2. **[Monetization-Design.md](Monetization-Design.md)** - Revenue Systems Design
   - Currency system (Coins and Gems)
   - Shop system architecture
   - In-App Purchase (IAP) integration
   - Advertisement integration (Rewarded & Interstitial)
   - Battle Pass/Season Pass system
   - Economic balance and player progression

3. **[Upgrade-Systems.md](Upgrade-Systems.md)** - Upgrade Mechanics
   - Ball upgrade tiers (Standard → Heavy → Bouncy → Magnetic → Fire → Cosmic)
   - Flipper upgrade variants (Long, Power, Twin, Plasma, Turbo)
   - Special ramp types (Multiplier, Bank Shot, Accelerator)
   - Cosmetic systems (Trails, Table Skins, Flipper Skins, Sound Packs)
   - Physics modifications and special abilities

### Technical Specifications

4. **[Component-Specifications-v2.0.md](Component-Specifications-v2.0.md)** - Component Architecture
   - Enhanced v1.0 components (Ball, Flipper, Ramp)
   - New monetization components (ShopManager, CurrencyManager, AdManager)
   - New progression components (BattlePassManager, SaveManager)
   - GlobalGameSettings autoload
   - Component integration specifications

5. **[Technical-Design-v2.0.md](Technical-Design-v2.0.md)** - System Architecture
   - Architecture overview with monetization layer
   - Scene structure (Shop, Customize, Battle Pass scenes)
   - Script architecture and data flow
   - Data persistence and save system
   - Platform integration (iOS/Android IAP and ads)
   - Performance and security considerations

6. **[Game-Flow-v2.0.md](Game-Flow-v2.0.md)** - Game Flow and State Management
   - Enhanced game flow with monetization features
   - Shop browsing and purchase flow
   - Customize and equipment flow
   - Ad reward flow
   - Battle Pass progression flow
   - Daily login and challenge flow

7. **[UI-Design-v2.0.md](UI-Design-v2.0.md)** - User Interface Design
   - Main menu with Shop, Customize, Battle Pass buttons
   - Shop UI (category tabs, item cards, purchase buttons)
   - Customize UI (item selection, preview, equip/unequip)
   - Battle Pass UI (tier progression, rewards)
   - In-game monetization UI (currency display, ad buttons)
   - Purchase confirmation dialogs and notifications

8. **[Physics-Specifications-v2.0.md](Physics-Specifications-v2.0.md)** - Enhanced Physics
   - Inherits all v1.0 physics specifications
   - Ball upgrade physics (Heavy, Bouncy, Magnetic, Fire, Cosmic)
   - Flipper upgrade physics (Twin, Power, Turbo)
   - Special ramp physics (Multiplier, Bank Shot, Accelerator)
   - Special effect calculations (attraction forces, chain reactions, gravity wells)

9. **[Mobile-Platform-Specs.md](Mobile-Platform-Specs.md)** - Platform Requirements
   - iOS requirements (StoreKit, AdMob, touch controls)
   - Android requirements (Google Play Billing, AdMob, touch controls)
   - Cross-platform abstraction layer design
   - Platform detection and conditional compilation
   - App Store and Google Play guidelines compliance

## Version Comparison: v1.0 vs v2.0

| Feature | v1.0 | v2.0 |
|---------|------|------|
| **Platform** | Desktop (Windows, macOS, Linux) | Mobile (iOS, Android) |
| **Controls** | Keyboard only | Touch controls + Keyboard support |
| **Monetization** | None | Shop, IAP, Ads, Battle Pass |
| **Currency** | None | Coins (earnable) + Gems (premium) |
| **Progression** | Score only | Score + Currency + XP + Battle Pass |
| **Upgrades** | None | Ball, Flipper, Ramp upgrades |
| **Cosmetics** | None | Trails, Table Skins, Flipper Skins, Sound Packs |
| **Shop System** | N/A | Full shop with categories and purchase flow |
| **Daily Features** | None | Daily Login Rewards, Daily Challenges |
| **Season System** | None | 30-day Battle Pass with Free/Premium tracks |
| **Save System** | None | Persistent save (owned items, currency, progress) |
| **Ad Integration** | None | Rewarded ads (coins/gems/extra ball) + Interstitial ads |
| **Physics** | Standard ball physics | Enhanced with upgrade-based special effects |

## Design Principles

### 1. Backward Compatibility
- v2.0 maintains all v1.0 core gameplay mechanics
- Default items (Standard Ball, Standard Flipper) provide identical experience to v1.0
- Non-paying players can fully enjoy the game without purchases

### 2. Non-Predatory Monetization
- Free players can progress and earn currency through gameplay
- No pay-to-win mechanics that create unfair advantages
- Paid items provide meaningful but balanced advantages
- All items can be earned through gameplay (time investment)

### 3. Clear Value Proposition
- Each paid item has clear, visible benefits
- Upgrade effects are noticeable but don't break game balance
- Cosmetic items provide visual customization without gameplay impact

### 4. Mobile-First UI
- Touch-friendly button sizes and spacing
- Responsive layouts for various screen sizes
- Intuitive navigation and clear visual hierarchy
- Performance optimized for mobile devices

### 5. Data Persistence
- All player progress saved locally
- Currency, owned items, and equipped items persist between sessions
- Cloud save support planned for future versions
- Save system supports restore purchases functionality

### 6. Balance
- Economy balanced for both free and paying players
- Daily earning limits prevent currency inflation
- Battle Pass provides steady progression goals
- Upgrade costs scale appropriately with benefits

## Quick Reference: Monetization Features

### Currency Earning
- **Coins**: Earned from score (1 coin per 100 points), daily login, challenges, rewarded ads
- **Gems**: Rare drops from gameplay, rewarded ads (limited), daily login (rare), IAP purchase

### Shop Categories
- **Balls**: Physics upgrades (Heavy, Bouncy, Magnetic, Fire, Cosmic)
- **Flippers**: Control upgrades (Long, Power, Twin, Plasma, Turbo)
- **Ramps**: Special ramps (Multiplier, Bank Shot, Accelerator)
- **Cosmetics**: Visual customization (Trails, Table Skins, Flipper Skins, Sound Packs)
- **Specials**: Limited-time offers, starter packs, gem packages

### Ad Integration
- **Rewarded Ads**: Watch for 250 coins, 5 gems (max 3/day), or extra ball revival
- **Interstitial Ads**: Shown after game session ends (every 3rd session, max 1 per hour)

### Battle Pass
- **Free Track**: Common items, small currency amounts, standard upgrades
- **Premium Track**: Exclusive items, larger currency, premium upgrades (unlock with 100 gems)
- **Progression**: Earn XP from gameplay, unlock tiers over 30-day season

## Implementation Status

**Current Status**: Design Phase Complete

All design documents are complete and ready for implementation. These documents specify:
- Complete system architecture
- Component specifications
- Data structures and formats
- UI/UX designs
- Physics specifications
- Platform integration requirements

**Next Steps**: Implementation Phase
1. Create scene structure (Shop, Customize, Battle Pass scenes)
2. Implement currency system and managers
3. Integrate IAP SDKs (StoreKit for iOS, Google Play Billing for Android)
4. Integrate ad SDKs (AdMob/Unity Ads)
5. Implement upgrade systems with special physics
6. Create save/load system
7. Build shop UI and purchase flows
8. Implement battle pass system

## References

- v1.0 Design Documents: `../design/`
- v1.0 Requirements: `../requirements/`
- Godot 4.5 Documentation: https://docs.godotengine.org/
- iOS StoreKit Documentation: https://developer.apple.com/storekit/
- Android Google Play Billing: https://developer.android.com/google/play/billing
- Google AdMob: https://developers.google.com/admob

## Document Maintenance

- **Version**: 2.0
- **Last Updated**: 2024
- **Maintained By**: Development Team
- **Status**: Design Complete - Ready for Implementation

---

For questions or clarifications on the v2.0 design, refer to the specific document sections or consult the Technical Design document for implementation details.

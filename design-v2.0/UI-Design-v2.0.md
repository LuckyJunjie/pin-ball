# Pinball Game v2.0 - UI/UX Design Specification

## Overview

This document specifies UI/UX design for Pinball v2.0, inheriting all v1.0 UI specifications and adding monetization UI elements, shop interfaces, and mobile-friendly layouts.

## 1. In-Game UI (Enhanced)

### 1.1 Layout (Inherited + Additions)

**Base Layout** (Inherited from v1.0):
- Score: Top-left (20, 20)
- Instructions: Below score (hidden on mobile)
- Ball Queue: Right side (750, 300)

**v2.0 Additions**:
- Currency Display: Top-right (20, 20 from right edge)
- Battle Pass XP Bar: Below currency (20, 90 from right edge)
- Watch Ad Button: Bottom-center (appears after ball loss)

### 1.2 Currency Display (NEW)

**Position**: Top-right corner
**Size**: 200×60 pixels
**Components**:
- Coin icon (32×32) + "Coins: {amount}" (Font size: 20)
- Gem icon (32×32) + "Gems: {amount}" (Font size: 20)
**Colors**: Gold (#FFD700) for coins, Purple (#9966FF) for gems
**Behavior**: Updates immediately on currency change, tappable to open shop

### 1.3 Battle Pass XP Bar (NEW)

**Position**: Below currency display (20, 90 from right)
**Size**: 200×20 pixels
**Components**:
- Progress bar (shows XP progress to next tier)
- Label: "Tier {current}/50 - {xp}/{xp_needed} XP"
**Colors**: Progress bar fill: Blue (#4A90E2)
**Behavior**: Updates as XP is earned, tappable to open Battle Pass scene

### 1.4 Watch Ad Button (NEW)

**Position**: Bottom-center, appears conditionally
**Size**: 200×60 pixels
**Appearance**: 
- Appears 5 seconds after ball loss
- Text: "Watch Ad for Extra Ball" or "Watch Ad for 250 Coins"
- Icon: Ad symbol
**Behavior**: Triggers rewarded ad on tap, disappears if player releases next ball

---

## 2. Main Menu UI (NEW)

### 2.1 Layout

```
Main Menu Scene
├── Header (Top)
│   ├── Title: "PINBALL"
│   └── Currency Display (coins/gems)
├── Button Grid (Center)
│   ├── Play Button (Large, prominent)
│   ├── Shop Button
│   ├── Customize Button
│   ├── Battle Pass Button (with progress indicator)
│   └── Settings Button
└── Footer (Bottom)
    ├── Daily Login Button (with badge if reward available)
    └── Challenge Notifications
```

### 2.2 Buttons

**Play Button**: 
- Size: 300×80 pixels
- Position: Center
- Style: Prominent, large, primary color

**Shop/Customize/Battle Pass Buttons**:
- Size: 200×60 pixels
- Style: Secondary buttons with icons

**Daily Login Button**:
- Size: 180×50 pixels
- Badge: Red circle with number (streak day) if reward available

---

## 3. Shop UI (NEW)

### 3.1 Layout

```
Shop Scene
├── Header
│   ├── Back Button (←)
│   ├── Title: "PINBALL SHOP"
│   └── Currency Display (coins/gems)
├── Tab Container
│   ├── Balls Tab
│   ├── Flippers Tab
│   ├── Ramps Tab
│   ├── Cosmetics Tab
│   └── Specials Tab
├── Item Grid (ScrollContainer)
│   └── Item Cards (3 columns, scrollable)
└── Footer
    ├── Buy Coins Button (opens gem packages)
    └── Buy Gems Button (opens IAP menu)
```

### 3.2 Item Card Design

**Size**: 180×220 pixels
**Components**:
- Item Icon (64×64, top)
- Item Name (Font size: 16, bold)
- Stats Preview (Font size: 12, condensed)
- Price Display (Currency icon + amount)
- Action Button ("BUY" / "OWNED" / "EQUIP")

**States**:
- **Available**: Normal colors, "BUY" button enabled
- **Owned**: Green tint, "EQUIP" button
- **Equipped**: Gold border, "EQUIPPED" label
- **Locked**: Grayscale, lock icon overlay

### 3.3 Purchase Confirmation Dialog

**Size**: 400×300 pixels
**Components**:
- Title: "Confirm Purchase"
- Item Preview (icon, name, stats)
- Price Display (highlighted)
- Current Balance: "Your balance: {currency} {amount}"
- Buttons: "CANCEL" (left), "BUY" (right, highlighted)

---

## 4. Customize UI (NEW)

### 4.1 Layout

```
Customize Scene
├── Header
│   ├── Back Button
│   └── Title: "CUSTOMIZE"
├── Category Tabs
│   ├── Balls
│   ├── Flippers
│   ├── Trails
│   ├── Table Skins
│   └── Sound Packs
├── Item List (ScrollContainer)
│   └── Owned items with preview
└── Preview Area (Right)
    └── Visual preview of selected item
```

### 4.2 Item Selection

- Owned items displayed in grid
- Currently equipped item highlighted (gold border)
- Preview area shows visual of selected item
- "EQUIP" / "UNEQUIP" buttons

---

## 5. Battle Pass UI (NEW)

### 5.1 Layout

```
Battle Pass Scene
├── Header
│   ├── Back Button
│   ├── Season Info: "Season 1 - 15 days remaining"
│   └── Unlock Premium Button (if not unlocked)
├── Tier List (ScrollContainer, vertical)
│   └── Tier Cards (1-50)
└── Progress Summary (Bottom)
    └── Current tier, XP progress
```

### 5.2 Tier Card Design

**Size**: Full width, 100 pixels height
**Components**:
- Tier Number (left)
- Free Track Reward (center-left, always visible)
- Premium Track Reward (center-right, locked if not purchased)
- XP Requirement: "{xp_needed} XP"
- Status: Locked / Unlocked / Claimed

**Visual States**:
- **Locked**: Grayscale, locked icon
- **Unlocked (not claimed)**: Normal colors, "CLAIM" button
- **Claimed**: Checkmark, grayed out
- **Current Tier**: Highlighted border, active animation

---

## 6. Mobile-Specific UI Considerations

### 6.1 Touch Targets

- Minimum 44×44 pixels for all buttons
- Adequate spacing between buttons (8-12 pixels)
- Flipper touch zones clearly visible (bottom 20% of screen)

### 6.2 Responsive Layout

- UI scales for different screen sizes
- Portrait and landscape support
- Safe area insets respected (iOS notch, Android status bar)

### 6.3 Mobile Optimizations

- Instructions label hidden on mobile
- Simplified navigation (tabs instead of complex menus)
- Swipe gestures for category navigation (optional)

---

## 7. Visual Design (Enhanced)

### 7.1 Color Scheme

**Inherited** (v1.0 colors maintained):
- Background: Dark blue-gray
- Primary text: White
- Game elements: Red (ball), Light blue (flippers)

**v2.0 Additions**:
- Currency: Gold (coins), Purple (gems)
- Buttons: Blue primary, Gray secondary
- Success: Green (#4CAF50)
- Error: Red (#F44336)
- Premium: Gold gradient

### 7.2 Typography

**Font Sizes**:
- Headers: 32px
- Buttons: 20px
- Body text: 16px
- Small text: 12px

**Font Family**: System default or custom retro gaming font

### 7.3 Animations

- Purchase success: Scale + fade animation
- Currency popup: Floating text animation
- Button press: Scale down (0.95×)
- Tier unlock: Pulse animation
- Reward claim: Particle burst

---

## 8. Accessibility

### 8.1 Visual Accessibility

- High contrast ratios (WCAG AA compliant)
- Color not sole indicator (icons + colors)
- Adjustable font sizes (future enhancement)

### 8.2 Input Accessibility

- Touch targets meet minimum size (44×44px)
- Clear visual feedback on all interactions
- Error messages clearly displayed

---

*This UI design maintains v1.0's clean aesthetic while adding comprehensive monetization interfaces that are intuitive and mobile-friendly.*

# Pinball Game v2.0 - Upgrade Systems Design

## 1. Overview

Pinball v2.0 introduces comprehensive upgrade systems that enhance gameplay through physics modifications, special abilities, and visual effects. All upgrades are optional and can be purchased through the shop system using coins (common items) or gems (premium items).

### 1.1 Upgrade Philosophy

- **Meaningful Impact**: Upgrades provide noticeable gameplay advantages
- **Balanced**: Upgrades don't break game balance or create unfair advantages
- **Visual Feedback**: Upgrades have clear visual and audio effects
- **Progression**: Upgrades create sense of progression and collection
- **Optional**: Default items provide complete gameplay experience

---

## 2. Ball Upgrade System

### 2.1 Ball Upgrade Tiers

#### Tier 0: Standard Ball (Default - Free)
- **Physics**:
  - Mass: 0.5
  - Bounce: 0.8
  - Friction: 0.3
  - Linear Damping: 0.05
  - Angular Damping: 0.05
  - Gravity Scale: 1.0
- **Visual**: Red circle
- **Special Abilities**: None
- **Price**: Free (default equipped)

#### Tier 1: Heavy Ball (Common - 500 Coins)
- **Physics**:
  - Mass: 0.8 (+60%)
  - Bounce: 0.8 (same)
  - Friction: 0.3 (same)
  - Linear Damping: 0.07 (+40%)
  - Angular Damping: 0.05 (same)
  - Gravity Scale: 1.0 (same)
- **Visual**: Darker red circle, slightly larger appearance
- **Special Abilities**: 
  - Increased momentum (harder to stop, more impact force)
  - Better for hitting obstacles with force
- **Gameplay Impact**: Medium - useful for players who want more control and power
- **Price**: 500 coins

#### Tier 2: Bouncy Ball (Common - 1000 Coins)
- **Physics**:
  - Mass: 0.5 (same)
  - Bounce: 1.0 (+25%)
  - Friction: 0.2 (-33%)
  - Linear Damping: 0.03 (-40%)
  - Angular Damping: 0.03 (-40%)
  - Gravity Scale: 1.0 (same)
- **Visual**: Bright red/orange circle with glow effect
- **Special Abilities**:
  - Higher energy retention (bounces longer, faster)
  - Better for combo scoring and obstacle chains
- **Gameplay Impact**: Medium - useful for players who want faster, more dynamic gameplay
- **Price**: 1000 coins

#### Tier 3: Magnetic Ball (Premium - 50 Gems)
- **Physics**:
  - Mass: 0.6 (+20%)
  - Bounce: 0.75 (-6%)
  - Friction: 0.3 (same)
  - Linear Damping: 0.07 (+40%)
  - Angular Damping: 0.05 (same)
  - Gravity Scale: 1.0 (same)
- **Visual**: Blue/purple circle with electric glow, magnetic field visualization
- **Special Abilities**:
  - **Magnetic Attraction**: Attracts to obstacles within 150px radius
  - Attraction force: 150.0 units (scales with distance)
  - Visual: Electric arc connections to nearby obstacles
  - Effect: Easier to hit obstacles, better combo potential
- **Gameplay Impact**: High - significantly easier obstacle hits, better for high scores
- **Price**: 50 gems
- **Implementation**: See Physics-Specifications-v2.0.md for detailed physics calculations

#### Tier 4: Fire Ball (Premium - 150 Gems)
- **Physics**:
  - Mass: 0.45 (-10%)
  - Bounce: 1.04 (+30%)
  - Friction: 0.15 (-50%)
  - Linear Damping: 0.03 (-40%)
  - Angular Damping: 0.03 (-40%)
  - Gravity Scale: 1.0 (same)
- **Visual**: Orange/red circle with fire particle trail, flame effects
- **Special Abilities**:
  - **Burn Effect**: When ball hits obstacle, starts "burning" for 3 seconds
  - **Chain Reaction**: Obstacles within 80px radius also "ignite" on hit
  - **Score Multiplier**: 1.5× score multiplier while burning
  - Visual: Fire particle system, orange glow, trail effect
- **Gameplay Impact**: Very High - significantly higher scores due to multipliers and chain reactions
- **Price**: 150 gems
- **Implementation**: See Physics-Specifications-v2.0.md for chain reaction calculations

#### Tier 5: Cosmic Ball (Exclusive - 300 Gems)
- **Physics**:
  - Mass: 0.5 (same)
  - Bounce: 0.85 (+6%)
  - Friction: 0.2 (-33%)
  - Linear Damping: 0.05 (same)
  - Angular Damping: 0.05 (same)
  - Gravity Scale: 0.5 (-50% gravity)
- **Visual**: Purple/blue circle with cosmic distortion, star particles, space shader
- **Special Abilities**:
  - **Anti-Gravity**: Creates local gravity well (gravity scale 0.5, -300 units upward force)
  - **Time Warp**: Nearby obstacles slow down (time dilation effect, 0.7× speed)
  - **Visual Distortion**: Space distortion shader effect around ball
  - **Star Trail**: Galaxy particle trail following ball
- **Gameplay Impact**: Very High - unique physics create interesting gameplay, high scores possible
- **Price**: 300 gems (most expensive, exclusive item)
- **Implementation**: See Physics-Specifications-v2.0.md for gravity well and time warp calculations

### 2.2 Ball Upgrade Comparison Table

| Ball | Price | Mass | Bounce | Special Ability | Best For |
|------|-------|------|--------|-----------------|----------|
| Standard | Free | 0.5 | 0.8 | None | All players |
| Heavy | 500 coins | 0.8 | 0.8 | More momentum | Power players |
| Bouncy | 1000 coins | 0.5 | 1.0 | High energy | Speed players |
| Magnetic | 50 gems | 0.6 | 0.75 | Obstacle attraction | Combo players |
| Fire | 150 gems | 0.45 | 1.04 | Chain reactions | Score maximizers |
| Cosmic | 300 gems | 0.5 | 0.85 | Anti-gravity | Unique gameplay |

### 2.3 Ball Visual Effects System

#### Trail System
All upgraded balls can have custom trails:
- **Standard Trail**: Default red trail (Standard, Heavy, Bouncy balls)
- **Fire Trail**: Orange flame particles (Fire Ball)
- **Electric Trail**: Blue/purple electric arcs (Magnetic Ball)
- **Galaxy Trail**: Star particles, nebula effect (Cosmic Ball)
- **Rainbow Trail**: Multi-color gradient (Cosmetic purchase)

#### Particle Effects
- **Fire Ball**: Continuous fire particles, ignition burst on obstacle hit
- **Magnetic Ball**: Electric arc connections to nearby obstacles
- **Cosmic Ball**: Star field particles, cosmic distortion shader, gravity well visualization

#### Shader Effects
- **Magnetic Ball**: Electric glow shader, pulsing energy effect
- **Cosmic Ball**: Space distortion shader, gravitational lensing effect
- **Fire Ball**: Flame shader, heat distortion effect

---

## 3. Flipper Upgrade System

### 3.1 Flipper Upgrade Variants

#### Variant 0: Standard Flipper (Default - Free)
- **Physics**:
  - Length: 64 pixels
  - Rotation Speed: 20.0 degrees/second
  - Power Multiplier: 1.0×
  - Bounce: 0.6
  - Friction: 0.5
- **Visual**: Light blue baseball bat shape
- **Special Abilities**: None
- **Price**: Free (default equipped)

#### Variant 1: Long Flipper (Common - 1000 Coins)
- **Physics**:
  - Length: 80 pixels (+25%)
  - Rotation Speed: 20.0 degrees/second (same)
  - Power Multiplier: 1.0× (same)
  - Bounce: 0.6 (same)
  - Friction: 0.5 (same)
- **Visual**: Light blue, longer baseball bat shape
- **Special Abilities**:
  - Wider hitbox (easier to hit ball)
  - Better coverage of bottom area
- **Gameplay Impact**: Medium - easier ball control, fewer missed hits
- **Price**: 1000 coins

#### Variant 2: Power Flipper (Premium - 50 Gems)
- **Physics**:
  - Length: 64 pixels (same)
  - Rotation Speed: 20.0 degrees/second (same)
  - Power Multiplier: 1.3× (+30% impulse force)
  - Bounce: 0.7 (+17%)
  - Friction: 0.5 (same)
- **Visual**: Darker blue, thicker appearance, power glow effect
- **Special Abilities**:
  - Increased impulse force when hitting ball
  - Ball travels faster and further after flipper hit
  - Better for launching ball to top of playfield
- **Gameplay Impact**: High - significantly more power, better for reaching top obstacles
- **Price**: 50 gems

#### Variant 3: Twin Flipper (Premium - 75 Gems)
- **Physics**:
  - Length: 64 pixels (primary segment)
  - Secondary Length: 30 pixels (secondary segment)
  - Rotation Speed: 20.0 degrees/second (same)
  - Power Multiplier: 1.0× (same)
  - Secondary Angle Offset: 15.0 degrees
  - Bounce: 0.6 (same)
  - Friction: 0.5 (same)
- **Visual**: Two-segment flipper, joint visible, unique design
- **Special Abilities**:
  - **Dual Segment**: Secondary segment attached via PinJoint2D
  - **Wider Coverage**: Two segments provide extended hitbox
  - **Dual Hit**: Can hit ball with both segments in rapid succession
  - **Flexible Movement**: Secondary segment moves with offset angle
- **Gameplay Impact**: Very High - significantly better coverage and control
- **Price**: 75 gems
- **Implementation**: See Physics-Specifications-v2.0.md for joint physics

#### Variant 4: Plasma Flipper (Premium - 150 Gems)
- **Physics**:
  - Length: 64 pixels (same)
  - Rotation Speed: 25.0 degrees/second (+25%)
  - Power Multiplier: 1.2× (+20%)
  - Bounce: 0.7 (+17%)
  - Friction: 0.4 (-20%)
- **Visual**: Plasma shader effect, electric arcs, blue/purple glow
- **Special Abilities**:
  - **Plasma Effect**: Visual plasma shader with animated waves
  - **Electric Arcs**: Sparks when ball hits flipper
  - **Faster Rotation**: 25% faster than standard
  - **Combined Power**: Both speed and power bonuses
- **Gameplay Impact**: Very High - best overall flipper performance
- **Price**: 150 gems
- **Implementation**: See Physics-Specifications-v2.0.md for shader specifications

#### Variant 5: Turbo Flipper (Exclusive - 200 Gems)
- **Physics**:
  - Length: 64 pixels (same)
  - Rotation Speed: 30.0 degrees/second (+50%)
  - Power Multiplier: 1.0× (same)
  - Bounce: 0.6 (same)
  - Friction: 0.5 (same)
- **Visual**: Yellow/orange glow, speed lines, turbo effect
- **Special Abilities**:
  - **Maximum Speed**: Fastest rotation speed (50% faster)
  - **Rapid Response**: Almost instant flipper activation
  - **Speed Lines**: Visual effect showing speed
- **Gameplay Impact**: High - fastest response time, excellent for precise timing
- **Price**: 200 gems (most expensive flipper)

### 3.2 Flipper Upgrade Comparison Table

| Flipper | Price | Length | Rotation Speed | Power | Special Ability |
|---------|-------|--------|----------------|-------|-----------------|
| Standard | Free | 64px | 20°/s | 1.0× | None |
| Long | 1000 coins | 80px | 20°/s | 1.0× | Wider hitbox |
| Power | 50 gems | 64px | 20°/s | 1.3× | More force |
| Twin | 75 gems | 64+30px | 20°/s | 1.0× | Dual segment |
| Plasma | 150 gems | 64px | 25°/s | 1.2× | Plasma effect |
| Turbo | 200 gems | 64px | 30°/s | 1.0× | Maximum speed |

### 3.3 Flipper Visual Effects

#### Shader Effects
- **Plasma Flipper**: Plasma shader with animated waves, electric arcs on hit
- **Turbo Flipper**: Speed lines, motion blur effect
- **Power Flipper**: Power glow, impact flash on hit

#### Particle Effects
- **Plasma Flipper**: Electric sparks when ball collides
- **Standard/Long/Power**: Standard impact particles (optional)

---

## 4. Ramp Upgrade System

### 4.1 Special Ramp Types

All special ramps are session-based (activated for current game only). Standard ramps are permanent fixtures in the playfield.

#### Ramp Type 1: Multiplier Ramp (Session - 100 Coins)
- **Activation**: Purchase for current game session
- **Effect**: When ball passes through ramp, applies 2× score multiplier for 10 seconds
- **Visual**: Golden glow, multiplier indicator (×2) above ramp
- **Mechanics**:
  - Ball enters ramp Area2D
  - Multiplier effect activates on ball
  - Score multiplier applied to all obstacle hits
  - Timer counts down from 10 seconds
  - Effect expires, multiplier returns to 1×
- **Stacking**: Multiple multiplier ramps extend duration (additive, max 30 seconds)
- **Gameplay Impact**: Medium - doubles score during effect, useful for high-score runs
- **Price**: 100 coins per activation

#### Ramp Type 2: Bank Shot Ramp (Session - 200 Coins)
- **Activation**: Purchase for current game session
- **Effect**: Applies curved force to guide ball toward target hold
- **Visual**: Arrow indicator showing target direction, trajectory line preview
- **Mechanics**:
  - Ball enters ramp Area2D
  - System calculates trajectory to nearest hold (or highest-value hold)
  - Applies perpendicular force (curve_strength: 500.0 units) to guide ball
  - Visual guide line shows trajectory
  - Ball curves toward target hold
- **Target Selection**: Automatically targets highest-value hold within range
- **Gameplay Impact**: High - guarantees hold entry for bonus coins, final scoring
- **Price**: 200 coins per activation

#### Ramp Type 3: Accelerator Ramp (Session - 150 Coins)
- **Activation**: Purchase for current game session
- **Effect**: Boosts ball speed by 50% when passing through
- **Visual**: Speed lines, acceleration particles, blue energy effect
- **Mechanics**:
  - Ball enters ramp Area2D
  - Current ball velocity measured
  - Velocity increased by 50% (multiplier: 1.5×)
  - Visual speed effect applied
  - Ball continues at increased speed
- **Speed Cap**: Maximum speed cap prevents physics glitches
- **Gameplay Impact**: Medium - faster gameplay, more dynamic ball movement
- **Price**: 150 coins per activation

### 4.2 Ramp Placement and Activation

#### Placement Rules
- Special ramps replace existing standard ramps (player chooses which ramp to upgrade)
- Maximum 2 special ramps per game session
- Ramps can be positioned in same locations as standard ramps
- Visual indicator shows which ramps are active

#### Activation Flow
1. Player purchases ramp activation in shop (before game starts) or during pause
2. Ramp is "equipped" for current session
3. Visual indicator appears on ramp in playfield
4. Ramp effect activates when ball enters ramp Area2D
5. Effect applies according to ramp type
6. Effect expires (for multiplier) or completes (for bank shot/accelerator)
7. Ramp returns to standard after session ends

#### Permanent Ramp Unlocks (Future)
- Future enhancement: Permanent ramp unlocks (costs gems, applies to all sessions)
- Currently: All special ramps are session-based only

---

## 5. Cosmetic System

### 5.1 Ball Trail Customization

#### Trail Types
- **Standard Trail**: Default red trail (free, all balls)
- **Fire Trail**: Orange flame particles (200 coins, matches Fire Ball)
- **Electric Trail**: Blue/purple electric arcs (300 coins, matches Magnetic Ball)
- **Rainbow Trail**: Multi-color gradient trail (500 coins, all balls)
- **Galaxy Trail**: Star particles, nebula effect (50 gems, all balls, premium)

#### Trail Properties
- **Length**: 15-20 trail points (configurable)
- **Width**: 3-5 pixels (configurable)
- **Fade**: Alpha gradient from current position to oldest point
- **Texture**: Trail texture (tile or stretch mode)

#### Trail Implementation
- Uses Line2D node following ball
- Trail points updated each frame
- Oldest points removed when trail exceeds length
- Particle effects overlaid on trail for premium trails

### 5.2 Table Skin Customization

#### Table Themes

**Classic Theme** (Default - Free):
- Background: Dark blue-gray (0.1, 0.1, 0.2, 1)
- Walls: Gray-blue (0.3, 0.3, 0.4, 1)
- Obstacles: Default colors
- Overall: Standard pinball aesthetic

**Neo-Noir Theme** (300 Coins):
- Background: Very dark (0.05, 0.05, 0.05, 1)
- Walls: Purple accent (0.3, 0.0, 0.4, 1)
- Obstacles: Neon pink/magenta (0.8, 0.0, 0.6, 1)
- Overall: Dark, cyberpunk-inspired aesthetic

**Cyberpunk Theme** (75 Gems):
- Background: Cyberpunk cityscape texture
- Walls: Neon blue/green (0.0, 0.8, 0.6, 1)
- Obstacles: Neon yellow/orange (1.0, 0.8, 0.0, 1)
- Effects: Scanline shader overlay
- Overall: Futuristic, high-tech aesthetic

**Nature Theme** (200 Coins):
- Background: Forest/meadow texture
- Walls: Brown/tan (0.4, 0.3, 0.2, 1)
- Obstacles: Green/earth tones
- Effects: Subtle nature particles
- Overall: Natural, organic aesthetic

**Space Theme** (100 Gems):
- Background: Space/nebula texture with stars
- Walls: Dark purple (0.1, 0.1, 0.3, 0.8)
- Obstacles: Bright star colors (white, blue, yellow)
- Effects: Star particle field, cosmic glow
- Overall: Space, cosmic aesthetic

#### Table Skin Implementation
- Table skins modify background texture, wall colors, obstacle colors
- Shader effects applied as overlay
- Particle systems added for themed effects
- All gameplay mechanics unchanged (only visual)

### 5.3 Flipper Skin Customization

#### Flipper Skins (Visual-Only)
- **Standard Skin**: Light blue (default, free)
- **Fire Skin**: Red/orange with flame pattern (200 coins)
- **Ice Skin**: Blue/white with frost pattern (200 coins)
- **Plasma Skin**: Purple/blue with plasma pattern (300 coins)
- **Cosmic Skin**: Space-themed with star pattern (50 gems)

**Note**: Flipper skins are cosmetic only and don't affect gameplay. Premium flipper upgrades (Plasma Flipper, etc.) have built-in visual effects that override skins.

### 5.4 Sound Pack Customization

#### Sound Packs
- **Classic Pack**: Default pinball sounds (free)
- **Sci-Fi Pack**: Futuristic sound effects (100 coins)
- **Nature Pack**: Natural, ambient sounds (100 coins)
- **Electronic Pack**: Electronic/synthetic sounds (200 coins)
- **Retro Pack**: 8-bit style sounds (300 coins)

#### Sound Pack Implementation
- Replaces sound effects for: flipper clicks, obstacle hits, ball launch, hold entry, ball lost
- Background music can be themed (optional, future enhancement)
- All gameplay sounds remain functional, only audio style changes

---

## 6. Upgrade Balance and Gameplay Impact

### 6.1 Upgrade Power Level

| Upgrade Tier | Power Level | Gameplay Impact | Recommended For |
|--------------|-------------|-----------------|-----------------|
| Common (Coins) | Low-Medium | Noticeable but balanced | Casual players |
| Premium (Gems) | Medium-High | Significant advantages | Engaged players |
| Exclusive (High Gems) | Very High | Maximum advantages | Dedicated players |

### 6.2 Balance Considerations

**Free Players**:
- Can earn enough coins to purchase common upgrades
- Can earn gems slowly through ads and daily rewards
- Can eventually acquire premium items with time investment
- Gameplay experience remains complete without upgrades

**Paying Players**:
- Faster progression and immediate access to premium items
- Exclusive items provide unique gameplay experiences
- Visual customization options
- Time savings (less grinding)

**Balance Principles**:
1. No upgrade makes the game "unfair" - all players can achieve high scores
2. Upgrades provide advantages but don't break core gameplay
3. Skill still matters more than upgrades
4. Upgrades enhance experience, don't gate content

### 6.3 Upgrade Recommendation System

**For New Players**:
- Recommend Heavy Ball (affordable, noticeable impact)
- Recommend Long Flipper (easier ball control)

**For Experienced Players**:
- Recommend Magnetic Ball (better combo potential)
- Recommend Power or Twin Flipper (advanced control)

**For Score Maximizers**:
- Recommend Fire Ball (score multipliers)
- Recommend Multiplier Ramps (doubles score)

**For Collection Players**:
- Recommend Cosmic Ball (unique gameplay)
- Recommend all table skins (visual variety)

---

## 7. Implementation Specifications

### 7.1 Upgrade Data Structure

```gdscript
# UpgradeData.gd (Resource)
extends Resource
class_name UpgradeData

@export var upgrade_id: String
@export var name: String
@export var category: String  # "ball", "flipper", "ramp", "cosmetic"
@export var tier: String  # "common", "premium", "exclusive"
@export var price_coins: int = 0
@export var price_gems: int = 0

# Physics modifications (for ball/flipper)
@export var physics_modifications: Dictionary = {}

# Special abilities
@export var special_abilities: Array[Dictionary] = []

# Visual effects
@export var visual_effects: Dictionary = {}

# Description
@export var description: String = ""
```

### 7.2 Upgrade Application Flow

```
1. Player purchases upgrade in shop
2. Upgrade marked as "owned" in player data
3. Player equips upgrade in Customize scene
4. Equipped upgrade ID saved to GlobalGameSettings
5. On game start, GameManager loads equipped upgrade
6. GameManager applies upgrade to game object (Ball/Flipper/Ramp)
7. Physics modifications applied
8. Visual effects activated
9. Special abilities enabled
10. Gameplay proceeds with upgraded item
```

### 7.3 Upgrade Compatibility

- Only one ball upgrade active at a time
- Only one flipper upgrade active at a time (applies to both flippers)
- Multiple special ramps can be active (up to 2 per session)
- Cosmetics can be mixed (trail + table skin + flipper skin + sound pack)

---

*This upgrade system provides meaningful progression while maintaining game balance and ensuring all players can enjoy the full gameplay experience.*

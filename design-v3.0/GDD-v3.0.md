# Pinball Game - Game Design Document v3.0

## Document Information

- **Game Title**: Pinball
- **Version**: 3.0
- **Last Updated**: 2025-01-25
- **Engine**: Godot 4.5
- **Platform**: Mobile (iOS, Android) - Primary; Desktop support maintained
- **Base Versions**: Inherits all features from v1.0 and v2.0

---

## 1. Game Overview

### 1.1 Game Concept

Pinball v3.0 is a major enhancement that builds upon v1.0 (core mechanics) and v2.0 (monetization, mobile support) by incorporating proven game mechanics from open-source pinball projects and enhancing visual/audio polish using Godot best practices. v3.0 introduces modern pinball mechanics including skill shots, multiball mode, dynamic multipliers, combo systems, and enhanced physics for a more engaging and attractive gameplay experience.

### 1.2 Key Enhancements

v3.0 incorporates design elements from:
- **VisualPinball.Engine/vpinball**: Realistic physics values, proper elasticity/friction settings, advanced flipper mechanics
- **Flutter Pinball (Google I/O)**: Modern mechanics (skill shots, multiball, multipliers, blinking behaviors)
- **Godot Demos**: Animation techniques (tweening), particle effects, audio effects

### 1.3 Inheritance

v3.0 preserves 100% compatibility with:
- **v1.0**: All core mechanics (ball physics, flippers, obstacles, holds, ramps, maze pipe system)
- **v2.0**: All monetization features (shop, currency, battle pass, upgrades, mobile support)

---

## 2. v3.0 New Features

### 2.1 Enhanced Physics System

#### Playfield Physics
- **Gravity constant**: Normalized to 0.97-1.0 range (was 980.0)
- **Playfield friction**: 0.075+ (adjustable for ball speed)
- **Playfield elasticity**: 0.25 (realistic bounce)

#### Flipper Physics (Enhanced)
- **Strength**: 1200-1800 (EM tables) or 2200-2800 (modern tables) - configurable
- **Elasticity**: 0.55-0.8 (was 0.6)
- **Elasticity falloff**: 0.1-0.43 (new property for realistic flipper feel)
- **Friction**: 0.1-0.6 (was 0.5)
- **Return strength**: 0.058+ (smooth return)
- **Coil up ramp**: 2.4-3.5 (gradual power increase)

#### Rubber/Wall Physics
- **Rubber elasticity**: 0.6-0.8 (was 0.8)
- **Rubber elasticity falloff**: 0.2-0.4 (new)
- **Wall elasticity**: 0.3-0.5 (metal) or 0.375-0.425 (wood)
- **Scatter angle**: 5 degrees (randomness in physics interactions)

**Implementation**: `scripts/Flipper.gd`, `scripts/Ball.gd`, physics materials

### 2.2 Skill Shot System

**Concept**: Launch ball through specific target zones for bonus points

**Mechanics**:
- Multiple skill shot targets at different heights/angles
- Time window: 2-3 seconds after launch
- Scoring: 100-500 points based on difficulty level
- Visual feedback: Target zones glow/blink when active
- Audio: Distinct sound for skill shot success

**Implementation**: `scripts/SkillShot.gd` component, Area2D zones, visual indicators

### 2.3 Multiball Mode

**Concept**: Multiple active balls simultaneously for high-scoring chaos

**Mechanics**:
- Trigger: Hit specific combination of targets or hold entries (configurable)
- Activation: 2-4 balls released simultaneously
- Duration: Until all balls are lost or time limit (30-60 seconds)
- Scoring multiplier: 1.5x-2x during multiball
- Visual: Distinct ball colors/trails for each ball
- Audio: Special multiball music/effects

**Implementation**: `scripts/MultiballManager.gd`, extends `BallQueue.gd`, visual effects

### 2.4 Dynamic Multiplier System

**Concept**: Progressive score multipliers that increase with gameplay

**Mechanics**:
- Base multiplier: 1x
- Increase: +0.5x per 5 obstacle hits or specific target sequences
- Max multiplier: 5x-10x (configurable)
- Visual: Multiplier display with pulsing animation
- Decay: Multiplier decreases if no hits for 10 seconds
- Special ramps: Multiplier ramps double current multiplier for 10 seconds

**Implementation**: `scripts/MultiplierSystem.gd`, integrated into `GameManager.gd`, UI updates

### 2.5 Combo System

**Concept**: Chain hits for bonus scoring

**Mechanics**:
- Combo window: 3 seconds between hits
- Combo multiplier: +0.1x per hit in combo
- Max combo: 20 hits (2x multiplier)
- Visual: Combo counter with animation
- Audio: Rising pitch per combo hit

**Implementation**: `scripts/ComboSystem.gd`, integrated into `GameManager.gd`

### 2.6 Enhanced Bumpers

**Current (v2.0)**: Static bumpers with basic bounce

**v3.0 Enhancements**:
- **Blinking Behavior**: Bumpers pulse/glow when ready to be hit
- **Bumping Behavior**: Active force application (strength: 15-25)
- **Visual States**: Lit (active) vs dimmed (cooldown)
- **Particle Effects**: Explosion particles on hit
- **Audio**: Distinct bumper hit sound with pitch variation

**Implementation**: Enhanced `scripts/Obstacle.gd`, blinking behavior, particle systems

### 2.7 Animation System

**Tween-based Animations** (from Godot tween demo):
- Score popups: Animated text that scales up and fades out
- Multiplier display: Pulsing scale animation
- UI transitions: Smooth fade/slide animations
- Component highlights: Glow/shake effects on important events
- Screen shake: Subtle shake on big hits/multiball activation

**Implementation**: `scripts/AnimationManager.gd`, uses Godot's Tween system

### 2.8 Particle Effects

**Particle Systems** (from Godot particles demo):
- **Bumper Hits**: Explosion particles with sparks
- **Ball Trails**: Customizable trail effects (fire, electric, cosmic)
- **Multiplier Activation**: Particle burst on multiplier increase
- **Multiball Launch**: Special particle effect when multiball activates
- **Hold Entry**: Celebration particles

**Implementation**: `scripts/ParticleManager.gd`, GPUParticles2D nodes, particle materials

### 2.9 Enhanced Audio System

**Audio Bus System**:
- Separate buses for SFX, music, UI
- Dynamic effects:
  - Reverb on bumper hits (spatial audio)
  - Pitch variation based on ball speed
  - Low-pass filter during pause
  - Echo effect for multiball mode

**Enhanced Sound Design**:
- Bumper hits: Multiple variations with pitch randomization
- Flipper clicks: Mechanical sound with slight variation
- Ball launch: Charging sound that increases in pitch
- Skill shot: Distinct success/fail sounds
- Multiball: Special music/ambient track
- Multiplier increase: Rising tone effect

**Implementation**: Enhanced `scripts/SoundManager.gd`, audio buses, AudioEffectReverb, AudioEffectPitchShift

### 2.10 Enhanced UI

**New UI Elements**:
- **Score Display**: Animated with popup effects
- **Multiplier Display**: Large, pulsing display when >1x
- **Combo Counter**: Shows current combo chain
- **Ball Counter**: Enhanced visual for remaining balls
- **Visual Polish**: Screen shake, color grading, glow effects, smooth transitions

**Implementation**: Enhanced `scripts/UI.gd`, new UI components

---

## 3. Technical Implementation

### 3.1 New Scripts

- `scripts/SkillShot.gd` - Skill shot system
- `scripts/MultiballManager.gd` - Multiball mode management (with enhanced dependency finding)
- `scripts/MultiplierSystem.gd` - Dynamic multiplier system
- `scripts/ComboSystem.gd` - Combo tracking
- `scripts/AnimationManager.gd` - Animation system
- `scripts/ParticleManager.gd` - Particle effect management

**Note**: GameManager uses `preload()` statements for all v3.0 system classes for better performance.

### 3.2 Modified Scripts

- `scripts/Flipper.gd` - Enhanced physics (strength, elasticity falloff, coil up ramp)
- `scripts/Ball.gd` - Enhanced physics (playfield friction)
- `scripts/GameManager.gd` - Integration of all v3.0 systems (with preload statements, version detection, skill shot signal connection)
- `scripts/Obstacle.gd` - Blinking, bumping behaviors, particle effects
- `scripts/UI.gd` - Enhanced HUD with multiplier/combo displays (with update loop)
- `scripts/SoundManager.gd` - Audio buses, pitch variation, new sounds (gracefully handles missing sound files)

### 3.3 Architecture

- **Behavior System**: Component-based behaviors (blinking, bumping, etc.)
- **Event System**: Enhanced signal system for game events
- **State Management**: Improved game state management with v3.0 systems

---

## 4. Gameplay Flow (v3.0)

### 4.1 Enhanced Gameplay Loop

1. Game starts with balls in queue
2. Player releases ball from queue
3. Ball falls through maze pipe to launcher
4. **v3.0**: Skill shots activate (2-3 second window)
5. Player charges and launches ball
6. **v3.0**: Ball can hit skill shot targets for bonus points
7. Ball interacts with obstacles (scores points, builds combo, increases multiplier)
8. **v3.0**: Bumpers blink and apply active force
9. **v3.0**: Combo system tracks chain hits
10. **v3.0**: Multiplier increases with hits, decays if inactive
11. **v3.0**: Multiball can activate (multiple balls, scoring multiplier)
12. Ball interacts with holds (final scoring)
13. Repeat until all balls used

### 4.2 v3.0 Scoring Flow

- **Base Score**: Points from obstacles/holds (v1.0/v2.0)
- **Skill Shot Bonus**: 100-500 points for skill shots
- **Combo Multiplier**: Up to 2x from combo chain
- **Dynamic Multiplier**: Up to 10x from progressive hits
- **Multiball Multiplier**: 1.5x-2x during multiball
- **Final Score**: Base × Combo × Dynamic × Multiball multipliers

---

## 5. Design Principles for v3.0

1. **Inheritance**: All v1.0 and v2.0 features preserved
2. **Realism**: Physics values from real pinball machines (vpinball)
3. **Engagement**: Modern mechanics for sustained interest (Flutter pinball)
4. **Polish**: Professional visual/audio feedback (Godot demos)
5. **Performance**: Optimized for mobile and desktop
6. **Accessibility**: Clear visual/audio cues for all players

---

## 6. Version History

- **v3.0** (2025-01-25): Enhanced mechanics, physics, animations, audio, and UI polish
- **v2.0** (2024): Monetization, mobile support, upgrades, battle pass
- **v1.0** (2024): Base game with core pinball mechanics

---

## 7. Future Enhancements

### 7.1 Potential v3.1 Features
- Progressive difficulty system
- Special game modes (Frenzy, Time Attack, Precision)
- Advanced particle customization
- More skill shot variations

### 7.2 Long-term (v4.0+)
- Campaign mode with progressive levels
- Tournament mode
- Player vs Player multiplayer
- User-generated content

---

*This document inherits all specifications from v1.0 and v2.0 GDDs and adds v3.0 enhancements. For complete technical details, refer to the specific design documents and source code.*

# Pinball Game v3.0 - Technical Design Document

## 1. Architecture Overview

### 1.1 System Architecture (Enhanced)

The v3.0 architecture builds upon v1.0's component-based design and v2.0's monetization layer, adding enhanced physics, modern game mechanics, and visual/audio polish systems.

**Architecture Layers**:
```
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (UI, Shop, Customize, Battle Pass)    │
│  + v3.0: Animation, Particle Effects   │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Gameplay Layer (v1.0 + v3.0)       │
│  (Ball, Flipper, Obstacle, GameManager, │
│   SkillShot, Multiball, Combo, Multiplier)│
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Enhancement Layer (v3.0 NEW)       │
│  (AnimationManager, ParticleManager,    │
│   Enhanced Physics, Audio Buses)        │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Monetization Layer (v2.0)          │
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

**Inherited from v1.0 and v2.0**:
- Each game element is a separate scene
- Signal-based communication
- Modular and reusable components
- Autoload singletons for global systems
- Manager pattern for systems

**v3.0 Enhancements**:
- Behavior-based components (blinking, bumping behaviors)
- Animation system with tween management
- Particle effect system with pooling
- Enhanced audio system with bus management
- Physics enhancement system with realistic values

---

## 2. Scene Structure

### 2.1 Main Scene (Enhanced)

**Scene**: `scenes/Main.tscn`

**Node Structure** (v3.0 additions):
```
Main (Node2D)
├── Playfield (Node2D)
│   ├── Walls (StaticBody2D)
│   ├── ObstacleSpawner (Node2D)
│   │   └── [Obstacle instances]
│   ├── HoldSpawner (Node2D)
│   │   └── [Hold instances]
│   ├── RampSpawner (Node2D)
│   │   └── [Ramp instances]
│   ├── SkillShotSpawner (Node2D) - NEW v3.0
│   │   └── [SkillShot instances]
│   └── MazePipeManager (TileMapLayer)
├── GameManager (Node2D)
│   ├── MultiballManager (Node) - NEW v3.0
│   ├── ComboSystem (Node) - NEW v3.0
│   ├── AnimationManager (Node) - NEW v3.0
│   └── ParticleManager (Node) - NEW v3.0
├── BallQueue (Node2D)
├── Launcher (Node2D)
├── FlipperLeft (RigidBody2D)
├── FlipperRight (RigidBody2D)
├── UI (CanvasLayer)
│   ├── ScoreLabel (Label)
│   ├── MultiplierLabel (Label) - NEW v3.0
│   ├── ComboLabel (Label) - NEW v3.0
│   └── CurrencyDisplay (HBoxContainer)
├── Camera2D
└── SoundManager (Node)
```

### 2.2 New v3.0 Scenes

**SkillShot Scene**: `scenes/SkillShot.tscn`
- Area2D with CollisionShape2D
- Visual indicator (ColorRect/Sprite2D)
- Script: `SkillShot.gd`

**Particle Effect Scenes**: Created programmatically by ParticleManager
- Bumper hit particles
- Ball trail particles
- Multiplier activation particles
- Multiball launch particles

---

## 3. Script Architecture

### 3.1 Core Gameplay Scripts (Enhanced)

#### GameManager.gd (v3.0 Enhanced)

**Preload Statements** (v3.0):
```gdscript
# v3.0: Preload system classes
const MultiballManager = preload("res://scripts/MultiballManager.gd")
const ComboSystem = preload("res://scripts/ComboSystem.gd")
const AnimationManager = preload("res://scripts/AnimationManager.gd")
const ParticleManager = preload("res://scripts/ParticleManager.gd")
```

**New Properties**:
```gdscript
# v3.0: New systems
var multiball_manager: Node = null
var combo_system: Node = null
var animation_manager: Node = null
var current_multiplier: float = 1.0
var multiplier_timer: float = 0.0
var obstacle_hit_count: int = 0
var skill_shots: Array[Node] = []
var is_v3_mode: bool = false  # Version detection
```

**New Methods**:
- `_initialize_v3_systems()` - Initialize all v3.0 systems (only if v3.0 mode)
- `_connect_skill_shot_signals()` - Connect skill shot signals to GameManager
- `_on_skill_shot_hit(points: int)` - Handle skill shot scoring
- `_on_multiball_activated(ball_count: int)` - Handle multiball activation
- `_on_multiball_ended()` - Handle multiball end
- `_on_combo_increased(combo_count: int, multiplier: float)` - Handle combo updates
- `_update_multiplier()` - Manage dynamic multiplier
- `_process(delta)` - Handle multiplier decay

**Enhanced Methods**:
- `_on_obstacle_hit()` - Now integrates combo, multiplier, multiball multipliers
- `_on_ball_launched()` - Now activates skill shots

#### Flipper.gd (v3.0 Enhanced)

**New Export Variables**:
```gdscript
# v3.0: Enhanced physics properties from vpinball
@export var flipper_strength: float = 2200.0
@export var elasticity: float = 0.7
@export var elasticity_falloff: float = 0.3
@export var flipper_friction: float = 0.3
@export var return_strength: float = 0.058
@export var coil_up_ramp: float = 3.0
```

**New Methods**:
- `_apply_flipper_force(delta: float)` - Apply realistic flipper force to ball

**Enhanced Methods**:
- `_physics_process()` - Now applies coil up ramp and force

#### Ball.gd (v3.0 Enhanced)

**Enhanced Properties**:
- Playfield friction: 0.075 (was 0.2)

#### Obstacle.gd (v3.0 Enhanced)

**New Export Variables**:
```gdscript
# v3.0: Enhanced bumper properties
@export var is_bumper: bool = false
@export var bumping_strength: float = 20.0
@export var blinking_enabled: bool = true
@export var blink_speed: float = 2.0
```

**New Properties**:
- `is_lit: bool = true` - Visual state
- `blink_timer: float = 0.0` - Blink animation timer

**New Methods**:
- `_apply_bumping_force(ball: RigidBody2D)` - Apply active bumping force
- `_play_hit_effect(ball: RigidBody2D)` - Play visual/audio effect
- `_spawn_hit_particles(position: Vector2)` - Spawn particle effect

**Enhanced Methods**:
- `_process()` - Now handles blinking behavior
- `_on_body_entered()` - Now applies bumping force and particles

### 3.2 New v3.0 Scripts

#### SkillShot.gd

**Purpose**: Skill shot target zones for bonus scoring

**Key Methods**:
- `activate()` - Activate skill shot target
- `deactivate()` - Deactivate target
- `_on_body_entered()` - Handle ball entry
- `_create_visual_indicator()` - Create visual target
- `_play_hit_effect()` - Play hit effect

#### MultiballManager.gd

**Purpose**: Manage multiple active balls simultaneously

**Key Methods**:
- `activate_multiball()` - Activate multiball mode
- `_release_multiball_ball()` - Release a ball for multiball
- `_set_multiball_visual(ball, index)` - Set distinct visual
- `end_multiball()` - End multiball mode
- `is_multiball_active()` - Check if active
- `get_scoring_multiplier()` - Get current multiplier

#### ComboSystem.gd

**Purpose**: Track chain hits for bonus scoring

**Key Methods**:
- `register_hit()` - Register a hit for combo
- `start_combo()` - Start new combo
- `end_combo()` - End current combo
- `get_combo_multiplier()` - Get current multiplier
- `get_combo_count()` - Get current combo count

#### MultiplierSystem.gd

**Purpose**: Progressive score multipliers

**Key Methods**:
- `register_hit()` - Register hit and potentially increase multiplier
- `increase_multiplier()` - Increase multiplier
- `decay_multiplier()` - Decay multiplier if inactive
- `get_multiplier()` - Get current multiplier
- `reset()` - Reset to base

#### AnimationManager.gd

**Purpose**: Tween-based animation system

**Key Methods**:
- `animate_score_popup(position, points, color)` - Animate score popup
- `animate_multiplier_display(control, multiplier)` - Animate multiplier
- `animate_ui_transition(control, fade_in, duration)` - UI transitions
- `animate_component_highlight(node, color, duration)` - Component highlights
- `screen_shake(camera, intensity, duration)` - Screen shake

#### ParticleManager.gd

**Purpose**: Particle effect management

**Key Methods**:
- `spawn_bumper_hit(position)` - Spawn bumper hit particles
- `spawn_multiplier_activation(position)` - Spawn multiplier particles
- `spawn_multiball_launch(position)` - Spawn multiball particles
- `add_ball_trail(ball, color)` - Add trail to ball
- `_create_bumper_particles()` - Create bumper particle system
- `_create_multiplier_particles()` - Create multiplier particle system
- `_create_multiball_particles()` - Create multiball particle system

---

## 4. Data Flow

### 4.1 Gameplay Data Flow (v3.0 Enhanced)

```
Ball Launch
  ↓
SkillShot.activate() [v3.0]
  ↓
Ball Hits Obstacle
  ↓
Obstacle._on_body_entered()
  ├─→ ComboSystem.register_hit() [v3.0]
  ├─→ GameManager._update_multiplier() [v3.0]
  ├─→ Obstacle._apply_bumping_force() [v3.0]
  ├─→ Obstacle._spawn_hit_particles() [v3.0]
  └─→ GameManager._on_obstacle_hit()
      ├─→ Apply multipliers (combo × dynamic × multiball) [v3.0]
      ├─→ AnimationManager.animate_score_popup() [v3.0]
      └─→ Add score
```

### 4.2 Scoring Data Flow (v3.0)

```
Base Points (from obstacle/hold)
  ↓
Apply Combo Multiplier [v3.0]
  ↓
Apply Dynamic Multiplier [v3.0]
  ↓
Apply Multiball Multiplier [v3.0]
  ↓
Final Score
  ↓
Update UI (with animation) [v3.0]
```

### 4.3 Multiball Activation Flow (v3.0)

```
Trigger Condition (manual or automatic)
  ↓
MultiballManager.activate_multiball()
  ├─→ Release multiple balls
  ├─→ Set distinct visuals
  ├─→ Apply scoring multiplier
  ├─→ ParticleManager.spawn_multiball_launch()
  ├─→ AnimationManager.screen_shake()
  └─→ SoundManager.play_sound("multiball_activate")
```

---

## 5. Signal System

### 5.1 New v3.0 Signals

**SkillShot.gd**:
- `skill_shot_hit(points: int)` - Emitted when skill shot is hit

**MultiballManager.gd**:
- `multiball_activated(ball_count: int)` - Emitted when multiball starts
- `multiball_ended()` - Emitted when multiball ends

**ComboSystem.gd**:
- `combo_started()` - Emitted when combo starts
- `combo_increased(combo_count: int, multiplier: float)` - Emitted on each hit
- `combo_ended()` - Emitted when combo ends

**MultiplierSystem.gd**:
- `multiplier_changed(new_multiplier: float)` - Emitted when multiplier changes

**AnimationManager.gd**:
- `animation_completed(animation_name: String)` - Emitted when animation completes

### 5.2 Signal Connections (v3.0)

```gdscript
# In GameManager._initialize_v3_systems()
multiball_manager.multiball_activated.connect(_on_multiball_activated)
multiball_manager.multiball_ended.connect(_on_multiball_ended)
combo_system.combo_increased.connect(_on_combo_increased)

# Skill shots discovered via group
for skill_shot in skill_shots:
    skill_shot.skill_shot_hit.connect(_on_skill_shot_hit)
```

---

## 6. State Management

### 6.1 Game States (v3.0 Enhanced)

**Inherited States** (from v1.0/v2.0):
- Initializing
- Waiting for Release
- Ball at Launcher
- Playing
- Paused
- Ball Ended

**New v3.0 States**:
- Skill Shot Active (2-3 second window after launch)
- Multiball Active (multiple balls in play)
- Combo Active (chain hits within 3 seconds)
- Multiplier Active (multiplier > 1.0)

### 6.2 State Transitions (v3.0)

```
Ball Launch
  ↓
Skill Shot Active (2-3 seconds) [v3.0]
  ↓
Playing
  ├─→ Combo Active (if hits within 3s) [v3.0]
  ├─→ Multiplier Active (if hits accumulated) [v3.0]
  └─→ Multiball Active (if triggered) [v3.0]
```

---

## 7. Performance Considerations

### 7.1 v3.0 Performance Optimizations

**Particle System**:
- Particle effects auto-remove after animation
- Particle pooling for frequently used effects
- LOD system for low-end devices (reduce particle count)

**Animation System**:
- Tween reuse and cleanup
- Parallel tweens for efficiency
- Animation completion callbacks for cleanup

**Physics Enhancements**:
- Force calculations only when flipper is moving
- Efficient collision queries for flipper force
- Scatter angle calculations optimized

**Audio System**:
- Audio bus separation reduces processing overhead
- Pitch variation uses efficient calculations
- Sound pooling for frequently played sounds

### 7.2 Mobile Optimization

- Particle count scaling based on device performance
- Animation complexity reduction on low-end devices
- Audio effect simplification on mobile
- Physics calculations optimized for mobile CPUs

---

## 8. Extension Points

### 8.1 Adding New Skill Shot Types

1. Create new SkillShot scene variant
2. Set difficulty_level and skill_shot_points
3. Add to scene and "skill_shots" group
4. GameManager automatically discovers and activates

### 8.2 Adding New Particle Effects

1. Add method to ParticleManager
2. Create particle system in method
3. Call from appropriate game event
4. Auto-cleanup handled by ParticleManager

### 8.3 Adding New Animations

1. Add method to AnimationManager
2. Use Tween system for animation
3. Connect to game events via signals
4. Handle cleanup in animation completion

---

## 9. Integration with v1.0 and v2.0

### 9.1 v1.0 Compatibility

- All v1.0 components preserved
- All v1.0 physics maintained (with enhancements)
- All v1.0 gameplay flow preserved
- v3.0 features are additive, not replacements

### 9.2 v2.0 Compatibility

- All v2.0 monetization features preserved
- All v2.0 upgrades work with v3.0 enhancements
- v3.0 multipliers stack with v2.0 upgrade bonuses
- Currency and shop systems unchanged

### 9.3 Version Detection

```gdscript
# In GameManager._ready()
var game_version: String = "v1.x"  # v1.x, v2.0, or v3.0
var is_v2_mode: bool = false
var is_v3_mode: bool = false

# Check from GlobalGameSettings
var global_settings = get_node_or_null("/root/GlobalGameSettings")
if global_settings:
    game_version = global_settings.game_version
    is_v2_mode = (game_version == "v2.0" or game_version == "v3.0")
    is_v3_mode = (game_version == "v3.0")

# Initialize v3.0 systems only if v3.0 mode
if is_v3_mode:
    call_deferred("_initialize_v3_systems")
```

---

## 10. Testing Considerations

### 10.1 Unit Testing

- Test each v3.0 system independently
- Test signal connections
- Test multiplier calculations
- Test combo tracking

### 10.2 Integration Testing

- Test v3.0 systems with v1.0/v2.0 systems
- Test scoring with all multipliers active
- Test multiball with multiple systems
- Test particle effects with various events

### 10.3 Performance Testing

- Test particle effects on low-end devices
- Test animation performance with many active animations
- Test physics enhancements don't impact frame rate
- Test audio system with multiple simultaneous sounds

---

*This document specifies the technical architecture for v3.0. For component details, see Component-Specifications-v3.0.md. For physics details, see Physics-Specifications-v3.0.md.*

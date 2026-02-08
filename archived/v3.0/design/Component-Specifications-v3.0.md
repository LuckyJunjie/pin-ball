# Pinball Game v3.0 - Component Specifications

## Overview

This document specifies all components for Pinball v3.0, including enhanced v1.0/v2.0 components and new v3.0 components. All previous version components are preserved with v3.0 enhancements.

---

## 1. Enhanced v1.0/v2.0 Components

### 1.1 Ball Component (v3.0 Enhanced)

#### Scene: Ball.tscn
**Node Structure** (v3.0 additions):
```
Ball (RigidBody2D)
├── CollisionShape2D
│   └── Shape: CircleShape2D (radius: 8.0)
├── Visual (ColorRect/Sprite2D)
│   └── (Upgrade-dependent visual)
├── TrailManager (Node) - v2.0
│   └── TrailLine2D (Line2D)
├── ParticleManager (Node) - v2.0
│   └── GPUParticles2D
├── BallTrail (GPUParticles2D) - NEW v3.0
│   └── (Added by ParticleManager for multiball)
└── UpgradeHandler (Node) - v2.0
    └── Special ability handlers
```

#### Script: Ball.gd (v3.0 Enhanced)

**Class**: `extends RigidBody2D`

**Inherited Properties** (from v1.0/v2.0):
- All previous properties maintained

**Enhanced Properties** (v3.0):
- `physics_material.friction = 0.075` (was 0.2) - Playfield friction from vpinball

**No new methods** - Physics enhancement only

---

### 1.2 Flipper Component (v3.0 Enhanced)

#### Scene: Flipper.tscn
**Node Structure** (unchanged):
```
Flipper (RigidBody2D)
├── CollisionShape2D
│   └── Shape: ConvexPolygonShape2D (baseball bat shape)
└── Visual (ColorRect/Sprite2D)
```

#### Script: Flipper.gd (v3.0 Enhanced)

**Class**: `extends RigidBody2D`

**New Export Variables** (v3.0):
```gdscript
# v3.0: Enhanced physics properties from vpinball
@export var flipper_strength: float = 2200.0  # 1200-1800 (EM) or 2200-2800 (modern)
@export var elasticity: float = 0.7  # 0.55-0.8
@export var elasticity_falloff: float = 0.3  # 0.1-0.43
@export var flipper_friction: float = 0.3  # 0.1-0.6
@export var return_strength: float = 0.058  # Smooth return
@export var coil_up_ramp: float = 3.0  # 2.4-3.5
```

**New Properties** (v3.0):
- `angle_diff: float = 0.0` - Track angle difference for force calculation

**New Methods** (v3.0):
- `_apply_flipper_force(delta: float)` - Apply realistic flipper force to ball

**Enhanced Methods** (v3.0):
- `_physics_process()` - Now applies coil up ramp and force application

**Physics Material** (v3.0):
- `bounce = elasticity` (configurable, was 0.6)
- `friction = flipper_friction` (configurable, was 0.5)

---

### 1.3 Obstacle Component (v3.0 Enhanced)

#### Scene: Obstacle.tscn
**Node Structure** (v3.0 additions):
```
Obstacle (StaticBody2D)
├── CollisionShape2D
│   └── Shape: CircleShape2D or RectangleShape2D
├── Visual (Sprite2D/ColorRect)
├── DetectionArea (Area2D) - v1.0
│   └── CollisionShape2D
└── HitParticles (GPUParticles2D) - NEW v3.0 (spawned on hit)
```

#### Script: Obstacle.gd (v3.0 Enhanced)

**Class**: `extends StaticBody2D`

**New Export Variables** (v3.0):
```gdscript
# v3.0: Enhanced bumper properties
@export var is_bumper: bool = false  # True for bumpers (basketball hoops)
@export var bumping_strength: float = 20.0  # Active force (15-25)
@export var blinking_enabled: bool = true  # Enable blinking
@export var blink_speed: float = 2.0  # Blink speed multiplier
```

**New Properties** (v3.0):
- `is_lit: bool = true` - Visual state (lit vs dimmed)
- `blink_timer: float = 0.0` - Blink animation timer

**New Methods** (v3.0):
- `_apply_bumping_force(ball: RigidBody2D)` - Apply active bumping force
- `_play_hit_effect(ball: RigidBody2D)` - Play visual/audio effect
- `_spawn_hit_particles(position: Vector2)` - Spawn particle effect

**Enhanced Methods** (v3.0):
- `_process(delta)` - Now handles blinking behavior and visual states
- `_on_body_entered(body)` - Now applies bumping force and particles
- `set_obstacle_type(value)` - Now sets is_bumper based on type

---

### 1.4 GameManager Component (v3.0 Enhanced)

#### Script: GameManager.gd (v3.0 Enhanced)

**Class**: `extends Node2D`

**Preload Statements** (v3.0):
```gdscript
# v3.0: Preload system classes
const MultiballManager = preload("res://scripts/MultiballManager.gd")
const ComboSystem = preload("res://scripts/ComboSystem.gd")
const AnimationManager = preload("res://scripts/AnimationManager.gd")
const ParticleManager = preload("res://scripts/ParticleManager.gd")
```

**New Properties** (v3.0):
```gdscript
# v3.0: New systems
var multiball_manager: Node = null
var combo_system: Node = null
var animation_manager: Node = null
var current_multiplier: float = 1.0
var multiplier_timer: float = 0.0
var obstacle_hit_count: int = 0
var skill_shots: Array[Node] = []
```

**New Methods** (v3.0):
- `_initialize_v3_systems()` - Initialize all v3.0 systems (only if v3.0 mode)
- `_connect_skill_shot_signals()` - Connect skill shot signals to GameManager
- `_on_skill_shot_hit(points: int)` - Handle skill shot scoring
- `_on_multiball_activated(ball_count: int)` - Handle multiball activation
- `_on_multiball_ended()` - Handle multiball end
- `_on_combo_increased(combo_count: int, multiplier: float)` - Handle combo updates
- `_update_multiplier()` - Manage dynamic multiplier

**Enhanced Methods** (v3.0):
- `_on_obstacle_hit(points: int)` - Now integrates combo, multiplier, multiball multipliers
- `_on_ball_launched(force: Vector2)` - Now activates skill shots and connects signals if needed
- `_process(delta)` - Now handles multiplier decay

**Implementation Details**:
- Uses `preload()` for v3.0 system classes (better performance)
- Version detection: `is_v3_mode = (game_version == "v3.0")`
- Conditional initialization: `if is_v3_mode: call_deferred("_initialize_v3_systems")`
- Skill shot signal connection: `_connect_skill_shot_signals()` called during initialization and on ball launch

---

### 1.5 UI Component (v3.0 Enhanced)

#### Scene: UI.tscn (v3.0 additions)
**Node Structure** (v3.0 additions):
```
UI (CanvasLayer)
├── ScoreLabel (Label)
├── MultiplierLabel (Label) - NEW v3.0
├── ComboLabel (Label) - NEW v3.0
├── CurrencyDisplay (HBoxContainer) - v2.0
│   ├── CoinLabel (Label)
│   └── GemLabel (Label)
└── BackToMenuButton (Button)
```

#### Script: UI.gd (v3.0 Enhanced)

**Class**: `extends CanvasLayer`

**New Properties** (v3.0):
```gdscript
# v3.0: New UI elements
var multiplier_label: Label = null
var combo_label: Label = null
var animation_manager: Node = null
```

**New Methods** (v3.0):
- `_initialize_v3_ui()` - Initialize v3.0 UI elements
- `_start_ui_update_loop()` - Start UI update loop
- `_update_ui_loop()` - Update UI elements continuously
- `_on_combo_increased(combo_count: int, multiplier: float)` - Update combo display
- `_on_combo_ended()` - Hide combo display

**Enhanced Methods** (v3.0):
- `_on_score_changed(new_score: int)` - Now animates score update

---

## 2. New v3.0 Components

### 2.1 SkillShot Component

#### Scene: SkillShot.tscn
**Node Structure**:
```
SkillShot (Area2D)
├── CollisionShape2D
│   └── Shape: CircleShape2D (radius: 20.0)
├── Visual (ColorRect/Sprite2D)
│   └── (Glowing target indicator)
└── VisualLabel (Label) - Debug only
```

#### Script: SkillShot.gd

**Class**: `extends Area2D`

**Export Variables**:
```gdscript
@export var skill_shot_points: int = 200  # Points awarded
@export var time_window: float = 2.5  # Time window in seconds
@export var difficulty_level: int = 1  # 1=easy, 2=medium, 3=hard
```

**Properties**:
- `is_active: bool = false` - Active state
- `activation_timer: float = 0.0` - Time remaining
- `has_been_hit: bool = false` - Hit state

**Methods**:
- `activate()` - Activate skill shot target
- `deactivate()` - Deactivate target
- `_on_body_entered(body: Node2D)` - Handle ball entry
- `_create_visual_indicator()` - Create visual target
- `_play_hit_effect()` - Play hit effect

**Signals**:
- `skill_shot_hit(points: int)` - Emitted when hit

**Groups**:
- `"skill_shots"` - For GameManager discovery

---

### 2.2 MultiballManager Component

#### Script: MultiballManager.gd

**Class**: `extends Node`

**Export Variables**:
```gdscript
@export var multiball_ball_count: int = 3  # Number of balls
@export var multiball_duration: float = 45.0  # Duration in seconds
@export var scoring_multiplier: float = 1.5  # Score multiplier
```

**Properties**:
- `is_active: bool = false` - Active state
- `active_balls: Array[RigidBody2D]` - Active ball references
- `duration_timer: float = 0.0` - Time remaining
- `ball_queue: Node` - Reference to BallQueue
- `game_manager: Node` - Reference to GameManager

**Enhanced Dependency Finding** (v3.0):
- Multiple fallback methods to find BallQueue:
  1. Check `"ball_queue"` group
  2. Check `../BallQueue` node
  3. Check parent's BallQueue node
- Multiple fallback methods to find GameManager:
  1. Check `"game_manager"` group
  2. Check `../GameManager` node
  3. Check parent if it has `add_score` method
- Robust initialization even if scene structure varies

**Methods**:
- `activate_multiball()` - Activate multiball mode
- `_release_multiball_ball()` - Release a ball for multiball
- `_set_multiball_visual(ball: RigidBody2D, index: int)` - Set distinct visual
- `_on_multiball_ball_lost(ball: RigidBody2D)` - Handle ball loss
- `end_multiball()` - End multiball mode
- `is_multiball_active() -> bool` - Check if active
- `get_scoring_multiplier() -> float` - Get current multiplier

**Enhanced Dependency Finding** (v3.0):
- Multiple fallback methods to find BallQueue and GameManager
- Checks groups, parent nodes, and parent's children
- Robust initialization even if scene structure varies

**Signals**:
- `multiball_activated(ball_count: int)` - Emitted on activation
- `multiball_ended()` - Emitted on end

**Groups**:
- `"multiball_manager"` - For easy access

---

### 2.3 ComboSystem Component

#### Script: ComboSystem.gd

**Class**: `extends Node`

**Export Variables**:
```gdscript
@export var combo_window: float = 3.0  # Time window between hits
@export var combo_multiplier_per_hit: float = 0.1  # +0.1x per hit
@export var max_combo: int = 20  # Maximum combo hits
@export var max_combo_multiplier: float = 2.0  # Maximum multiplier
```

**Properties**:
- `current_combo: int = 0` - Current combo count
- `combo_timer: float = 0.0` - Time remaining
- `is_combo_active: bool = false` - Active state

**Methods**:
- `register_hit()` - Register a hit for combo
- `start_combo()` - Start new combo
- `end_combo()` - End current combo
- `get_combo_multiplier() -> float` - Get current multiplier
- `get_combo_count() -> int` - Get current combo count
- `_play_combo_sound()` - Play combo sound with rising pitch

**Signals**:
- `combo_started()` - Emitted when combo starts
- `combo_increased(combo_count: int, multiplier: float)` - Emitted on each hit
- `combo_ended()` - Emitted when combo ends

**Groups**:
- `"combo_system"` - For easy access

---

### 2.4 MultiplierSystem Component

#### Script: MultiplierSystem.gd

**Class**: `extends Node`

**Export Variables**:
```gdscript
@export var base_multiplier: float = 1.0
@export var increase_per_hits: int = 5  # Increase every N hits
@export var multiplier_increment: float = 0.5  # +0.5x per increase
@export var max_multiplier: float = 10.0  # Maximum multiplier
@export var decay_time: float = 10.0  # Seconds before decay
@export var decay_amount: float = 0.5  # Multiplier decrease
```

**Properties**:
- `current_multiplier: float = 1.0` - Current multiplier
- `hit_count: int = 0` - Hit counter
- `decay_timer: float = 0.0` - Decay timer

**Methods**:
- `register_hit()` - Register hit and potentially increase multiplier
- `increase_multiplier()` - Increase multiplier
- `decay_multiplier()` - Decay multiplier if inactive
- `get_multiplier() -> float` - Get current multiplier
- `reset()` - Reset to base

**Signals**:
- `multiplier_changed(new_multiplier: float)` - Emitted when multiplier changes

**Groups**:
- `"multiplier_system"` - For easy access

---

### 2.5 AnimationManager Component

#### Script: AnimationManager.gd

**Class**: `extends Node`

**Properties**:
- `active_tweens: Dictionary` - Track active tweens

**Methods**:
- `animate_score_popup(position: Vector2, points: int, color: Color)` - Animate score popup
- `animate_multiplier_display(control: Control, multiplier: float)` - Animate multiplier
- `animate_ui_transition(control: Control, fade_in: bool, duration: float)` - UI transitions
- `animate_component_highlight(node: Node2D, color: Color, duration: float)` - Component highlights
- `screen_shake(camera: Camera2D, intensity: float, duration: float)` - Screen shake

**Signals**:
- `animation_completed(animation_name: String)` - Emitted when animation completes

**Groups**:
- `"animation_manager"` - For easy access

---

### 2.6 ParticleManager Component

#### Script: ParticleManager.gd

**Class**: `extends Node`

**Properties**:
- `particle_scenes: Dictionary` - Particle scene cache

**Methods**:
- `spawn_bumper_hit(position: Vector2)` - Spawn bumper hit particles
- `spawn_multiplier_activation(position: Vector2)` - Spawn multiplier particles
- `spawn_multiball_launch(position: Vector2)` - Spawn multiball particles
- `add_ball_trail(ball: RigidBody2D, color: Color)` - Add trail to ball
- `_create_bumper_particles() -> GPUParticles2D` - Create bumper particle system
- `_create_multiplier_particles() -> GPUParticles2D` - Create multiplier particle system
- `_create_multiball_particles() -> GPUParticles2D` - Create multiball particle system

**Groups**:
- `"particle_manager"` - For easy access

---

## 3. Component Integration

### 3.1 Initialization Order

1. GameManager initializes
2. GameManager calls `_initialize_v3_systems()`
3. MultiballManager, ComboSystem, AnimationManager, ParticleManager created
4. Skill shots discovered via group
5. Signals connected
6. Systems ready

### 3.2 Component Communication

**Signal-Based**:
- SkillShot → GameManager (skill_shot_hit)
- MultiballManager → GameManager (multiball_activated, multiball_ended)
- ComboSystem → GameManager (combo_increased)
- MultiplierSystem → GameManager (multiplier_changed)

**Group-Based**:
- SkillShot nodes in "skill_shots" group
- Systems in their respective groups for discovery

**Direct References**:
- GameManager holds references to all v3.0 systems
- Systems hold references to GameManager and other dependencies

---

## 4. Component Lifecycle

### 4.1 SkillShot Lifecycle

```
_ready()
  ↓
Add to "skill_shots" group
  ↓
Create visual indicator
  ↓
[Inactive state - dimmed]
  ↓
activate() [called by GameManager on ball launch]
  ↓
[Active state - glowing/blinking]
  ↓
_on_body_entered() [ball hits]
  ↓
_play_hit_effect()
  ↓
deactivate()
  ↓
[Inactive state - dimmed]
```

### 4.2 MultiballManager Lifecycle

```
_ready()
  ↓
Find dependencies (BallQueue, GameManager)
  ↓
[Inactive state]
  ↓
activate_multiball() [called manually or by trigger]
  ↓
Release multiple balls
  ↓
[Active state - managing multiple balls]
  ↓
_process() [check for end conditions]
  ↓
end_multiball() [all balls lost or timer expired]
  ↓
[Inactive state]
```

### 4.3 ComboSystem Lifecycle

```
_ready()
  ↓
[Inactive state]
  ↓
register_hit() [first hit]
  ↓
start_combo()
  ↓
[Active state - tracking combo]
  ↓
register_hit() [subsequent hits]
  ↓
[Combo increases]
  ↓
_process() [check for timeout]
  ↓
end_combo() [timeout or max reached]
  ↓
[Inactive state]
```

---

*This document specifies all v3.0 components. For physics details, see Physics-Specifications-v3.0.md. For technical architecture, see Technical-Design-v3.0.md.*

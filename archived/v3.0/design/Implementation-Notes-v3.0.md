# Pinball Game v3.0 - Implementation Notes

## Overview

This document provides implementation-specific notes and details that differ from or supplement the main design documents. It captures actual implementation decisions and patterns used in the codebase.

## 1. Code Implementation Patterns

### 1.1 Preload Statements

**Location**: `scripts/GameManager.gd`

**Pattern**:
```gdscript
# v3.0: Preload system classes
const MultiballManager = preload("res://scripts/MultiballManager.gd")
const ComboSystem = preload("res://scripts/ComboSystem.gd")
const AnimationManager = preload("res://scripts/AnimationManager.gd")
const ParticleManager = preload("res://scripts/ParticleManager.gd")
```

**Reason**: Better performance - classes are loaded at compile time rather than runtime.

**Usage**: Used when creating new instances:
```gdscript
multiball_manager = MultiballManager.new()
combo_system = ComboSystem.new()
```

### 1.2 Version Detection

**Location**: `scripts/GameManager.gd`

**Pattern**:
```gdscript
var game_version: String = "v1.x"  # v1.x, v2.0, or v3.0
var is_v2_mode: bool = false
var is_v3_mode: bool = false

# Check from GlobalGameSettings
var global_settings = get_node_or_null("/root/GlobalGameSettings")
if global_settings:
    game_version = global_settings.game_version
    is_v2_mode = (game_version == "v2.0" or game_version == "v3.0")
    is_v3_mode = (game_version == "v3.0")
```

**Reason**: Allows selective feature activation based on game version.

**Usage**: Conditional initialization:
```gdscript
if is_v3_mode:
    call_deferred("_initialize_v3_systems")
```

### 1.3 Skill Shot Signal Connection

**Location**: `scripts/GameManager.gd`

**Pattern**:
```gdscript
func _connect_skill_shot_signals():
    """v3.0: Connect skill shot signals to GameManager"""
    skill_shots = get_tree().get_nodes_in_group("skill_shots")
    
    for skill_shot in skill_shots:
        if skill_shot and skill_shot.has_signal("skill_shot_hit"):
            if not skill_shot.skill_shot_hit.is_connected(_on_skill_shot_hit):
                skill_shot.skill_shot_hit.connect(_on_skill_shot_hit)
```

**Reason**: Skill shots may be added to scene after GameManager initialization, so signals are connected both at initialization and on ball launch.

**Usage**: Called in `_initialize_v3_systems()` and `_on_ball_launched()`.

### 1.4 Enhanced Dependency Finding

**Location**: `scripts/MultiballManager.gd`

**Pattern**:
```gdscript
# Multiple fallback methods
ball_queue = get_tree().get_first_node_in_group("ball_queue")
if not ball_queue:
    ball_queue = get_node_or_null("../BallQueue")
if not ball_queue:
    var parent = get_parent()
    if parent:
        ball_queue = parent.get_node_or_null("BallQueue")
```

**Reason**: Robust initialization even if scene structure varies. Handles different node hierarchies.

### 1.5 Deferred Initialization

**Location**: `scripts/GameManager.gd`

**Pattern**:
```gdscript
if is_v3_mode:
    call_deferred("_initialize_v3_systems")
```

**Reason**: Avoids issues with scene tree initialization order. Ensures all nodes are ready before v3.0 systems initialize.

## 2. Asset Handling

### 2.1 Graceful Sound File Loading

**Location**: `scripts/SoundManager.gd`

**Pattern**:
```gdscript
# Try to load sounds - check both WAV and OGG formats
for sound_name in sound_names:
    var wav_path = "res://assets/sounds/" + sound_name + ".wav"
    var ogg_path = "res://assets/sounds/" + sound_name + ".ogg"
    var sound_path = null
    
    if ResourceLoader.exists(ogg_path):
        sound_path = ogg_path
    elif ResourceLoader.exists(wav_path):
        sound_path = wav_path
    
    if sound_path:
        var stream = load(sound_path)
        if stream:
            sound_players[sound_name].stream = stream
    # No error if file doesn't exist - sound simply won't play
```

**Behavior**: Missing sound files don't cause errors. Game continues normally, sounds just don't play.

### 2.2 Programmatic Visual Creation

**Location**: `scripts/SkillShot.gd`, `scripts/ParticleManager.gd`

**Pattern**: Visual elements created programmatically rather than from scene files.

**Reason**: 
- No dependency on external asset files
- Dynamic configuration
- Easier to modify programmatically

**Fallback**: Can be enhanced with sprite textures if provided, but not required.

## 3. UI Update Patterns

### 3.1 Continuous Update Loop

**Location**: `scripts/UI.gd`

**Pattern**:
```gdscript
func _update_ui_loop():
    # Update multiplier display
    if multiplier_label:
        var game_manager = get_tree().get_first_node_in_group("game_manager")
        if game_manager:
            var multiplier = game_manager.get("current_multiplier")
            # Update display
    
    # Schedule next update
    await get_tree().create_timer(0.1).timeout
    _update_ui_loop()
```

**Reason**: Continuous updates ensure UI stays in sync with game state.

**Performance**: Limited to 10 FPS (0.1 second intervals) to reduce overhead.

### 3.2 Signal-Based Updates

**Location**: `scripts/UI.gd`

**Pattern**: Combo updates use signals for immediate feedback:
```gdscript
combo_system.combo_increased.connect(_on_combo_increased)
combo_system.combo_ended.connect(_on_combo_ended)
```

**Reason**: Immediate visual feedback when combo changes.

## 4. Test Coverage

### 4.1 Unit Tests

**Location**: `test/unit/v3.0/`

**Test Files**:
- `test_skill_shot.gd` - Skill shot activation, detection, scoring
- `test_multiball.gd` - Multiball activation, management, scoring
- `test_combo_system.gd` - Combo tracking and multipliers
- `test_multiplier_system.gd` - Multiplier increases and decay

### 4.2 Integration Tests

**Location**: `test/integration/v3.0/`

**Test Files**:
- `test_v3_features_integration.gd` - Integration of all v3.0 systems

### 4.3 Regression Tests

**Location**: `test/regression/`

**Test Files**:
- `test_version_compatibility.gd` - Ensures v1.0/v2.0 features still work
- `test_physics_regression.gd` - Ensures physics enhancements don't break existing behavior

## 5. Performance Optimizations

### 5.1 Preload vs Load

**Pattern**: Use `preload()` for classes that are always needed.

**Benefit**: Classes loaded at compile time, faster instantiation.

### 5.2 Deferred Initialization

**Pattern**: Use `call_deferred()` for initialization that depends on scene tree.

**Benefit**: Avoids initialization order issues.

### 5.3 Update Frequency Limiting

**Pattern**: UI updates limited to 10 FPS (0.1 second intervals).

**Benefit**: Reduces CPU overhead while maintaining responsive UI.

## 6. Error Handling

### 6.1 Missing Dependencies

**Pattern**: Multiple fallback methods to find dependencies.

**Example**: MultiballManager tries multiple methods to find BallQueue and GameManager.

**Benefit**: Robust initialization even with varying scene structures.

### 6.2 Missing Assets

**Pattern**: Graceful degradation - missing assets don't cause errors.

**Example**: Missing sound files result in silent gameplay, not crashes.

**Benefit**: Game works even if assets aren't ready.

## 7. Code Organization

### 7.1 Group-Based Discovery

**Pattern**: Use groups for system discovery.

**Example**: Skill shots in `"skill_shots"` group, systems in their respective groups.

**Benefit**: Loose coupling, easy to add/remove components.

### 7.2 Signal-Based Communication

**Pattern**: Use signals for event communication.

**Example**: `skill_shot_hit`, `multiball_activated`, `combo_increased` signals.

**Benefit**: Decoupled systems, easy to extend.

## 8. Differences from Design

### 8.1 Preload Statements

**Design**: Didn't specify preload usage.

**Implementation**: Uses preload() for better performance.

### 8.2 Skill Shot Signal Connection

**Design**: Assumed signals connected at initialization.

**Implementation**: Also connects on ball launch for late-discovered skill shots.

### 8.3 Dependency Finding

**Design**: Assumed simple parent-child relationships.

**Implementation**: Multiple fallback methods for robust initialization.

### 8.4 Asset Requirements

**Design**: Assumed all assets would exist.

**Implementation**: Graceful degradation for missing assets.

---

*This document captures implementation-specific details. For design specifications, see the main design documents.*

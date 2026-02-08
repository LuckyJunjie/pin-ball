# Pinball Game v3.0 - Physics Specifications

## Overview

This document specifies enhanced physics for v3.0, incorporating realistic values from vpinball and VisualPinball.Engine. All v1.0 and v2.0 physics specifications are inherited and maintained. This document adds physics enhancements based on real pinball machine values.

## 1. Base Physics (Inherited from v1.0/v2.0)

All v1.0 and v2.0 physics specifications are maintained. See Physics-Specifications.md and Physics-Specifications-v2.0.md for complete base physics.

**Summary**:
- Gravity: 980.0 units/s² (normalized to 0.97-1.0 range in calculations)
- Physics layers: Ball (1), Flippers (2), Walls (4), Obstacles (8), Holds (16)
- Base ball: Mass 0.4-0.5, Bounce 0.85, Friction 0.075 (v3.0), Damping 0.02
- Base flipper: Rotation speed 20°/s, Bounce 0.6, Friction 0.5
- Maze Pipe Walls: Bounce 0.3, Friction 0.1

## 2. Enhanced Playfield Physics (v3.0)

### 2.1 Playfield Friction

**v3.0 Enhancement**:
- **Friction**: 0.075+ (was 0.2-0.3)
- **Source**: vpinball PhysicValues.txt recommendations
- **Effect**: Slower ball movement on playfield, more realistic rolling
- **Adjustability**: Can be increased for slower ball movement (EM tables) or decreased for faster (modern tables)

**Implementation**:
```gdscript
# In Ball.gd
var physics_material = PhysicsMaterial.new()
physics_material.friction = 0.075  # v3.0: Realistic playfield friction
```

### 2.2 Playfield Elasticity

**v3.0 Specification**:
- **Elasticity**: 0.25 (realistic bounce)
- **Source**: vpinball recommendations
- **Effect**: Realistic bounce behavior on playfield surface

### 2.3 Gravity Constant

**v3.0 Specification**:
- **Gravity**: 980.0 units/s² (unchanged)
- **Normalized Range**: 0.97-1.0 (for calculations)
- **Source**: vpinball recommendations
- **Note**: Actual gravity value remains 980.0, normalization used in some calculations

## 3. Enhanced Flipper Physics (v3.0)

### 3.1 Flipper Strength

**v3.0 Enhancement**:
- **EM Tables**: 1200-1800
- **Modern Tables**: 2200-2800 (default: 2200)
- **Source**: vpinball PhysicValues.txt
- **Effect**: Realistic flipper power based on table era

**Implementation**:
```gdscript
# In Flipper.gd
@export var flipper_strength: float = 2200.0  # Modern table default
```

### 3.2 Flipper Elasticity

**v3.0 Enhancement**:
- **Range**: 0.55-0.8 (default: 0.7, was 0.6)
- **Source**: vpinball recommendations
- **Effect**: Realistic bounce behavior when ball hits flipper

**Implementation**:
```gdscript
# In Flipper.gd
@export var elasticity: float = 0.7
physics_material.bounce = elasticity
```

### 3.3 Elasticity Falloff (NEW v3.0)

**v3.0 New Property**:
- **Range**: 0.1-0.43 (default: 0.3)
- **Source**: vpinball recommendations
- **Effect**: Realistic flipper feel - elasticity decreases as flipper rotates
- **Usage**: Applied in force calculations for realistic physics

**Implementation**:
```gdscript
# In Flipper.gd
@export var elasticity_falloff: float = 0.3

# In _apply_flipper_force()
var falloff_factor = 1.0 - (elasticity_falloff * (1.0 - distance_factor))
```

### 3.4 Flipper Friction

**v3.0 Enhancement**:
- **Range**: 0.1-0.6 (default: 0.3, was 0.5)
- **Source**: vpinball recommendations
- **Effect**: Realistic friction between ball and flipper

**Implementation**:
```gdscript
# In Flipper.gd
@export var flipper_friction: float = 0.3
physics_material.friction = flipper_friction
```

### 3.5 Return Strength (NEW v3.0)

**v3.0 New Property**:
- **Value**: 0.058+ (default: 0.058)
- **Source**: vpinball recommendations
- **Effect**: Smooth return to rest position
- **Usage**: Controls flipper return speed

**Implementation**:
```gdscript
# In Flipper.gd
@export var return_strength: float = 0.058
# Applied in rotation calculations
```

### 3.6 Coil Up Ramp (NEW v3.0)

**v3.0 New Property**:
- **Range**: 2.4-3.5 (default: 3.0)
- **Source**: vpinball recommendations
- **Effect**: Gradual power increase as flipper activates
- **Usage**: Makes flipper feel more realistic with gradual power build-up

**Implementation**:
```gdscript
# In Flipper.gd
@export var coil_up_ramp: float = 3.0

# In _physics_process()
var ramp_factor = 1.0 + (coil_up_ramp - 1.0) * (1.0 - abs(angle_diff) / abs(pressed_angle - rest_angle))
var rotation_amount = rotation_speed * delta * 60.0 * ramp_factor
```

### 3.7 Flipper Force Application (NEW v3.0)

**v3.0 Enhancement**:
- **Active Force**: Applied when flipper is moving
- **Direction**: Perpendicular to flipper surface
- **Magnitude**: Based on flipper_strength and elasticity_falloff
- **Effect**: Realistic ball interaction with moving flipper

**Implementation**:
```gdscript
# In Flipper.gd
func _apply_flipper_force(delta: float):
    var direction = (ball.global_position - global_position).normalized()
    var force_direction = Vector2(-flipper_direction.y, flipper_direction.x)  # Perpendicular
    var force_magnitude = flipper_strength * falloff_factor * delta
    ball.apply_impulse(force_direction * force_magnitude)
```

## 4. Enhanced Rubber/Wall Physics (v3.0)

### 4.1 Rubber Elasticity

**v3.0 Enhancement**:
- **Range**: 0.6-0.8 (default: 0.7, was 0.8)
- **Source**: vpinball recommendations
- **Effect**: More realistic rubber bounce

### 4.2 Rubber Elasticity Falloff (NEW v3.0)

**v3.0 New Property**:
- **Range**: 0.2-0.4 (default: 0.3)
- **Source**: vpinball recommendations
- **Effect**: Realistic rubber behavior with distance-based falloff

### 4.3 Wall Elasticity

**v3.0 Specification**:
- **Metal Walls**: 0.3-0.5 (default: 0.4)
- **Wood Walls**: 0.375-0.425 (default: 0.4)
- **Source**: vpinball recommendations
- **Effect**: Realistic wall bounce based on material

### 4.4 Scatter Angle (NEW v3.0)

**v3.0 New Property**:
- **Value**: 5 degrees
- **Source**: vpinball recommendations
- **Effect**: Randomness in physics interactions for realistic feel
- **Usage**: Applied to collision calculations for slight randomness

## 5. Enhanced Bumper Physics (v3.0)

### 5.1 Bumping Force (NEW v3.0)

**v3.0 New Property**:
- **Range**: 15-25 (default: 20)
- **Source**: Flutter Pinball reference
- **Effect**: Active force application when ball hits bumper
- **Direction**: Away from bumper center

**Implementation**:
```gdscript
# In Obstacle.gd
@export var bumping_strength: float = 20.0

func _apply_bumping_force(ball: RigidBody2D):
    var direction = (ball.global_position - global_position).normalized()
    var force = direction * bumping_strength
    ball.apply_impulse(force)
```

### 5.2 Bumper Bounce

**v3.0 Specification**:
- **Bounce**: 0.9-0.95 (inherited from v1.0)
- **Enhanced with**: Active bumping force for more dynamic interaction

## 6. Physics Material Specifications

### 6.1 Ball Physics Material (v3.0)

```gdscript
PhysicsMaterial:
  bounce: 0.85
  friction: 0.075  # v3.0: Enhanced from 0.2
```

### 6.2 Flipper Physics Material (v3.0)

```gdscript
PhysicsMaterial:
  bounce: 0.7  # v3.0: Configurable (0.55-0.8)
  friction: 0.3  # v3.0: Configurable (0.1-0.6)
```

### 6.3 Obstacle Physics Material (v3.0)

```gdscript
PhysicsMaterial:
  bounce: 0.9  # Bumper bounce
  friction: 0.2
  # v3.0: Enhanced with active bumping force
```

### 6.4 Wall Physics Material (v3.0)

```gdscript
PhysicsMaterial:
  bounce: 0.4  # v3.0: Material-based (0.3-0.5 metal, 0.375-0.425 wood)
  friction: 0.2-0.3  # Material-dependent
```

## 7. Physics Calculations

### 7.1 Flipper Force Calculation (v3.0)

```gdscript
# Calculate force direction (perpendicular to flipper surface)
var flipper_direction = Vector2(cos(rotation), sin(rotation))
var force_direction = Vector2(-flipper_direction.y, flipper_direction.x)

# Calculate distance factor (0.0 to 1.0)
var angle_range = abs(pressed_angle - rest_angle)
var distance_factor = 1.0 - (abs(angle_diff) / angle_range)

# Apply elasticity falloff
var falloff_factor = 1.0 - (elasticity_falloff * (1.0 - distance_factor))

# Calculate force magnitude
var force_magnitude = flipper_strength * falloff_factor * delta

# Apply impulse
ball.apply_impulse(force_direction * force_magnitude)
```

### 7.2 Bumper Force Calculation (v3.0)

```gdscript
# Calculate direction away from bumper center
var direction = (ball.global_position - global_position).normalized()
if direction.length() < 0.1:
    direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()

# Apply impulse
var force = direction * bumping_strength
ball.apply_impulse(force)
```

### 7.3 Scatter Angle Application (v3.0)

```gdscript
# Apply scatter angle for randomness
var scatter_angle = deg_to_rad(5.0)  # 5 degrees
var random_angle = randf_range(-scatter_angle, scatter_angle)
var scattered_direction = direction.rotated(random_angle)
```

## 8. Performance Considerations

### 8.1 Force Application Optimization

- Force calculations only when flipper is moving
- Efficient collision queries using PhysicsShapeQueryParameters2D
- Cached direction calculations
- Delta-based force application for frame-rate independence

### 8.2 Physics Material Caching

- Physics materials created once and reused
- Material properties updated only when needed
- Efficient material lookups

## 9. Physics Debugging

### 9.1 Debug Visualization

- Visual indicators for force directions
- Debug labels showing physics values
- Force magnitude visualization (optional)

### 9.2 Physics Testing

- Test flipper force at different angles
- Test bumper force with various ball speeds
- Test elasticity falloff behavior
- Test scatter angle randomness

## 10. Compatibility

### 10.1 v1.0 Compatibility

- All v1.0 physics values remain as defaults
- v3.0 enhancements are additive
- Can disable v3.0 physics if needed

### 10.2 v2.0 Compatibility

- v2.0 upgrade physics work with v3.0 enhancements
- Enhanced physics stack with upgrade bonuses
- No conflicts between systems

---

*This document specifies v3.0 physics enhancements. For base physics, see Physics-Specifications.md (v1.0) and Physics-Specifications-v2.0.md (v2.0).*

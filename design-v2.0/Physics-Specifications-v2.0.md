# Pinball Game v2.0 - Physics Specifications

## Overview

This document specifies enhanced physics for v2.0 upgrades. All v1.0 physics specifications are inherited and maintained. This document adds physics modifications for ball upgrades (Magnetic, Fire, Cosmic), flipper upgrades (Twin, Power, Turbo), and special ramps.

## 1. Base Physics (Inherited from v1.0)

All v1.0 physics specifications are maintained. See Physics-Specifications.md for complete base physics.

**Summary**:
- Gravity: 980.0 units/s²
- Physics layers: Ball (1), Flippers (2), Walls (4), Obstacles (8)
- Base ball: Mass 0.5, Bounce 0.8, Friction 0.3, Damping 0.05
- Base flipper: Rotation speed 20°/s, Bounce 0.6, Friction 0.5
- **Maze Pipe Walls** (v1.0 Feature - Preserved in v2.0):
  - Collision layer: 4 (Walls layer)
  - Bounce: 0.3 (low bounce for smooth guidance)
  - Friction: 0.1 (very low for smooth sliding)
  - Tile size: 32 pixels
  - Maze channel width: 2-3 tiles wide (64-96 pixels) for ball passage

## 2. Ball Upgrade Physics

### 2.1 Heavy Ball Physics

**Physics Modifications**:
- Mass: 0.8 (+60% from 0.5)
- Linear Damping: 0.07 (+40% from 0.05)
- Bounce, Friction, Angular Damping: Unchanged

**Implementation**:
```gdscript
mass = 0.8
linear_damp = 0.07
# Other properties unchanged from base
```

**Effect**: Increased momentum, harder to stop, more impact force on obstacles.

### 2.2 Bouncy Ball Physics

**Physics Modifications**:
- Bounce: 1.0 (+25% from 0.8)
- Friction: 0.2 (-33% from 0.3)
- Linear Damping: 0.03 (-40% from 0.05)
- Angular Damping: 0.03 (-40% from 0.05)

**Implementation**:
```gdscript
physics_material_override.bounce = 1.0
physics_material_override.friction = 0.2
linear_damp = 0.03
angular_damp = 0.03
```

**Effect**: Higher energy retention, faster movement, longer bounces.

### 2.3 Magnetic Ball Physics

**Base Physics Modifications**:
- Mass: 0.6 (+20% from 0.5)
- Bounce: 0.75 (-6% from 0.8)
- Linear Damping: 0.07 (+40% from 0.05)

**Special Ability: Magnetic Attraction**

**Force Calculation** (each frame in `_physics_process`):
```gdscript
var attraction_force: float = 150.0
var attraction_radius: float = 150.0

func apply_magnetic_attraction(delta: float):
    var obstacles = get_tree().get_nodes_in_group("obstacles")
    for obstacle in obstacles:
        var distance = global_position.distance_to(obstacle.global_position)
        if distance < attraction_radius:
            var direction = (obstacle.global_position - global_position).normalized()
            var force_strength = attraction_force * (1.0 - distance / attraction_radius)
            apply_central_force(direction * force_strength * delta)
```

**Visual Effect**: Electric arc connections to nearby obstacles (Line2D, alpha fades with distance).

**Performance**: Run at 30Hz instead of 60Hz to reduce CPU usage.

### 2.4 Fire Ball Physics

**Base Physics Modifications**:
- Mass: 0.45 (-10% from 0.5)
- Bounce: 1.04 (+30% from 0.8)
- Friction: 0.15 (-50% from 0.3)
- Linear Damping: 0.03 (-40% from 0.05)
- Angular Damping: 0.03 (-40% from 0.05)

**Special Ability: Chain Reaction**

**Chain Reaction Detection**:
```gdscript
var chain_reaction_radius: float = 80.0
var burn_duration: float = 3.0

func _on_obstacle_hit(obstacle: StaticBody2D):
    if not is_burning:
        start_burning()
        
        # Chain reaction to nearby obstacles
        var obstacles = get_tree().get_nodes_in_group("obstacles")
        for other_obstacle in obstacles:
            if other_obstacle != obstacle:
                var distance = global_position.distance_to(other_obstacle.global_position)
                if distance < chain_reaction_radius:
                    other_obstacle.apply_chain_multiplier(2.0)  # Double points
```

**Burn Effect**:
- Score multiplier: 1.5× while burning
- Visual: Fire particle system, orange glow
- Duration: 3 seconds after obstacle hit
- Timer-based expiration

### 2.5 Cosmic Ball Physics

**Base Physics Modifications**:
- Gravity Scale: 0.5 (-50% from 1.0)
- Bounce: 0.85 (+6% from 0.8)
- Friction: 0.2 (-33% from 0.3)

**Special Ability 1: Anti-Gravity**

**Anti-Gravity Force** (continuous upward force):
```gdscript
var anti_gravity_strength: float = -300.0  # Negative = upward

func apply_cosmic_anti_gravity(delta: float):
    var anti_gravity = Vector2(0, anti_gravity_strength)
    apply_central_force(anti_gravity * delta)
```

**Special Ability 2: Time Warp** (slows nearby objects):
```gdscript
var time_warp_factor: float = 0.7  # 0.7× speed for nearby objects
var time_warp_radius: float = 120.0

func apply_time_warp():
    var obstacles = get_tree().get_nodes_in_group("obstacles")
    for obstacle in obstacles:
        var distance = global_position.distance_to(obstacle.global_position)
        if distance < time_warp_radius:
            obstacle.time_scale = time_warp_factor  # Slow down obstacle animations
```

**Visual Effect**: Space distortion shader, star particle trail, gravity well visualization.

## 3. Flipper Upgrade Physics

### 3.1 Long Flipper Physics

**Modifications**:
- Length: 80 pixels (+25% from 64)
- All other properties unchanged

**Implementation**: Modify CollisionShape2D polygon points to extend length.

### 3.2 Power Flipper Physics

**Modifications**:
- Power Multiplier: 1.3× (+30%)
- Bounce: 0.7 (+17% from 0.6)

**Implementation** (on ball collision):
```gdscript
func _on_body_entered(body: RigidBody2D):
    if body.is_in_group("ball"):
        var collision_normal = (body.global_position - global_position).normalized()
        var base_impulse = collision_normal * 500.0
        var power_impulse = base_impulse * power_multiplier  # 1.3×
        body.apply_central_impulse(power_impulse)
```

### 3.3 Twin Flipper Physics

**Structure**:
- Primary segment: 64 pixels (standard)
- Secondary segment: 30 pixels (new)
- Joint: PinJoint2D connecting segments
- Secondary angle offset: 15.0 degrees

**Joint Configuration**:
```gdscript
var secondary_segment: RigidBody2D
var joint: PinJoint2D

func create_twin_segment():
    secondary_segment = RigidBody2D.new()
    secondary_segment.freeze = true
    # Create collision shape for secondary segment
    # ...
    
    joint = PinJoint2D.new()
    joint.node_a = get_path()
    joint.node_b = secondary_segment.get_path()
    joint.position = Vector2(30, 0)  # End of primary segment
    add_child(joint)
```

**Rotation Synchronization**:
```gdscript
func rotate_to_target(target_angle: float):
    rotation = lerp_angle(rotation, deg_to_rad(target_angle), rotation_speed * delta)
    secondary_segment.rotation = rotation + deg_to_rad(secondary_angle_offset)
```

### 3.4 Plasma Flipper Physics

**Modifications**:
- Rotation Speed: 25.0°/s (+25% from 20.0)
- Power Multiplier: 1.2× (+20%)
- Bounce: 0.7 (+17%)
- Friction: 0.4 (-20%)

**Visual**: Plasma shader effect, electric sparks on ball collision.

### 3.5 Turbo Flipper Physics

**Modifications**:
- Rotation Speed: 30.0°/s (+50% from 20.0)
- All other properties unchanged

**Implementation**: Increase rotation_speed in `_physics_process`.

## 4. Special Ramp Physics

### 4.1 Multiplier Ramp Physics

**Effect**: Score multiplier for ball passing through

**Implementation**:
```gdscript
var score_multiplier: float = 2.0
var multiplier_duration: float = 10.0
var active_balls: Dictionary = {}  # ball: timer

func _on_body_entered(body: RigidBody2D):
    if body.is_in_group("ball"):
        if not active_balls.has(body):
            body.score_multiplier = score_multiplier
            
            # Set expiration timer
            var timer = get_tree().create_timer(multiplier_duration)
            timer.timeout.connect(_on_multiplier_end.bind(body))
            active_balls[body] = timer
```

**Score Calculation** (in GameManager):
```gdscript
var base_points = obstacle.points_value
var final_points = base_points * ball.score_multiplier  # Apply multiplier
```

### 4.2 Bank Shot Ramp Physics

**Effect**: Curved force to guide ball toward target hold

**Implementation**:
```gdscript
var curve_strength: float = 500.0

func _on_body_entered(body: RigidBody2D):
    if body.is_in_group("ball"):
        var target_hold = find_target_hold()  # Highest value hold within range
        if target_hold:
            var direction = (target_hold.global_position - body.global_position).normalized()
            var perpendicular = Vector2(-direction.y, direction.x)  # Perpendicular vector
            var curve_force = perpendicular * curve_strength
            body.apply_central_force(curve_force)
            
            # Visual guide line
            draw_trajectory_line(body.global_position, target_hold.global_position)
```

**Target Selection**: Finds highest-value hold within reasonable range (e.g., 400px).

### 4.3 Accelerator Ramp Physics

**Effect**: Speed boost when ball passes through

**Implementation**:
```gdscript
var speed_boost: float = 1.5  # 1.5× speed multiplier

func _on_body_entered(body: RigidBody2D):
    if body.is_in_group("ball"):
        var current_velocity = body.linear_velocity
        var boosted_velocity = current_velocity * speed_boost
        
        # Cap maximum speed to prevent physics glitches
        var max_speed: float = 2000.0
        if boosted_velocity.length() > max_speed:
            boosted_velocity = boosted_velocity.normalized() * max_speed
        
        body.linear_velocity = boosted_velocity
```

## 5. Performance Considerations

### 5.1 Optimization Strategies

**Magnetic Ball**:
- Run attraction calculations at 30Hz instead of 60Hz
- Limit obstacle checks to 50 obstacles max
- Use spatial partitioning for large obstacle counts

**Fire Ball**:
- Chain reaction detection only on obstacle hit (not continuous)
- Particle effects limited to 32 particles
- Timer-based burn expiration (no per-frame checks)

**Cosmic Ball**:
- Anti-gravity force applied every frame (simple calculation)
- Time warp only affects visual/animation, not physics simulation
- Particle effects limited to 50 particles

**Special Ramps**:
- Area2D detection (efficient collision detection)
- Effects applied once per ball entry
- Timer-based expiration (no per-frame checks)

### 5.2 Mobile Performance

- Special physics effects run at 30Hz on mobile devices
- Particle counts reduced on low-end devices
- Shader complexity limited on mobile
- Disable special effects option for very low-end devices

---

*All v1.0 physics specifications are maintained. These enhancements add special abilities while maintaining performance and game balance.*

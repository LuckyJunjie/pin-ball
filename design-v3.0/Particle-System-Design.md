# Pinball Game v3.0 - Particle System Design

## Overview

This document specifies the particle effect system for v3.0, which provides visual feedback for game events including bumper hits, ball trails, multiplier activation, and multiball launch. The system uses Godot's GPUParticles2D and follows best practices from Godot particle demos.

## 1. System Architecture

### 1.1 ParticleManager Component

**Script**: `scripts/ParticleManager.gd`

**Class**: `extends Node`

**Purpose**: Centralized particle effect management

**Properties**:
- `particle_scenes: Dictionary` - Particle scene cache (for future use)

**Groups**:
- `"particle_manager"` - For easy access

### 1.2 Particle Technology

**Technology**: GPUParticles2D (Godot 4.5)
- GPU-accelerated particle rendering
- Efficient for many particles
- ParticleProcessMaterial for advanced effects

## 2. Particle Effect Types

### 2.1 Bumper Hit Particles

**Purpose**: Explosion effect when ball hits bumper

**Visual Design**:
- **Particle Count**: 30 particles
- **Lifetime**: 0.5 seconds
- **Pattern**: Explosion (all particles at once)
- **Color**: Yellow/Orange (#FFCC00)
- **Size**: 3-6 pixels
- **Velocity**: 50-100 units/s (outward)

**Particle Material Configuration**:
```gdscript
var material = ParticleProcessMaterial.new()
material.direction = Vector3(0, 0, 0)  # Radial explosion
material.initial_velocity_min = 50.0
material.initial_velocity_max = 100.0
material.gravity = Vector3(0, 98, 0)  # Downward gravity
material.scale_min = 3.0
material.scale_max = 6.0
material.color = Color(1.0, 0.8, 0.0, 1.0)  # Yellow/orange
```

**Spawn Behavior**:
- Spawns at bumper position
- All particles emit simultaneously (explosiveness = 1.0)
- Auto-removes after 1.0 second

**Usage**:
```gdscript
particle_manager.spawn_bumper_hit(bumper.global_position)
```

### 2.2 Ball Trail Particles

**Purpose**: Visual trail following ball movement

**Visual Design**:
- **Particle Count**: 50 particles
- **Lifetime**: 0.5 seconds
- **Pattern**: Continuous trail
- **Color**: Configurable (Red, Green, Blue, Yellow for multiball)
- **Size**: 2-4 pixels
- **Velocity**: 10-20 units/s (backward, opposite ball direction)

**Particle Material Configuration**:
```gdscript
var material = ParticleProcessMaterial.new()
material.direction = Vector3(0, -1, 0)  # Upward (opposite ball movement)
material.initial_velocity_min = 10.0
material.initial_velocity_max = 20.0
material.gravity = Vector3(0, 0, 0)  # No gravity
material.scale_min = 2.0
material.scale_max = 4.0
material.color = color  # Configurable
```

**Attachment**:
- Attached to ball as child node
- Follows ball position automatically
- Removed when ball is removed

**Usage**:
```gdscript
particle_manager.add_ball_trail(ball, Color.RED)
```

### 2.3 Multiplier Activation Particles

**Purpose**: Celebration effect when multiplier increases

**Visual Design**:
- **Particle Count**: 50 particles
- **Lifetime**: 1.0 second
- **Pattern**: Upward burst
- **Color**: Green (#00FF00)
- **Size**: 4-8 pixels
- **Velocity**: 20-40 units/s (upward)

**Particle Material Configuration**:
```gdscript
var material = ParticleProcessMaterial.new()
material.direction = Vector3(0, -1, 0)  # Upward
material.initial_velocity_min = 20.0
material.initial_velocity_max = 40.0
material.gravity = Vector3(0, -20, 0)  # Upward (anti-gravity)
material.scale_min = 4.0
material.scale_max = 8.0
material.color = Color(0.0, 1.0, 0.0, 1.0)  # Green
```

**Spawn Behavior**:
- Spawns at UI multiplier position
- Upward burst pattern
- Auto-removes after 1.5 seconds

**Usage**:
```gdscript
particle_manager.spawn_multiplier_activation(ui_position)
```

### 2.4 Multiball Launch Particles

**Purpose**: Special effect when multiball activates

**Visual Design**:
- **Particle Count**: 100 particles
- **Lifetime**: 1.5 seconds
- **Pattern**: Radial burst
- **Color**: Orange (#FF8000)
- **Size**: 2-5 pixels
- **Velocity**: 30-60 units/s (outward)

**Particle Material Configuration**:
```gdscript
var material = ParticleProcessMaterial.new()
material.direction = Vector3(0, 0, 0)  # Radial
material.initial_velocity_min = 30.0
material.initial_velocity_max = 60.0
material.gravity = Vector3(0, 50, 0)  # Downward
material.scale_min = 2.0
material.scale_max = 5.0
material.color = Color(1.0, 0.5, 0.0, 1.0)  # Orange
```

**Spawn Behavior**:
- Spawns at launcher/ball release position
- Large radial burst
- Auto-removes after 2.0 seconds

**Usage**:
```gdscript
particle_manager.spawn_multiball_launch(launcher_position)
```

### 2.5 Hold Entry Particles (Future)

**Purpose**: Celebration effect when ball enters hold

**Visual Design**:
- **Particle Count**: 40 particles
- **Lifetime**: 0.8 seconds
- **Pattern**: Upward spiral
- **Color**: Gold (#FFD700)
- **Size**: 3-6 pixels

**Note**: Specified for future implementation

## 3. Particle Creation

### 3.1 Programmatic Creation

**Approach**: Particles created programmatically (no scene files)

**Benefits**:
- Dynamic configuration
- Easy parameter adjustment
- No scene file management

**Implementation Pattern**:
```gdscript
func _create_particle_type() -> GPUParticles2D:
    var particles = GPUParticles2D.new()
    particles.emitting = true
    particles.amount = particle_count
    particles.lifetime = lifetime
    
    var material = ParticleProcessMaterial.new()
    # Configure material properties
    particles.process_material = material
    
    return particles
```

### 3.2 Particle Spawning

**Spawn Method**:
1. Create particle system
2. Configure material
3. Set position
4. Add to scene
5. Auto-remove after animation

**Cleanup**:
- Particles auto-removed after lifetime + buffer
- Uses `await get_tree().create_timer()` for cleanup
- `queue_free()` called automatically

## 4. Performance Considerations

### 4.1 Particle Count Management

**Guidelines**:
- **Small Effects**: 20-30 particles (bumper hits)
- **Medium Effects**: 40-50 particles (trails, multiplier)
- **Large Effects**: 100+ particles (multiball launch)

**Optimization**:
- Reduce particle count on low-end devices
- LOD system for particle complexity
- Particle pooling for frequently used effects

### 4.2 GPU Usage

**GPUParticles2D Benefits**:
- GPU-accelerated rendering
- Efficient for many particles
- Minimal CPU overhead

**Considerations**:
- Limit simultaneous particle systems
- Auto-cleanup prevents accumulation
- Efficient material configuration

### 4.3 Mobile Optimization

**Low-End Devices**:
- Reduce particle count by 50%
- Simpler material configurations
- Shorter lifetimes
- Fewer simultaneous effects

**Implementation**:
```gdscript
var particle_count = 30
if is_low_end_device():
    particle_count = 15
```

## 5. Integration Points

### 5.1 Obstacle Integration

```gdscript
# In Obstacle._spawn_hit_particles()
var particle_manager = get_tree().get_first_node_in_group("particle_manager")
if particle_manager and particle_manager.has_method("spawn_bumper_hit"):
    particle_manager.spawn_bumper_hit(global_position)
```

### 5.2 Multiball Integration

```gdscript
# In MultiballManager.activate_multiball()
var particle_manager = get_tree().get_first_node_in_group("particle_manager")
if particle_manager:
    particle_manager.spawn_multiball_launch(launcher_position)
```

### 5.3 Multiplier Integration

```gdscript
# In GameManager._update_multiplier()
if animation_manager:
    var ui = get_tree().get_first_node_in_group("ui")
    if ui:
        var multiplier_pos = ui.multiplier_label.global_position
        particle_manager.spawn_multiplier_activation(multiplier_pos)
```

## 6. Visual Design Guidelines

### 6.1 Color Coding

**Bumper Hits**: Yellow/Orange (energy, impact)
**Ball Trails**: Configurable (Red, Green, Blue, Yellow for multiball)
**Multiplier**: Green (growth, success)
**Multiball**: Orange (excitement, intensity)

### 6.2 Size Guidelines

**Small Particles**: 2-3 pixels (trails, subtle effects)
**Medium Particles**: 3-6 pixels (bumper hits, standard effects)
**Large Particles**: 4-8 pixels (celebration, important events)

### 6.3 Lifetime Guidelines

**Quick Effects**: 0.3-0.5 seconds (bumper hits)
**Standard Effects**: 0.5-1.0 seconds (trails, multiplier)
**Long Effects**: 1.0-2.0 seconds (multiball launch, celebrations)

## 7. Extensibility

### 7.1 Adding New Particle Effects

1. Add method to ParticleManager
2. Create particle system with `_create_*_particles()`
3. Configure material properties
4. Handle spawn and cleanup
5. Document usage

### 7.2 Custom Particle Materials

```gdscript
var material = ParticleProcessMaterial.new()
material.direction = Vector3(0, -1, 0)
material.initial_velocity_min = 20.0
material.initial_velocity_max = 40.0
material.gravity = Vector3(0, 98, 0)
material.scale_min = 2.0
material.scale_max = 4.0
material.color = Color(1.0, 0.0, 0.0, 1.0)
```

## 8. Testing

### 8.1 Visual Testing

- Test each particle effect type
- Verify particle count and appearance
- Test cleanup (no lingering particles)
- Test performance with multiple effects

### 8.2 Performance Testing

- Test particle count impact on frame rate
- Test multiple simultaneous effects
- Test on low-end devices
- Profile GPU usage

---

*This document specifies the v3.0 particle system. For visual design, see UI-Design-v3.0.md and GDD-v3.0.md.*

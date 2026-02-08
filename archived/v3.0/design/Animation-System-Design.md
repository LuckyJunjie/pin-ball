# Pinball Game v3.0 - Animation System Design

## Overview

This document specifies the animation system for v3.0, which provides tween-based animations for UI elements, score popups, component highlights, and visual effects. The system is built using Godot's Tween system and follows best practices from Godot demo projects.

## 1. System Architecture

### 1.1 AnimationManager Component

**Script**: `scripts/AnimationManager.gd`

**Class**: `extends Node`

**Purpose**: Centralized animation management using Godot's Tween system

**Properties**:
- `active_tweens: Dictionary` - Track active tweens for cleanup

**Groups**:
- `"animation_manager"` - For easy access

### 1.2 Tween System

**Technology**: Godot 4.5 Tween system
- Parallel tweens for simultaneous animations
- Sequential tweens for chained animations
- Callback support for completion events
- Frame-rate independent timing

## 2. Animation Types

### 2.1 Score Popup Animation

**Purpose**: Animated text that appears when points are scored

**Visual Design**:
- Text: "+{points}" (e.g., "+200", "+500")
- Font Size: 32
- Color: Configurable (White, Yellow, Cyan, Green)
- Outline: Black, 3px

**Animation Sequence**:
1. **Scale Up** (0.2s): 0.5 → 1.2
2. **Scale Down** (0.1s): 1.2 → 1.0
3. **Fade Out** (0.5s): Alpha 1.0 → 0.0
4. **Move Up** (0.5s): Position + Vector2(0, -50)

**Implementation**:
```gdscript
func animate_score_popup(position: Vector2, points: int, color: Color = Color.WHITE):
	var label = Label.new()
	label.text = "+" + str(points)
	label.global_position = position
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale animation
	label.scale = Vector2(0.5, 0.5)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.2)
	
	# Fade and move
	tween.tween_method(
		func(alpha): label.modulate = Color(color.r, color.g, color.b, alpha),
		1.0, 0.0, 0.5
	)
	tween.tween_property(label, "global_position", position + Vector2(0, -50), 0.5)
	
	tween.tween_callback(label.queue_free).set_delay(0.5)
```

**Usage**:
```gdscript
animation_manager.animate_score_popup(
	ball.global_position + Vector2(0, -30),
	200,
	Color.YELLOW
)
```

### 2.2 Multiplier Display Animation

**Purpose**: Pulsing animation for multiplier display when active

**Visual Design**:
- Continuous pulsing scale effect
- Smooth, subtle animation
- Non-intrusive

**Animation Sequence**:
- **Scale Up** (0.3s): 1.0 → 1.1
- **Scale Down** (0.3s): 1.1 → 1.0
- **Loop**: Continuous

**Implementation**:
```gdscript
func animate_multiplier_display(control: Control, multiplier: float):
	var tween = create_tween()
	tween.set_loops()
	
	var base_scale = Vector2(1.0, 1.0)
	var pulse_scale = Vector2(1.1, 1.1)
	
	tween.tween_property(control, "scale", pulse_scale, 0.3)
	tween.tween_property(control, "scale", base_scale, 0.3)
```

**Usage**:
```gdscript
animation_manager.animate_multiplier_display(multiplier_label, multiplier)
```

### 2.3 UI Transition Animation

**Purpose**: Smooth fade in/out for UI elements

**Animation Types**:
- **Fade In**: Alpha 0.0 → 1.0
- **Fade Out**: Alpha 1.0 → 0.0

**Duration**: 0.3 seconds (default)

**Implementation**:
```gdscript
func animate_ui_transition(control: Control, fade_in: bool = true, duration: float = 0.3):
	var tween = create_tween()
	
	if fade_in:
		control.modulate = Color(1, 1, 1, 0)
		tween.tween_property(control, "modulate", Color(1, 1, 1, 1), duration)
	else:
		tween.tween_property(control, "modulate", Color(1, 1, 1, 0), duration)
```

**Usage**:
```gdscript
animation_manager.animate_ui_transition(menu_panel, true, 0.3)
```

### 2.4 Component Highlight Animation

**Purpose**: Glow/shake effect for important events

**Visual Design**:
- Color flash (original → highlight → original)
- Shake effect (3 iterations)
- Duration: 0.2-0.3 seconds

**Animation Sequence**:
1. **Color Flash** (parallel):
   - Modulate to highlight color (0.1s)
   - Modulate back to original (0.2s)
2. **Shake Effect** (parallel):
   - 3 shake iterations
   - Random offset each iteration
   - Return to original position

**Implementation**:
```gdscript
func animate_component_highlight(node: Node2D, color: Color = Color.YELLOW, duration: float = 0.2):
	var tween = create_tween()
	tween.set_parallel(true)
	
	var original_modulate = node.modulate
	var original_pos = node.position
	
	# Glow effect
	tween.tween_property(node, "modulate", color, duration * 0.5)
	tween.tween_property(node, "modulate", original_modulate, duration * 0.5).set_delay(duration * 0.5)
	
	# Shake effect
	var shake_amount = 5.0
	for i in range(3):
		var shake_offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		tween.tween_property(node, "position", original_pos + shake_offset, duration / 6.0)
		tween.tween_property(node, "position", original_pos, duration / 6.0)
	
	tween.tween_property(node, "position", original_pos, 0.1).set_delay(duration)
```

**Usage**:
```gdscript
animation_manager.animate_component_highlight(score_label, Color.YELLOW, 0.2)
```

### 2.5 Screen Shake Animation

**Purpose**: Camera shake for impactful events

**Visual Design**:
- Random offset applied to camera
- Intensity: 5-10 pixels
- Duration: 0.3-0.5 seconds

**Animation Sequence**:
- Multiple random offsets (10 per second)
- Smooth return to original position

**Implementation**:
```gdscript
func screen_shake(camera: Camera2D, intensity: float = 5.0, duration: float = 0.3):
	var original_offset = camera.offset
	var tween = create_tween()
	
	for i in range(int(duration * 10)):
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(camera, "offset", original_offset + shake_offset, 0.1)
	
	tween.tween_property(camera, "offset", original_offset, 0.1)
```

**Usage**:
```gdscript
var camera = get_viewport().get_camera_2d()
animation_manager.screen_shake(camera, 10.0, 0.5)
```

## 3. Animation Timing

### 3.1 Duration Guidelines

- **Quick Feedback**: 0.1-0.2 seconds (component highlights)
- **Standard Animations**: 0.3-0.5 seconds (transitions, popups)
- **Long Animations**: 0.5-1.0 seconds (complex sequences)
- **Continuous**: Loop indefinitely (multiplier pulsing)

### 3.2 Easing Functions

**Default**: Linear (no easing)
**Available**: Can use Tween easing methods if needed
- `Tween.EASE_IN`
- `Tween.EASE_OUT`
- `Tween.EASE_IN_OUT`

## 4. Performance Considerations

### 4.1 Tween Management

- **Auto-cleanup**: Tweens automatically cleaned up on completion
- **Parallel Tweens**: Used for simultaneous animations
- **Tween Pooling**: Can be implemented for frequently used animations

### 4.2 Frame Rate Independence

- All animations use delta-based timing
- Duration specified in seconds
- Works correctly at any frame rate

### 4.3 Memory Management

- Labels created for score popups are auto-freed
- Tweens are automatically cleaned up
- No memory leaks from animations

## 5. Integration Points

### 5.1 GameManager Integration

```gdscript
# In GameManager._on_obstacle_hit()
if animation_manager and current_ball:
	animation_manager.animate_score_popup(
		current_ball.global_position + Vector2(0, -30),
		final_points,
		Color.YELLOW if current_multiplier > 1.0 else Color.WHITE
	)
```

### 5.2 UI Integration

```gdscript
# In UI._on_score_changed()
if animation_manager:
	animation_manager.animate_component_highlight(score_label, Color.YELLOW, 0.2)
```

### 5.3 Multiball Integration

```gdscript
# In GameManager._on_multiball_activated()
var camera = get_viewport().get_camera_2d()
if camera and animation_manager:
	animation_manager.screen_shake(camera, 10.0, 0.5)
```

## 6. Extensibility

### 6.1 Adding New Animations

1. Add method to AnimationManager
2. Use Tween system for animation
3. Handle cleanup (auto-queue_free or callback)
4. Document usage and parameters

### 6.2 Custom Animation Sequences

```gdscript
func custom_animation(node: Node2D):
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Add multiple property tweens
	tween.tween_property(node, "scale", Vector2(1.2, 1.2), 0.3)
	tween.tween_property(node, "rotation", PI * 2, 0.3)
	tween.tween_property(node, "modulate", Color.RED, 0.3)
	
	tween.tween_callback(func(): print("Animation complete"))
```

## 7. Testing

### 7.1 Animation Testing

- Test each animation type independently
- Test animation completion callbacks
- Test cleanup (no memory leaks)
- Test performance with many simultaneous animations

### 7.2 Integration Testing

- Test animations with game events
- Test animation stacking (multiple animations)
- Test animation cancellation (if needed)

---

*This document specifies the v3.0 animation system. For UI design, see UI-Design-v3.0.md.*

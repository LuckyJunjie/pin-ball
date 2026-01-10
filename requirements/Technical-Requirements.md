# Pinball Game - Technical Requirements

## 1. Platform Requirements

### 1.1 Engine

- **TR-1.1.1**: Game must run on Godot Engine 4.5
- **TR-1.1.2**: Project must be compatible with Godot 4.5 Forward Plus renderer
- **TR-1.1.3**: Project must use Godot's built-in physics engine (Bullet-based)

### 1.2 Input System

- **TR-1.2.1**: Game must support keyboard input
- **TR-1.2.2**: Input actions must be configurable in project.godot
- **TR-1.2.3**: Input system must support the following actions:
  - `flipper_left`: Left Arrow (4194319) or A key (65)
  - `flipper_right`: Right Arrow (4194321) or D key (68)
  - `launch_ball`: Space (32) (for charging launcher)
  - `release_ball`: Down Arrow (4194320) (for releasing ball from queue)
  - `ui_cancel`: Esc key (for pause)

### 1.3 Input Behavior

- **TR-1.3.1**: Flipper inputs must be "pressed" actions (continuous while held)
- **TR-1.3.2**: Launch input must be "pressed" action (for charging launcher)
- **TR-1.3.3**: Release ball input must be "just_pressed" action (single activation to release ball from queue)
- **TR-1.3.4**: Pause input must be "just_pressed" action (single activation)

## 2. Performance Requirements

### 2.1 Frame Rate

- **TR-2.1.1**: Game must maintain 60 FPS on target hardware
- **TR-2.1.2**: Physics calculations must not cause frame drops
- **TR-2.1.3**: Physics FPS must match display FPS (60 FPS)

### 2.2 Responsiveness

- **TR-2.2.1**: Flipper input must respond within 1 frame (16ms at 60 FPS)
- **TR-2.2.2**: Ball physics must update smoothly without stuttering
- **TR-2.2.3**: All physics calculations must occur in `_physics_process()` with fixed timestep

## 3. Physics System Requirements

### 3.1 Physics Engine Configuration

- **TR-3.1.1**: Global gravity must be set to 980.0 units/s² (standard Earth gravity)
- **TR-3.1.2**: Default angular damping must be 0.1
- **TR-3.1.3**: Physics process must use fixed timestep for consistency

### 3.2 Physics Layers

- **TR-3.2.1**: Physics layer system must be implemented with the following layers:
  - **Layer 1**: Ball (bit 0, value 1)
  - **Layer 2**: Flippers (bit 1, value 2)
  - **Layer 4**: Walls (bit 2, value 4)
  - **Layer 8**: Obstacles (bit 3, value 8)
  - **Layer 16**: Ramps/Rails (bit 4, value 16) (optional, may use Walls layer)

### 3.3 Collision Masks

- **TR-3.3.1**: Ball must have collision_mask = 14 (2 + 4 + 8) - collides with Flippers, Walls, Obstacles (add 16 if ramps use separate layer)
- **TR-3.3.2**: Flippers must have collision_mask = 1 - collides with Ball only
- **TR-3.3.3**: Walls must have collision_mask = 0 - static, no mask needed
- **TR-3.3.4**: Obstacles must have collision_mask = 0 - static, collision via Area2D
- **TR-3.3.5**: Ramps/Rails must have collision_mask = 0 - static, collision via StaticBody2D
- **TR-3.3.6**: Holds must use Area2D (collision_mask = 0, detection via body_entered signal)

### 3.4 Physics Materials

- **TR-3.4.1**: Ball must have bounce=0.8, friction=0.3
- **TR-3.4.2**: Flippers must have bounce=0.6, friction=0.5
- **TR-3.4.3**: Walls must have bounce=0.7, friction=0.3
- **TR-3.4.4**: Bumpers must have bounce=0.95, friction=0.2
- **TR-3.4.5**: Pegs must have bounce=0.8, friction=0.3
- **TR-3.4.6**: Obstacle Walls must have bounce=0.85, friction=0.3

## 4. Rendering Requirements

### 4.1 Rendering System

- **TR-4.1.1**: UI elements must be rendered on CanvasLayer for proper overlay
- **TR-4.1.2**: Game world elements must be rendered on Node2D layer
- **TR-4.1.3**: Rendering must support transparent elements (queued balls at 0.8 opacity)

### 4.2 Visual Specifications

- **TR-4.2.1**: Playfield must be 800x600 pixels
- **TR-4.2.2**: Background color must be dark blue-gray (0.1, 0.1, 0.2, 1)
- **TR-4.2.3**: Ball must be visually represented as red circle (Color: 1, 0.2, 0.2, 1)
- **TR-4.2.4**: Flippers must be light blue (0.2, 0.6, 1, 1)
- **TR-4.2.5**: Walls must be gray-blue (0.3, 0.3, 0.4, 1)

### 4.3 Typography

- **TR-4.3.1**: Score label must use font size 32
- **TR-4.3.2**: Instructions label must use font size 16
- **TR-4.3.3**: Text must be white or light color for high contrast on dark background

## 5. Architecture Requirements

### 5.1 Code Organization

- **TR-5.1.1**: Code must be well-commented
- **TR-5.1.2**: Scripts must follow Godot naming conventions
- **TR-5.1.3**: Scene structure must be organized and logical
- **TR-5.1.4**: Component-based architecture must be used

### 5.2 Extensibility

- **TR-5.2.1**: System must support adding new obstacle types
- **TR-5.2.2**: Scoring system must be extensible
- **TR-5.2.3**: Component architecture must allow for feature additions
- **TR-5.2.4**: Signal system must be used for loose coupling

## 6. Memory and Resource Requirements

### 6.1 Memory Management

- **TR-6.1.1**: Balls must be instantiated once and reused via queue system
- **TR-6.1.2**: Obstacles must be instantiated once per game
- **TR-6.1.3**: No dynamic allocation during gameplay
- **TR-6.1.4**: Proper cleanup when balls are lost

### 6.2 Resource Optimization

- **TR-6.2.1**: Use simple collision shapes (circles, rectangles)
- **TR-6.2.2**: StaticBody2D for walls and obstacles (no physics calculations)
- **TR-6.2.3**: RigidBody2D only for dynamic objects (ball, flippers)
- **TR-6.2.4**: Freeze inactive objects (queued balls)

## 7. Audio System Requirements

### 7.1 Audio Engine

- **TR-7.1.1**: Audio system must use Godot's AudioStreamPlayer nodes
- **TR-7.1.2**: Sound files must be stored in `assets/sounds/` directory
- **TR-7.1.3**: Recommended audio formats: .ogg (compressed) or .wav (uncompressed)
- **TR-7.1.4**: AudioStreamPlayer nodes must be attached to appropriate components

### 7.2 Sound Effects

- **TR-7.2.1**: Flipper click sound must play when flipper activates
- **TR-7.2.2**: Ball hit obstacle sound must play on obstacle collision
- **TR-7.2.3**: Ball launch sound must play when launcher launches ball
- **TR-7.2.4**: Ball fall to hold sound must play when ball enters a hold
- **TR-7.2.5**: Ball lost sound must play when ball falls to bottom
- **TR-7.2.6**: Sound effects must have configurable volume settings
- **TR-7.2.7**: Sound effects must be enable/disable configurable

## 8. Debug System Requirements

### 8.1 Debug Configuration

- **TR-8.1.1**: Debug mode must be stored as @export variable in GameManager
- **TR-8.1.2**: Debug mode must be accessible via GameManager.debug_mode or DebugConfig singleton
- **TR-8.1.3**: Debug mode state must persist during gameplay session
- **TR-8.1.4**: Debug mode must default to false (disabled)

### 8.2 Debug Logging

- **TR-8.2.1**: All debug print() statements must be wrapped in `if debug_mode:` checks
- **TR-8.2.2**: Debug log format must be: `[ComponentName] Message`
- **TR-8.2.3**: Error and warning logs (push_error, push_warning) must always execute
- **TR-8.2.4**: Debug logging must use conditional runtime checks (not preprocessor)

### 8.3 Visual Debug Labels

- **TR-8.3.1**: Visual labels must check debug mode before creation: `if debug_mode: add_visual_label()`
- **TR-8.3.2**: Label styling must be consistent across all components
- **TR-8.3.3**: Labels must use Label node with font size 12-20, white/yellow color, black outline
- **TR-8.3.4**: Labels must be positioned to not obstruct gameplay


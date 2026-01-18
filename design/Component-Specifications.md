# Pinball Game - Component Specifications

## 1. Ball Component

### 1.1 Scene: Ball.tscn

**Node Structure**:
```
Ball (RigidBody2D)
├── CollisionShape2D
│   └── Shape: CircleShape2D (radius: 8.0)
└── Visual (ColorRect)
    ├── offset_left: -8.0
    ├── offset_top: -8.0
    ├── offset_right: 8.0
    ├── offset_bottom: 8.0
    └── color: Color(1, 0.2, 0.2, 1)
```

### 1.2 Script: Ball.gd

**Class**: `extends RigidBody2D`

**Export Variables**:
- `respawn_y_threshold: float = 800.0` - Y position where ball is considered lost
- `initial_position: Vector2 = Vector2(400, 200)` - Initial spawn position
- `boundary_left: float = 20.0` - Left boundary limit
- `boundary_right: float = 780.0` - Right boundary limit
- `boundary_top: float = 20.0` - Top boundary limit
- `boundary_bottom: float = 580.0` - Bottom boundary limit

**Properties**:
- `collision_layer = 1` (Ball layer)
- `collision_mask = 14` (Flippers + Walls + Obstacles)
- `mass = 0.5`
- `gravity_scale = 1.0`
- `linear_damp = 0.05`
- `angular_damp = 0.05`

**Physics Material**:
- `bounce = 0.8`
- `friction = 0.3`

**Methods**:
- `_ready()`: Configure physics properties
- `_physics_process(delta)`: Boundary enforcement and loss detection
- `reset_ball()`: Reset position and velocity
- `launch_ball(force: Vector2)`: Apply launch impulse

**Signals**:
- `ball_lost`: Emitted when ball falls below respawn_y_threshold

## 2. Flipper Component

### 2.1 Scene: Flipper.tscn

**Node Structure**:
```
Flipper (RigidBody2D)
├── CollisionShape2D
│   └── Shape: ConvexPolygonShape2D (baseball bat shape)
│       └── Points: (-6,0), (6,0), (14,60), (12,64), (-12,64), (-14,60)
├── Visual (Polygon2D)
│   └── Polygon: Same as collision shape
│   └── color: Color(0.2, 0.6, 1, 1)
└── SpriteFallback (Sprite2D, hidden)
```

### 2.2 Script: Flipper.gd

**Class**: `extends RigidBody2D`

**Export Variables**:
- `flipper_side: String = "left"` - "left" or "right"
- `rest_angle: float = -45.0` - Rest position angle (45° from vertical for easier ball hitting)
- `pressed_angle: float = -90.0` - Pressed position angle
- `rotation_speed: float = 20.0` - Rotation speed in degrees/second

**Properties**:
- `collision_layer = 2` (Flipper layer)
- `collision_mask = 1` (Ball)
- `gravity_scale = 0.0`
- `freeze = true` (kinematic control)
- `freeze_mode = FREEZE_MODE_KINEMATIC`
- `mass = 1.0`

**Physics Material**:
- `bounce = 0.6`
- `friction = 0.5`

**Methods**:
- `_ready()`: Configure physics and adjust angles based on side
- `_physics_process(delta)`: Handle input and rotation interpolation

**Behavior**:
- Left flipper: rest_angle = -45°, pressed_angle = -90°
- Right flipper: rest_angle = 45°, pressed_angle = 90°
- Flippers start at 45° from vertical for easier ball hitting
- Rotation only occurs when button is pressed
- Smooth interpolation to target angle

## 3. Ball Queue Component

### 3.1 Scene: BallQueue.tscn

**Node Structure**:
```
BallQueue (Node2D)
└── (Balls added as children dynamically)
```

### 3.2 Script: BallQueue.gd

**Class**: `extends Node2D`

**Export Variables**:
- `ball_scene: PackedScene = null` - Ball scene to instantiate
- `queue_size: int = 4` - Number of balls in queue
- `queue_spacing: float = 25.0` - Vertical spacing between balls
- `queue_position: Vector2 = Vector2(720, 100)` - Queue position (top right area)
- `queue_direction: Vector2 = Vector2(0, -1)` - Stacking direction (upward)

**Properties**:
- `ball_queue: Array[RigidBody2D]` - Array of queued balls
- `active_ball: RigidBody2D = null` - Currently active ball

**Methods**:
- `_ready()`: Initialize queue
- `initialize_queue()`: Create and position 4 standby balls
- `get_next_ball() -> RigidBody2D`: Activate next ball from queue (internal)
- `release_next_ball() -> RigidBody2D`: Release ball from queue (called by GameManager on Down Arrow)
- `return_ball_to_queue(ball: RigidBody2D)`: Return ball to queue
- `update_queue_positions()`: Reposition remaining balls
- `has_balls() -> bool`: Check if queue has balls
- `get_queue_count() -> int`: Get number of balls in queue
- `add_visual_label(text: String)`: Add debug label if debug mode enabled

**Signals**:
- `ball_ready(ball: RigidBody2D)`: Emitted when ball is activated
- `queue_empty`: Emitted when queue is empty

**Ball State Management**:
- **Queued**: `freeze = true`, `gravity_scale = 0.0`, `modulate = Color(1,1,1,0.8)`
- **Released**: `freeze = false`, `gravity_scale = 1.0`, `modulate = Color(1,1,1,1)`
  - Positioned at pipe entry (queue_position + Vector2(0, 20)) = (720, 120)
  - Falls through visible pipe guide to launcher

**Pipe Guide Integration**:
- Ball released from queue falls through visible pipe/chute
- Pipe spans from queue area (y=100) to launcher area (y=450)
- Pipe width: 35px (wider than ball diameter ~16px)
- Ball slides naturally through pipe to launcher position

## 4. Game Manager Component

### 4.1 Script: GameManager.gd

**Class**: `extends Node2D`

**Export Variables**:
- `ball_scene: PackedScene` - Ball scene reference
- `ball_spawn_position: Vector2 = Vector2(400, 600)` - Fallback spawn position
- `launch_force: Vector2 = Vector2(0, -500)` - Fallback launch force
- `debug_mode: bool = false` - Enable/disable debug mode (logging and visual labels)

**Properties**:
- `current_ball: RigidBody2D = null` - Currently active ball
- `score: int = 0` - Current score
- `is_paused: bool = false` - Pause state
- `ball_queue: Node2D = null` - BallQueue reference
- `launcher: Node2D = null` - Launcher reference (optional)

**Methods**:
- `_ready()`: Initialize and connect signals
- `_input(event)`: Handle pause input and ball release (Down Arrow)
- `prepare_next_ball()`: Get ball from queue and position it (legacy, for auto-release)
- `release_ball_from_queue()`: Handle Down Arrow input to release ball from queue
- `_on_ball_ready(ball)`: Handle ball ready from queue
- `_on_ball_launched(force)`: Handle ball launch
- `_on_ball_lost()`: Handle ball loss, wait for next release
- `_on_hold_entered(points)`: Handle hold entry and final scoring
- `_on_queue_empty()`: Handle empty queue (refill)
- `connect_obstacle_signals()`: Connect obstacle hit signals
- `connect_hold_signals()`: Connect hold entry signals
- `_on_obstacle_hit(points)`: Handle obstacle hit and score
- `spawn_ball()`: Fallback ball spawning
- `launch_ball()`: Fallback ball launching
- `add_score(points)`: Increment score
- `reset_score()`: Reset score to zero
- `toggle_pause()`: Toggle pause state
- `debug_log(message)`: Helper for debug logging (optional)

**Signals**:
- `score_changed(new_score: int)`: Emitted when score changes

**Group**: "game_manager" (for easy access)

## 5. Obstacle Component

### 5.1 Scene: Obstacle.tscn

**Node Structure**:
```
Obstacle (StaticBody2D)
├── CollisionShape2D
│   └── Shape: (varies by type)
├── Area2D (for collision detection)
│   └── CollisionShape2D
└── Visual (varies by type)
```

### 5.2 Script: Obstacle.gd

**Class**: `extends StaticBody2D`

**Export Variables**:
- `obstacle_type: String = "basketball"` - "basketball", "baseball_player", "baseball_bat", "soccer_goal" (or legacy: "bumper", "peg", "wall")
- `points_value: int = 20` - Points awarded on hit
- `bounce_strength: float = 0.95` - Bounce physics value

**Properties**:
- `collision_layer = 8` (Obstacle layer)
- `hit_cooldown: float = 0.5` - Cooldown between hits
- `last_hit_time: float = 0.0` - Last hit timestamp

**Methods**:
- `_ready()`: Configure based on obstacle type
- `_on_body_entered(body)`: Handle ball collision
- `award_points()`: Award points and emit signal

**Signals**:
- `obstacle_hit(points: int)`: Emitted when ball hits obstacle

**Obstacle Types (Sports-Themed)**:

**Basketball Hoop**:
- Shape: CircleShape2D (radius: 30)
- Points: 20
- Bounce: 0.95
- Sprite: basketball_hoop.png (60x60px, orange hoop on brown pole)
- Replaces: Legacy "bumper" type

**Baseball Player**:
- Shape: CircleShape2D (radius: 8)
- Points: 5
- Bounce: 0.8
- Sprite: baseball_player.png (20x40px, dark blue player silhouette)
- Replaces: Legacy "peg" type

**Baseball Bat**:
- Shape: RectangleShape2D (size: Vector2(40, 12))
- Points: 15
- Bounce: 0.85
- Rotation: Random (-45° to 45°)
- Sprite: baseball_bat.png (40x12px, brown bat shape)
- Replaces: Legacy "wall" type

**Soccer Goal**:
- Shape: RectangleShape2D (size: Vector2(50, 30))
- Points: 25
- Bounce: 0.9
- Rotation: Random (-30° to 30°)
- Sprite: soccer_goal.png (50x30px, white goal posts with net pattern)
- New obstacle type (not replacing legacy type)

## 6. Obstacle Spawner Component

### 6.1 Script: ObstacleSpawner.gd

**Class**: `extends Node2D`

**Export Variables**:
- `obstacle_scene: PackedScene` - Obstacle scene to instantiate
- `num_obstacles: int = 8` - Number of obstacles to spawn

**Methods**:
- `_ready()`: Spawn obstacles
- `spawn_obstacles()`: Create and place obstacles
- `is_valid_position(pos: Vector2) -> bool`: Validate obstacle position
- `get_random_obstacle_type() -> String`: Get random obstacle type

**Placement Rules**:
- Minimum 50px from walls
- Minimum 80px between obstacles
- Avoid flipper zones (x: 150-250, 550-650, y: 500-600)
- Avoid launcher zone (x: 350-450, y: 550-600)

## 7. UI Component

### 7.1 Scene: UI (in Main.tscn)

**Node Structure**:
```
UI (CanvasLayer)
├── ScoreLabel (Label)
│   ├── offset_left: 20.0
│   ├── offset_top: 20.0
│   ├── offset_right: 200.0
│   ├── offset_bottom: 60.0
│   ├── font_size: 32
│   └── text: "Score: 0"
└── Instructions (Label)
    ├── offset_left: 20.0
    ├── offset_top: 70.0
    ├── offset_right: 400.0
    ├── offset_bottom: 150.0
    ├── font_size: 16
    └── text: "Left/A: Left Flipper\nRight/D: Right Flipper\nHold Space/Down: Charge Launcher\nEsc: Pause"
```

### 7.2 Script: UI.gd

**Class**: `extends CanvasLayer`

**Properties**:
- `score_label: Label` - Reference to score label

**Methods**:
- `_ready()`: Connect to GameManager score signal
- `_on_score_changed(new_score: int)`: Update score display
- `set_score_text(score: int)`: Direct score text update

## 8. Launcher Component (Optional)

### 8.1 Scene: Launcher.tscn

**Node Structure**:
```
Launcher (Node2D)
├── Plunger (Node2D)
│   └── Visual (ColorRect)
├── ChargeMeter (ProgressBar)
└── LauncherBase (ColorRect)
```

### 8.2 Script: Launcher.gd

**Class**: `extends Node2D`

**Export Variables**:
- `base_launch_force: Vector2 = Vector2(0, -500)`
- `max_launch_force: Vector2 = Vector2(0, -1000)`
- `charge_rate: float = 2.0`
- `launcher_position: Vector2 = Vector2(720, 450)` - Positioned below queue on right side
- `horizontal_launch_angle: float = -15.0` - Launch angle toward center (degrees)
- `plunger_rest_position: Vector2 = Vector2(0, 0)`
- `plunger_max_pull: Vector2 = Vector2(0, 30)`

**Properties**:
- `current_charge: float = 0.0`
- `max_charge: float = 1.0`
- `is_charging: bool = false`
- `current_ball: RigidBody2D = null`

**Methods**:
- `_ready()`: Initialize visual elements and ramp
- `_process(delta)`: Handle charging input (Space key)
- `set_ball(ball: RigidBody2D)`: Set ball to launch (position ball at launcher)
- `update_plunger_visual()`: Update plunger position based on charge
- `update_charge_meter()`: Update charge display
- `launch_ball()`: Launch ball with current charge
- `has_ball() -> bool`: Check if launcher has a ball ready
- `add_visual_label(text: String)`: Add debug label if debug mode enabled

**Launcher Ramp**:
- Launch angle: -15° (toward center of playfield)
- Curved ramp guides ball from launcher to center using spline-based curve
- Ramp uses curved path (not straight rectangle)

**Signals**:
- `ball_launched(force: Vector2)`: Emitted when ball is launched

## 8A. Pipe Guide Component

### 8A.1 Scene: PipeGuide (in Main.tscn)

**Node Structure**:
```
PipeGuide (Node2D)
├── PipeLeftWall (StaticBody2D)
│   ├── CollisionShape2D (RectangleShape2D: 5x325)
│   └── Visual (ColorRect, brown/tan)
├── PipeRightWall (StaticBody2D)
│   ├── CollisionShape2D (RectangleShape2D: 5x325)
│   └── Visual (ColorRect, brown/tan)
└── PipeBack (StaticBody2D)
    ├── CollisionShape2D (RectangleShape2D: 35x3)
    └── Visual (ColorRect, brown/tan)
```

**Properties**:
- Position: Left wall at (702.5, 275), Right wall at (737.5, 275)
- Back barrier at (720, 112.5) to prevent ball from going back up
- Pipe width: 35px (between x=702.5 and x=737.5)
- Pipe length: 325px (from y=112.5 to y=437.5)
- `collision_layer = 4` (Wall layer)
- `collision_mask = 0` (static)

**Physics Material**:
- `friction = 0.1` (low friction for smooth sliding)
- `bounce = 0.3` (minimal bounce)

**Visual**:
- Color: Brown/tan (Color(0.6, 0.5, 0.3, 1))
- Pipe walls: 5px wide, 325px tall
- Pipe back: 35px wide, 3px tall (horizontal barrier at top)

**Functionality**:
- Guides ball from queue position (720, 100) to launcher (720, 450)
- Ball enters pipe at y=120 (pipe entry point)
- Ball slides naturally through pipe with gravity
- Ball exits pipe at bottom to reach launcher position

## 9. Wall Component

### 9.1 Scene: Walls (in Main.tscn)

**Node Structure**:
```
Walls (Node2D)
├── WallTop (StaticBody2D)
│   ├── CollisionShape2D (RectangleShape2D: 800x20)
│   └── Visual (ColorRect)
├── WallLeft (StaticBody2D)
│   ├── CollisionShape2D (RectangleShape2D: 20x600)
│   └── Visual (ColorRect)
├── WallRight (StaticBody2D)
│   ├── CollisionShape2D (RectangleShape2D: 20x600)
│   └── Visual (ColorRect)
└── WallBottom (StaticBody2D)
    ├── CollisionShape2D (RectangleShape2D: 800x20)
    └── Visual (ColorRect)
```

**Properties**:
- `collision_layer = 4` (Wall layer)
- `collision_mask = 0` (static, no mask needed)

**Physics Material**:
- `bounce = 0.7`
- `friction = 0.3`

**Positions**:
- Top: (400, 10)
- Left: (10, 300)
- Right: (790, 300)
- Bottom: (400, 590)

## 9B. Background Component

### 9B.1 Scene: Background (in Main.tscn)

**Node Structure**:
```
Background (Sprite2D)
└── texture: background.png
```

**Script**: No script (static visual)

**Properties**:
- Position: `Vector2(400, 300)` - Center of playfield
- `modulate = Color(1, 1, 1, 0.3)` - 30% opacity (70% transparent)
- Texture: `assets/sprites/background.png`

**Visual**:
- Background image displayed at center of playfield
- 70% transparent to reduce visual interference with game elements
- Remains visible but doesn't obscure balls, flippers, obstacles, etc.
- Sprite2D automatically scales to display texture at native size

## 10. Component Interactions

### 10.1 Ball ↔ Flipper
- Collision detection via physics layers
- Ball bounces off flipper with 0.6 bounce coefficient
- Flipper rotation affects ball trajectory
- Sound effect plays when flipper activates (if implemented)

### 10.2 Ball ↔ Obstacle
- Collision detection via Area2D
- Points awarded on collision (continuous scoring)
- Cooldown prevents multiple rapid hits
- Bounce coefficient varies by obstacle type
- Sound effect plays on hit (if implemented)

### 10.3 Ball ↔ Wall
- Collision detection via physics layers
- Ball bounces with 0.7 bounce coefficient
- Boundary enforcement prevents escape

### 10.4 GameManager ↔ All Components
- Coordinates ball lifecycle
- Manages score from obstacles and holds
- Connects signals between components
- Handles game state
- Manages debug mode configuration

### 10.5 Hold Component

**Scene: Hold.tscn**

**Node Structure**:
```
Hold (Area2D)
├── CollisionShape2D
│   └── Shape: CircleShape2D (radius: 20.0)
├── Visual (ColorRect) - Dark hole color
└── PointLabel (Label) - Point value display
```

**Script: Hold.gd**

**Class**: `extends Area2D`

**Export Variables**:
- `points_value: int = 10` - Point value for this hold (10, 15, 20, 25, 30, etc.)

**Properties**:
- `collision_layer = 0` (detection only)
- `collision_mask = 1` (detect ball layer)
- `captured_ball: RigidBody2D = null` - Currently captured ball (if any)

**Methods**:
- `_ready()`: Set up Area2D for detection and create visual
- `_on_body_entered(body: Node2D)`: Detect ball entry and capture ball
  - Freeze ball and position at hold center
  - Emit hold_entered signal with points value
  - Prevent multiple captures (only first ball captured)

**Behavior**:
- When ball enters hold, ball is frozen and positioned at hold center
- Score is calculated and awarded
- Ball round ends, ball removed after visual feedback delay (0.5s)
- Next ball prepared after delay (1.0s total)

**Signals**:
- `hold_entered(points: int)`: Emitted when ball enters hold

**Export Variables**:
- `points_value: int = 10` - Point value for this hold (10, 15, 20, 25, 30, etc.)

**Properties**:
- `collision_layer = 0` (no collision layer)
- Area2D `collision_mask = 1` (detect ball)

**Methods**:
- `_ready()`: Setup Area2D and connect body_entered signal
- `_on_body_entered(body)`: Handle ball entry, award points, emit signal
- `add_visual_label(text: String)`: Add debug label if debug mode enabled

**Signals**:
- `hold_entered(points: int)`: Emitted when ball enters hold

### 10.6 Ramp Component (Curved/Spline-Based)

**Scene: Ramp.tscn** (ramps created dynamically in Main.tscn or via Ramp.gd script)

**Node Structure**:
```
Ramp (StaticBody2D)
├── RampSegments (Node2D)
│   ├── CollisionShape2D (SegmentShape2D) - Multiple segments forming curve
│   ├── CollisionShape2D (SegmentShape2D)
│   └── ... (multiple segments)
└── Visual (Line2D) - Curved visual representation
```

**Script: Ramp.gd**

**Class**: `extends StaticBody2D`

**Export Variables**:
- `ramp_length: float = 200.0` - Length of ramp
- `ramp_angle: float = 30.0` - Starting angle in degrees
- `ramp_width: float = 40.0` - Width of ramp visual
- `curve_points: int = 8` - Number of segments for spline curve (more = smoother)
- `curve_type: String = "catmull"` - Spline type: "catmull", "bezier", or "smooth"

**Properties**:
- `collision_layer = 4` (Walls layer)
- `collision_mask = 0` (static)

**Methods**:
- `_ready()`: Generate spline curve and create collision/visual segments
- `_generate_spline_points(control_points: Array[Vector2], segments: int) -> Array[Vector2]`: Generate spline curve points using Catmull-Rom interpolation
- `_catmull_rom(p0, p1, p2, p3, t: float) -> Vector2`: Catmull-Rom spline interpolation
- `add_visual_label(text: String)`: Add debug label if debug mode enabled

**Curve Generation**:
- Creates 3-4 control points based on ramp_length and ramp_angle
- Generates smooth spline curve using Catmull-Rom interpolation
- Creates multiple SegmentShape2D shapes forming smooth curve for collision
- Visual representation using Line2D for curved appearance
- Ramp is curved (orbit-like) instead of straight rectangle

### 10.7 SoundManager Component (Optional)

**Scene: SoundManager.tscn (optional, or AudioStreamPlayer nodes in components)**

**Node Structure**:
```
SoundManager (Node) - Optional singleton
├── FlipperClickSound (AudioStreamPlayer)
├── ObstacleHitSound (AudioStreamPlayer)
├── BallLaunchSound (AudioStreamPlayer)
├── HoldEntrySound (AudioStreamPlayer)
└── BallLostSound (AudioStreamPlayer)
```

**Script: SoundManager.gd**

**Class**: `extends Node`

**Export Variables**:
- `volume: float = 1.0` - Master volume
- `enabled: bool = true` - Enable/disable sounds

**Methods**:
- `play_sound(sound_name: String)`: Play sound effect by name
- `set_volume(volume: float)`: Set master volume
- `set_enabled(enabled: bool)`: Enable/disable all sounds

**Sound Files**:
- Supports both WAV and OGG formats (prefers OGG)
- Sound files: flipper_click, obstacle_hit, ball_launch, hold_entry, ball_lost
- Placeholder WAV files generated by `scripts/generate_sounds.py`
- Can be converted to OGG using ffmpeg or audio software
- Gracefully handles missing sound files (no errors)

**Sound Generation**:
- `scripts/generate_sounds.py` generates procedural sound effects
- Creates WAV files using basic tone generation
- Instructions for conversion to OGG provided
- Sources for commercial-quality sounds documented

**Alternative Implementation**: AudioStreamPlayer nodes added directly to Flipper, Obstacle, Launcher, Hold, and Ball components

### 10.8 Debug System

**Debug Configuration**:
- GameManager has `@export var debug_mode: bool = false`
- All components access debug mode via GameManager.debug_mode

**Debug Logging**:
- Components wrap debug prints: `if GameManager.debug_mode: print("[Component] Message")`
- Helper function (optional): `debug_log(message)` in GameManager

**Visual Debug Labels**:
- All components have `add_visual_label(text: String)` method
- Labels created conditionally: `if GameManager.debug_mode: add_visual_label("TEXT")`
- Consistent styling: font size 12-20, white/yellow color, black outline

### 10.9 Component Interactions (Updated)

### 10.10 Ball ↔ Flipper
- Collision detection via physics layers
- Ball bounces off flipper with 0.6 bounce coefficient
- Flipper rotation affects ball trajectory
- Sound effect plays when flipper activates (if implemented)

### 10.11 Ball ↔ Obstacle
- Collision detection via Area2D
- Points awarded on collision (continuous scoring)
- Cooldown prevents multiple rapid hits
- Bounce coefficient varies by obstacle type
- Sound effect plays on hit (if implemented)

### 10.12 Ball ↔ Hold
- Entry detection via Area2D body_entered signal
- Ball freezes and positions at hold center when entered
- Points awarded (final scoring for ball) - calculated before ball removal
- Ball round ends - visual feedback delay (0.5s) then ball removed
- Next ball prepared after delay (1.0s total)
- Only one ball can be captured per hold
- Sound effect plays on entry (if implemented)

### 10.13 Ball ↔ Ramp/Rail
- Collision detection via StaticBody2D with multiple SegmentShape2D segments
- Ball trajectory adjusted by curved spline-based ramp path
- Ramps guide ball from launcher (right side) toward center of playfield
- Curved ramps provide smooth orbit-like paths instead of straight lines
- Ramp physics: bounce 0.6, friction 0.3

### 10.14 Ball ↔ Pipe Guide
- Collision detection via StaticBody2D pipe walls
- Ball slides naturally through pipe with gravity
- Pipe guides ball from queue (720, 100) to launcher (720, 450)
- Pipe physics: low friction (0.1) for smooth sliding, minimal bounce (0.3)
- Ball enters pipe at y=120, exits at bottom to reach launcher

### 10.15 BallQueue ↔ GameManager
- GameManager calls release_next_ball() when Down Arrow pressed
- BallQueue activates and provides ball
- GameManager handles ball loss
- BallQueue refills when empty

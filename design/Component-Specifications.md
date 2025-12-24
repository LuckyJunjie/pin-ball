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
│   └── Shape: RectangleShape2D (size: Vector2(60, 12))
└── Visual (ColorRect)
    ├── offset_left: -30.0
    ├── offset_top: -6.0
    ├── offset_right: 30.0
    ├── offset_bottom: 6.0
    └── color: Color(0.2, 0.6, 1, 1)
```

### 2.2 Script: Flipper.gd

**Class**: `extends RigidBody2D`

**Export Variables**:
- `flipper_side: String = "left"` - "left" or "right"
- `rest_angle: float = 0.0` - Rest position angle
- `pressed_angle: float = -45.0` - Pressed position angle
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
- Left flipper: pressed_angle = -45°
- Right flipper: pressed_angle = +45°
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
- `queue_position: Vector2 = Vector2(750, 300)` - Queue position (right side)
- `queue_direction: Vector2 = Vector2(0, -1)` - Stacking direction (upward)

**Properties**:
- `ball_queue: Array[RigidBody2D]` - Array of queued balls
- `active_ball: RigidBody2D = null` - Currently active ball

**Methods**:
- `_ready()`: Initialize queue
- `initialize_queue()`: Create and position 4 standby balls
- `get_next_ball() -> RigidBody2D`: Activate next ball from queue
- `return_ball_to_queue(ball: RigidBody2D)`: Return ball to queue
- `update_queue_positions()`: Reposition remaining balls
- `has_balls() -> bool`: Check if queue has balls
- `get_queue_count() -> int`: Get number of balls in queue

**Signals**:
- `ball_ready(ball: RigidBody2D)`: Emitted when ball is activated
- `queue_empty`: Emitted when queue is empty

**Ball State Management**:
- **Queued**: `freeze = true`, `gravity_scale = 0.0`, `modulate = Color(1,1,1,0.8)`
- **Active**: `freeze = false`, `gravity_scale = 1.0`, `modulate = Color(1,1,1,1)`

## 4. Game Manager Component

### 4.1 Script: GameManager.gd

**Class**: `extends Node2D`

**Export Variables**:
- `ball_scene: PackedScene` - Ball scene reference
- `ball_spawn_position: Vector2 = Vector2(400, 600)` - Fallback spawn position
- `launch_force: Vector2 = Vector2(0, -500)` - Fallback launch force

**Properties**:
- `current_ball: RigidBody2D = null` - Currently active ball
- `score: int = 0` - Current score
- `is_paused: bool = false` - Pause state
- `ball_queue: Node2D = null` - BallQueue reference
- `launcher: Node2D = null` - Launcher reference (optional)

**Methods**:
- `_ready()`: Initialize and connect signals
- `_input(event)`: Handle pause input
- `prepare_next_ball()`: Get ball from queue and position it
- `_on_ball_ready(ball)`: Handle ball ready from queue
- `_on_ball_launched(force)`: Handle ball launch (optional)
- `_on_ball_lost()`: Handle ball loss and prepare next
- `_on_queue_empty()`: Handle empty queue (refill)
- `connect_obstacle_signals()`: Connect obstacle hit signals
- `_on_obstacle_hit(points)`: Handle obstacle hit and score
- `spawn_ball()`: Fallback ball spawning
- `launch_ball()`: Fallback ball launching
- `add_score(points)`: Increment score
- `reset_score()`: Reset score to zero
- `toggle_pause()`: Toggle pause state

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
- `obstacle_type: String = "bumper"` - "bumper", "peg", or "wall"
- `points: int = 20` - Points awarded on hit
- `bounce_coefficient: float = 0.95` - Bounce physics value

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

**Obstacle Types**:

**Bumper**:
- Shape: CircleShape2D (radius: 30)
- Points: 20
- Bounce: 0.95
- Color: Yellow or bright color

**Peg**:
- Shape: CircleShape2D (radius: 8)
- Points: 5
- Bounce: 0.8
- Color: White or light color

**Wall**:
- Shape: RectangleShape2D (size: Vector2(40, 10))
- Points: 15
- Bounce: 0.85
- Rotation: Random (0-360°)
- Color: Gray

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
- `launcher_position: Vector2 = Vector2(400, 570)`
- `plunger_rest_position: Vector2 = Vector2(0, 0)`
- `plunger_max_pull: Vector2 = Vector2(0, 30)`

**Properties**:
- `current_charge: float = 0.0`
- `max_charge: float = 1.0`
- `is_charging: bool = false`
- `current_ball: RigidBody2D = null`

**Methods**:
- `_ready()`: Initialize visual elements
- `_process(delta)`: Handle charging input
- `set_ball(ball: RigidBody2D)`: Set ball to launch
- `update_plunger_visual()`: Update plunger position
- `update_charge_meter()`: Update charge display
- `launch_ball()`: Launch ball with current charge

**Signals**:
- `ball_launched(force: Vector2)`: Emitted when ball is launched

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

## 10. Component Interactions

### 10.1 Ball ↔ Flipper
- Collision detection via physics layers
- Ball bounces off flipper with 0.6 bounce coefficient
- Flipper rotation affects ball trajectory

### 10.2 Ball ↔ Obstacle
- Collision detection via Area2D
- Points awarded on collision
- Cooldown prevents multiple rapid hits
- Bounce coefficient varies by obstacle type

### 10.3 Ball ↔ Wall
- Collision detection via physics layers
- Ball bounces with 0.7 bounce coefficient
- Boundary enforcement prevents escape

### 10.4 GameManager ↔ All Components
- Coordinates ball lifecycle
- Manages score from obstacles
- Connects signals between components
- Handles game state

### 10.5 BallQueue ↔ GameManager
- GameManager requests next ball
- BallQueue activates and provides ball
- GameManager handles ball loss
- BallQueue refills when empty

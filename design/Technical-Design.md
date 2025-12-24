# Pinball Game - Technical Design Document

## 1. Architecture Overview

### 1.1 System Architecture

The game follows a component-based architecture using Godot's node system. Each major game element is a separate scene with its own script, allowing for modularity and reusability.

```
Main Scene (Main.tscn)
├── GameManager (Node2D) - Game state and coordination
├── BallQueue (Node2D) - Ball queue management
├── Launcher (Node2D) - Ball launcher mechanism (optional)
├── Playfield (Node2D) - Game area container
│   ├── Background (ColorRect) - Visual background
│   ├── Walls (Node2D) - Boundary walls
│   └── ObstacleSpawner (Node2D) - Obstacle placement
├── Flippers (Node2D) - Flipper controls
│   ├── FlipperLeft (Flipper.tscn)
│   └── FlipperRight (Flipper.tscn)
└── UI (CanvasLayer) - User interface
    ├── ScoreLabel (Label)
    └── Instructions (Label)
```

### 1.2 Component Architecture

Each component is self-contained with:
- Scene file (.tscn) for visual structure
- Script file (.gd) for behavior
- Export variables for configuration
- Signal system for communication

## 2. Scene Structure

### 2.1 Main Scene (Main.tscn)

**Purpose**: Root scene containing all game elements

**Structure**:
- Node2D root node
- GameManager as child Node2D
- BallQueue as child Node2D instance
- Launcher as child Node2D instance (optional)
- Playfield as child Node2D
- Flippers as child Node2D
- UI as child CanvasLayer

**Responsibilities**:
- Scene initialization
- Node hierarchy organization
- Scene-level configuration

### 2.2 Ball Scene (Ball.tscn)

**Purpose**: Ball physics and visual representation

**Structure**:
- RigidBody2D root
- CollisionShape2D (CircleShape2D, radius 8)
- Visual (ColorRect, 16x16, red color)

**Script**: `Ball.gd`

**Key Properties**:
- collision_layer = 1 (Ball layer)
- collision_mask = 14 (Flippers + Walls + Obstacles)
- mass = 0.5
- gravity_scale = 1.0
- linear_damp = 0.05
- angular_damp = 0.05

### 2.3 Flipper Scene (Flipper.tscn)

**Purpose**: Flipper physics and rotation

**Structure**:
- RigidBody2D root
- CollisionShape2D (RectangleShape2D, 60x12)
- Visual (ColorRect, 60x12, light blue)

**Script**: `Flipper.gd`

**Key Properties**:
- collision_layer = 2 (Flipper layer)
- collision_mask = 1 (Ball)
- freeze = true (kinematic control)
- freeze_mode = FREEZE_MODE_KINEMATIC

### 2.4 Ball Queue Scene (BallQueue.tscn)

**Purpose**: Ball queue display and management

**Structure**:
- Node2D root
- Script: `BallQueue.gd`

**Key Properties**:
- queue_size = 4
- queue_spacing = 25.0
- queue_position = Vector2(750, 300)
- queue_direction = Vector2(0, -1)

### 2.5 Obstacle Scene (Obstacle.tscn)

**Purpose**: Obstacle physics and scoring

**Structure**:
- StaticBody2D root
- CollisionShape2D (varies by type)
- Area2D for collision detection
- Visual representation

**Script**: `Obstacle.gd`

## 3. Script Architecture

### 3.1 GameManager.gd

**Purpose**: Central game state management

**Responsibilities**:
- Ball spawning and lifecycle
- Score management
- Signal coordination
- Obstacle signal connection
- Queue and launcher integration

**Key Methods**:
- `prepare_next_ball()`: Get ball from queue and position it
- `_on_ball_lost()`: Handle ball loss and prepare next
- `add_score(points)`: Increment score
- `connect_obstacle_signals()`: Connect obstacle hit signals

**Signals**:
- `score_changed(new_score: int)`

### 3.2 Ball.gd

**Purpose**: Ball physics and boundary management

**Responsibilities**:
- Physics configuration
- Boundary enforcement
- Ball loss detection
- Reset functionality

**Key Methods**:
- `reset_ball()`: Reset position and velocity
- `launch_ball(force)`: Apply launch impulse

**Signals**:
- `ball_lost`: Emitted when ball falls below threshold

### 3.3 Flipper.gd

**Purpose**: Flipper input and rotation control

**Responsibilities**:
- Input detection
- Rotation animation
- Physics configuration

**Key Methods**:
- `_physics_process(delta)`: Handle input and rotation

**Key Properties**:
- `flipper_side`: "left" or "right"
- `rest_angle`: 0.0
- `pressed_angle`: ±45.0
- `rotation_speed`: 20.0

### 3.4 BallQueue.gd

**Purpose**: Queue management and ball state

**Responsibilities**:
- Queue initialization
- Ball state management (frozen/active)
- Position updates
- Queue refilling

**Key Methods**:
- `initialize_queue()`: Create 4 standby balls
- `get_next_ball()`: Activate next ball from queue
- `update_queue_positions()`: Reposition remaining balls
- `return_ball_to_queue(ball)`: Return ball to queue

**Signals**:
- `ball_ready(ball: RigidBody2D)`
- `queue_empty`

### 3.5 Obstacle.gd

**Purpose**: Obstacle collision and scoring

**Responsibilities**:
- Collision detection
- Score awarding
- Cooldown management

**Key Methods**:
- `_on_body_entered(body)`: Handle ball collision

**Signals**:
- `obstacle_hit(points: int)`

### 3.6 ObstacleSpawner.gd

**Purpose**: Random obstacle placement

**Responsibilities**:
- Obstacle instantiation
- Position validation
- Zone avoidance

**Key Methods**:
- `spawn_obstacles()`: Place 8 obstacles randomly
- `is_valid_position(pos)`: Check if position is valid

## 4. Data Flow

### 4.1 Ball Lifecycle

```
BallQueue.initialize_queue()
  → Creates 4 frozen balls
  → Positions at queue location (750, 300)

GameManager.prepare_next_ball()
  → BallQueue.get_next_ball()
  → Ball unfreezes, becomes active
  → Ball positioned at queue location
  → Ball falls naturally with gravity

Ball falls and interacts with:
  → Flippers (collision)
  → Obstacles (collision, scoring)
  → Walls (collision, bounce)

Ball falls below y=800
  → Ball.ball_lost signal emitted
  → GameManager._on_ball_lost()
  → Wait 1 second
  → GameManager.prepare_next_ball() (repeat)
```

### 4.2 Scoring Flow

```
Ball collides with Obstacle
  → Obstacle._on_body_entered()
  → Check cooldown
  → Obstacle.obstacle_hit signal emitted
  → GameManager._on_obstacle_hit(points)
  → GameManager.add_score(points)
  → GameManager.score_changed signal emitted
  → UI._on_score_changed()
  → ScoreLabel text updated
```

### 4.3 Input Flow

```
Player presses Left Arrow / A
  → Input.is_action_pressed("flipper_left")
  → FlipperLeft._physics_process()
  → target_angle = pressed_angle (-45°)
  → rotation_degrees interpolates to target

Player releases button
  → Input.is_action_pressed() = false
  → target_angle = rest_angle (0°)
  → rotation_degrees interpolates back
```

## 5. Physics System

### 5.1 Physics Configuration

**Gravity**: 980.0 units/s² (standard Earth gravity)

**Physics Process**: `_physics_process(delta)` for all physics-based nodes

**Collision Detection**: Godot's built-in RigidBody2D collision system

### 5.2 Physics Materials

Each physics body uses PhysicsMaterial with:
- `bounce`: Restitution coefficient (0.0 to 1.0)
- `friction`: Friction coefficient (0.0 to 1.0)

### 5.3 Collision Layers and Masks

**Layer System**:
- Layer 1: Ball (bit 0)
- Layer 2: Flippers (bit 1)
- Layer 4: Walls (bit 2)
- Layer 8: Obstacles (bit 3)

**Collision Masks**:
- Ball: 14 (2+4+8) - collides with Flippers, Walls, Obstacles
- Flippers: 1 - collides with Ball only
- Walls: 0 - static, no collisions needed
- Obstacles: 0 - static, collision via Area2D

## 6. Signal System

### 6.1 Signal Architecture

Signals enable loose coupling between components:

```
Ball
  └─ ball_lost → GameManager._on_ball_lost()

Obstacle
  └─ obstacle_hit(points) → GameManager._on_obstacle_hit()

GameManager
  └─ score_changed(score) → UI._on_score_changed()

BallQueue
  ├─ ball_ready(ball) → GameManager._on_ball_ready()
  └─ queue_empty → GameManager._on_queue_empty()

Launcher (optional)
  └─ ball_launched(force) → GameManager._on_ball_launched()
```

### 6.2 Signal Usage Patterns

- **Event-driven**: Components emit signals on events
- **Observer pattern**: Multiple listeners can connect to signals
- **Decoupling**: Components don't need direct references

## 7. State Management

### 7.1 Game States

**Playing State**:
- Physics active
- Input processing
- Ball active
- Score tracking

**Paused State**:
- `get_tree().paused = true`
- All physics frozen
- Input processing paused
- UI remains visible

### 7.2 Ball States

**Queued State**:
- `freeze = true`
- `gravity_scale = 0.0`
- `modulate = Color(1, 1, 1, 0.8)` (semi-transparent)
- Positioned in queue

**Active State**:
- `freeze = false`
- `gravity_scale = 1.0`
- `modulate = Color(1, 1, 1, 1)` (fully opaque)
- Physics active

**Lost State**:
- Ball falls below y=800
- Signal emitted
- Ball removed after delay

## 8. Rendering System

### 8.1 Rendering Layers

**CanvasLayer (UI)**:
- ScoreLabel
- Instructions
- ChargeMeter (if applicable)

**Node2D (Game World)**:
- Playfield
- Balls
- Flippers
- Obstacles
- Walls

### 8.2 Visual Representation

All game elements use ColorRect for simple visual representation:
- Easy to implement
- Fast rendering
- Can be replaced with sprites later

## 9. Extension Points

### 9.1 Adding New Obstacle Types

1. Create new obstacle scene with Obstacle.gd script
2. Add obstacle type enum to Obstacle.gd
3. Update ObstacleSpawner to include new type
4. Configure physics material and scoring

### 9.2 Adding Sound Effects

1. Add AudioStreamPlayer nodes to scenes
2. Connect signals to play sounds:
   - Ball collision → bounce sound
   - Obstacle hit → score sound
   - Flipper activation → flipper sound

### 9.3 Adding Game Over

1. Add game_over signal to GameManager
2. Check conditions (queue empty, time limit, etc.)
3. Emit signal and show game over UI
4. Save high score if applicable

## 10. Performance Considerations

### 10.1 Optimization Strategies

- **Physics**: Use appropriate collision shapes (circles for balls, rectangles for flippers)
- **Rendering**: Simple ColorRect for fast rendering
- **Signals**: Efficient signal system for event handling
- **Object Pooling**: Queue system reuses ball instances

### 10.2 Memory Management

- Balls are instantiated once and reused via queue
- Obstacles are instantiated once per game
- No dynamic allocation during gameplay
- Proper cleanup when balls are lost

## 11. Testing Considerations

### 11.1 Unit Testing

- Ball physics calculations
- Flipper rotation logic
- Score calculations
- Queue management

### 11.2 Integration Testing

- Ball lifecycle
- Signal connections
- Obstacle collision
- Game state transitions

### 11.3 Manual Testing

- Flipper responsiveness
- Ball physics feel
- Visual clarity
- Performance on target hardware

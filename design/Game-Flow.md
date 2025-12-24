# Pinball Game - Game Flow and State Management

## 1. Game Flow Overview

### 1.1 High-Level Flow

```
Game Start
  ↓
Initialization
  ↓
Gameplay Loop
  ↓
Ball Lost
  ↓
Next Ball / Game Over
  ↓
(Repeat or End)
```

### 1.2 Detailed Flow

```
1. Application Launch
   ↓
2. Load Main.tscn
   ↓
3. Initialize All Components
   ↓
4. Start Gameplay
   ↓
5. Ball Drops from Queue
   ↓
6. Player Controls Flippers
   ↓
7. Ball Interacts with Obstacles
   ↓
8. Score Updates
   ↓
9. Ball Falls Below Threshold
   ↓
10. Next Ball Activates
    ↓
11. (Repeat from step 5 or Game Over)
```

## 2. Initialization Flow

### 2.1 Scene Loading

**Step 1: Main Scene Loads**
- Godot loads `Main.tscn`
- All nodes instantiated
- Scripts attached

**Step 2: Node Initialization**
- `_ready()` called on all nodes
- Order: Parent → Children (depth-first)

**Step 3: Component Setup**

**GameManager._ready()**:
1. Add to "game_manager" group
2. Find BallQueue node
3. Find Launcher node (optional)
4. Connect BallQueue signals
5. Connect Launcher signals (if exists)
6. Connect obstacle signals
7. Call `prepare_next_ball()`

**BallQueue._ready()**:
1. Check if ball_scene is set
2. Call `initialize_queue()`
3. Create 4 standby balls
4. Position balls in queue
5. Freeze all balls

**ObstacleSpawner._ready()**:
1. Check if obstacle_scene is set
2. Call `spawn_obstacles()`
3. Place 8 obstacles randomly
4. Validate positions

**UI._ready()**:
1. Find GameManager
2. Connect score_changed signal
3. Initialize score display

### 2.2 First Ball Activation

**GameManager.prepare_next_ball()**:
1. Check if BallQueue has balls
2. Call `BallQueue.get_next_ball()`
3. Ball unfreezes and becomes active
4. Position ball at queue location (750, 300)
5. Connect ball_lost signal
6. Ball falls naturally with gravity

## 3. Gameplay Loop

### 3.1 Active Gameplay

**Frame-by-Frame (60 FPS)**:

**Input Processing**:
- Check flipper input (Left Arrow/A, Right Arrow/D)
- Update flipper target angles
- Check pause input (Esc)

**Physics Processing** (`_physics_process`):
- Update ball physics
- Update flipper rotation
- Check collisions
- Enforce boundaries

**Visual Processing** (`_process`):
- Update UI elements
- Update visual feedback
- Update charge meter (if applicable)

### 3.2 Ball Interactions

**Ball-Flipper Collision**:
1. Ball collides with flipper
2. Physics engine calculates bounce
3. Flipper rotation affects trajectory
4. Ball continues movement

**Ball-Obstacle Collision**:
1. Ball collides with obstacle
2. Physics engine calculates bounce
3. Area2D detects collision
4. Check cooldown (0.5s)
5. If not on cooldown:
   - Award points
   - Emit obstacle_hit signal
   - Update score
   - Set cooldown timer

**Ball-Wall Collision**:
1. Ball collides with wall
2. Physics engine calculates bounce
3. Boundary check (if escaped)
4. Ball continues movement

### 3.3 Score Updates

**Obstacle Hit Flow**:
```
Ball hits Obstacle
  ↓
Obstacle._on_body_entered()
  ↓
Check cooldown
  ↓
If not on cooldown:
  ↓
  Obstacle.obstacle_hit signal emitted
    ↓
    GameManager._on_obstacle_hit(points)
      ↓
      GameManager.add_score(points)
        ↓
        GameManager.score_changed signal emitted
          ↓
          UI._on_score_changed(new_score)
            ↓
            ScoreLabel text updated
```

## 4. Ball Lifecycle

### 4.1 Ball States

**Queued State**:
- `freeze = true`
- `gravity_scale = 0.0`
- `modulate = Color(1, 1, 1, 0.8)` (semi-transparent)
- Positioned in queue
- No physics active

**Activating State**:
- `get_next_ball()` called
- Ball removed from queue
- Queue positions updated

**Active State**:
- `freeze = false`
- `gravity_scale = 1.0`
- `modulate = Color(1, 1, 1, 1)` (fully opaque)
- Positioned at queue location
- Physics active
- Falls with gravity

**Playing State**:
- Ball moving in playfield
- Interacting with flippers, obstacles, walls
- Scoring points
- Physics fully active

**Lost State**:
- Ball falls below y=800
- `ball_lost` signal emitted
- Ball marked for removal

**Removed State**:
- Ball disconnected from signals
- Ball queue_free() called
- Ball removed from scene

### 4.2 Ball Transition Flow

```
Queued → Activating → Active → Playing → Lost → Removed
  ↑                                                      ↓
  └────────────────── Next Ball ───────────────────────┘
```

## 5. Ball Loss and Recovery

### 5.1 Ball Loss Detection

**Detection Method**:
- Check in `Ball._physics_process()`
- If `global_position.y > respawn_y_threshold` (800)
- Emit `ball_lost` signal

**Loss Handling**:
```
Ball falls below y=800
  ↓
Ball.ball_lost signal emitted
  ↓
GameManager._on_ball_lost()
  ↓
Disconnect ball_lost signal
  ↓
Remove ball (queue_free())
  ↓
Wait 1 second
  ↓
GameManager.prepare_next_ball()
  ↓
Next ball from queue activates
```

### 5.2 Queue Management

**Queue Empty Handling**:
```
BallQueue.get_next_ball()
  ↓
If queue is empty:
  ↓
  queue_empty signal emitted
    ↓
    GameManager._on_queue_empty()
      ↓
      BallQueue.initialize_queue()
        ↓
        Create 4 new balls
          ↓
          GameManager.prepare_next_ball()
            ↓
            Next ball activates
```

## 6. Pause System

### 6.1 Pause Flow

**Entering Pause**:
```
Player presses Esc
  ↓
GameManager._input(event)
  ↓
GameManager.toggle_pause()
  ↓
get_tree().paused = true
  ↓
All physics frozen
All _process() stopped
All _physics_process() stopped
Input processing stopped
  ↓
Game in paused state
```

**Exiting Pause**:
```
Player presses Esc again
  ↓
GameManager._input(event)
  ↓
GameManager.toggle_pause()
  ↓
get_tree().paused = false
  ↓
All systems resume
  ↓
Game in playing state
```

### 6.2 Pause Behavior

**Frozen Systems**:
- Physics simulation
- Ball movement
- Flipper rotation
- Obstacle detection
- Score updates

**Active Systems**:
- UI rendering (if not paused)
- Input detection (Esc key)
- Scene tree structure

## 7. State Machine

### 7.1 Game States

**Initializing**:
- Scene loading
- Component setup
- Signal connections
- First ball preparation

**Playing**:
- Active gameplay
- Physics running
- Input processing
- Score tracking

**Paused**:
- Game frozen
- Physics stopped
- Input limited (Esc only)
- UI visible

**Ball Lost** (Transient):
- Ball removal
- Delay timer
- Next ball preparation

**Game Over** (Future):
- Queue empty
- Final score
- Restart option

### 7.2 State Transitions

```
Initializing → Playing
  (After initialization complete)

Playing → Paused
  (Esc pressed)

Paused → Playing
  (Esc pressed again)

Playing → Ball Lost
  (Ball falls below threshold)

Ball Lost → Playing
  (After delay and next ball ready)

Playing → Game Over (Future)
  (Queue empty, no more balls)
```

## 8. Signal Flow Diagram

### 8.1 Component Communication

```
Ball
  └─ ball_lost
      └─→ GameManager._on_ball_lost()
            └─→ prepare_next_ball()
                  └─→ BallQueue.get_next_ball()

Obstacle
  └─ obstacle_hit(points)
      └─→ GameManager._on_obstacle_hit(points)
            └─→ add_score(points)
                  └─→ score_changed(score)
                        └─→ UI._on_score_changed(score)
                              └─→ Update ScoreLabel

BallQueue
  ├─ ball_ready(ball)
  │   └─→ GameManager._on_ball_ready(ball)
  └─ queue_empty
      └─→ GameManager._on_queue_empty()
            └─→ BallQueue.initialize_queue()
```

## 9. Error Handling

### 9.1 Error Scenarios

**BallQueue Not Found**:
- GameManager checks for BallQueue
- Falls back to old spawn system
- Warning logged

**Launcher Not Found**:
- GameManager checks for Launcher
- Continues without launcher
- Warning logged

**Ball Scene Not Set**:
- BallQueue checks ball_scene
- Error logged
- Queue not initialized

**Obstacle Scene Not Set**:
- ObstacleSpawner checks obstacle_scene
- Error logged
- No obstacles spawned

### 9.2 Recovery Mechanisms

**Missing Components**:
- Fallback systems where possible
- Graceful degradation
- Error messages logged
- Game continues if possible

**Invalid States**:
- State validation
- Automatic correction
- Boundary enforcement
- Safety checks

## 10. Performance Flow

### 10.1 Frame Processing Order

**Frame Start**:
1. Input events processed
2. `_input()` called
3. `_process(delta)` called (visual updates)
4. `_physics_process(delta)` called (physics)
5. Rendering

**Optimization**:
- Physics in fixed timestep
- Visuals in variable timestep
- Efficient collision detection
- Minimal allocations

### 10.2 Memory Management

**Ball Lifecycle**:
- Balls created once in queue
- Reused when possible
- Properly freed when lost
- No memory leaks

**Obstacle Lifecycle**:
- Obstacles created once per game
- Static, no movement
- Freed when game ends

**Signal Management**:
- Signals connected in _ready()
- Properly disconnected when needed
- No orphaned connections

# Pinball Game - Game Flow and State Management

## 1. Game Flow Overview

### 1.1 High-Level Flow

```
Game Start
  ↓
Initialization
  ↓
Wait for Ball Release (Down Arrow)
  ↓
Ball Falls to Launcher
  ↓
Player Launches Ball (Space)
  ↓
Gameplay Loop (Obstacles, Holds, Ramps)
  ↓
Ball Ends (Hold Entry or Fall to Bottom)
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
3. Initialize All Components (Queue, Launcher, Obstacles, Holds, Ramps)
   ↓
4. Wait for Player to Release Ball (Down Arrow)
   ↓
5. Ball Drops from Queue to Launcher
   ↓
6. Player Charges and Launches Ball (Space)
   ↓
7. Ball Travels Through Launcher Ramp to Playfield
   ↓
8. Player Controls Flippers
   ↓
9. Ball Interacts with Obstacles (Continuous Scoring)
   ↓
10. Ball Interacts with Holds (Final Scoring, Ball Ends)
    ↓
11. Ball Travels Through Ramps/Rails
    ↓
12. Ball Falls Below Flippers or Enters Hold
    ↓
13. Next Ball Can Be Released (Repeat from step 4 or Game Over)
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
3. Find Launcher node
4. Connect BallQueue signals
5. Connect Launcher signals
6. Connect obstacle signals
7. Connect hold signals (if holds exist)
8. Initialize debug mode
9. Wait for player to release ball (do not auto-prepare ball)

**BallQueue._ready()**:
1. Check if ball_scene is set
2. Call `initialize_queue()`
3. Create 4 standby balls
4. Position balls in queue (top area, e.g., x=400, y=100)
5. Freeze all balls
6. Wait for release input (Down Arrow)

**ObstacleSpawner._ready()**:
1. Check if obstacle_scene is set
2. Call `spawn_obstacles()`
3. Place 8 obstacles randomly
4. Validate positions

**Hold Spawner/Manager._ready()** (if exists):
1. Create multiple holds in playfield
2. Set varying point values (10, 15, 20, 25, 30, etc.)
3. Position holds to avoid flippers and main ball paths
4. Connect hold signals to GameManager

**Ramp/Rail Manager._ready()** (if exists):
1. Create launcher ramp
2. Create playfield ramps
3. Create rails for ball guidance
4. Position ramps/rails appropriately

**UI._ready()**:
1. Find GameManager
2. Connect score_changed signal
3. Initialize score display

### 2.2 Ball Release Flow

**Player Presses Down Arrow**:
1. GameManager detects release_ball input
2. Check if BallQueue has balls
3. Call `BallQueue.release_next_ball()` (new method)
4. Ball unfreezes and becomes active
5. Ball positioned at queue location (e.g., x=400, y=100)
6. Ball falls naturally with gravity to launcher
7. Connect ball_lost signal
8. Ball reaches launcher area

**Ball Arrives at Launcher**:
1. Launcher detects ball arrival (position check or Area2D)
2. Launcher positions ball at launch position
3. Ball frozen at launcher position
4. Wait for player to charge launcher (Space key)

**Player Launches Ball**:
1. Player holds Space to charge launcher
2. Launcher charges from 0.0 to 1.0
3. Player releases Space to launch
4. Ball unfreezes and receives launch force
5. Ball travels through launcher ramp to playfield

## 3. Gameplay Loop

### 3.1 Active Gameplay

**Frame-by-Frame (60 FPS)**:

**Input Processing**:
- Check flipper input (Left Arrow/A, Right Arrow/D)
- Update flipper target angles
- Check ball release input (Down Arrow)
- Check launcher charge input (Space)
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

**Ball-Hold Interaction**:
1. Ball enters hold Area2D
2. Area2D body_entered signal triggered
3. Hold checks if ball is valid
4. Award points (final scoring for ball)
5. Emit hold_entered signal
6. Ball removed from playfield
7. GameManager prepares next ball

**Ball-Ramp Interaction**:
1. Ball collides with ramp StaticBody2D
2. Physics engine calculates bounce/slide
3. Ball trajectory adjusted by ramp angle
4. Ball continues movement along ramp path

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

**Hold Entry Flow**:
```
Ball enters Hold
  ↓
Hold._on_body_entered()
  ↓
Hold checks if ball is valid
  ↓
Hold.hold_entered signal emitted (points)
  ↓
GameManager._on_hold_entered(points)
  ↓
GameManager.add_score(points)
  ↓
GameManager.score_changed signal emitted
  ↓
UI._on_score_changed(new_score)
  ↓
ScoreLabel text updated
  ↓
Ball removed from playfield
  ↓
GameManager prepares next ball
```

## 4. Ball Lifecycle

### 4.1 Ball States

**Queued State**:
- `freeze = true`
- `gravity_scale = 0.0`
- `modulate = Color(1, 1, 1, 0.8)` (semi-transparent)
- Positioned in queue
- No physics active

**Released State** (Activating):
- `release_next_ball()` called (Down Arrow pressed)
- Ball removed from queue
- Queue positions updated
- `freeze = false`
- `gravity_scale = 1.0`
- `modulate = Color(1, 1, 1, 1)` (fully opaque)
- Positioned at queue location (top area)
- Physics active
- Falls with gravity to launcher

**At Launcher State**:
- Ball reaches launcher area
- Ball positioned at launcher position
- Ball frozen (`freeze = true`) at launcher
- Waiting for player to charge and launch

**Launched State**:
- Player launches ball (Space key released)
- Ball unfrozen (`freeze = false`)
- Ball receives launch force
- Ball travels through launcher ramp

**Playing State**:
- Ball moving in playfield
- Interacting with flippers, obstacles, walls, holds, ramps
- Scoring points (continuous from obstacles)
- Physics fully active

**In Hold State**:
- Ball enters hold Area2D
- Final scoring awarded
- Ball marked for removal
- `hold_entered` signal emitted

**Lost State**:
- Ball falls below flippers (below y threshold)
- `ball_lost` signal emitted
- Ball marked for removal

**Removed State**:
- Ball disconnected from signals
- Ball queue_free() called
- Ball removed from scene

### 4.2 Ball Transition Flow

```
Queued → Released → At Launcher → Launched → Playing → In Hold/Lost → Removed
  ↑                                                                          ↓
  └────────────────────────── Next Ball ────────────────────────────────────┘
```

## 5. Ball Loss and Recovery

### 5.1 Ball Loss Detection

**Detection Method**:
- Check in `Ball._physics_process()`
- If `global_position.y > respawn_y_threshold` (800)
- Emit `ball_lost` signal

**Hold Entry Handling**:
```
Ball enters Hold
  ↓
Hold.hold_entered signal emitted (points)
  ↓
GameManager._on_hold_entered(points)
  ↓
Award final score
  ↓
Remove ball (queue_free())
  ↓
Wait 1 second
  ↓
GameManager waits for next ball release
```

**Ball Loss Handling**:
```
Ball falls below flippers (y threshold)
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
GameManager waits for next ball release (Down Arrow)
```

### 5.2 Queue Management

**Queue Empty Handling**:
```
BallQueue.release_next_ball() called
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
          GameManager waits for next ball release (Down Arrow)
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
Initializing → Waiting for Release
  (After initialization complete)

Waiting for Release → Ball at Launcher
  (Down Arrow pressed, ball released from queue)

Ball at Launcher → Playing
  (Ball launched from launcher)

Playing → Paused
  (Esc pressed)

Paused → Playing
  (Esc pressed again)

Playing → Ball Ended
  (Ball enters hold or falls below threshold)

Ball Ended → Waiting for Release
  (After delay, ready for next ball release)

Playing → Game Over (Future)
  (Queue empty, no more balls, no auto-refill)
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

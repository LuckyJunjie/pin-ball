# Pinball Game - Requirements Specification

## 1. Functional Requirements

### 1.1 Core Gameplay

#### FR-1.1: Ball Physics
- **FR-1.1.1**: The ball must use RigidBody2D physics with realistic gravity (980.0 units/s²)
- **FR-1.1.2**: Ball must have bounce coefficient of 0.8 for realistic collisions
- **FR-1.1.3**: Ball must have friction coefficient of 0.3
- **FR-1.1.4**: Ball must have mass of 0.5 units
- **FR-1.1.5**: Ball must have linear damping of 0.05 and angular damping of 0.05
- **FR-1.1.6**: Ball must be circular with radius of 8 pixels
- **FR-1.1.7**: Ball must be visually represented as a red circle (Color: 1, 0.2, 0.2, 1)

#### FR-1.2: Flippers
- **FR-1.2.1**: Two flippers must be present (left and right)
- **FR-1.2.2**: Left flipper must be controlled by Left Arrow key or A key
- **FR-1.2.3**: Right flipper must be controlled by Right Arrow key or D key
- **FR-1.2.4**: Flippers must rotate only when button is pressed (not automatically)
- **FR-1.2.5**: Flippers must start at rest angle of 45° from vertical for easier ball hitting
  - Left flipper: rest_angle = -45°, pressed_angle = -90°
  - Right flipper: rest_angle = 45°, pressed_angle = 90°
- **FR-1.2.6**: Flippers must smoothly return to rest position when button is released
- **FR-1.2.7**: Flippers must have rotation speed of 20.0 degrees/second
- **FR-1.2.8**: Flippers must be baseball bat-shaped (ConvexPolygonShape2D)
  - Narrow handle at base (12px wide)
  - Wider hitting surface at tip (28px wide)
  - Length: 64px
- **FR-1.2.9**: Flippers must have bounce coefficient of 0.6 and friction of 0.5
- **FR-1.2.10**: Flippers must be positioned at y=564-567, with left at x=332 and right at x=454

#### FR-1.3: Ball Queue System
- **FR-1.3.1**: Ball queue must display 4 standby balls
- **FR-1.3.2**: Ball queue must be positioned on the right side of the screen (x=720, y=100)
- **FR-1.3.3**: Balls in queue must be stacked vertically with 25 pixel spacing
- **FR-1.3.4**: Queued balls must be frozen (physics disabled) and semi-transparent (opacity 0.8)
- **FR-1.3.5**: When a ball is released (Down Arrow), it must fall through visible pipe guide to launcher
- **FR-1.3.6**: When queue is empty, it must automatically refill (infinite balls mode)
- **FR-1.3.7**: Released ball must be positioned at pipe entry (y=120) and fall through pipe to launcher

#### FR-1.3A: Pipe Guide System
- **FR-1.3A.1**: Visible pipe/chute must guide ball from queue (720, 100) to launcher (720, 450)
- **FR-1.3A.2**: Pipe must have left and right collision walls (5px wide each) to contain ball
- **FR-1.3A.3**: Pipe must have back barrier at top to prevent ball from going back up
- **FR-1.3A.4**: Pipe width must be 35px (wider than ball diameter ~16px)
- **FR-1.3A.5**: Pipe must have low friction physics material (friction 0.1, bounce 0.3)
- **FR-1.3A.6**: Ball must slide naturally through pipe to launcher position

#### FR-1.4: Ball Launching
- **FR-1.4.1**: Ball must drop from queue position on right side (x=720, y=100)
- **FR-1.4.2**: Ball must fall through visible pipe guide to launcher (x=720, y=450)
- **FR-1.4.3**: Ball must be launched from launcher with curved ramp guiding toward center
- **FR-1.4.4**: Launcher must have charge mechanism (Space key) to control launch force
- **FR-1.4.5**: Launch angle must be -15° (toward center of playfield)

#### FR-1.5: Playfield Boundaries
- **FR-1.5.1**: Playfield must be 800x600 pixels
- **FR-1.5.2**: Four walls must enclose the playfield:
  - Top wall: 800x20 pixels at y=10
  - Left wall: 20x600 pixels at x=10
  - Right wall: 20x600 pixels at x=790
  - Bottom wall: Split into left (350px) and right (350px) sections with gap (100px) at center
- **FR-1.5.3**: All walls must have bounce coefficient of 0.7 and friction of 0.3
- **FR-1.5.4**: Ball must not be able to escape horizontal boundaries
- **FR-1.5.5**: Ball must be able to fall through bottom gap to complete round
- **FR-1.5.6**: Boundary detection must automatically correct if ball escapes horizontally or at top
- **FR-1.5.7**: Background must be 70% transparent (30% opacity) to reduce visual interference

#### FR-1.6: Obstacles
- **FR-1.6.1**: 8 obstacles must be randomly placed per game
- **FR-1.6.2**: Sports-themed obstacle types must exist:
  - **Basketball Hoop**: Large circular obstacle (radius 30px, 20 points, bounce 0.95)
    - Visual: Orange hoop on brown pole (60x60px sprite)
  - **Baseball Player**: Small obstacle (radius 8px, 5 points, bounce 0.8)
    - Visual: Dark blue player silhouette (20x40px sprite)
  - **Baseball Bat**: Rectangular obstacle (40x12px, 15 points, bounce 0.85, random rotation)
    - Visual: Brown bat shape (40x12px sprite)
  - **Soccer Goal**: Medium obstacle (50x30px, 25 points, bounce 0.9, random rotation)
    - Visual: White goal posts with net pattern (50x30px sprite)
- **FR-1.6.3**: Obstacles must avoid flipper zones and launcher area
- **FR-1.6.4**: Obstacles must have minimum 50px distance from walls
- **FR-1.6.5**: Obstacles must have minimum 80px distance between each other
- **FR-1.6.6**: Obstacles must award points on collision with 0.5s cooldown
- **FR-1.6.7**: Obstacles must use sports-themed sprites instead of generic rectangles

### 1.2 Scoring System

#### FR-2.1: Score Tracking
- **FR-2.1.1**: Score must be displayed in top-left corner of screen
- **FR-2.1.2**: Score must increment when ball hits obstacles:
  - Basketball hoops: +20 points
  - Baseball players: +5 points
  - Baseball bats: +15 points
  - Soccer goals: +25 points
- **FR-2.1.3**: Score must increment when ball enters holds:
  - Holds have varying point values (10, 15, 20, 25, 30, etc.)
  - Hold scoring finalizes the ball's score for that ball
  - Ball round ends when ball enters hold
- **FR-2.1.4**: Score must persist during gameplay
- **FR-2.1.5**: Score must reset when game restarts

### 1.3 Game State Management

#### FR-3.1: Game States
- **FR-3.1.1**: Game must support playing state
- **FR-3.1.2**: Game must support paused state (Esc key)
- **FR-3.1.3**: Pause must freeze entire game tree
- **FR-3.1.4**: Game must handle ball lost state (ball falls below y=800)

#### FR-3.2: Ball Management
- **FR-3.2.1**: Only one ball may be active at a time
- **FR-3.2.2**: When ball is lost, 1 second delay before next ball activates
- **FR-3.2.3**: Next ball must come from queue automatically

### 1.4 User Interface

#### FR-4.1: UI Elements
- **FR-4.1.1**: Score label must be visible in top-left (font size 32)
- **FR-4.1.2**: Instructions label must be visible below score (font size 16)
- **FR-4.1.3**: Charge meter must be visible when launcher is active (if implemented)
- **FR-4.1.4**: All UI elements must be on CanvasLayer for proper rendering

#### FR-4.2: Visual Feedback
- **FR-4.2.1**: Queued balls must be visually distinct (semi-transparent)
- **FR-4.2.2**: Active ball must be fully opaque
- **FR-4.2.3**: Flippers must visually rotate when activated

### 1.5 Sound Effects System

#### FR-5.1: Sound Effects Implementation
- **FR-5.1.1**: Sound effect system must be implemented using Godot's AudioStreamPlayer nodes
- **FR-5.1.2**: Sound files must be placed in `assets/sounds/` directory
- **FR-5.1.3**: Required sound effects:
  - Flipper click sound (plays when flipper activates)
  - Ball hit obstacle sound (plays when ball collides with obstacle)
  - Ball launch sound (plays when launcher hits ball)
  - Ball fall to hold sound (plays when ball enters a hold)
  - Ball lost sound (plays when ball falls to bottom)
- **FR-5.1.4**: Sound effects must be configurable (volume, enable/disable)
- **FR-5.1.5**: Sound effects must not interrupt gameplay or cause lag

### 1.6 Launcher System Redesign

#### FR-6.1: Launcher Positioning
- **FR-6.1.1**: Launcher must be positioned below the ball queue on right side
- **FR-6.1.2**: Ball queue position: Top right area (x=720, y=100)
- **FR-6.1.3**: Launcher position: Bottom right area (x=720, y=450)
- **FR-6.1.4**: Visible pipe/chute must guide ball from queue to launcher

#### FR-6.2: Pipe Guide System
- **FR-6.2.1**: Visible pipe/chute must connect queue (720, 100) to launcher (720, 450)
- **FR-6.2.2**: Pipe must have left and right collision walls to contain ball
- **FR-6.2.3**: Pipe width must be 35px (wider than ball diameter)
- **FR-6.2.4**: Pipe must have low friction physics material (friction 0.1, bounce 0.3)
- **FR-6.2.5**: Pipe must have visual representation (brown/tan appearance)
- **FR-6.2.6**: Ball must slide naturally through pipe to launcher position

#### FR-6.3: Ball Release Mechanism
- **FR-6.3.1**: Down Arrow key must release ball from queue
- **FR-6.3.2**: When Down Arrow is pressed, next ball from queue unfreezes and falls through pipe
- **FR-6.3.3**: Ball must be positioned at pipe entry (y=120) when released
- **FR-6.3.4**: Ball must fall naturally with gravity through pipe to launcher
- **FR-6.3.5**: Launcher must automatically detect and position ball when ball arrives at launcher
- **FR-6.3.6**: Space key remains for charging and launching ball from launcher

### 1.7 Holds (Target Holes) System

#### FR-7.1: Holds Implementation
- **FR-7.1.1**: Multiple holds (target holes) must be placed in the playfield
- **FR-7.1.2**: Holds must have varying point values (10, 15, 20, 25, 30, etc.)
- **FR-7.1.3**: Holds must use Area2D for detection when ball enters
  - Area2D collision_mask = 1 (detect ball layer)
  - Area2D collision_layer = 0 (detection only)
- **FR-7.1.4**: When ball enters a hold:
  - Ball must freeze and position at hold center
  - Ball's scoring is finalized and points are awarded
  - Visual feedback delay (0.5s) before ball removal
- **FR-7.1.5**: After ball enters hold, ball round ends and next ball is prepared
- **FR-7.1.6**: Holds must have visual indicators showing point values
- **FR-7.1.7**: Holds must be positioned to avoid interference with flippers and main ball paths
- **FR-7.1.8**: Only one ball can be captured per hold (subsequent entries ignored)

### 1.8 Ramps and Rails System

#### FR-8.1: Launcher Ramp
- **FR-8.1.1**: Launcher must have curved ramp component attached
- **FR-8.1.2**: Ramp must guide ball from launcher toward center of playfield
- **FR-8.1.3**: Ramp must use spline-based curve (not straight rectangle)
  - Multiple SegmentShape2D shapes forming smooth curve
  - Catmull-Rom interpolation for smooth transitions
  - Visual representation using Line2D
- **FR-8.1.4**: Launch angle must be -15° (toward center)
- **FR-8.1.5**: Ramp angle and curve must be configured for proper ball trajectory

#### FR-8.2: Playfield Ramps and Rails
- **FR-8.2.1**: Multiple curved ramps must be placed in playfield to guide ball movement
- **FR-8.2.2**: Ramps must use spline-based curves instead of straight rectangles
- **FR-8.2.3**: Ramps must guide ball toward center of playfield
- **FR-8.2.4**: Ramps must guide ball toward bottom narrow space (flipper area)
- **FR-8.2.5**: Ramps positioned to guide ball from launcher (right side) to center
- **FR-8.2.6**: Bottom area must have sufficient space for flippers to hit ball
- **FR-8.2.7**: Ramps must not completely cover bottom area - flippers must have clear access

### 1.9 Updated Game Flow

#### FR-9.1: Game Start Flow
- **FR-9.1.1**: Game starts with ball in queue
- **FR-9.1.2**: Player presses Down Arrow to release ball from queue
- **FR-9.1.3**: Ball falls to launcher
- **FR-9.1.4**: Player charges launcher (Space key) and releases to launch ball
- **FR-9.1.5**: Ball travels through launcher ramp to playfield

#### FR-9.2: Gameplay Flow
- **FR-9.2.1**: Ball interacts with obstacles (scores points on hit)
- **FR-9.2.2**: Ball interacts with holds (scores final points and ends ball life)
- **FR-9.2.3**: Ball can hit walls (scores points)
- **FR-9.2.4**: Ball travels through ramps and rails to bottom area
- **FR-9.2.5**: Flippers can hit ball from bottom area (not covered by ramp)
- **FR-9.2.6**: Ball can be hit by flippers back into playfield if timing is correct

#### FR-9.3: Ball End Conditions
- **FR-9.3.1**: Ball enters a hold → final scoring, next ball prepared
- **FR-9.3.2**: Ball falls to bottom (below flippers) → ball finished, wait for next ball launch

### 1.10 Debug System

#### FR-10.1: Debug Configuration
- **FR-10.1.1**: Debug mode must be configurable (enable/disable)
- **FR-10.1.2**: Debug configuration must be accessible globally (singleton or GameManager)
- **FR-10.1.3**: Debug mode can be enabled via @export variable or project setting
- **FR-10.1.4**: Debug mode state must persist during gameplay session
- **FR-10.1.5**: Debug configuration must be easily toggleable for development

#### FR-10.2: Debug Logging
- **FR-10.2.1**: Key operations must have debug logs when debug mode is enabled
- **FR-10.2.2**: Debug logs must use consistent format: `[ComponentName] Message`
- **FR-10.2.3**: Key operations requiring logging:
  - **GameManager**: Ball spawn/loss, score changes, state transitions, component initialization
  - **Ball**: Position updates (periodic), boundary corrections, state changes (queued/active/lost)
  - **Flipper**: Activation/deactivation, rotation angle changes, collision events
  - **Launcher**: Ball assignment, charge updates, launch events
  - **BallQueue**: Queue initialization, ball retrieval, queue refill
  - **Obstacle**: Collision detection, score awarding, cooldown state
  - **Hold**: Ball entry detection, score awarding, ball removal
  - **Ramp**: Ball interaction events
- **FR-10.2.4**: Error and warning logs (push_error, push_warning) must always print regardless of debug mode
- **FR-10.2.5**: Debug logs must not impact performance when debug mode is disabled

#### FR-10.3: Visual Debug Labels
- **FR-10.3.1**: All entities must have visual name labels when debug mode is enabled
- **FR-10.3.2**: Visual labels must be hidden when debug mode is disabled
- **FR-10.3.3**: Entities requiring debug labels:
  - Ball (shows "BALL")
  - BallQueue (shows "BALL QUEUE")
  - Launcher (shows "LAUNCHER")
  - Obstacle (shows "OBSTACLE" + type)
  - Flipper (shows "FLIPPER" + side)
  - Hold (shows "HOLD" + point value)
  - Ramp (shows "RAMP")
  - Rail (shows "RAIL")
- **FR-10.3.4**: Visual labels must have consistent styling (font, size, color, outline)
- **FR-10.3.5**: Visual labels must not obstruct gameplay when visible
- **FR-10.3.6**: Existing add_visual_label() methods must respect debug mode setting

## 2. Non-Functional Requirements

### 2.1 Performance

#### NFR-1.1: Frame Rate
- **NFR-1.1.1**: Game must maintain 60 FPS on target hardware
- **NFR-1.1.2**: Physics calculations must not cause frame drops

#### NFR-1.2: Responsiveness
- **NFR-1.2.1**: Flipper input must respond within 1 frame (16ms at 60 FPS)
- **NFR-1.2.2**: Ball physics must update smoothly without stuttering

### 2.2 Usability

#### NFR-2.1: Controls
- **NFR-2.1.1**: Controls must be intuitive and responsive
- **NFR-2.1.2**: Control instructions must be visible in-game
- **NFR-2.1.3**: Controls must use standard keyboard keys

#### NFR-2.2: Visual Clarity
- **NFR-2.2.1**: All game elements must be clearly visible
- **NFR-2.2.2**: Ball queue must be clearly visible on right side
- **NFR-2.2.3**: Score and UI elements must not obstruct gameplay

### 2.3 Code Quality

#### NFR-3.1: Maintainability
- **NFR-3.1.1**: Code must be well-commented
- **NFR-3.1.2**: Scripts must follow Godot naming conventions
- **NFR-3.1.3**: Scene structure must be organized and logical

#### NFR-3.2: Extensibility
- **NFR-3.2.1**: System must support adding new obstacle types
- **NFR-3.2.2**: Scoring system must be extensible
- **NFR-3.2.3**: Component architecture must allow for feature additions

## 3. Game Flow Requirements

### 3.1 Initialization

1. Game loads Main.tscn
2. GameManager initializes
3. BallQueue creates 4 standby balls (positioned at top area)
4. Launcher initializes (positioned below queue)
5. ObstacleSpawner places 8 obstacles
6. Holds are placed in playfield
7. Ramps and rails are placed in playfield
8. Game waits for player to release ball from queue

### 3.2 Game Start Flow

1. Player presses Down Arrow to release ball from queue
2. Ball unfreezes and falls to launcher
3. Launcher positions ball at launch position
4. Player charges launcher (Space key) and releases to launch ball
5. Ball travels through launcher ramp to playfield

### 3.3 Gameplay Loop

1. Ball interacts with obstacles (scores points on hit)
2. Ball interacts with holds (scores final points, ends ball life, next ball prepared)
3. Ball can hit walls (scores points)
4. Ball travels through ramps and rails to bottom area
5. Flippers can hit ball from bottom area (not covered by ramp)
6. Ball can be hit by flippers back into playfield if timing is correct
7. If ball falls below flippers, ball is finished
8. After delay, next ball can be released from queue

### 3.4 Ball End Conditions

1. Ball enters a hold → final scoring awarded, ball removed, next ball prepared
2. Ball falls to bottom (below flippers) → ball finished, wait for next ball release

### 3.5 Pause Flow

1. Player presses Esc
2. Game tree pauses
3. All physics and input freeze
4. Player presses Esc again to unpause


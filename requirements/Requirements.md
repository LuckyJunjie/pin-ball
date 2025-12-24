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
- **FR-1.2.5**: Flippers must rotate from rest angle (0°) to pressed angle (±45°) when activated
- **FR-1.2.6**: Flippers must smoothly return to rest position when button is released
- **FR-1.2.7**: Flippers must have rotation speed of 20.0 degrees/second
- **FR-1.2.8**: Flippers must be rectangular (60x12 pixels)
- **FR-1.2.9**: Flippers must have bounce coefficient of 0.6 and friction of 0.5
- **FR-1.2.10**: Flippers must be positioned at y=550, with left at x=200 and right at x=600

#### FR-1.3: Ball Queue System
- **FR-1.3.1**: Ball queue must display 4 standby balls
- **FR-1.3.2**: Ball queue must be positioned on the right side of the screen (x=750, y=300)
- **FR-1.3.3**: Balls in queue must be stacked vertically with 25 pixel spacing
- **FR-1.3.4**: Queued balls must be frozen (physics disabled) and semi-transparent (opacity 0.8)
- **FR-1.3.5**: When a ball is lost, the next ball from queue must automatically activate
- **FR-1.3.6**: When queue is empty, it must automatically refill
- **FR-1.3.7**: Active ball must be positioned at queue location and fall naturally to middle of playfield

#### FR-1.4: Ball Launching
- **FR-1.4.1**: Ball must drop from queue position on right side (x=750, y=300)
- **FR-1.4.2**: Ball must fall naturally with gravity to middle of playfield
- **FR-1.4.3**: No manual launcher required for initial ball drop
- **FR-1.4.4**: (Optional) Launcher mechanism may be available for re-launching balls

#### FR-1.5: Playfield Boundaries
- **FR-1.5.1**: Playfield must be 800x600 pixels
- **FR-1.5.2**: Four walls must enclose the playfield:
  - Top wall: 800x20 pixels at y=10
  - Left wall: 20x600 pixels at x=10
  - Right wall: 20x600 pixels at x=790
  - Bottom wall: 800x20 pixels at y=590
- **FR-1.5.3**: All walls must have bounce coefficient of 0.7 and friction of 0.3
- **FR-1.5.4**: Ball must not be able to escape playfield boundaries
- **FR-1.5.5**: Boundary detection must automatically correct if ball escapes

#### FR-1.6: Obstacles
- **FR-1.6.1**: 8 obstacles must be randomly placed per game
- **FR-1.6.2**: Three obstacle types must exist:
  - **Bumpers**: Large circular obstacles (radius 30px, 20 points, bounce 0.95)
  - **Pegs**: Small circular obstacles (radius 8px, 5 points, bounce 0.8)
  - **Walls**: Rectangular obstacles (40x10px, 15 points, bounce 0.85, random rotation)
- **FR-1.6.3**: Obstacles must avoid flipper zones and launcher area
- **FR-1.6.4**: Obstacles must have minimum 50px distance from walls
- **FR-1.6.5**: Obstacles must have minimum 80px distance between each other
- **FR-1.6.6**: Obstacles must award points on collision with 0.5s cooldown

### 1.2 Scoring System

#### FR-2.1: Score Tracking
- **FR-2.1.1**: Score must be displayed in top-left corner of screen
- **FR-2.1.2**: Score must increment when ball hits obstacles:
  - Bumpers: +20 points
  - Pegs: +5 points
  - Walls: +15 points
- **FR-2.1.3**: Score must persist during gameplay
- **FR-2.1.4**: Score must reset when game restarts

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
3. BallQueue creates 4 standby balls
4. ObstacleSpawner places 8 obstacles
5. First ball activates and drops from queue

### 3.2 Gameplay Loop

1. Ball drops from queue on right side
2. Ball falls to middle of playfield
3. Player uses flippers to keep ball in play
4. Ball hits obstacles and scores points
5. If ball falls below y=800, ball is lost
6. After 1 second delay, next ball activates from queue
7. Repeat until queue is empty
8. Queue refills automatically

### 3.3 Pause Flow

1. Player presses Esc
2. Game tree pauses
3. All physics and input freeze
4. Player presses Esc again to unpause


# Pinball Game - Game Design Document (GDD)

## Document Information

- **Game Title**: Pinball
- **Version**: 1.0
- **Last Updated**: 2024
- **Engine**: Godot 4.5
- **Platform**: Desktop (Windows, macOS, Linux)

---

## 1. Game Overview

### 1.1 Game Concept

Pinball is a classic arcade-style pinball game that recreates the authentic pinball machine experience in a digital format. Players control flippers to keep a ball in play, hitting obstacles to score points. The game features realistic physics, multiple ball lives, and a dynamic obstacle system.

### 1.2 Game Vision

To create an engaging, physics-based pinball experience that captures the excitement and skill-based gameplay of classic pinball machines while leveraging modern game engine capabilities for smooth, responsive gameplay.

### 1.3 Target Audience

- **Primary**: Casual gamers who enjoy arcade-style games
- **Secondary**: Pinball enthusiasts and retro game fans
- **Tertiary**: Players seeking quick, skill-based gameplay sessions

### 1.4 Platform & Engine

- **Engine**: Godot Engine 4.5
- **Platform**: Desktop (Windows, macOS, Linux)
- **Input**: Keyboard
- **Display**: 800x600 pixels

### 1.5 Core Gameplay Loop

1. Ball drops from queue on the right side of the playfield
2. Ball falls naturally with gravity into the play area
3. Player uses flippers to keep the ball in play
4. Ball hits obstacles and awards points
5. Player attempts to keep the ball alive as long as possible
6. When ball is lost, next ball automatically activates from queue
7. Repeat until all balls are used (queue refills automatically)

---

## 2. Gameplay Mechanics

### 2.1 Core Mechanics

#### Ball Physics
- Realistic physics-based movement using RigidBody2D
- Gravity: 980.0 units/s² (standard Earth gravity)
- Bounce coefficient: 0.8 for realistic collisions
- Friction: 0.3 for smooth movement
- Mass: 0.5 units
- Damping: 0.05 linear and angular to prevent infinite bouncing
- Circular shape with 8-pixel radius
- Visual: Red circle

#### Flipper Control
- Two flippers (left and right) at the bottom of the playfield
- Rotate from rest position (0°) to pressed position (±45°)
- Only rotate when button is pressed (not automatic)
- Smooth rotation at 20.0 degrees/second
- Return to rest position when button is released
- Position: Left at x=200, Right at x=600, both at y=550
- Visual: Light blue rectangular paddles (60x12 pixels)

#### Ball Queue System
- Displays 4 standby balls on the right side of screen
- Balls stacked vertically with 25-pixel spacing
- Queued balls are frozen (physics disabled) and semi-transparent (80% opacity)
- When a ball is lost, next ball automatically activates
- Queue automatically refills when empty
- Active ball drops from queue position (x=750, y=300) and falls naturally

#### Obstacle System
- 8 obstacles randomly placed per game
- Three obstacle types:
  - **Bumpers**: Large circular (30px radius), 20 points, high bounce (0.95)
  - **Pegs**: Small circular (8px radius), 5 points, medium bounce (0.8)
  - **Walls**: Rectangular (40x10px), 15 points, high bounce (0.85), random rotation
- Obstacles avoid flipper zones and launcher area
- Minimum 50px distance from playfield walls
- Minimum 80px distance between obstacles
- 0.5-second cooldown between scoring hits

### 2.2 Scoring System

#### Point Values
- **Bumpers**: 20 points per hit
- **Pegs**: 5 points per hit
- **Obstacle Walls**: 15 points per hit

#### Score Display
- Score shown in top-left corner of screen
- Updates immediately when obstacles are hit
- Persists during gameplay
- Resets when game restarts

### 2.3 Game States

#### Playing State
- Physics active
- Input processing enabled
- Ball active and moving
- Score tracking active

#### Paused State
- Entire game tree frozen
- All physics stopped
- Input processing paused (except Esc to unpause)
- UI remains visible

#### Ball Lost State
- Ball falls below y=800 threshold
- 1-second delay before next ball activates
- Next ball automatically comes from queue

---

## 3. Game World & Level Design

### 3.1 Playfield Layout

- **Dimensions**: 800x600 pixels
- **Background**: Dark blue-gray (0.1, 0.1, 0.2, 1)
- **Boundaries**: Four walls enclose the playfield:
  - Top wall: 800x20 pixels at y=10
  - Left wall: 20x600 pixels at x=10
  - Right wall: 20x600 pixels at x=790
  - Bottom wall: 800x20 pixels at y=590

### 3.2 Obstacle Placement

- **Placement Rules**:
  - Random placement at game start
  - Avoid flipper zones (x: 150-250, 550-650, y: 500-600)
  - Avoid launcher zone (x: 350-450, y: 550-600)
  - Minimum 50px from playfield walls
  - Minimum 80px between obstacles
- **Distribution**: Mix of all three obstacle types

### 3.3 Boundary System

- Ball cannot escape playfield boundaries
- Automatic boundary enforcement if ball escapes
- Boundary limits:
  - Left: x = 20.0
  - Right: x = 780.0
  - Top: y = 20.0
  - Bottom: y = 580.0

---

## 4. Game Objects & Entities

### 4.1 Ball

- **Type**: Dynamic physics object (RigidBody2D)
- **Shape**: Circle (8-pixel radius)
- **Physics**:
  - Mass: 0.5
  - Gravity scale: 1.0
  - Linear damping: 0.05
  - Angular damping: 0.05
  - Bounce: 0.8
  - Friction: 0.3
- **Visual**: Red circle (Color: 1, 0.2, 0.2, 1)
- **States**:
  - Queued: Frozen, semi-transparent (80% opacity)
  - Active: Physics enabled, fully opaque
  - Lost: Falls below y=800

### 4.2 Flippers

- **Type**: Kinematic physics object (RigidBody2D, frozen)
- **Shape**: Rectangle (60x12 pixels)
- **Physics**:
  - Mass: 1.0
  - Gravity scale: 0.0
  - Freeze: true (kinematic control)
  - Bounce: 0.6
  - Friction: 0.5
- **Visual**: Light blue rectangle (Color: 0.2, 0.6, 1, 1)
- **Rotation**:
  - Rest angle: 0°
  - Pressed angle: -45° (left), +45° (right)
  - Rotation speed: 20.0 degrees/second
- **Position**: Left at (200, 550), Right at (600, 550)

### 4.3 Obstacles

#### Bumpers
- **Type**: Static obstacle (StaticBody2D)
- **Shape**: Circle (30-pixel radius)
- **Points**: 20
- **Physics**: Bounce 0.95, Friction 0.2
- **Visual**: Yellow or bright color

#### Pegs
- **Type**: Static obstacle (StaticBody2D)
- **Shape**: Circle (8-pixel radius)
- **Points**: 5
- **Physics**: Bounce 0.8, Friction 0.3
- **Visual**: White or light color

#### Obstacle Walls
- **Type**: Static obstacle (StaticBody2D)
- **Shape**: Rectangle (40x10 pixels)
- **Points**: 15
- **Physics**: Bounce 0.85, Friction 0.3
- **Rotation**: Random (0-360°)
- **Visual**: Gray

### 4.4 Walls

- **Type**: Static boundary (StaticBody2D)
- **Shapes**: Four rectangular walls enclosing playfield
- **Physics**: Bounce 0.7, Friction 0.3
- **Visual**: Gray-blue (Color: 0.3, 0.3, 0.4, 1)
- **Purpose**: Keep ball within playfield boundaries

---

## 5. User Interface

### 5.1 UI Layout

- **Playfield Area**: 800x600 pixels (main game area)
- **UI Overlay**: CanvasLayer on top of playfield
- **Layout Structure**:
  - Score: Top-left corner (20, 20)
  - Instructions: Below score (20, 70)
  - Ball Queue: Right side of playfield (750, 300)

### 5.2 UI Elements

#### Score Label
- **Position**: Top-left corner
- **Offset**: (20, 20) from top-left
- **Size**: 180x40 pixels
- **Font Size**: 32
- **Color**: White
- **Text**: "Score: {score}"
- **Behavior**: Updates immediately when score changes

#### Instructions Label
- **Position**: Below score label
- **Offset**: (20, 70) from top-left
- **Size**: 380x80 pixels
- **Font Size**: 16
- **Color**: Light gray
- **Text**: Multi-line control instructions
- **Content**: 
  - "Left/A: Left Flipper"
  - "Right/D: Right Flipper"
  - "Hold Space/Down: Charge Launcher"
  - "Esc: Pause"

#### Ball Queue (Visual Element)
- **Position**: Right side of playfield
- **Location**: x=750, y=300 (center vertically)
- **Visual**: Stacked balls, semi-transparent (80% opacity)
- **Spacing**: 25 pixels between balls

### 5.3 Visual Feedback

- **Score Updates**: Immediate visual update when obstacles are hit
- **Ball States**: 
  - Queued balls: Semi-transparent (80% opacity)
  - Active ball: Fully opaque (100% opacity)
- **Flipper Activation**: Visual rotation when buttons pressed
- **Obstacle Hits**: Points awarded with cooldown to prevent spam

---

## 6. Controls & Input

### 6.1 Input Mapping

- **Left Flipper**: Left Arrow key or A key
- **Right Flipper**: Right Arrow key or D key
- **Launch Ball** (optional): Space or Down Arrow (hold to charge)
- **Pause**: Esc key

### 6.2 Control Scheme

- **Flipper Controls**: 
  - Press and hold to activate flipper
  - Release to return to rest position
  - Continuous input (pressed action)
- **Pause Control**:
  - Single press to pause/unpause
  - Instant action (just_pressed)

### 6.3 Input Behavior

- **Responsiveness**: Input must respond within 1 frame (16ms at 60 FPS)
- **Input Actions**: Configurable in project.godot
- **Input Types**:
  - Flippers: "pressed" actions (continuous while held)
  - Launch: "pressed" action (for charging)
  - Pause: "just_pressed" action (single activation)

---

## 7. Progression & Scoring

### 7.1 Scoring Mechanics

- **Scoring Method**: Points awarded when ball hits obstacles
- **Point Values**:
  - Bumpers: 20 points (high value, large target)
  - Obstacle Walls: 15 points (medium value, directional)
  - Pegs: 5 points (low value, small target)
- **Cooldown**: 0.5 seconds between scoring hits on same obstacle
- **Score Persistence**: Score maintained throughout gameplay session

### 7.2 Score Display

- **Location**: Top-left corner of screen
- **Format**: "Score: {number}"
- **Update**: Real-time updates on obstacle hits
- **Reset**: Score resets when game restarts

### 7.3 Progression Elements

- **Ball Lives**: 4 balls per queue (refills automatically)
- **Challenge**: Keep ball alive as long as possible to maximize score
- **Skill Factor**: Player skill affects score through:
  - Ball control via flippers
  - Strategic obstacle targeting
  - Timing and precision

---

## 8. Visual Design

### 8.1 Color Scheme

- **Background**: Dark blue-gray (0.1, 0.1, 0.2, 1)
- **Ball**: Red (1, 0.2, 0.2, 1)
- **Flippers**: Light blue (0.2, 0.6, 1, 1)
- **Walls**: Gray-blue (0.3, 0.3, 0.4, 1)
- **Bumpers**: Yellow or bright color
- **Pegs**: White or light color
- **Obstacle Walls**: Gray (0.5, 0.5, 0.5, 1)
- **Text**: White or light gray for high contrast

### 8.2 Art Style

- **Style**: Simple, clean geometric shapes
- **Rendering**: ColorRect-based visuals for fast rendering
- **Visual Hierarchy**:
  - Primary: Score, active ball, flippers (bright, fully opaque)
  - Secondary: Instructions, queued balls, obstacles (semi-transparent or medium colors)
  - Background: Playfield background, walls (dark, subtle)

### 8.3 Visual Feedback

- **Ball States**: Opacity changes (queued vs active)
- **Flipper Movement**: Visual rotation animation
- **Score Updates**: Immediate text updates
- **Obstacle Hits**: Points awarded (visual feedback via score update)

---

## 9. Technical Overview

### 9.1 Engine & Platform

- **Engine**: Godot Engine 4.5
- **Platform**: Desktop (Windows, macOS, Linux)
- **Renderer**: Forward Plus renderer
- **Physics**: Built-in Bullet-based physics engine

### 9.2 Performance Targets

- **Frame Rate**: 60 FPS
- **Input Latency**: < 16ms (1 frame at 60 FPS)
- **Physics**: Fixed timestep at 60 FPS
- **Rendering**: Smooth, no stuttering

### 9.3 Physics System

- **Gravity**: 980.0 units/s²
- **Physics Layers**: 
  - Layer 1: Ball
  - Layer 2: Flippers
  - Layer 4: Walls
  - Layer 8: Obstacles
- **Collision Detection**: Automatic via Godot physics engine
- **Physics Materials**: Configured per object type for realistic bounce and friction

### 9.4 Architecture

- **Pattern**: Component-based architecture
- **Communication**: Signal-based event system
- **Scene Structure**: Modular scenes for each game element
- **State Management**: GameManager coordinates game state

---

## 10. Audio Design

### 10.1 Current Status

Audio design is not yet implemented. This section is a placeholder for future enhancements.

### 10.2 Planned Audio Elements

- **Ball Collisions**: Bounce sounds for different surfaces
- **Obstacle Hits**: Distinct sounds for each obstacle type
- **Flipper Activation**: Mechanical flipper sound
- **Background Music**: Optional ambient pinball machine sounds
- **UI Feedback**: Subtle sound effects for score updates

---

## 11. Future Enhancements

### 11.1 Short-term Enhancements

- **Game Over Screen**: Display final score, restart option
- **High Score System**: Track and display best scores
- **Sound Effects**: Add audio feedback for collisions and actions
- **Particle Effects**: Visual effects on obstacle hits

### 11.2 Medium-term Enhancements

- **Multiple Playfields**: Different obstacle layouts
- **Power-ups**: Special effects or bonuses
- **Multi-ball Mode**: Multiple active balls simultaneously
- **Difficulty Levels**: Adjustable obstacle density and ball speed

### 11.3 Long-term Enhancements

- **Campaign Mode**: Progressive levels with increasing difficulty
- **Achievement System**: Unlockable achievements
- **Leaderboards**: Online score tracking
- **Custom Obstacle Layouts**: Player-created configurations

---

## 12. Game Flow Summary

### 12.1 Initialization

1. Game loads Main.tscn scene
2. GameManager initializes game state
3. BallQueue creates 4 standby balls
4. ObstacleSpawner places 8 obstacles randomly
5. First ball activates and drops from queue

### 12.2 Core Gameplay Loop

1. Ball drops from queue position (right side)
2. Ball falls naturally with gravity
3. Player uses flippers to control ball
4. Ball hits obstacles and scores points
5. Player attempts to keep ball in play
6. If ball falls below threshold, ball is lost
7. After 1-second delay, next ball activates
8. Queue refills automatically when empty
9. Repeat until player stops playing

### 12.3 State Transitions

- **Initializing → Playing**: After scene load and initialization
- **Playing → Paused**: Player presses Esc
- **Paused → Playing**: Player presses Esc again
- **Playing → Ball Lost**: Ball falls below y=800
- **Ball Lost → Playing**: After delay and next ball activation

---

## Appendix A: Design Principles

1. **Physics Realism**: Authentic pinball physics for engaging gameplay
2. **Responsiveness**: Instant input feedback for satisfying control
3. **Visual Clarity**: Clear distinction between game elements
4. **Accessibility**: Simple controls, visible instructions
5. **Extensibility**: Architecture supports future feature additions

---

## Appendix B: Reference Materials

- Technical implementation details: See [Technical-Design.md](Technical-Design.md)
- Component specifications: See [Component-Specifications.md](Component-Specifications.md)
- Physics details: See [Physics-Specifications.md](Physics-Specifications.md)
- UI/UX specifications: See [UI-Design.md](UI-Design.md)
- Game flow diagrams: See [Game-Flow.md](Game-Flow.md)


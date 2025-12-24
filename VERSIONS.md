# Version Documentation

This document provides detailed feature documentation for each version of the Pin-Ball game.

## Version 0.0.1 - Initial Release

**Release Date:** Initial baseline version

### Overview
A minimal, playable pinball game built with Godot Engine 4.5. This version establishes the core gameplay mechanics and basic physics system.

### Features

#### Core Gameplay
- **Ball Physics**: RigidBody2D-based ball with realistic physics
  - Gravity scale: 1.0
  - Linear damping: 0.05
  - Angular damping: 0.05
  - Mass: 0.5
  - Bounce coefficient: 0.8
  - Friction: 0.3

- **Flippers**: Two flippers (left and right) controlled by keyboard
  - Left flipper: A key or Left Arrow
  - Right flipper: D key or Right Arrow
  - Rotating RigidBody2D with torque-based movement
  - Rest angle: 0 degrees
  - Pressed angle: ±45 degrees
  - Rotation speed: 20.0 degrees/second

- **Ball Launch**: Simple launch mechanism
  - Trigger: Space key or Up Arrow
  - Launch force: Vector2(0, -500) to Vector2(0, -600)
  - Ball spawns at bottom center of playfield
  - Launch only works when ball is sleeping (at rest)

- **Boundaries**: Four walls enclosing the playfield
  - Top wall: 800x20 pixels at y=10
  - Left wall: 20x600 pixels at x=10
  - Right wall: 20x600 pixels at x=790
  - Bottom wall: 800x20 pixels at y=590
  - All walls have bounce: 0.7, friction: 0.3

#### Game Systems
- **Scoring**: Basic score tracking system
  - Score displayed in UI
  - Score can be incremented (extensible for future features)
  - Score resets when game resets

- **Ball Management**: Automatic ball respawn
  - Ball respawns when it falls below y=800
  - 1 second delay before respawn
  - Ball resets to initial position with zero velocity

- **Game State**: Pause functionality
  - Pause/Unpause: Esc key
  - Pauses entire game tree

#### User Interface
- **Score Display**: Label showing current score
- **Minimal UI**: Clean, simple interface

### Controls
- **Flipper Left**: Left Arrow / A
- **Flipper Right**: Right Arrow / D
- **Launch Ball**: Space / Up Arrow
- **Pause**: Esc

### Technical Architecture

#### Scene Structure
- `Main.tscn`: Main game scene containing:
  - GameManager node
  - Playfield with background and walls
  - Flippers (left and right)
  - UI layer with score display

#### Scripts
- `Ball.gd`: Ball physics, collision, and respawn logic
- `Flipper.gd`: Flipper input handling and rotation
- `GameManager.gd`: Game state, scoring, ball spawning
- `UI.gd`: UI and score display

#### Physics Layers
- Layer 1: Ball
- Layer 2: Flippers
- Layer 4: Walls

### Known Limitations
- Single ball at a time
- No ball queue system
- Simple launch mechanism (no visual launcher)
- No obstacles or bumpers
- Basic scoring system (no point values for different actions)
- No game over or win conditions

### Future Enhancements
- Game over/win conditions
- Sound effects and music
- Power-ups and special features
- Multiplayer support
- High score system

## Version 0.1.1 - Enhanced Gameplay

**Release Date:** Current version

### Overview
Major gameplay enhancements with visual launcher, ball queue system, random obstacles, and complete version control infrastructure.

### New Features

#### Visual Ball Launcher System
- **Plunger Mechanism**: Visual plunger that pulls back when charging
  - Charge by holding Space or Down Arrow
  - Charge rate: 2.0 per second (0.0 to 1.0)
  - Visual feedback: Plunger position and charge meter
  - Launch force: Base 500 to Max 1000 (proportional to charge)
  - Launcher position: (400, 570) at bottom center

#### Ball Queue System
- **Queue Management**: Visible queue of 4 standby balls
  - Balls stack vertically near launcher (position: 50, 300)
  - Queue spacing: 25 pixels between balls
  - Queued balls are frozen and semi-transparent
  - Automatic advancement when ball is lost
  - Queue auto-refills when empty

#### Enhanced Boundary System
- **Complete Enclosure**: Ball cannot escape playfield
  - Boundary detection with automatic correction
  - Boundary limits: Left 20, Right 780, Top 20, Bottom 580
  - Correction impulses applied if ball escapes
  - Safety mechanism prevents ball from leaving playfield

#### Random Static Obstacles
- **Dynamic Obstacle Placement**: 8 obstacles per game
  - **Obstacle Types**:
    - Bumpers: Large circular obstacles (20 points, 0.95 bounce)
    - Pegs: Small circular obstacles (5 points, 0.8 bounce)
    - Walls: Rectangular obstacles (15 points, 0.85 bounce, random rotation)
  - **Placement Algorithm**:
    - Random positions avoiding flipper zones
    - Minimum distance from walls: 50 pixels
    - Minimum distance between obstacles: 80 pixels
    - Avoid zones: Flipper areas, launcher area
  - **Scoring**: Points awarded on collision with cooldown (0.5s)

### Updated Controls
- **Flipper Left**: Left Arrow / A (unchanged)
- **Flipper Right**: Right Arrow / D (unchanged)
- **Charge Launcher**: Hold Space / Hold Down Arrow (changed from tap)
- **Pause**: Esc (unchanged)

### Technical Architecture

#### New Scene Structure
- `Launcher.tscn`: Visual plunger launcher with charge meter
- `BallQueue.tscn`: Ball queue display and management
- `Obstacle.tscn`: Obstacle prefab with collision detection

#### New Scripts
- `Launcher.gd`: Plunger charge mechanics and visual feedback
- `BallQueue.gd`: Queue management and ball state handling
- `Obstacle.gd`: Obstacle collision detection and scoring
- `ObstacleSpawner.gd`: Random obstacle placement algorithm
- `release.sh`: Automated version release script
- `build.sh`: Binary export build script

#### Updated Scripts
- `GameManager.gd`: Integrated with launcher, queue, and obstacle systems
- `Ball.gd`: Enhanced boundary collision detection

#### Physics Layers
- Layer 1: Ball
- Layer 2: Flippers
- Layer 4: Walls
- Layer 8: Obstacles (new)

### Version Control System

#### Files
- `VERSION`: Current version identifier (v0.1.1)
- `CHANGELOG.md`: Version history following Keep a Changelog format
- `VERSIONS.md`: Detailed feature documentation per version
- `scripts/release.sh`: Automated release script
- `scripts/build.sh`: Binary export script
- `export_presets.cfg`: Godot export configuration template

#### Release Process
1. Update version in `VERSION` file
2. Run `./scripts/release.sh v0.1.1` (or new version)
3. Script archives source to `releases/v0.1.1/source/`
4. Creates git tag (if in git repository)
5. Exports binaries to `releases/v0.1.1/binaries/` (if configured)
6. Updates documentation

### Known Limitations
- Obstacle collision detection uses Area2D (may have slight delay)
- Ball queue refills automatically (no game over on queue empty)
- No sound effects or music
- No game over/win conditions
- Export presets need to be configured in Godot Editor

### Future Enhancements
- Sound effects and music
- Game over/win conditions
- High score persistence
- Power-ups and special features
- Multiplayer support
- Advanced obstacle types (moving obstacles)



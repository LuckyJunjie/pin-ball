# Changelog

All notable changes to the Pin-Ball project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - Maze Pipe System and Bug Fixes

### Added
- **Tile-Based Maze Pipe System**: Replaced CurvedPipe with TileMap-based maze pipes
  - `MazePipeManager.gd`: Manages maze pipe tilemap configuration
  - `assets/tilesets/pipe_maze_tileset.tres`: TileSet resource with pipe wall tiles
  - `levels/maze_layouts/`: JSON-based level layout system for different maze designs
  - Level-based maze layouts (extensible for future levels)
  - Maze-aware obstacle spawning (obstacles avoid maze walls)
- **Maze Layout System**: JSON format for level configuration
  - Default layout: `level_1.json`
  - Tile coordinate system for maze walls
  - Support for different maze designs per level

### Changed
- **Pipe System**: Replaced script-based CurvedPipe with TileMapLayer-based maze pipes
  - Ball now falls through maze channels guided by tile walls
  - Maze walls use same collision layer as regular walls (layer 4)
  - Better performance and easier level editing
- **Ball Release Position**: Changed from (720, 400) to (720, 150)
  - Ball starts above maze entry to fall naturally into maze pipe
  - Prevents Launcher from immediately catching released balls
- **Launcher Detection**: Improved to only catch balls from playfield
  - Only catches balls below y=350 (coming from playfield)
  - Ignores balls above y=350 (falling from queue)
- **ObstacleSpawner**: Enhanced with maze-aware positioning
  - Checks maze tiles before spawning obstacles
  - Maintains random spawning while avoiding maze walls

### Fixed
- **Invalid Texture UIDs**: Fixed UID references in Ball.tscn and Obstacle.tscn
- **Ternary Operator Type Error**: Fixed type incompatibility in Ramp.gd (line 80)
- **TileSet.INVALID_SOURCE Error**: Replaced with `-1` check in MazePipeManager.gd
- **Ball Release Issue**: Fixed Launcher catching ball immediately upon release
- **Ball Physics State**: Improved ball state management in BallQueue.gd

### Technical Details
- Maze pipes use TileMapLayer with TileSet for collision
- Physics material: friction 0.1, bounce 0.3 (low friction for smooth ball flow)
- Maze path creates open channel (2 tiles wide) for ball to pass through
- Ball release position (720, 150) aligns with maze entry channel

## [0.2.0] - Commercial Optimization and Sports Theme

### Added
- **Background Transparency**: 70% transparent background (30% opacity) to reduce visual interference with game elements
- **Visible Pipe Guide**: Visual pipe/chute guiding ball from queue (720, 100) to launcher (720, 450)
  - Left and right pipe walls with collision
  - Back barrier at top to prevent ball from going back up
  - Brown/tan visual appearance matching game aesthetic
- **Sports-Themed Obstacles**: Procedural sprites replacing generic rectangles
  - Basketball hoop (replaces bumpers) - 60x60px orange hoop on pole
  - Baseball player (replaces pegs) - 20x40px dark blue player silhouette  
  - Baseball bat (replaces wall obstacles) - 40x12px brown bat shape
  - Soccer goal (new obstacle type) - 50x30px white goal posts with net
- **Curved Ramp System**: Spline-based curved ramps using Catmull-Rom interpolation
  - Multiple segments forming smooth curves
  - Configurable control points and curve density
  - Visual representation using Line2D
- **Sound Effect System**: Procedural sound generation script
  - Generated WAV files: flipper_click, obstacle_hit, ball_launch, hold_entry, ball_lost
  - SoundManager supports both WAV and OGG formats
  - Sound generation script with instructions for conversion
- **Enhanced Hold Mechanics**: Ball capture and round end functionality
  - Ball freezes and positions at hold center when entered
  - Score calculated before ball removal
  - Visual feedback delay for player
  - Proper round ending with next ball ready

### Changed
- **Flipper Starting Angle**: Changed from 0° (vertical) to 45° from vertical
  - Left flipper: rest_angle = -45°, pressed_angle = -90°
  - Right flipper: rest_angle = 45°, pressed_angle = 90°
  - Better ball hitting capability with angled starting position
- **Flipper Shape**: Changed from rectangle to baseball bat shape
  - ConvexPolygonShape2D with narrow handle and wider hitting surface
  - Visual representation using Polygon2D matching collision shape
- **Ball Queue and Launcher Positioning**: Repositioned to right side of screen
  - BallQueue: Position (720, 100) - top right area
  - Launcher: Position (720, 450) - bottom right area
  - Improved visual layout and gameplay flow
- **Ramp Guidance**: Improved ramp positioning and angles
  - Ramps guide ball from launcher toward center of playfield
  - Launch angle adjusted to -15° (toward center)
- **Obstacle Types**: Changed from generic bumper/peg/wall to sports-themed
  - Random spawning uses basketball, baseball_player, baseball_bat, soccer_goal
  - Maintains backwards compatibility with old types
- **Sound Manager**: Enhanced to support both WAV and OGG formats
  - Prefers OGG, falls back to WAV
  - Handles missing sound files gracefully

### Technical Details
- Ramp system uses spline curve generation with configurable control points
- Pipe guide uses StaticBody2D with collision walls and low-friction physics material
- Sports sprites generated procedurally using PNG creation algorithm
- Flipper collision shape changed to ConvexPolygonShape2D for bat-like appearance
- Hold collision detection properly configured with Area2D collision_mask = 1

## [0.1.1] - Enhanced Gameplay

### Added
- **Visual Ball Launcher**: Plunger mechanism with charge system
  - Hold Space/Down Arrow to charge launcher
  - Visual charge meter and plunger animation
  - Launch force proportional to charge (500-1000)
- **Ball Queue System**: Visible queue of 4 standby balls
  - Balls stack vertically near launcher
  - Automatic queue management
  - Queue refills when empty
- **Enhanced Boundary System**: Complete playfield enclosure
  - Boundary collision detection and correction
  - Ball cannot escape playfield
- **Random Static Obstacles**: Dynamic obstacle placement
  - 8 randomly placed obstacles per game
  - Three obstacle types: Bumpers (20 pts), Pegs (5 pts), Walls (15 pts)
  - Obstacles award points on collision
  - Obstacles avoid flipper and launcher zones
- **Version Control System**: Automated release management
  - VERSION file for current version tracking
  - CHANGELOG.md for version history
  - VERSIONS.md for detailed feature documentation
  - Release script (`scripts/release.sh`) for version archiving
  - Build script (`scripts/build.sh`) for binary exports
- **Export Configuration**: `export_presets.cfg` template for binary builds

### Changed
- Ball launch mechanism replaced with visual plunger system
- Ball management now uses queue system instead of single ball respawn
- Scoring system enhanced with obstacle collision points
- Controls updated: Hold Space/Down to charge launcher (instead of tap)

### Technical Details
- New physics layer: Obstacles (8)
- Ball collision mask updated to include obstacles
- GameManager integrated with Launcher and BallQueue systems
- Obstacle spawner with intelligent placement algorithm

## [0.0.1] - Initial Release

### Added
- Basic pinball game mechanics
- Ball physics with RigidBody2D
- Left and right flippers controlled by keyboard (A/D or Left/Right arrows)
- Simple ball launch mechanism (Space or Up Arrow)
- Basic wall boundaries (top, left, right, bottom)
- Score system with UI display
- Auto-respawn when ball falls below playfield
- Pause functionality (Esc key)

### Technical Details
- Built with Godot Engine 4.5
- Uses Forward Plus rendering
- Physics layers: Ball (1), Flippers (2), Walls (4)
- Gravity: 980.0 (standard Earth gravity)
- Physics materials configured for realistic bounce and friction



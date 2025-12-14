# Changelog

All notable changes to the Pin-Ball project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

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

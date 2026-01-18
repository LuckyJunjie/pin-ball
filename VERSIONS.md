# Version Documentation

This document provides detailed feature documentation for each version of the Pin-Ball game.

## Version 1.0.0 - Maze Pipe System and Bug Fixes

**Release Date:** 2025-01-18

### Overview
Version 1.0.0 introduces a tile-based maze pipe system replacing the script-based CurvedPipe, along with critical bug fixes that restore proper ball release and game flow.

### Features

#### Maze Pipe System
- **TileMap-Based Maze Pipes**: Replaced CurvedPipe StaticBody2D with TileMapLayer-based maze system
  - `MazePipeManager.gd`: Manages maze pipe tilemap configuration
  - `assets/tilesets/pipe_maze_tileset.tres`: TileSet resource with pipe wall tiles
  - Level-based maze layouts via JSON files in `levels/maze_layouts/`
  - Default layout: `level_1.json` creates ball-guiding channels

- **Maze Layout System**: JSON-based level configuration
  - Tile coordinate system for maze walls
  - Support for vertical, horizontal, corner, and junction tiles
  - Extensible for multiple level designs
  - Programmatic default path generation if JSON not found

- **Maze-Aware Obstacle Spawning**: ObstacleSpawner enhanced with maze detection
  - Checks if spawn position is inside maze walls
  - Avoids spawning obstacles on maze tiles
  - Maintains random spawning in open areas

#### Bug Fixes
- **Ball Release Issue**: Fixed Launcher catching ball immediately upon release
  - Changed ball release position from (720, 400) to (720, 150)
  - Launcher detection only catches balls from playfield (y > 350)
  - Balls now fall naturally into maze pipe

- **Texture UID Fixes**: Updated invalid UID references in scene files
  - Ball.tscn: `uid://ball_texture` → `uid://crq2nyf046hpl`
  - Obstacle.tscn: `uid://bumper_texture` → `uid://d1pxl2d7eeg41`

- **Type Compatibility Fixes**:
  - Fixed ternary operator type incompatibility in Ramp.gd
  - Fixed TileSet.INVALID_SOURCE reference in MazePipeManager.gd

### Technical Details

#### New Scripts
- `scripts/MazePipeManager.gd`: Extends TileMapLayer for maze management
- `scripts/ObstacleSpawner.gd`: Enhanced with `is_position_in_maze()` method

#### New Resources
- `assets/tilesets/pipe_maze_tileset.tres`: TileSet with wall tiles
- `levels/maze_layouts/level_1.json`: Default maze layout
- `levels/maze_layouts/README.md`: Maze layout format documentation

#### Modified Scripts
- `scripts/BallQueue.gd`: Changed release position to (720, 150)
- `scripts/Launcher.gd`: Improved detection to only catch balls from playfield
- `scripts/ObstacleSpawner.gd`: Added maze-aware positioning

#### Scene Changes
- `scenes/Main.tscn`: Replaced CurvedPipe with MazePipe TileMapLayer
- `scenes/Ball.tscn`: Fixed texture UID reference
- `scenes/Obstacle.tscn`: Fixed texture UID reference

#### Physics Configuration
- Maze pipe walls: Collision layer 4 (Walls layer)
- Physics material: friction 0.1, bounce 0.3 (low friction for smooth ball flow)
- Tile size: 32 pixels
- Maze channel width: 2-3 tiles wide for ball passage

### Controls
- **Down Arrow**: Release ball from queue (falls through maze pipe)
- (Other controls unchanged from previous version)

### Known Issues
- None (all critical bugs fixed)

### Future Enhancements
- Multiple maze layouts for different levels
- Procedural maze generation
- Dynamic maze modifications (moving walls, gates)
- Special maze tiles (speed boosts, direction changes)

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

## Version 0.2.0 - Commercial Optimization and Sports Theme

**Release Date:** 2025-01-10

### Overview
Major commercial optimization update with improved visuals, sports-themed obstacles, curved ramps, pipe guide system, and enhanced gameplay mechanics.

### New Features

#### Visual Improvements
- **Background Transparency**: 70% transparent background (30% opacity) reduces visual interference
- **Flipper Baseball Bat Shape**: Changed from rectangle to baseball bat shape (ConvexPolygonShape2D)
  - Narrow handle at base (12px wide)
  - Wider hitting surface at tip (28px wide)
  - Length: 64px
- **Flipper 45-Degree Starting Angle**: Flippers start at 45° from vertical for easier ball hitting
  - Left flipper: rest_angle = -45°, pressed_angle = -90°
  - Right flipper: rest_angle = 45°, pressed_angle = 90°

#### Pipe Guide System
- **Visible Pipe/Chute**: Visual pipe guide from ball queue to launcher
  - Queue position: (720, 100) - top right
  - Launcher position: (720, 450) - bottom right
  - Pipe width: 35px (wider than ball diameter)
  - Pipe length: 325px
  - Left/right collision walls (5px wide each)
  - Back barrier at top prevents ball from going back up
  - Low friction physics material (friction 0.1, bounce 0.3)

#### Curved Ramp System
- **Spline-Based Curved Ramps**: Replaced straight rectangles with spline curves
  - Catmull-Rom interpolation for smooth curves
  - Multiple SegmentShape2D shapes forming smooth curve
  - Visual representation using Line2D
  - Configurable control points and curve density
  - Ramps guide ball from launcher toward center of playfield
  - Launch angle: -15° (toward center)

#### Sports-Themed Obstacles
- **Procedural Sports Sprites**: Generated sports-themed obstacles
  - Basketball hoop (60x60px, orange hoop on brown pole) - replaces bumpers
  - Baseball player (20x40px, dark blue silhouette) - replaces pegs
  - Baseball bat (40x12px, brown bat shape) - replaces wall obstacles
  - Soccer goal (50x30px, white goal posts with net) - new obstacle type
- **Updated Obstacle System**: ObstacleSpawner randomly selects from sports-themed types
- **Backwards Compatibility**: Legacy types (bumper, peg, wall) still supported

#### Enhanced Hold Mechanics
- **Ball Capture**: Ball freezes and positions at hold center when entered
- **Round End**: Score calculated before ball removal
- **Visual Feedback**: Delay (0.5s) before ball removal for visual feedback
- **Proper Round Ending**: Ball round ends, next ball prepared after delay (1.0s total)
- **Single Capture**: Only one ball can be captured per hold

#### Sound System
- **Procedural Sound Generation**: `generate_sounds.py` script creates placeholder sounds
  - Generated WAV files: flipper_click, obstacle_hit, ball_launch, hold_entry, ball_lost
  - Instructions for conversion to OGG provided
- **SoundManager Enhancement**: Supports both WAV and OGG formats (prefers OGG)
- **Documentation**: Sources for commercial-quality sounds documented

#### Graphics Assets Documentation
- **Asset Specifications**: Created README with sprite specifications
- **Commercial Sources**: Documented free commercial sources (OpenGameArt, Kenney.nl, itch.io, etc.)
- **Placeholder Sprites**: Current sprites are placeholders ready for replacement

### Updated Controls
- **Flipper Left**: Left Arrow / A (unchanged)
- **Flipper Right**: Right Arrow / D (unchanged)
- **Release Ball**: Down Arrow (releases ball from queue into pipe)
- **Charge Launcher**: Hold Space (charges launcher when ball arrives)
- **Pause**: Esc (unchanged)

### Technical Architecture

#### New Scene Structure
- `PipeGuide` node in Main.tscn with left/right walls and back barrier
- Updated flipper instances with 45° starting angles
- Sports-themed obstacles in ObstacleSpawner

#### Updated Scripts
- `Flipper.gd`: Angle adjustment logic for 45° starting position
- `BallQueue.gd`: Pipe entry positioning
- `GameManager.gd`: Removed position reset interfering with pipe
- `Ramp.gd`: Complete rewrite with spline-based curve generation
- `Hold.gd`: Ball capture and round end logic
- `Obstacle.gd`: Sports-themed obstacle type support
- `ObstacleSpawner.gd`: Sports obstacle spawning
- `SoundManager.gd`: WAV/OGG format support

#### New Scripts
- `generate_sounds.py`: Procedural sound generation

#### Updated Physics
- Pipe guide uses low-friction physics material (friction 0.1, bounce 0.3)
- Curved ramps use multiple SegmentShape2D segments for smooth curves
- Hold Area2D collision_mask = 1 (detect ball layer)

### Known Limitations
- Sound files are procedural placeholders (WAV format) - can be converted to OGG or replaced with commercial sounds
- Sports sprites are procedurally generated (simple shapes) - can be replaced with professional art assets
- Pipe guide is functional but could have more visual polish
- Curved ramps work but may need tuning for optimal ball trajectory

### Future Enhancements
- Replace procedural sounds with commercial-quality sound effects
- Replace procedural sprites with professional art assets
- Add more visual polish to pipe guide (textures, effects)
- Fine-tune curved ramp control points for optimal gameplay
- Add particle effects for ball hits and captures
- Add animations for obstacle hits

---

## Version 2.0 - Design Documentation (Design Phase Complete)

**Design Completion Date:** 2024  
**Status:** Design documents complete, ready for implementation  
**Implementation Status:** Not started (design phase only)

### Overview

Version 2.0 represents a major enhancement to the Pinball game, adding monetization systems, mobile platform support, upgrade mechanics, and comprehensive progression systems. All v1.0 features are preserved and enhanced. The design maintains full backward compatibility.

**Design Documentation Location:** `design-v2.0/` directory  
**Requirements Documentation Location:** `requirements/Requirements-v2.0.md` and `requirements/Technical-Requirements-v2.0.md`

### Design Scope

#### New Platform Support
- **Mobile Platforms**: iOS (13.0+) and Android (8.0+) as primary platforms
- **Touch Controls**: Comprehensive touch control system for mobile
- **Responsive UI**: Mobile-first UI design with portrait/landscape support
- **Desktop Support**: Maintained for development and testing

#### Monetization Systems (NEW)
- **Dual Currency System**: 
  - Coins (earnable through gameplay)
  - Gems (premium currency, earnable or purchasable)
- **Shop System**: Comprehensive shop with 5 categories (Balls, Flippers, Ramps, Cosmetics, Specials)
- **In-App Purchases (IAP)**: 
  - iOS: StoreKit integration
  - Android: Google Play Billing integration
  - 4 gem packages ($0.99 - $19.99)
  - 2 starter packs
- **Advertisement Integration**:
  - Rewarded ads (watch for coins/gems/extra ball, 3 per day limit)
  - Interstitial ads (between game sessions, smart timing)
  - AdMob primary, Unity Ads fallback
- **Battle Pass System**: 
  - 30-day seasons with 50 tiers
  - Free track (always available)
  - Premium track (unlock with 100 gems)
  - XP-based progression from gameplay

#### Upgrade Systems (NEW)
- **Ball Upgrades** (6 types):
  - Standard (default, free)
  - Heavy (500 coins) - Increased mass and momentum
  - Bouncy (1000 coins) - Higher bounce, more energy
  - Magnetic (50 gems) - Attracts to obstacles
  - Fire (150 gems) - Chain reactions, score multiplier
  - Cosmic (300 gems) - Anti-gravity, time warp
- **Flipper Upgrades** (6 types):
  - Standard (default, free)
  - Long (1000 coins) - Wider hitbox
  - Power (50 gems) - Increased impulse force
  - Twin (75 gems) - Dual segment flipper
  - Plasma (150 gems) - Plasma effects, faster rotation
  - Turbo (200 gems) - Maximum rotation speed
- **Special Ramps** (3 types, session-based):
  - Multiplier Ramp (100 coins) - 2× score for 10 seconds
  - Bank Shot Ramp (200 coins) - Guides ball to target hold
  - Accelerator Ramp (150 coins) - 50% speed boost

#### Cosmetic Systems (NEW)
- **Ball Trails**: Standard, Fire, Electric, Rainbow, Galaxy
- **Table Skins**: Classic, Neo-Noir, Cyberpunk, Nature, Space
- **Flipper Skins**: Visual-only customization variants
- **Sound Packs**: Theme-based audio replacements

#### Daily Systems (NEW)
- **Daily Login Rewards**: 
  - 7-day streak system
  - Scaling rewards (100-500 coins, 0-50 gems)
  - Exclusive item on Day 7
- **Daily Challenges**: 
  - 3 challenges per day
  - Score, obstacle, hold, and combo challenges
  - Auto-tracking and completion

#### Data Persistence (NEW)
- **Save System**: Comprehensive save/load system
  - Currency (coins/gems)
  - Owned items
  - Equipped items
  - Battle Pass progress
  - Daily login streak
  - Challenge progress
- **Save Format**: JSON with optional encryption
- **Backup/Restore**: Save file backup and restore functionality

### Design Documents

Complete design documentation is available in `design-v2.0/`:

1. **GDD-v2.0.md** - Complete Game Design Document (886 lines)
2. **Monetization-Design.md** - Revenue systems, shop, IAP, ads, battle pass
3. **Upgrade-Systems.md** - Detailed upgrade mechanics and physics
4. **Component-Specifications-v2.0.md** - Component architecture with new managers
5. **Technical-Design-v2.0.md** - System architecture and platform integration
6. **Game-Flow-v2.0.md** - Enhanced game flow with monetization features
7. **UI-Design-v2.0.md** - Complete UI/UX specifications
8. **Physics-Specifications-v2.0.md** - Enhanced physics for upgrades
9. **Mobile-Platform-Specs.md** - iOS/Android platform specifications
10. **README.md** - Navigation and overview guide

### Requirements Documents

Complete requirements documentation:

1. **Requirements-v2.0.md** - Functional and non-functional requirements
2. **Technical-Requirements-v2.0.md** - Technical specifications

### Design Principles

- **Backward Compatibility**: All v1.0 gameplay mechanics preserved
- **Non-Predatory Monetization**: Free players can progress without paying
- **Clear Value Proposition**: Paid items provide meaningful but balanced advantages
- **Mobile-First UI**: Touch-friendly controls and responsive layouts
- **Data Persistence**: All progress saved and restorable
- **Balance**: Economy balanced for both free and paying players

### Implementation Roadmap

**Phase 1: Foundation** (Weeks 1-2) - Currency system, save system, shop structure  
**Phase 2: Shop System** (Weeks 3-4) - Shop UI, purchase flow, item database  
**Phase 3: Upgrade Systems** (Weeks 5-6) - Ball/flipper/ramp upgrades, visual effects  
**Phase 4: Platform Integration** (Weeks 7-8) - IAP, ads, StoreKit, Google Play Billing  
**Phase 5: Progression Systems** (Weeks 9-10) - Battle Pass, daily login, challenges  
**Phase 6: Mobile Optimization** (Weeks 11-12) - Touch controls, UI optimization  
**Phase 7: Polish & Testing** (Weeks 13-14) - Balance tuning, beta testing, bug fixes

### Known Design Considerations

- Special physics effects (magnetic, cosmic) optimized to run at 30Hz on mobile
- Particle effects limited to 100 particles per effect for performance
- Ad integration requires careful timing to maintain user experience
- Economy balance needs playtesting to ensure free players can progress
- Platform-specific implementations (IAP, ads) require abstraction layer for maintainability

### Design Status

✅ **DESIGN PHASE COMPLETE** - All design documents finalized  
⏳ **IMPLEMENTATION PHASE** - Pending (design ready for implementation)

See `design-v2.0/DESIGN-COMPLETE.md` for detailed design completion status and implementation roadmap.



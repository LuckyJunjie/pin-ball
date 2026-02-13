# Agent Documentation - Pinball Game System

This document describes the complete pinball game system architecture implemented in Godot 4.x.

## Overview

The pinball game is a feature-complete recreation of the Flutter reference implementation, with additional enhancements and polish features. The game runs on Godot 4.5+ and targets mobile and desktop platforms.

## Project Structure

```
pin-ball/
├── scripts/v4/              # Main game scripts
├── scenes/                   # Game scenes
├── assets/                   # Resources (sprites, audio)
├── project.godot            # Project configuration
└── agent_doc/               # This documentation
```

---

## Core Systems (5)

### 1. GameManagerV4

**File:** `scripts/v4/GameManagerV4.gd`  
**Type:** Autoload (Global)

**Purpose:** Central game state management

**Key Features:**
- Manages game state (WAITING, PLAYING, GAME_OVER)
- Handles scoring system with multiplier
- Tracks rounds and ball count
- Manages bonuses and achievements
- Auto-save functionality
- Ball pooling coordination

**Signals:**
```gdscript
signal scored(points: int)
signal round_lost()
signal bonus_activated(bonus: Bonus)
signal multiplier_increased()
signal game_over()
signal game_started()
signal zone_ramp_hit(zone_name: String, hit_count: int)
```

**Constants:**
```gdscript
const MAX_SCORE: int = 9999999999
const INITIAL_ROUNDS: int = 3
const MAX_MULTIPLIER: int = 6
const BONUS_BALL_DELAY: float = 5.0
const RAMP_HITS_PER_MULTIPLIER: int = 5
```

**Key Methods:**
```gdscript
func start_game() -> void
func add_score(points: int) -> void
func on_round_lost() -> void
func increase_multiplier() -> void
func add_bonus(bonus: Bonus) -> void
func register_zone_ramp_hit(zone_name: String) -> void
func set_character_theme(theme_key: String) -> void
func save_game_state() -> bool
func load_game_state() -> bool
```

---

### 2. BallPoolV4

**File:** `scripts/v4/BallPoolV4.gd`  
**Type:** Autoload

**Purpose:** Object pooling for ball instances to optimize performance

**Note:** The autoload name `BallPoolV4` refers to the *instance*. To call static methods (e.g. `get_instance()`), use the script: `preload("res://scripts/v4/BallPoolV4.gd").get_instance()` or a const script reference. GameManagerV4 uses `const BallPoolScript := preload("res://scripts/v4/BallPoolV4.gd")` then `BallPoolScript.get_instance()`.

**Key Features:**
- Pre-allocates ball instances
- Reuses balls instead of creating/destroying
- Tracks active ball count
- Manages ball lifecycle

**Key Methods:**
```gdscript
func initialize(ball_scene: PackedScene, container: Node2D) -> void
func spawn_ball_at_position(pos: Vector2, impulse: Vector2, freeze: bool = false) -> RigidBody2D
func return_ball(ball: RigidBody2D) -> void
func get_active_ball_count() -> int
func is_initialized() -> bool
```

---

### 3. CharacterThemeManagerV4

**File:** `scripts/v4/CharacterThemeManagerV4.gd`  
**Type:** Autoload

**Purpose:** Manages character theme selection and assets

**Themes:**
- sparky (default) - Electric blue/cyan
- dino - Orange/brown
- dash - Green/butterfly
- android - Green/robot

**Key Methods:**
```gdscript
func get_theme_sprite(theme: String) -> Texture2D
func get_all_themes() -> Array
func get_default_theme() -> String
```

---

### 4. BonusManagerV4

**File:** `scripts/v4/BonusManagerV4.gd`  
**Type:** Autoload

**Purpose:** Manages bonus activation and scoring

**Bonus Types:**
- GOOGLE_WORD - Complete "GOOGLE" letters
- DASH_NEST - Hit all Dash bumpers
- SPARKY_TURBO_CHARGE - Enter Sparky's computer
- DINO_CHOMP - Ball in Dino mouth
- ANDROID_SPACESHIP - Ball in spaceship

**Key Methods:**
```gdscript
func activate_bonus(bonus_type: Bonus) -> void
func get_bonus_score(bonus_type: Bonus) -> int
func is_bonus_active(bonus_type: Bonus) -> bool
```

---

### 5. Save (GameManagerV4 internal + SaveManager)

**v4 game state:** GameManagerV4 saves/loads to `user://saves/v4.0_save.json` via `save_game_state()` and `load_game_state()`. Auto-save (e.g. every 30s, on score change, round end) is implemented inside GameManagerV4; there is no separate AutoSaveV4 autoload.

**SaveManager** (optional): `scripts/SaveManager.gd` — Autoload for other persistent data if needed. v4 does not require it for core game state.

---

## Enhancement Systems (9)

### 6. DifficultySystem

**File:** `scripts/v4/DifficultySystem.gd`  
**Type:** Autoload (name: `DifficultySystem`)

**Purpose:** Configurable difficulty levels

**Difficulty Levels:**
| Level | Flipper Strength | Gravity | Decay | Extra Ball |
|-------|-----------------|----------|--------|-------------|
| Easy | 1500 | 0.8x | None | 15% |
| Normal | 2200 | 1.0x | 15s/0.5x | 10% |
| Hard | 2800 | 1.2x | None | 5% |

**Key Methods:**
```gdscript
func set_difficulty(difficulty: Difficulty) -> void
func get_flipper_strength() -> float
func get_gravity_scale() -> float
func is_multiplier_decay_enabled() -> bool
```

---

### 7. ScreenShake

**File:** `scripts/v4/ScreenShake.gd`  
**Type:** Autoload (name: `ScreenShake`)

**Purpose:** Camera shake effects for feedback

**Shake Levels:**
- Light - Bumper hits
- Medium - Flipper hits
- Heavy - Bonus activation
- Extreme - Game events

**Key Methods:**
```gdscript
func shake(intensity: float, duration: float) -> void
func shake_light() -> void
func shake_medium() -> void
func shake_heavy() -> void
func shake_extreme() -> void
func stop_shake() -> void
```

---

### 8. ComboSystem

**File:** `scripts/v4/ComboSystem.gd`  
**Type:** Autoload (name: `ComboSystem`)

**Purpose:** Tracks consecutive hits for bonus multipliers

**Mechanics:**
- Tracks consecutive hits without drain
- 3-second timeout between hits
- Max 20x combo level
- Bonus = Base × (1 + (Combo-1) × 0.5)

**Key Methods:**
```gdscript
func register_hit(hit_type: String, base_points: int) -> int
func register_drain() -> int
func get_combo_multiplier() -> float
func get_max_combo() -> int
```

---

### 9. BallTrailV4

**File:** `scripts/v4/BallTrailV4.gd`  
**Type:** Node2D

**Purpose:** Visual trail following the ball

**Features:**
- Configurable trail length (default 20 points)
- Fade effect (50% length)
- Customizable color and width

**Key Methods:**
```gdscript
func set_ball(ball: RigidBody2D) -> void
func set_trail_color(color: Color) -> void
func set_trail_width(width: float) -> void
```

---

### 10. ParticleEffectsV4

**File:** `scripts/v4/ParticleEffectsV4.gd`  
**Type:** Autoload

**Purpose:** Visual particle effects

**Effect Types:**
- Hit effects (10-30 particles)
- Score popups
- Bonus celebrations
- Letter activations
- Multiplier increase
- Word completion
- Ball drain

**Key Methods:**
```gdscript
func spawn_hit_effect(position: Vector2, color: Color, count: int) -> void
func spawn_score_popup(position: Vector2, score: int) -> void
func spawn_bonus_effect(position: Vector2) -> void
func spawn_multiplier_effect(multiplier: int) -> void
```

---

### 11. EnhancedAudioV4

**File:** `scripts/v4/EnhancedAudioV4.gd`  
**Type:** Autoload

**Purpose:** Dynamic audio with volume scaling

**Features:**
- 24+ sound effect types
- Zone-specific sounds
- Dynamic volume based on ball speed
- Pitch variation for variety
- Intensity-based background music
- Separate SFX/Music/UI buses

**Key Methods:**
```gdscript
func play_sound(sound_name: String, volume_override: float = -1.0, pitch_override: float = 1.0) -> void
func play_zone_sound(zone_name: String, sound_suffix: String) -> void
func update_ball_speed(speed: float) -> void
func set_music_intensity(intensity: float) -> void
```

---

### 12. MobileControlsV4

**File:** `scripts/v4/MobileControlsV4.gd`  
**Type:** Autoload

**Purpose:** Touch input for mobile devices

**Touch Zones:**
- Left third of screen - Left flipper
- Right third of screen - Right flipper
- Bottom center - Launch ball
- Swipe detection - Gestures

**Features:**
- Haptic feedback support
- Debug zone visualization
- Multi-touch support

**Key Methods:**
```gdscript
func flipper_touched(side: String, is_pressed: bool) -> void
func launch_tap() -> void
func is_mobile_device() -> bool
func trigger_haptic_feedback(type: String) -> void
```

---

### 13. AchievementSystemV4

**File:** `scripts/v4/AchievementSystemV4.gd`  
**Type:** Autoload

**Purpose:** Tracks player achievements and milestones

**Categories (25 achievements):**
| Category | Count | Examples |
|----------|-------|----------|
| General | 3 | First Game, 5 Games, 25 Games |
| Scoring | 6 | 1M, 5M, 10M points; 2x, 4x, 6x multiplier |
| Zones | 6 | Each zone bonuses, All zones |
| Combos | 3 | 5x, 10x, 20x combo |
| Bonuses | 3 | 1st Bonus Ball, 5 in one game, All types |

**Key Methods:**
```gdscript
func unlock_achievement(ach_id: String) -> bool
func is_unlocked(ach_id: String) -> bool
func get_progress_percentage() -> float
func get_all_achievements() -> Array
func get_statistics() -> Dictionary
```

---

## Polish Systems (5)

### 14. CRTEffectV4

**File:** `scripts/v4/CRTEffectV4.gd`  
**Type:** CanvasLayer

**Purpose:** Retro CRT monitor effects

**Features:**
- Scanlines (configurable intensity)
- Glow effect
- Chromatic aberration
- Vignette
- Subtle noise
- Curvature effect

**Configuration:**
```gdscript
@export var scanline_intensity: float = 0.3
@export var glow_strength: float = 0.5
@export var chromatic_aberration: float = 0.002
@export var vignette_intensity: float = 0.3
```

**Key Methods:**
```gdscript
func set_enabled(enabled: bool) -> void
func set_scanline_intensity(value: float) -> void
func set_glow_strength(value: float) -> void
func toggle() -> void
func flash(intensity: float = 0.5) -> void
```

---

### 15. CharacterAnimatronicV4

**File:** `scripts/v4/CharacterAnimatronicV4.gd`  
**Type:** Node2D

**Purpose:** Character-specific animations

**Themes:**
- Sparky: idle, turbo_charge, celebrate, hit
- Dino: idle, chomp, celebrate, sleep
- Dash: idle, nest_complete, celebrate
- Android: idle, spaceship_land, celebrate

**Key Methods:**
```gdscript
func set_theme(new_theme: String) -> void
func play(anim_name: String, loop_animation: bool = true) -> void
func play_once(anim_name: String) -> void
func stop() -> void
func is_playing() -> bool
```

---

### 16. LeaderboardV4

**File:** `scripts/v4/LeaderboardV4.gd`  
**Type:** Autoload

**Purpose:** Persistent local leaderboard

**Features:**
- Local JSON storage
- Character-specific boards
- Export/import
- Statistics

**Key Methods:**
```gdscript
func submit_score(initials: String, score: int, character: String) -> String
func get_leaderboard(count: int = 10, character: String = "") -> Array
func get_rank(initials: String, score: int) -> int
func is_high_score(score: int) -> bool
func export_leaderboard() -> String
func import_leaderboard(json_string: String) -> bool
```

---

### 17. TutorialSystemV4

**File:** `scripts/v4/TutorialSystemV4.gd`  
**Type:** Autoload

**Purpose:** Guided tutorial for new players

**Tutorial Steps (8):**
1. Welcome
2. Flippers (wait for input)
3. Launch (wait for input)
4. Scoring
5. Multiplier
6. Zones
7. Bonuses
8. Ready to Play

**Key Methods:**
```gdscript
func start_tutorial() -> void
func skip_tutorial() -> void
func complete_tutorial() -> void
func has_completed_tutorial() -> bool
func show_prompt(prompt_id: String, duration: float = 5.0) -> void
```

---

### 18. PerformanceMonitorV4

**File:** `scripts/v4/PerformanceMonitorV4.gd`  
**Type:** Autoload

**Purpose:** FPS monitoring and auto-optimization

**Features:**
- FPS tracking (avg/min/max)
- Auto-optimization triggers
- Quality presets (low/medium/high/ultra)
- Memory usage tracking

**Key Methods:**
```gdscript
func get_average_fps() -> float
func get_min_fps() -> float
func get_memory_usage() -> Dictionary
func set_quality_preset(preset: String) -> void
func start_benchmark(duration: float = 5.0) -> void
func print_performance_report() -> void
```

---

## Bonus Systems (8)

### 19. DailyChallengeV4

**File:** `scripts/v4/DailyChallengeV4.gd`  
**Type:** Autoload

**Purpose:** Rotating daily challenges

**Challenge Templates (10):**
| ID | Name | Target | Difficulty | Reward |
|----|------|--------|------------|--------|
| high_score | High Scorer | 500K points | 1 | 100 |
| multiplier_master | Multiplier Master | 6x | 2 | 150 |
| bonus_hunter | Bonus Hunter | 3 bonus balls | 2 | 200 |
| zone_king | Zone King | All 5 zones | 3 | 300 |
| combo_king | Combo King | 10x combo | 2 | 175 |

**Key Methods:**
```gdscript
func start_tracking() -> void
func update_progress(challenge_type: String, value: int) -> void
func get_today_challenges() -> Array
func is_completed(challenge_id: String) -> bool
func get_streak() -> int
```

---

### 20. StatisticsTrackerV4

**File:** `scripts/v4/StatisticsTrackerV4.gd`  
**Type:** Autoload

**Purpose:** Comprehensive player statistics

**Categories:**
- Lifetime (games played, total score, time)
- Scoring (hits, ramp hits, letter hits)
- Zones (zone-specific bonuses)
- Achievements (unlocked count, points)

**Key Methods:**
```gdscript
func on_game_started() -> void
func on_game_ended(final_score: int) -> void
func on_hit(points: int) -> void
func get_statistics_summary() -> Dictionary
func get_friendly_summary() -> String
```

---

### 21. EasterEggV4

**File:** `scripts/v4/EasterEggV4.gd`  
**Type:** Autoload

**Purpose:** Hidden features and secrets

**Secrets (8):**
- lucky_ball - First bonus ball
- combo_master - 50x combo
- flipper_god - 1000 flipper hits
- bumper_king - 1000 bumpers
- perfectionist - No drain + 1M score
- night_owl - Play after midnight
- speedy - 50K in 1 minute
- collector - All themes

**Easter Eggs (5):**
- invincible - 10s invincibility
- party_mode - Double points
- rainbow - Rainbow colors
- tiny_ball - Shrink ball
- ghost_mode - Pass through flippers

---

### 22. SettingsV4

**File:** `scripts/v4/SettingsV4.gd`  
**Type:** Autoload

**Purpose:** Game settings with persistence

**Categories:**
- Audio (master, SFX, music volume)
- Video (fullscreen, VSync, CRT, particles)
- Gameplay (difficulty, sensitivity, launch power)
- Accessibility (large text, high contrast, haptic)

**Key Methods:**
```gdscript
func get_setting(category: String, key: String) -> Variant
func set_difficulty(difficulty: String) -> void
func set_crt_effect(enabled: bool) -> void
func get_all_settings() -> Dictionary
func reset_settings() -> void
```

---

### 23. SocialSharingV4

**File:** `scripts/v4/SocialSharingV4.gd`  
**Type:** Autoload

**Purpose:** Share scores and achievements

**Share Types:**
- High Score
- Achievement
- Challenge Completion
- Milestone

**Key Methods:**
```gdscript
func share_high_score(score: int, character: String) -> void
func share_achievement(ach_name: String, points: int) -> void
func generate_score_card(score: int, character: String) -> Texture2D
```

---

### 24. LocalizationV4

**File:** `scripts/v4/LocalizationV4.gd`  
**Type:** Autoload

**Purpose:** Multi-language support

**Languages (7):**
- English (en)
- Chinese (zh)
- Japanese (ja)
- Korean (ko)
- Spanish (es)
- German (de)
- French (fr)

**Key Methods:**
```gdscript
func tr(key: String, context: String = "") -> String
func set_language(lang_code: String) -> void
func get_language() -> String
func get_available_languages() -> Array
```

---

### 25. ReplayV4

**File:** `scripts/v4/ReplayV4.gd`  
**Type:** Autoload

**Purpose:** Record and replay game sessions

**Features:**
- Record input frames
- Replay functionality
- Export/import replays
- Max 10 replays stored

**Key Methods:**
```gdscript
func start_recording(final_score: int = 0, character: String = "sparky") -> void
func stop_recording() -> String
func start_replay() -> bool
func load_replay(replay_id: String) -> bool
func export_replay(replay_id: String) -> String
```

---

## Advanced Polish (4)

### 26. LightingV4

**File:** `scripts/v4/LightingV4.gd`  
**Type:** Autoload

**Purpose:** Dynamic lighting effects

**Features:**
- Zone-specific lighting colors
- Pulse animations
- Global light energy control
- Glow effects

---

### 27. BackgroundV4

**File:** `scripts/v4/BackgroundV4.gd`  
**Type:** Autoload

**Purpose:** Background animations and weather

**Features:**
- Animated backgrounds
- Scene transitions
- Weather particles
- Parallax scrolling

---

### 28. SpecialBallV4

**File:** `scripts/v4/SpecialBallV4.gd`  
**Type:** Autoload

**Purpose:** Special ball types

**Ball Types (5):**
| Type | Probability | Effect |
|------|-------------|--------|
| Normal | 70% | Standard |
| Fireball | 10% | 2x points |
| Ghostball | 10% | Phase through |
| Multiball | 5% | Spawn 2 balls |
| Megaball | 5% | 3x points + large |

---

### 29. ShopV4

**File:** `scripts/v4/ShopV4.gd`  
**Type:** Autoload

**Purpose:** In-game shop for items

**Items (10):**
- Double Points (1 min) - 100 coins
- Extra Ball - 200 coins
- Safe Landing - 150 coins
- Theme unlocks - 500 coins
- Skin unlocks - 300-500 coins
- Titles - 1000-2000 coins

---

### 30. ChallengeModeV4

**File:** `scripts/v4/ChallengeModeV4.gd`  
**Type:** Autoload

**Purpose:** Special game modes

**Modes (4):**
| Mode | Description | Duration |
|------|-------------|----------|
| Time Attack | Score high in 2 min | 2 min |
| Survival | Keep ball alive | Unlimited |
| Precision | Hit specific targets | 3 min |
| Madness | 2x chaos mode | 90 sec |

---

### 31. AccessibilityV4

**File:** `scripts/v4/AccessibilityV4.gd`  
**Type:** Autoload

**Purpose:** Accessibility features

**Features:**
- Large text (1.0x-2.0x)
- High contrast mode
- Color blind filters (2 types)
- Motion reduction
- Haptic feedback
- Subtitles
- Simplified controls

---

## Cloud & Monetization

### 32. CloudSaveV4

**File:** `scripts/v4/CloudSaveV4.gd`  
**Type:** Autoload

**Purpose:** Cloud backup and sync

**Features:**
- Cloud upload/download
- Automatic sync
- Conflict resolution
- Version management

---

### 33. AdSystemV4

**File:** `scripts/v4/AdSystemV4.gd`  
**Type:** Autoload

**Purpose:** Ad monetization

**Reward Types:**
| Type | Description | Duration |
|------|-------------|----------|
| Extra Life | +1 ball | 15-30s |
| 2x Score | Double points | 30s |
| Coin Bonus | +100 coins | 15-30s |
| Free Skin | Random skin | 24hr |
| Continue | Continue game | 30s |

**Placement:**
- Game (ball lost)
- Shop (daily reward)
- Game over
- Daily login

---

## Scene Structure

```
MainV4.tscn (Main game scene)
├── Camera2D
├── Playfield
│   ├── Background
│   ├── Walls (StaticBody2Ds)
│   ├── Zones
│   │   ├── AndroidAcres.tscn
│   │   ├── GoogleGallery.tscn
│   │   ├── FlutterForest.tscn
│   │   ├── DinoDesert.tscn
│   │   └── SparkyScorch.tscn
│   ├── Flippers
│   ├── Launcher
│   └── Balls
├── UI (CanvasLayer)
│   ├── ScorePanel
│   ├── MultiplierLabel
│   ├── GameOverPanel
│   └── Backbox
└── Audio

MainMenuV4.tscn (Menu scene)
├── Title
├── MenuButtons
│   ├── Start Game
│   ├── Character Select
│   ├── Settings
│   ├── Achievements
│   └── Leaderboard
```

---

## Input Configuration

### Keyboard
| Action | Key | Description |
|--------|-----|-------------|
| flipper_left | A / ← | Left flipper |
| flipper_right | D / → | Right flipper |
| launch_ball | Space / ↓ | Launch ball |

### Touch
| Zone | Action |
|------|--------|
| Left 1/3 screen | Left flipper |
| Right 1/3 screen | Right flipper |
| Bottom center | Launch |

---

## Physics Configuration

### Ball Settings
```gdscript
gravity_scale: float = 1.0
mass: float = 0.4
linear_damp: float = 0.02
angular_damp: float = 0.02
continuous_cd: CCD_MODE_CAST_SHAPE
```

### Physics Material
```gdscript
bounce: float = 0.85
friction: float = 0.075
```

### Collision Layers
| Layer | Purpose |
|-------|---------|
| 1 | Ball |
| 2 | Flippers |
| 4 | Walls |
| 8 | Obstacles |

---

## Build Configuration

### Export Platforms
- Android (APK/AAB)
- iOS
- Windows
- macOS
- Linux

### Project Settings
```ini
[application]
config/name="PinBall"
run/main_scene="res://scenes/MainMenuV4.tscn"
config/features=PackedStringArray("4.5")

[display]
window/size/viewport_width=800
window/size/viewport_height=600
window/stretch/mode="canvas_items"
```

---

## Performance Targets

| Metric | Target |
|--------|--------|
| FPS | 60 |
| Load Time | < 3s |
| Memory | < 100MB |
| Package Size | < 50MB |

---

## Version History

| Version | Date | Changes |
|---------|------|---------|
| 1.0.0 | 2026-02-13 | Initial release (Minimax extension: 4 phases, 32 systems) |
| 1.1.0 | 2026-02-13 | Doc fix: correct filenames (ScreenShake.gd, ComboSystem.gd, DifficultySystem.gd), Save/AutoSave notes, BallPoolV4 static-call note |

---

*Document generated: 2026-02-13*
*Project: Pinball Godot 4.x*
*Total Systems: 32 (27 systems + 5 zones). Some autoloads use shorter names: DifficultySystem, ScreenShake, ComboSystem. Auto-save is inside GameManagerV4.*

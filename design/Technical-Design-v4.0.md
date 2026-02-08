# Pinball Game v4.0 – Technical Design Document

## 1. Architecture Overview

### 1.1 Purpose

v4.0 replicates the Flutter I/O Pinball game in Godot 4.x. The architecture maps Flutter components and state (GameBloc, StartGameBloc, BackboxBloc) to Godot scenes, nodes, and scripts. No shop, currency, or battle pass; leaderboard and share use local or optional backend.

### 1.2 Layers

```
┌─────────────────────────────────────────┐
│      Presentation Layer (v4.0)          │
│  (Backbox displays, HUD, Overlays,      │
│   Character select, How to Play)       │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Gameplay Layer (v4.0)              │
│  (Playfield, Zones, Ball, Flippers,     │
│   Launcher, Drain, Scoring, Bonuses)    │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      State Layer (v4.0)                 │
│  (GameManager = GameBloc, StartFlow,     │
│   BackboxManager = BackboxBloc)         │
└─────────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────────┐
│      Data Layer (v4.0)                  │
│  (Local leaderboard, SaveManager        │
│   for initials/scores; optional share)  │
└─────────────────────────────────────────┘
```

### 1.3 Mapping from Flutter

| Flutter | Godot v4.0 |
|---------|------------|
| GameBloc | GameManager (autoload or root) – roundScore, totalScore, multiplier, rounds, bonusHistory, status |
| StartGameBloc | StartFlow state (e.g. in GameManager or dedicated node) – initial, selectCharacter, howToPlay, play |
| BackboxBloc | BackboxManager or Backbox scene script – leaderboard, initials, game over, share |
| PinballGame (Forge2D) | Main scene with Playfield, Camera2D |
| BallSpawningBehavior | GameManager + Launcher – spawn ball at plunger on round start / round lost |
| BonusBallSpawningBehavior | GameManager – timer 5s, spawn ball at DinoWalls with impulse |
| DrainingBehavior | Drain area – body_entered Ball → remove ball; if no balls → RoundLost |
| CameraFocusingBehavior | Camera2D script – zoom/position per status (waiting, playing, gameOver) |
| Zones (AndroidAcres, etc.) | Child nodes of Playfield with zone scripts and scoring/bonus logic |

---

## 2. Scene Structure

### 2.1 Main / Game Root

**Scene**: e.g. `scenes/MainV4.tscn` or `scenes/PinballGameV4.tscn`

**Node structure** (conceptual):

```
Main (Node2D)
├── Camera2D                    # Camera behavior per status
├── Playfield (Node2D)          # Board background, boundaries
│   ├── Boundaries (StaticBody2D / Area2D)
│   ├── Backbox (CanvasLayer or Node2D)  # Marquee + display states
│   ├── GoogleGallery (Node2D)
│   ├── Multipliers (Node2D)    # x2–x6 targets
│   ├── Multiballs (Node2D)     # 4 indicators
│   ├── SkillShot (Area2D)
│   ├── AndroidAcres (Node2D)
│   ├── DinoDesert (Node2D)
│   ├── FlutterForest (Node2D)
│   ├── SparkyScorch (Node2D)
│   ├── Drain (Area2D)
│   ├── BottomGroup (Node2D)
│   │   ├── FlipperLeft (RigidBody2D)
│   │   ├── FlipperRight (RigidBody2D)
│   │   ├── BaseboardLeft, BaseboardRight
│   │   ├── KickerLeft, KickerRight
│   └── Launcher (Node2D)
│       ├── LaunchRamp
│       ├── Flapper
│       ├── Plunger
│       └── RocketSprite
├── Balls (Node2D)              # Container for Ball instances
├── GameManager (Node)           # Or autoload GameManagerV4
├── UI (CanvasLayer)             # HUD: score, multiplier, rounds
└── Overlays (CanvasLayer)       # Play button, Replay button, mobile controls
```

### 2.2 Start Flow Scenes

- **MainMenuV4** or **StartFlow**: Initial screen with Play → navigates to CharacterSelect.
- **CharacterSelect**: Four themes (Sparky, Dino, Dash, Android); selection stores theme, then navigates to HowToPlay.
- **HowToPlay**: Single screen; dismiss → start game (load Main/PinballGameV4, set StartFlow = play, Game status = playing).

Alternatively, all three can be sub-scenes or UI layers controlled by one root (e.g. MainMenuV4 as root that switches between initial, character select, how to play, then loads game scene).

### 2.3 Backbox

- **Backbox** node: Holds current display (Leaderboard, InitialsForm, GameOverInfo, Share, Loading, Failure). Switch display via BackboxManager state; position above playfield (e.g. y = -87 in world or in UI space).

---

## 3. Script Architecture

### 3.1 GameManager (GameBloc equivalent)

**Script**: e.g. `scripts/v4/GameManagerV4.gd` or extend existing `GameManager.gd` for v4.0.

**State**:
- `round_score: int`
- `total_score: int`
- `multiplier: int` (1–6)
- `rounds: int` (3)
- `bonus_history: Array` (enum or string: googleWord, dashNest, etc.)
- `status: Enum` (waiting, playing, gameOver)

**Signals**:
- `scored(points: int)`
- `round_lost()`
- `bonus_activated(bonus: String)`
- `multiplier_increased()`
- `game_over()`
- `game_started()`

**Methods**:
- `add_score(points: int)` – only if status == playing; emit scored, update round_score.
- `on_round_lost()` – total_score += round_score * multiplier; round_score = 0; multiplier = 1; rounds -= 1; if rounds == 0 emit game_over; else request new ball.
- `increase_multiplier()` – multiplier = min(6, multiplier + 1); emit multiplier_increased.
- `add_bonus(bonus: String)` – append to bonus_history; emit bonus_activated.
- `start_game()` – status = playing; rounds = 3; etc.; emit game_started; spawn ball.
- `display_score() -> int` – return round_score + total_score (capped).

### 3.2 StartFlow (StartGameBloc equivalent)

Can be part of GameManagerV4 or a separate node (e.g. StartFlowManager).

**State**: initial | selectCharacter | howToPlay | play

**Signals**: `flow_changed(state)`

**Methods**: `play_tapped()`, `character_selected()`, `how_to_play_finished()`, `replay_tapped()`.

### 3.3 BackboxManager (BackboxBloc equivalent)

**State**: LeaderboardSuccess(entries) | LeaderboardFailure | Loading | InitialsForm(score, character) | InitialsSuccess(score) | InitialsFailure | Share(score)

**Signals**: `state_changed(state)`

**Methods**: `request_initials(score, character)`, `submit_initials(initials)`, `request_share(score)`, `load_leaderboard()`.

**Persistence**: Leaderboard entries stored locally (e.g. SaveManager or JSON file); optional REST/backend later.

### 3.4 Zone Scripts (Behaviors)

Each zone script:
- Listens for ball/body contact (Area2D body_entered or RigidBody2D collision).
- Calls GameManagerV4.add_score(points) and optionally GameManagerV4.add_bonus(bonus).
- Ramp zone: track hit count; every 5 hits call GameManagerV4.increase_multiplier().
- Google Word / Dash Nest: track lit state; when all lit, add_bonus and trigger bonus ball (GameManagerV4 or dedicated timer).

**Mapping**:
- SkillShot: Area2D, 1M points.
- GoogleGallery: Rollovers 5k; GoogleWord bonus when all lit.
- AndroidAcres: Ramp 5k/1M, ramp multiplier every 5 hits, bumpers 20k, spaceship 200k + bonus.
- DinoDesert: Dino mouth 200k + bonus; DinoWalls used for bonus ball spawn position.
- FlutterForest: Signpost 5k, Dash bumpers 20k/200k, Dash Nest bonus + bonus ball.
- SparkyScorch: Bumpers 20k, computer 200k + bonus.
- Kickers (BottomGroup): 5k each.
- Drain: Remove ball; if no balls left, GameManagerV4.on_round_lost().

### 3.5 Ball Spawning

- **Round start / round lost**: GameManagerV4 (or Launcher) spawns one Ball at plunger position; add to Balls container.
- **Bonus ball**: After 5s timer (when Google Word or Dash Nest bonus), spawn one Ball at DinoWalls position with impulse (e.g. Vector2(-40, 0) or scaled); add to Balls container.

### 3.6 Camera

- Script on Camera2D or main scene: on GameManagerV4 status change, tween camera position and zoom.
  - waiting: position (0, -112) or top; zoom = viewport_height / 175.
  - playing: position (0, -7.8); zoom = viewport_height / 160.
  - gameOver: position (0, -111) or top; zoom = viewport_height / 100.
- Use Tween or Camera2D position/zoom properties; match aspect and scale to project.

---

## 4. Data Flow

### 4.1 Scoring

1. Zone (e.g. bumper) detects ball contact.
2. Zone script calls `GameManagerV4.add_score(points)`.
3. GameManagerV4 updates round_score, emits `scored(points)`.
4. UI listens to `scored` and updates score label; optional score popup (5k, 20k, 200k, 1M).

### 4.2 Round Lost

1. Drain body_entered(Ball) → remove ball from tree.
2. If no balls left in Balls container → call `GameManagerV4.on_round_lost()`.
3. GameManagerV4 updates total_score, round_score, multiplier, rounds; emits `round_lost`; if rounds > 0 spawn new ball at launcher; if rounds == 0 emit `game_over`.

### 4.3 Bonus and Bonus Ball

1. Zone (e.g. Google Word all lit) calls `GameManagerV4.add_bonus("googleWord")`.
2. GameManagerV4 appends to bonus_history, emits `bonus_activated`.
3. If bonus is googleWord or dashNest: start 5s timer; on timeout spawn bonus ball at DinoWalls with impulse. Multiball indicators animate (listen to bonus_activated or last bonus in history).

### 4.4 Multiplier

1. Ramp zone tracks hits; every 5th hit call `GameManagerV4.increase_multiplier()` (if multiplier < 6).
2. GameManagerV4 updates multiplier, emits `multiplier_increased`.
3. UI updates multiplier label.

### 4.5 Game Over and Backbox

1. GameManagerV4 emits `game_over()`.
2. Root or UI switches to backbox state: BackboxManager.request_initials(final_score, character).
3. BackboxManager emits InitialsForm(score, character); Backbox shows initials input.
4. User submits → BackboxManager.submit_initials(initials) → save to local leaderboard → InitialsSuccess → Backbox shows game over info and share option.
5. Share: copy score text or native share; BackboxManager.request_share(score).

---

## 5. Signals Summary

| Signal | Source | Args | Listeners |
|--------|--------|------|-----------|
| scored | GameManagerV4 | points: int | UI, optional popup |
| round_lost | GameManagerV4 | — | Camera, Ball spawn, UI |
| bonus_activated | GameManagerV4 | bonus: String | Multiball indicators, Bonus ball timer |
| multiplier_increased | GameManagerV4 | — | UI |
| game_over | GameManagerV4 | — | BackboxManager, Camera, Overlays |
| game_started | GameManagerV4 | — | Camera, Ball spawn |
| flow_changed | StartFlow | state | UI (screens), Game load |
| state_changed | BackboxManager | state | Backbox (switch display) |

---

## 6. File Layout (Suggested)

```
scripts/
  v4/
    GameManagerV4.gd      # Game state, scoring, rounds, bonus, multiplier
    StartFlowManager.gd   # Optional; or inside GameManagerV4
    BackboxManagerV4.gd   # Backbox state, leaderboard, initials, share
    CameraBehaviorV4.gd  # Camera zoom/position per status
  # Zone scripts (or under v4/zones/)
    AndroidAcresV4.gd     # Ramp, bumpers, spaceship
    DinoDesertV4.gd       # Dino, slingshots
    GoogleGalleryV4.gd    # Rollovers, word
    FlutterForestV4.gd    # Signpost, Dash bumpers
    SparkyScorchV4.gd     # Sparky bumpers, computer
    SkillShotV4.gd       # 1M target
    DrainV4.gd            # Drain logic
    LauncherV4.gd        # Plunger, spawn position
scenes/
  MainV4.tscn            # Or PinballGameV4.tscn
  MainMenuV4.tscn         # Play → Character → How to Play
  BackboxV4.tscn         # Optional sub-scene for backbox
```

---

## 7. Reuse from Existing Project

- **Ball.gd**: Reuse physics and scene; ensure spawn at launcher position and layer.
- **Flipper.gd**: Reuse left/right flipper; ensure input left/right half on mobile.
- **Launcher.gd**: Reuse or adapt for plunger + rocket sprite; integrate spawn point for GameManagerV4.
- **SoundManager**: Reuse for bumper, kicker, rollover, drain, launch, bonus.
- **assets/sprites/v3.0**: Reuse android_spaceship, dino_chomp, google_word, sparky_turbo_charge, dash_nest, key, space, etc., where they match v4.0 assets (see Asset-Requirements-v4.0.md).

---

## 8. Reference

- Flutter: `lib/game/bloc/game_bloc.dart`, `lib/game/pinball_game.dart`, `lib/game/components/*`, [FLUTTER-PINBALL-PARSING.md](FLUTTER-PINBALL-PARSING.md).

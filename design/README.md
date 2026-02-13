# Pinball Game v4.0 – Design Documentation

## Overview

This directory contains design documentation for Pinball Game v4.0. Version 4.0 replicates the **same functions and game design** as the open-source **I/O Pinball** (Flutter + Forge2D, Google I/O 2022) at `/Users/junjiepan/github/pinball`, implemented in **Godot 4.x**.

v4.0 does **not** include shop, currency, or battle pass from v2/v3; it is a clone of the Flutter I/O Pinball rules, playfield zones, scoring, bonuses, multiplier, rounds, and flow.

## Document Index

### Parsing and Requirements

1. **[FLUTTER-PINBALL-PARSING.md](FLUTTER-PINBALL-PARSING.md)** – Parsing summary of the Flutter I/O Pinball project
   - Components and file paths
   - State machines (StartGameBloc, GameBloc, BackboxBloc)
   - Playfield hierarchy and point values
   - Bonus triggers, multiplier rule (5 ramp hits = +1, max 6), rounds (3), bonus ball spawn
   - Camera, character themes, input, physics
   - Cross-references to Flutter repo

2. **[Requirements-v4.0.md](Requirements-v4.0.md)** – Functional and non-functional requirements for v4.0
   - Game state, rounds, scoring, bonuses, multiplier, skill shot, all zones
   - Character select, how to play, game over, initials, leaderboard, share
   - No Firebase required; platform Godot 4.x, desktop/mobile

### Core Design

3. **[GDD-v4.0.md](GDD-v4.0.md)** – Game Design Document v4.0
   - Overview and mechanics (scoring, multiplier, bonus ball, five bonuses)
   - Playfield layout (zones and components)
   - Flow: start → character → how to play → play → game over → initials → leaderboard/share
   - UI (HUD, backbox displays, overlays), character themes, input, camera

4. **[Technical-Design-v4.0.md](Technical-Design-v4.0.md)** – System architecture for Godot
   - Scene tree (Main, Playfield, Backbox, zones, launcher, drain, flippers, ball(s))
   - Scripts mapping from Flutter components
   - State management (game + start flow + backbox), signals (Scored, RoundLost, BonusActivated, MultiplierIncreased, GameOver)

5. **[Game-Flow-v4.0.md](Game-Flow-v4.0.md)** – State diagrams and flows
   - Start flow: initial → selectCharacter → howToPlay → play
   - Game: waiting → playing → roundLost → (playing or gameOver)
   - Backbox: leaderboard / initials / game over / share
   - Round life cycle, bonus ball and multiplier flows

6. **[Component-Specifications-v4.0.md](Component-Specifications-v4.0.md)** – Zone and component specs
   - Android Acres, Dino Desert, Google Gallery, Flutter Forest, Sparky Scorch
   - Launcher, Drain, Multipliers, Multiballs, Skill Shot, Backbox
   - Behaviors (scoring, bonus, multiplier, ball spawn) and Godot equivalents

7. **[Asset-Requirements-v4.0.md](Asset-Requirements-v4.0.md)** – Art and sounds
   - Board background, bumpers, ramps, animatronics, score popups, backbox, ball variants, UI
   - References to Flutter `assets/` and pinball_components / pinball_theme assets

8. **[V4.0-IMPLEMENTATION-SUMMARY.md](V4.0-IMPLEMENTATION-SUMMARY.md)** – Implementation summary
   - How to run v4.0 (main scene MainMenuV4)
   - Implemented: GameManagerV4, start flow, playfield, drain, skill shot, UI, game over
   - Not yet: full zones, bonus ball triggers, backbox leaderboard/initials/share, camera behavior

9. **Implementation history (Minimax extension)** – **[PINBALL_CHANGELOG.md](PINBALL_CHANGELOG.md)** and **[GDD-v4.0.md §10](GDD-v4.0.md)** document the four-phase extension (32 systems: core, enhancement, polish, additional + 5 zones). Script vs autoload names (e.g. ScreenShake.gd → `ScreenShake`) are listed there. Agent API: `agent_doc/SYSTEMS.md`.

## Related

- **Implementation:** Godot project under [scripts/](../scripts/), [scenes/](../scenes/), [assets/](../assets/) (v4.0-specific or shared).
- **v3.0 design:** [design-v3.0/](../design-v3.0/) – enhanced physics, skill shot, multiball, multiplier, polish (different scope from v4.0 clone).
- **Source:** Flutter I/O Pinball at `/Users/junjiepan/github/pinball`.

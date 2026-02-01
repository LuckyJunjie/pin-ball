# Pinball Game v4.0 – Game Design Document

## Document Information

- **Game Title**: Pinball (v4.0 – I/O Pinball Clone)
- **Version**: 4.0
- **Source**: Same game design as Flutter I/O Pinball (Google I/O 2022)
- **Engine**: Godot 4.x
- **Platform**: Desktop and mobile

---

## 1. Game Overview

### 1.1 Concept

v4.0 is a faithful clone of the open-source I/O Pinball: same rules, playfield zones, scoring, bonuses, multiplier, rounds, and flow. The game is implemented in Godot 4.x with no shop, currency, or battle pass; leaderboard and share use local or optional backend.

### 1.2 Core Loop

1. **Start**: Play → Character select (4 themes) → How to Play → Game starts.
2. **Play**: Camera focuses on playfield; player has 3 rounds. Each round: ball at launcher, player launches and plays until ball drains; round score is multiplied by current multiplier and added to total; multiplier resets to 1, rounds decrease.
3. **Game Over**: When rounds reach 0, backbox shows initials → submit to leaderboard → game over info → share (optional). Replay returns to character select.

### 1.3 Win Condition

- No "win" state; goal is to maximize total score (roundScore * multiplier per round, summed) and appear on the leaderboard.

---

## 2. Mechanics

### 2.1 Scoring

- **Display score**: roundScore + totalScore (capped at 9999999999).
- **During round**: Hits add points to roundScore (5k, 20k, 200k, 1M depending on target).
- **End of round**: totalScore += roundScore * multiplier; then roundScore = 0, multiplier = 1.

### 2.2 Multiplier

- **Range**: 1–6.
- **Increase**: +1 for every 5 successful ramp shots (SpaceshipRamp in Android Acres). At 6, no further increase from ramp.
- **Reset**: To 1 on each round lost.

### 2.3 Bonus Ball

- **Trigger**: Google Word (all letters lit) or Dash Nest (all Dash bumpers lit).
- **Effect**: Bonus recorded; after 5 seconds a bonus ball spawns from DinoWalls area with impulse toward center. Multiball indicators (4) animate when bonus ball is earned.

### 2.4 Bonuses (Five)

| Bonus | Trigger |
|-------|---------|
| googleWord | All Google letters lit |
| dashNest | All Dash bumpers lit |
| sparkyTurboCharge | Ball enters Sparky computer target |
| dinoChomp | Ball enters Chrome Dino mouth |
| androidSpaceship | Ball enters Android spaceship target |

- googleWord and dashNest also trigger bonus ball (5s delay). All bonuses are recorded in bonusHistory.

---

## 3. Playfield Layout

### 3.1 Zones (Top to Bottom / Logical Order)

- **Backbox**: Marquee and display (leaderboard, initials, game over, share). Position above board (e.g. y = -87 in Flutter coords).
- **Google Gallery**: Center; Google Word + left/right rollovers (5k each).
- **Multipliers**: Five multiplier targets (x2–x6) at fixed positions.
- **Multiballs**: Four indicator lights (lit when bonus ball earned).
- **Skill Shot**: Rollover/target for 1M points.
- **Android Acres**: Left; SpaceshipRamp, rail, Android bumpers A/B/COW, AndroidSpaceship + animatronic.
- **Dino Desert**: Near launcher; ChromeDino, DinoWalls, Slingshots.
- **Flutter Forest**: Top right; Signpost, Dash bumpers main/A/B, Dash animatronic.
- **Sparky Scorch**: Top left; Sparky bumpers A/B/C, Sparky animatronic, Sparky computer.
- **Drain**: Bottom edge; ball contact removes ball and triggers round-lost when no balls left.
- **Bottom Group**: Left and right; flippers, baseboard, kickers (5k each).
- **Launcher**: Right side; launch ramp, flapper, plunger, rocket sprite; ball spawns here at round start.

### 3.2 Board Dimensions

- Reference: 101.6 x 143.8 (Flutter BoardDimensions). Godot may use same aspect or scale to fit viewport.

---

## 4. Flow

### 4.1 Start Flow

1. **Initial**: Play button visible.
2. **Select Character**: User picks Sparky, Dino, Dash, or Android.
3. **How to Play**: User dismisses to continue.
4. **Play**: Game starts; status = playing; camera to playfield; ball spawns at launcher.

### 4.2 Game State

- **Waiting**: Before first ball in play (e.g. camera on backbox/top).
- **Playing**: Ball(s) in play; scoring and multiplier active; camera on playfield.
- **Game Over**: Rounds = 0; backbox shows initials then game over info.

### 4.3 Backbox Flow

- **Loading**: Fetching leaderboard (or local load).
- **Leaderboard**: Top 10 when idle or before game.
- **Initials**: After game over; user enters initials and submits.
- **Game Over Info**: After submit; option to share.
- **Share**: User can share score (e.g. copy text or native share).

---

## 5. UI and Presentation

### 5.1 HUD (When Playing, Not Game Over)

- Score (roundScore + totalScore).
- Multiplier (1x–6x).
- Rounds left (3 down to 0).

### 5.2 Overlays

- **Play button**: Before game starts (start flow).
- **Replay button**: After game over.
- **Mobile controls**: Optional overlay when showing initials on mobile (match Flutter behavior).

### 5.3 Backbox Displays

- Leaderboard (top 10: rank, initials, score, character icon).
- Initials input (score, character icon, submit).
- Game over info (score, share button).
- Share options (e.g. copy score text, share URL).
- Loading and failure states for leaderboard/initials.

### 5.4 Character Themes

- **Sparky, Dino, Dash, Android**: Each provides ball asset and leaderboard icon. Selection affects only visuals for the session.

---

## 6. Input

- **Desktop**: Keyboard – left flipper (e.g. A/Left), right flipper (e.g. D/Right), plunger (e.g. Space or dedicated key).
- **Mobile**: Touch – left half of board = left flipper, right half = right flipper; tap on plunger/rocket = launch ball.
- **Replay**: Button or tap to go back to character select after game over.

---

## 7. Camera

- **Waiting**: Zoom/focus on top of board (e.g. backbox area).
- **Playing**: Zoom/focus on playfield (e.g. center y ≈ -7.8).
- **Game Over**: Zoom/focus on top (e.g. backbox).

Exact zoom ratios and positions should match playability and aspect ratio (reference: Flutter camera focusing behavior).

---

## 8. Audio (Recommendations)

- Bumper hit, kicker hit, rollover, drain, ball launch, bonus, multiplier increase, and UI feedback. Use or adapt assets from Flutter pinball_audio / project assets.

---

## 9. Reference

- Design and behavior parity with Flutter I/O Pinball; see [FLUTTER-PINBALL-PARSING.md](FLUTTER-PINBALL-PARSING.md) and [Component-Specifications-v4.0.md](Component-Specifications-v4.0.md) for details.

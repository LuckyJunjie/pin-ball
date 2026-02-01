# Pinball Game v4.0 – Requirements Specification

## Document Information

- **Game Title**: Pinball (v4.0 – I/O Pinball Clone)
- **Version**: 4.0
- **Source**: Same functions and game design as Flutter I/O Pinball (Google I/O 2022) at `/Users/junjiepan/github/pinball`
- **Engine**: Godot 4.x
- **Platform**: Desktop and mobile (no Firebase required; leaderboard/share via local or optional backend)

---

## 1. Functional Requirements

### 1.1 Start Flow

- **FR-1.1.1**: App shall show an initial screen with a Play action.
- **FR-1.1.2**: On Play, the app shall show a character selection screen with four themes (Sparky, Dino, Dash, Android).
- **FR-1.1.3**: On character selected, the app shall show a How to Play screen.
- **FR-1.1.4**: On How to Play finished, the app shall start the game (transition to playfield, game status = playing).
- **FR-1.1.5**: On Replay (after game over), the app shall return to character selection.

### 1.2 Game State

- **FR-1.2.1**: Game shall maintain: roundScore, totalScore, multiplier (1–6), rounds (initial 3), bonusHistory (list of bonuses), status (waiting | playing | gameOver).
- **FR-1.2.2**: Display score shall be roundScore + totalScore; max score 9999999999.
- **FR-1.2.3**: On round lost: totalScore += roundScore * multiplier (capped); roundScore = 0; multiplier = 1; rounds -= 1; if rounds == 0 then status = gameOver.
- **FR-1.2.4**: Scoring shall apply only when status is playing; roundScore shall increase by points from hits.

### 1.3 Rounds and Ball

- **FR-1.3.1**: Game shall have 3 rounds; when all balls of a round are lost, the round ends and the next round starts (new ball at launcher) until rounds reach 0.
- **FR-1.3.2**: When the last ball of a round drains, the game shall emit RoundLost logic (update totalScore, roundScore, multiplier, rounds, status).
- **FR-1.3.3**: A new ball shall spawn at the launcher (plunger position) when a round starts (game start or after round lost) while status is playing.
- **FR-1.3.4**: Bonus ball shall spawn after 5 seconds from a defined position (DinoWalls area) with an impulse toward the center when triggered by Google Word or Dash Nest bonus.

### 1.4 Scoring and Points

- **FR-1.4.1**: Point values shall be: 5000, 20000, 200000, 1000000.
- **FR-1.4.2**: Skill shot shall award 1,000,000 points.
- **FR-1.4.3**: Rollovers (Google), Kicker, Signpost shall award 5,000 points.
- **FR-1.4.4**: Android/Dash/Sparky bumpers shall award 20,000 points; main Dash bumper and animatronic/computer/dino mouth targets shall award 200,000 where specified.
- **FR-1.4.5**: Ramp shot shall award 5,000; ramp bonus shall award 1,000,000.
- **FR-1.4.6**: Score popups (5k, 20k, 200k, 1M) shall be shown when scoring (optional but recommended).

### 1.5 Multiplier

- **FR-1.5.1**: Multiplier shall range from 1 to 6.
- **FR-1.5.2**: Multiplier shall increase by 1 when the ball completes 5 ramp hits (SpaceshipRamp); when at 6, no further increase from ramp.
- **FR-1.5.3**: Multiplier shall reset to 1 on round lost.
- **FR-1.5.4**: Multiplier shall be applied to roundScore when the round ends (totalScore += roundScore * multiplier).

### 1.6 Bonuses

- **FR-1.6.1**: Bonuses shall be: googleWord, dashNest, sparkyTurboCharge, dinoChomp, androidSpaceship.
- **FR-1.6.2**: Google Word bonus: when all Google letters are lit, award bonus and trigger bonus ball (after 5s).
- **FR-1.6.3**: Dash Nest bonus: when all Dash bumpers are lit, award bonus and trigger bonus ball (after 5s).
- **FR-1.6.4**: Sparky Turbo Charge, Dino Chomp, Android Spaceship: award bonus when ball enters the corresponding target (computer sensor, dino mouth, spaceship).
- **FR-1.6.5**: Bonus history shall be recorded and shown (e.g. backbox or HUD) and used for multiball indicator logic.

### 1.7 Playfield Zones and Components

- **FR-1.7.1**: Playfield shall include: Backbox, Google Gallery, Multipliers, Multiballs (indicators), Skill Shot, Android Acres, Dino Desert, Flutter Forest, Sparky Scorch, Drain, Bottom Group (flippers, baseboard, kickers), Launcher.
- **FR-1.7.2**: Launcher shall include: launch ramp, flapper, plunger, rocket sprite; ball shall be launched by user action (e.g. tap/button).
- **FR-1.7.3**: Drain shall remove the ball on contact and trigger round-lost logic when no balls remain.
- **FR-1.7.4**: Flippers (left/right) shall be controllable by keyboard and touch (left half = left flipper, right half = right flipper); plunger/rocket tap shall launch ball.
- **FR-1.7.5**: Android Acres: SpaceshipRamp (5k shot, 1M bonus, progress, multiplier +1 every 5 hits, reset), rail, Android bumpers A/B/COW (20k), AndroidSpaceship + animatronic (200k, bonus).
- **FR-1.7.6**: Dino Desert: ChromeDino (200k inside mouth, bonus), DinoWalls, Slingshots.
- **FR-1.7.7**: Google Gallery: Google Word, two rollovers (5k each); spell "Google" → bonus + bonus ball.
- **FR-1.7.8**: Flutter Forest: Signpost (5k), Dash bumpers main (200k)/A/B (20k), Dash animatronic; all dash bumpers lit → Dash Nest bonus + bonus ball.
- **FR-1.7.9**: Sparky Scorch: Sparky bumpers A/B/C (20k), Sparky animatronic, Sparky computer (200k sensor, bonus).
- **FR-1.7.10**: Multiplier targets x2–x6 shall be present at specified positions; Multiball indicators (4) shall light/animate when bonus ball is earned (e.g. after Google Word or Dash Nest).

### 1.8 Backbox and Game Over

- **FR-1.8.1**: Backbox shall display: loading, leaderboard (top 10), initials form, game over info, share.
- **FR-1.8.2**: When game over (rounds == 0), backbox shall show initials input; on submit, store entry (local or mock leaderboard) and show game over info with option to share.
- **FR-1.8.3**: Leaderboard shall show top 10 entries (initials, score, character icon); may be local/mock without Firebase.
- **FR-1.8.4**: Share shall offer same UX as Flutter (e.g. copy score text or share URL); implementation may be local (copy/share dialog) without Firebase.

### 1.9 Character Selection

- **FR-1.9.1**: Four character themes shall be selectable: Sparky, Dino, Dash, Android.
- **FR-1.9.2**: Selected theme shall determine ball asset and leaderboard icon for the session.
- **FR-1.9.3**: How to Play shall be shown after character selection and before play.

### 1.10 Camera and HUD

- **FR-1.10.1**: Camera shall focus/zoom: waiting (top of board), playing (playfield), game over (top).
- **FR-1.10.2**: HUD shall show score, multiplier, and rounds when playing and not game over.
- **FR-1.10.3**: Overlays: Play button (before play), Replay button (after game over), optional mobile controls overlay when entering initials on mobile.

---

## 2. Non-Functional Requirements

- **NFR-2.1**: Game shall run at target frame rate (e.g. 60 FPS) on supported platforms.
- **NFR-2.2**: Input latency for flippers and plunger shall be minimal (responsive).
- **NFR-2.3**: Game shall be playable on desktop (keyboard) and mobile (touch: left/right flipper by side, tap plunger to launch).
- **NFR-2.4**: No dependency on Firebase; leaderboard and share shall work with local storage or optional backend.

---

## 3. Technical Requirements

- **TR-3.1**: Engine: Godot 4.x.
- **TR-3.2**: Physics: 2D physics (gravity e.g. 30 units/s² in world space to match Flutter Forge2D; board dimensions reference 101.6 x 143.8).
- **TR-3.3**: State management shall support: Start flow (initial → selectCharacter → howToPlay → play), Game state (waiting, playing, gameOver), Backbox state (leaderboard, initials, game over, share).
- **TR-3.4**: Signals or equivalent for: Scored, RoundLost, BonusActivated, MultiplierIncreased, GameOver, and backbox events.

---

## 4. Out of Scope for v4.0

- Shop, in-app currency, battle pass (v2/v3 features).
- Firebase Authentication or Firestore (optional; v4.0 can use local/mock leaderboard and share).

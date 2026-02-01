# v4.0 Refactor for Flutter I/O Pinball Parity

## Completed (this refactor)

### 1. Flutter assets reused
- **Source:** `/Users/junjiepan/github/pinball` (pinball_components, pinball_theme, main assets)
- **Destination:** `assets/sprites/v4.0/`
- **Contents:** board_background.png, backbox/marquee.png, android/, dash/, dino/, sparky/, google_word/, multiplier/, multiball/, skill_shot/, plunger/, launch_ramp/, flipper/, kicker/, score/, boundary/, baseboard/, etc.
- **Usage:** MainV4 uses `board_background.png` for playfield and `backbox/marquee.png` for backbox marquee at top.

### 2. Backbox UI (Flutter-style)
- **Score:** "score:" (lowercase) + score value, matching Flutter ScoreView.
- **Ball Ct:** "Ball Ct:" + 3 round indicators (yellow squares when round available, dim when lost), matching RoundCountDisplay (3 rounds).
- **Marquee:** TextureRect at top using Flutter marquee image.
- **Bottom banner:** "I/O PINBALL" and "FREE PLAY | 3 Balls Per Game" at bottom center.

### 3. Playfield layout (Flutter coordinates)
- **Transform:** Flutter (x, y) → Godot (400 + x×5, 300 + y×5). See FLUTTER-LAYOUT-AND-ASSETS.md.
- **Launcher:** Position (605, 518.5) from Flutter (41, 43.7).
- **Flippers:** Left (339.75, 518), Right (424, 518) from Flutter flipper positions.
- **Board background:** Flutter board_background.png, scaled 0.5, centered at (400, 300).

### 4. Game mechanics (already aligned with Flutter)
- **GameManagerV4:** round_score, total_score, multiplier (1–6), rounds (3), bonus_history, status (waiting, playing, gameOver). Round lost: totalScore += roundScore×multiplier; multiplier reset to 1; rounds decrement.
- **Scoring:** 5k, 20k, 200k, 1M (skill shot 1M; bumpers 20k/200k).
- **Drain:** Ball removal and RoundLost when no balls left.
- **Start flow:** Play → Character select (4 themes) → How to play → Game.

### 5. BackboxBloc parity (this session)
- **BackboxManagerV4** (autoload): States LeaderboardSuccess, LeaderboardFailure, Loading, InitialsForm, InitialsSuccess, InitialsFailure, Share. Mock leaderboard (no Firebase). `request_initials(score, character_key)`, `submit_initials(initials)`, `request_share(score)`, `go_to_leaderboard()`.
- **Backbox views:** BackboxContent in MainV4 UI: LeaderboardPanel (top 10 list), InitialsPanel (3-letter OptionButtons + Submit), GameOverInfoPanel (after submit). Game Over panel (Replay) shows only after initials submitted (Flutter flow).
- **Character:** MainMenuV4 sets `BackboxManagerV4.selected_character_key` on character select; game over passes it to `request_initials`.

### 6. Camera focusing (this session)
- **MainV4._apply_camera_status():** Flutter CameraFocusingBehavior parity – waiting zoom=175/vp.y pos (0,-112)×5; playing 160/vp.y (0,-7.8)×5; gameOver 100/vp.y (0,-111)×5. Connected on game_started and game_over.

### 7. Score view parity (this session)
- **UIV4:** When game over, score area shows "Game Over" (Flutter ScoreView); Ball Ct column hidden. Multiplier label visible during play, shows "Multiplier: Nx".

### 8. Ramp multiplier (this session)
- **RampV4.gd:** Area2D on Playfield; body_entered (ball) → add_score(5000), hit_count++; every 5 hits → GameManagerV4.increase_multiplier(). Ramp node in MainV4.tscn.

## Remaining for full parity

- **Zones with Flutter art and behavior:** Google Gallery (GOOGLE letters, rollovers), Android Acres (full ramp visual, bumpers, spaceship), Dino Desert (Chrome Dino, slingshots), Flutter Forest (Dash bumpers, signpost), Sparky Scorch (bumpers, computer). Use assets under `assets/sprites/v4.0/` and Component-Specifications-v4.0.md.
- **Bonuses:** googleWord, dashNest, sparkyTurboCharge, dinoChomp, androidSpaceship (bonus ball 5s after Google Word or Dash Nest already in GameManagerV4).
- **Share display:** Backbox ShareState view (copy/share message); optional.
- **Character theme:** Apply selected theme to ball sprite and leaderboard icon.

## Reference

- Flutter layout and coordinates: [FLUTTER-LAYOUT-AND-ASSETS.md](FLUTTER-LAYOUT-AND-ASSETS.md)
- Flutter parsing: [FLUTTER-PINBALL-PARSING.md](FLUTTER-PINBALL-PARSING.md)
- Component specs: [Component-Specifications-v4.0.md](Component-Specifications-v4.0.md)

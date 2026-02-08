# Pinball Game v3.0 - Game Flow and State Management

## 1. Enhanced Game Flow Overview

### 1.1 High-Level Flow (v3.0 Enhanced)

```
Application Launch
  ↓
Load Main Menu Scene
  ↓
[Check Daily Login / Challenges] (v2.0)
  ↓
Player Selects Action:
  ├─→ [Play] → Load Main.tscn → Enhanced Gameplay Flow (v3.0)
  ├─→ [Shop] → Load ShopScene → Shop Flow (v2.0)
  ├─→ [Customize] → Load CustomizeScene → Customize Flow (v2.0)
  ├─→ [Battle Pass] → Load BattlePassScene → Battle Pass Flow (v2.0)
  └─→ [Settings] → Settings Menu
```

### 1.2 Enhanced Gameplay Flow (v3.0)

```
1. Player Selects "Play" from Main Menu
   ↓
2. Load Main.tscn Scene
   ↓
3. Initialize Systems:
   - GameManager initializes
   - v3.0: Initialize v3.0 systems (if v3.0 mode)
     ├─→ MultiballManager
     ├─→ ComboSystem
     ├─→ AnimationManager
     └─→ ParticleManager
   - BallQueue creates 4 standby balls
   - ObstacleSpawner places obstacles
   - v3.0: SkillShotSpawner places skill shots
   ↓
4. Game Ready - Waiting for Ball Release
   ↓
5. Player Presses Down Arrow (Release Ball)
   ↓
6. Ball Released from Queue
   ↓
7. Ball Falls Through Maze Pipe
   ↓
8. Ball Arrives at Launcher
   ↓
9. v3.0: Skill Shots Activate (2-3 second window)
   ↓
10. Player Charges Launcher (Hold Space)
    ↓
11. Player Releases Launcher
    ↓
12. Ball Launched to Playfield
    ↓
13. v3.0: Ball Can Hit Skill Shot Targets
    ↓
14. Ball Interacts with Obstacles:
    ├─→ v3.0: ComboSystem.register_hit()
    ├─→ v3.0: GameManager._update_multiplier()
    ├─→ v3.0: Obstacle._apply_bumping_force()
    ├─→ v3.0: Obstacle._spawn_hit_particles()
    ├─→ Score Points (with multipliers)
    └─→ v3.0: AnimationManager.animate_score_popup()
    ↓
15. Ball Interacts with Holds:
    ├─→ Final Scoring (with multipliers)
    └─→ Ball Removed
    ↓
16. v3.0: Check for Multiball Trigger
    ↓
17. Repeat from Step 4 (or Game Over)
```

## 2. v3.0 State Management

### 2.1 Game States (Enhanced)

**Inherited States** (from v1.0/v2.0):
- `Initializing` - Game initialization
- `Waiting for Release` - Waiting for ball release
- `Ball at Launcher` - Ball ready at launcher
- `Playing` - Ball in play
- `Paused` - Game paused
- `Ball Ended` - Ball lost or captured

**New v3.0 States**:
- `Skill Shot Active` - Skill shot targets active (2-3 seconds)
- `Multiball Active` - Multiple balls in play
- `Combo Active` - Combo chain in progress
- `Multiplier Active` - Dynamic multiplier > 1.0x

### 2.2 State Transitions (v3.0)

```
Initializing
  ↓
Waiting for Release
  ↓
Ball at Launcher
  ↓
[Skill Shot Active] (v3.0 - 2-3 second window)
  ↓
Playing
  ├─→ [Combo Active] (v3.0 - if hits within 3s)
  ├─→ [Multiplier Active] (v3.0 - if multiplier > 1.0)
  └─→ [Multiball Active] (v3.0 - if triggered)
  ↓
Ball Ended
  ↓
Waiting for Release (or Game Over)
```

### 2.3 State Flags (v3.0)

**Concurrent States**:
- Multiple v3.0 states can be active simultaneously
- Example: Playing + Combo Active + Multiplier Active + Multiball Active
- States are independent and stack

## 3. Skill Shot Flow (NEW v3.0)

### 3.1 Skill Shot Activation Flow

```
Ball Launched
  ↓
GameManager._on_ball_launched()
  ↓
For each SkillShot in skill_shots:
  ├─→ SkillShot.activate()
  ├─→ Set is_active = true
  ├─→ Set activation_timer = time_window
  └─→ Visual: Glow/blink effect
  ↓
[Skill Shot Active State - 2-3 seconds]
  ↓
Ball Enters Skill Shot Zone:
  ├─→ SkillShot._on_body_entered()
  ├─→ Calculate points (points × difficulty_level)
  ├─→ Apply multipliers (multiball × dynamic)
  ├─→ GameManager._on_skill_shot_hit()
  ├─→ AnimationManager.animate_score_popup()
  ├─→ SoundManager.play_sound("skill_shot")
  └─→ SkillShot.deactivate()
  ↓
[Skill Shot Inactive]
```

### 3.2 Skill Shot Timeout Flow

```
Skill Shot Active
  ↓
activation_timer counts down
  ↓
activation_timer <= 0.0
  ↓
SkillShot.deactivate()
  ↓
Visual: Dimmed state
  ↓
[Skill Shot Inactive]
```

## 4. Multiball Flow (NEW v3.0)

### 4.1 Multiball Activation Flow

```
Trigger Condition (manual or automatic)
  ↓
MultiballManager.activate_multiball()
  ↓
Set is_active = true
Set duration_timer = multiball_duration
  ↓
For each ball (multiball_ball_count):
  ├─→ Wait 0.2 seconds (staggered release)
  ├─→ MultiballManager._release_multiball_ball()
  ├─→ BallQueue.release_next_ball()
  ├─→ Set distinct visual (color/trail)
  └─→ Add to active_balls array
  ↓
[Multiball Active State]
  ├─→ Scoring multiplier: 1.5x-2x
  ├─→ ParticleManager.spawn_multiball_launch()
  ├─→ AnimationManager.screen_shake()
  └─→ SoundManager.play_sound("multiball_activate")
  ↓
MultiballManager._process() (every frame):
  ├─→ Check active_balls (remove invalid)
  ├─→ Count down duration_timer
  └─→ Check end conditions
  ↓
End Condition Met:
  ├─→ All balls lost, OR
  └─→ duration_timer <= 0.0
  ↓
MultiballManager.end_multiball()
  ↓
[Multiball Inactive]
```

### 4.2 Multiball Ball Management

```
Ball Released for Multiball
  ↓
Set Distinct Visual:
  ├─→ Color: Red, Green, Blue, Yellow (rotating)
  └─→ Trail: Matching color
  ↓
Ball in Play
  ↓
Ball Lost:
  ├─→ MultiballManager._on_multiball_ball_lost()
  ├─→ Remove from active_balls
  └─→ Check if all balls lost
  ↓
[Continue or End Multiball]
```

## 5. Combo Flow (NEW v3.0)

### 5.1 Combo Start Flow

```
First Obstacle Hit
  ↓
ComboSystem.register_hit()
  ↓
Check: is_combo_active == false
  ↓
ComboSystem.start_combo()
  ├─→ Set is_combo_active = true
  ├─→ Set current_combo = 1
  ├─→ Set combo_timer = combo_window
  └─→ Emit combo_started signal
  ↓
[Combo Active State]
```

### 5.2 Combo Increase Flow

```
Obstacle Hit (within combo_window)
  ↓
ComboSystem.register_hit()
  ↓
Reset combo_timer = combo_window
Increment current_combo
  ↓
Calculate multiplier:
  multiplier = 1.0 + (current_combo × combo_multiplier_per_hit)
  ↓
Emit combo_increased signal
  ↓
UI._on_combo_increased()
  ├─→ Update combo_label
  └─→ Animate combo display
  ↓
ComboSystem._play_combo_sound()
  ├─→ Pitch increases with combo
  └─→ Rising pitch effect
  ↓
[Combo Continues]
```

### 5.3 Combo End Flow

```
Combo Active
  ↓
ComboSystem._process() (every frame)
  ├─→ Decrement combo_timer
  └─→ Check: combo_timer <= 0.0
  ↓
ComboSystem.end_combo()
  ├─→ Set is_combo_active = false
  ├─→ Reset current_combo = 0
  ├─→ Emit combo_ended signal
  └─→ UI._on_combo_ended() (hide combo display)
  ↓
[Combo Inactive]
```

## 6. Multiplier Flow (NEW v3.0)

### 6.1 Multiplier Increase Flow

```
Obstacle Hit
  ↓
GameManager._on_obstacle_hit()
  ↓
Increment obstacle_hit_count
  ↓
Check: obstacle_hit_count % 5 == 0
  ↓
GameManager._update_multiplier()
  ├─→ current_multiplier += 0.5
  ├─→ Clamp to max (10.0)
  ├─→ Reset multiplier_timer = 10.0
  └─→ Animate multiplier display
  ↓
[Multiplier Active State]
```

### 6.2 Multiplier Decay Flow

```
Multiplier Active (current_multiplier > 1.0)
  ↓
GameManager._process() (every frame)
  ├─→ Decrement multiplier_timer
  └─→ Check: multiplier_timer <= 0.0
  ↓
GameManager._process() (multiplier decay)
  ├─→ current_multiplier -= 0.5
  ├─→ Clamp to min (1.0)
  ├─→ Reset multiplier_timer = 10.0
  └─→ Update multiplier display
  ↓
[Multiplier Decayed or Still Active]
```

## 7. Scoring Flow (v3.0 Enhanced)

### 7.1 Enhanced Scoring Calculation

```
Base Points (from obstacle/hold)
  ↓
Apply Combo Multiplier (v3.0)
  ├─→ Get ComboSystem.get_combo_multiplier()
  └─→ final_points = base_points × combo_multiplier
  ↓
Apply Dynamic Multiplier (v3.0)
  ├─→ Get GameManager.current_multiplier
  └─→ final_points = final_points × current_multiplier
  ↓
Apply Multiball Multiplier (v3.0)
  ├─→ Get MultiballManager.get_scoring_multiplier()
  └─→ final_points = final_points × multiball_multiplier
  ↓
Apply v2.0 Upgrade Bonuses (if applicable)
  ↓
Final Score
  ↓
GameManager.add_score(final_points)
  ↓
AnimationManager.animate_score_popup() (v3.0)
  ↓
UI._on_score_changed() (v3.0: with animation)
```

### 7.2 Score Popup Flow (v3.0)

```
Score Calculated
  ↓
AnimationManager.animate_score_popup()
  ├─→ Create Label with "+{points}"
  ├─→ Position at ball/obstacle location
  ├─→ Animate: Scale (0.5 → 1.2 → 1.0)
  ├─→ Animate: Fade (1.0 → 0.0)
  ├─→ Animate: Move up 50 pixels
  └─→ Duration: 0.5 seconds
  ↓
Animation Complete
  ↓
Label.queue_free()
```

## 8. Particle Effect Flow (NEW v3.0)

### 8.1 Bumper Hit Particles

```
Ball Hits Bumper
  ↓
Obstacle._on_body_entered()
  ↓
Obstacle._spawn_hit_particles()
  ↓
ParticleManager.spawn_bumper_hit(position)
  ├─→ Create GPUParticles2D
  ├─→ Configure: 30 particles, 0.5s lifetime
  ├─→ Configure: Explosion pattern
  ├─→ Set position
  └─→ Add to scene
  ↓
Particles Emit
  ↓
Wait 1.0 second
  ↓
Particles.queue_free()
```

### 8.2 Multiball Launch Particles

```
Multiball Activated
  ↓
MultiballManager.activate_multiball()
  ↓
ParticleManager.spawn_multiball_launch(position)
  ├─→ Create GPUParticles2D
  ├─→ Configure: 100 particles, 1.5s lifetime
  ├─→ Configure: Burst pattern
  └─→ Add to scene
  ↓
Particles Emit
  ↓
Wait 2.0 seconds
  ↓
Particles.queue_free()
```

## 9. Error Handling

### 9.1 System Initialization Errors

```
_initialize_v3_systems() fails
  ↓
Log error
  ↓
Continue with v1.0/v2.0 systems only
  ↓
Game continues (v3.0 features disabled)
```

### 9.2 Missing Dependencies

```
System requires dependency (e.g., ParticleManager)
  ↓
Check if dependency exists
  ↓
If missing: Log warning, skip feature
  ↓
Game continues without feature
```

## 10. Performance Considerations

### 10.1 State Update Frequency

- **GameManager._process()**: Every frame (multiplier decay)
- **ComboSystem._process()**: Every frame (combo timer)
- **MultiballManager._process()**: Every frame (duration timer)
- **UI._update_ui_loop()**: Every 0.1 seconds (10 FPS)

### 10.2 Signal Optimization

- Signals used for loose coupling
- Group-based discovery for skill shots
- Direct references cached for frequent access
- Signal connections established once at initialization

---

*This document specifies v3.0 game flow. For base game flow, see Game-Flow.md (v1.0) and Game-Flow-v2.0.md (v2.0).*

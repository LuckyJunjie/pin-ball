# Pinball Game v3.0 - UI/UX Design Specification

## Overview

This document specifies UI/UX design for Pinball v3.0, inheriting all v1.0 and v2.0 UI specifications and adding v3.0 enhancements including multiplier display, combo counter, animated score popups, and enhanced visual feedback.

## 1. In-Game UI (v3.0 Enhanced)

### 1.1 Layout (Inherited + v3.0 Additions)

**Base Layout** (Inherited from v1.0/v2.0):
- Score: Top-left (20, 20)
- Instructions: Below score (hidden on mobile)
- Ball Queue: Right side (750, 300)
- Currency Display: Top-right (v2.0)
- Battle Pass XP Bar: Below currency (v2.0)

**v3.0 Additions**:
- Multiplier Display: Below score (20, 100) - NEW
- Combo Counter: Below multiplier (20, 140) - NEW
- Score Popups: Dynamic position (at ball/obstacle location) - NEW
- Visual Effects: Screen shake, glow effects - NEW

### 1.2 Score Display (v3.0 Enhanced)

**Position**: Top-left corner
**Size**: 180×40 pixels
**Font Size**: 32
**Color**: White

**v3.0 Enhancements**:
- **Animated Updates**: Score label highlights when score changes
- **Animation**: Yellow glow effect, 0.2 second duration
- **Implementation**: Uses AnimationManager.animate_component_highlight()

**Behavior**:
- Updates immediately when score changes
- Animation plays on each update
- Smooth transitions

### 1.3 Multiplier Display (NEW v3.0)

**Position**: Below score label (20, 100)
**Size**: 200×30 pixels
**Font Size**: 24
**Color**: Green (#00FF00) when active, hidden when 1.0x

**Visual Design**:
- Text: "{multiplier}x" (e.g., "2.5x", "10.0x")
- Outline: Black, 2px
- Background: Optional subtle glow

**v3.0 Behavior**:
- **Visibility**: Hidden when multiplier = 1.0x, visible when > 1.0x
- **Animation**: Pulsing scale animation (1.0 → 1.1 → 1.0, continuous)
- **Update Frequency**: Every 0.1 seconds
- **Color Change**: 
  - Green (1.0x - 3.0x)
  - Yellow (3.0x - 6.0x)
  - Orange (6.0x - 8.0x)
  - Red (8.0x+)

**Implementation**:
```gdscript
# In UI.gd
multiplier_label.text = str(multiplier) + "x"
multiplier_label.visible = (multiplier > 1.0)
animation_manager.animate_multiplier_display(multiplier_label, multiplier)
```

### 1.4 Combo Counter (NEW v3.0)

**Position**: Below multiplier display (20, 140)
**Size**: 200×30 pixels
**Font Size**: 20
**Color**: Cyan (#00FFFF)

**Visual Design**:
- Text: "Combo: {count} ({multiplier}x)" (e.g., "Combo: 5 (1.5x)")
- Outline: Black, 2px
- Background: Optional subtle glow

**v3.0 Behavior**:
- **Visibility**: Hidden when no combo active, visible when combo > 0
- **Animation**: Cyan highlight flash on each combo increase
- **Update**: Real-time as combo increases
- **Auto-hide**: Hides when combo ends

**Implementation**:
```gdscript
# In UI.gd
combo_label.text = "Combo: " + str(combo_count) + " (" + str(multiplier) + "x)"
combo_label.visible = (combo_count > 0)
animation_manager.animate_component_highlight(combo_label, Color.CYAN, 0.2)
```

### 1.5 Score Popups (NEW v3.0)

**Position**: Dynamic (at ball/obstacle location)
**Size**: Auto-sized based on text
**Font Size**: 32
**Color**: White (default), Yellow (with multiplier), Cyan (skill shot)

**Visual Design**:
- Text: "+{points}" (e.g., "+200", "+500")
- Outline: Black, 3px
- Animation: Scale up (0.5 → 1.2 → 1.0) and fade out
- Movement: Moves up 50 pixels while fading

**v3.0 Behavior**:
- **Spawn**: At obstacle/ball position when hit
- **Animation Duration**: 0.5 seconds
- **Auto-remove**: Removed after animation
- **Color Coding**:
  - White: Normal score
  - Yellow: Score with multiplier
  - Cyan: Skill shot bonus
  - Green: Combo bonus

**Implementation**:
```gdscript
# In AnimationManager.gd
animate_score_popup(
    position: Vector2,
    points: int,
    color: Color = Color.WHITE
)
```

### 1.6 Visual Effects (NEW v3.0)

**Screen Shake**:
- **Trigger**: Big hits, multiball activation, multiplier increase
- **Intensity**: 5-10 pixels
- **Duration**: 0.3-0.5 seconds
- **Implementation**: AnimationManager.screen_shake()

**Component Highlights**:
- **Trigger**: Important events (multiplier increase, combo increase)
- **Effect**: Glow/shake animation
- **Duration**: 0.2-0.3 seconds
- **Color**: Event-dependent (green for multiplier, cyan for combo)

**Glow Effects**:
- **Bumpers**: Blinking glow when ready
- **Skill Shots**: Pulsing glow when active
- **Flippers**: Subtle glow when activated

## 2. Main Menu UI (Inherited from v2.0)

All v2.0 main menu UI specifications are maintained. No v3.0 changes.

## 3. Shop UI (Inherited from v2.0)

All v2.0 shop UI specifications are maintained. No v3.0 changes.

## 4. Customize UI (Inherited from v2.0)

All v2.0 customize UI specifications are maintained. No v3.0 changes.

## 5. Battle Pass UI (Inherited from v2.0)

All v2.0 battle pass UI specifications are maintained. No v3.0 changes.

## 6. Animation System Integration

### 6.1 UI Animation Types

**Score Popup Animation**:
- Scale: 0.5 → 1.2 → 1.0
- Fade: 1.0 → 0.0
- Movement: Up 50 pixels
- Duration: 0.5 seconds

**Multiplier Display Animation**:
- Scale: 1.0 → 1.1 → 1.0 (continuous loop)
- Duration: 0.6 seconds per cycle

**Component Highlight Animation**:
- Modulate: Original → Highlight color → Original
- Position: Shake effect (3 iterations)
- Duration: 0.2-0.3 seconds

**UI Transition Animation**:
- Fade: 0.0 → 1.0 (fade in) or 1.0 → 0.0 (fade out)
- Duration: 0.3 seconds

### 6.2 Animation Timing

- **Immediate**: Score updates, multiplier changes
- **Smooth**: UI transitions, component highlights
- **Continuous**: Multiplier pulsing, blinking effects

## 7. Visual Hierarchy (v3.0)

### 7.1 Priority Levels

**Level 1 (Highest)**:
- Score popups (dynamic, attention-grabbing)
- Multiplier display (when > 1.0x)
- Combo counter (when active)

**Level 2 (High)**:
- Score label
- Currency display
- Battle Pass XP bar

**Level 3 (Medium)**:
- Ball queue
- Instructions (desktop only)

**Level 4 (Low)**:
- Background elements
- Static UI elements

### 7.2 Color Coding

**Score Colors**:
- White: Normal score
- Yellow: Score with multiplier
- Cyan: Skill shot bonus
- Green: Combo bonus
- Orange: Multiball bonus

**Status Colors**:
- Green: Multiplier active
- Cyan: Combo active
- Yellow: Skill shot active
- Red: High multiplier (8x+)

## 8. Responsive Design (v3.0)

### 8.1 Mobile Layout

**Portrait Mode**:
- Score: Top-left (10, 10) - smaller font (24)
- Multiplier: Below score (10, 50) - smaller font (20)
- Combo: Below multiplier (10, 80) - smaller font (18)
- Currency: Top-right (10, 10)
- Score popups: Scaled down (font size 24)

**Landscape Mode**:
- Same as desktop layout
- Adjusted spacing for wider screen

### 8.2 Desktop Layout

**Standard (800×600)**:
- Full layout as specified
- All elements visible
- Optimal spacing

**Wide Screen**:
- Elements maintain relative positions
- Additional spacing for larger screens

## 9. Accessibility (v3.0)

### 9.1 Visual Accessibility

- High contrast text (white on dark background)
- Large font sizes for important information
- Clear visual indicators for active states
- Color coding with shape/symbol backup

### 9.2 Animation Accessibility

- Animations can be disabled in settings
- Reduced motion option available
- Static alternatives for animated elements

## 10. Performance Considerations

### 10.1 Animation Performance

- Tween pooling for efficient reuse
- Parallel tweens for simultaneous animations
- Auto-cleanup of completed animations
- Frame-rate independent timing

### 10.2 UI Update Performance

- UI updates limited to 10 FPS (every 0.1 seconds)
- Conditional updates (only when values change)
- Efficient label text updates
- Minimal draw calls

## 11. Implementation Details

### 11.1 UI Component Structure

```gdscript
# In UI.gd
@onready var score_label: Label
var multiplier_label: Label  # Created in _initialize_v3_ui()
var combo_label: Label  # Created in _initialize_v3_ui()
var animation_manager: Node  # Reference to AnimationManager
```

### 11.2 Update Loop

```gdscript
# In UI.gd
func _update_ui_loop():
    # Update multiplier display
    if multiplier_label:
        var multiplier = game_manager.current_multiplier
        multiplier_label.text = str(multiplier) + "x"
        multiplier_label.visible = (multiplier > 1.0)
    
    # Schedule next update
    await get_tree().create_timer(0.1).timeout
    _update_ui_loop()
```

### 11.3 Signal Connections

```gdscript
# In UI.gd
combo_system.combo_increased.connect(_on_combo_increased)
combo_system.combo_ended.connect(_on_combo_ended)
game_manager.score_changed.connect(_on_score_changed)
```

---

*This document specifies v3.0 UI enhancements. For base UI design, see UI-Design.md (v1.0) and UI-Design-v2.0.md (v2.0).*

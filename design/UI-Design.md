# Pinball Game - UI/UX Design Specification

## 1. UI Layout

### 1.1 Screen Layout

**Playfield Area**: 800x600 pixels (main game area)

**UI Overlay**: CanvasLayer on top of playfield

**Layout Structure**:
```
┌─────────────────────────────────────┐
│ UI Layer (CanvasLayer)              │
│ ┌───────────────────────────────┐   │
│ │ Score: 0        [Instructions]│   │
│ └───────────────────────────────┘   │
│                                     │
│ ┌─────────────────────────────────┐ │
│ │                                 │ │
│ │      Playfield (800x600)        │ │
│ │                                 │ │
│ │                    [Ball Queue] │ │
│ │                                 │ │
│ │  [Flippers]                     │ │
│ └─────────────────────────────────┘ │
└─────────────────────────────────────┘
```

### 1.2 UI Elements Positioning

**Score Label**:
- Position: Top-left corner
- Offset: (20, 20) from top-left
- Size: 180x40 pixels
- Font Size: 32
- Color: White or light color
- Text: "Score: {score}"

**Instructions Label**:
- Position: Below score label
- Offset: (20, 70) from top-left
- Size: 380x80 pixels
- Font Size: 16
- Color: White or light gray
- Text: Multi-line instructions

**Ball Queue** (Game Element, not UI):
- Position: Right side of playfield
- X: 750 (50px from right edge)
- Y: 300 (center vertically)
- Visual: Stacked balls, semi-transparent

## 2. Visual Design

### 2.1 Color Scheme

**Background**:
- Playfield: Dark blue-gray `Color(0.1, 0.1, 0.2, 1)`
- UI Background: Transparent (overlay)

**Text Colors**:
- Score: White `Color(1, 1, 1, 1)`
- Instructions: Light gray `Color(0.9, 0.9, 0.9, 1)`

**Game Element Colors**:
- Ball: Red `Color(1, 0.2, 0.2, 1)`
- Flippers: Light blue `Color(0.2, 0.6, 1, 1)`
- Walls: Gray-blue `Color(0.3, 0.3, 0.4, 1)`
- Bumpers: Yellow `Color(1, 1, 0.2, 1)`
- Pegs: White `Color(1, 1, 1, 1)`
- Obstacle Walls: Gray `Color(0.5, 0.5, 0.5, 1)`

### 2.2 Typography

**Score Font**:
- Size: 32 pixels
- Style: Bold (if available)
- Family: System default or Godot default

**Instructions Font**:
- Size: 16 pixels
- Style: Regular
- Family: System default or Godot default

### 2.3 Visual Hierarchy

**Primary Information** (Most Visible):
1. Score (large, top-left)
2. Active ball (red, fully opaque)
3. Flippers (bright blue)

**Secondary Information** (Visible but not distracting):
1. Instructions (smaller, below score)
2. Queued balls (semi-transparent)
3. Obstacles (various colors)

**Background Elements** (Subtle):
1. Playfield background (dark)
2. Walls (medium gray-blue)

## 3. User Experience

### 3.1 Information Display

**Always Visible**:
- Current score
- Control instructions
- Ball queue status (visual)

**Contextual**:
- Charge meter (only when launcher active, if implemented)
- Pause indicator (if pause menu implemented)

### 3.2 Feedback Mechanisms

**Visual Feedback**:
- Score updates immediately on obstacle hit
- Ball queue shows remaining balls
- Flippers visually rotate when activated
- Ball changes opacity when activated from queue

**Haptic Feedback** (Future):
- Controller vibration on flipper activation
- Controller vibration on obstacle hit

### 3.3 Clarity Principles

**Non-Intrusive UI**:
- UI elements don't obstruct gameplay
- Score and instructions in corners
- No overlay during active gameplay

**Clear Visual Distinction**:
- Active ball fully opaque
- Queued balls semi-transparent (0.8 opacity)
- Different colors for different obstacle types

**Readable Text**:
- High contrast (white on dark background)
- Appropriate font sizes
- Clear, concise instructions

## 4. UI Components

### 4.1 Score Label

**Implementation**: Label node

**Properties**:
```gdscript
offset_left = 20.0
offset_top = 20.0
offset_right = 200.0
offset_bottom = 60.0
theme_override_font_sizes/font_size = 32
text = "Score: 0"
```

**Behavior**:
- Updates when score changes
- Format: "Score: {number}"
- Left-aligned text
- Auto-updates via signal connection

### 4.2 Instructions Label

**Implementation**: Label node

**Properties**:
```gdscript
offset_left = 20.0
offset_top = 70.0
offset_right = 400.0
offset_bottom = 150.0
theme_override_font_sizes/font_size = 16
text = "Left/A: Left Flipper\nRight/D: Right Flipper\nHold Space/Down: Charge Launcher\nEsc: Pause"
```

**Behavior**:
- Multi-line text
- Static (doesn't change during gameplay)
- Left-aligned, top-aligned

### 4.3 Charge Meter (Optional)

**Implementation**: ProgressBar node

**Properties**:
```gdscript
offset_left = -50.0
offset_top = -40.0
offset_right = 50.0
offset_bottom = -30.0
min_value = 0.0
max_value = 1.0
value = 0.0
```

**Behavior**:
- Only visible when launcher is charging
- Updates in real-time during charge
- Visual feedback for launch power

## 5. Responsive Design

### 5.1 Screen Size Considerations

**Current Design**: Fixed 800x600 playfield

**Future Considerations**:
- Scaling for different screen sizes
- Aspect ratio handling
- UI element scaling

### 5.2 UI Scaling

**Fixed Positioning**:
- UI elements use fixed pixel offsets
- Works well for fixed 800x600 window

**Future Scaling**:
- Could use anchors for responsive design
- Could scale font sizes based on screen size
- Could adjust UI element positions dynamically

## 6. Accessibility

### 6.1 Visual Accessibility

**High Contrast**:
- White text on dark background
- Bright colors for game elements
- Clear visual distinction between elements

**Color Blindness Considerations**:
- Different shapes for different obstacle types
- Patterns or textures could be added
- Not relying solely on color

### 6.2 Input Accessibility

**Keyboard Controls**:
- Standard keyboard keys (Arrow keys, WASD, Space)
- No special hardware required
- Configurable input actions

**Future Enhancements**:
- Controller support
- Customizable key bindings
- On-screen button indicators

## 7. UI State Management

### 7.1 Playing State

**UI Elements**:
- Score visible and updating
- Instructions visible
- No pause menu

### 7.2 Paused State

**UI Elements**:
- Score visible (frozen)
- Instructions visible
- (Future) Pause menu overlay

### 7.3 Game Over State (Future)

**UI Elements**:
- Final score display
- Game over message
- Restart button
- High score display

## 8. Animation and Transitions

### 8.1 Score Updates

**Current**: Instant text update

**Future Enhancements**:
- Number counting animation
- Highlight flash on score increase
- Particle effects on obstacle hit

### 8.2 UI Transitions

**Current**: Static UI

**Future Enhancements**:
- Fade in/out for pause menu
- Slide animations for UI panels
- Smooth transitions between states

## 9. Localization (Future)

### 9.1 Text Elements

**Localizable Strings**:
- "Score: "
- Instruction text
- Button labels (if added)
- Game over messages (if added)

### 9.2 Implementation

- Use Godot's translation system
- Store strings in .po files
- Support multiple languages

## 10. UI Testing Checklist

### 10.1 Visual Testing

- [ ] Score displays correctly
- [ ] Instructions are readable
- [ ] UI doesn't obstruct gameplay
- [ ] Colors are distinguishable
- [ ] Text is readable at all sizes

### 10.2 Functional Testing

- [ ] Score updates correctly
- [ ] UI responds to game state changes
- [ ] No UI elements overlap
- [ ] All text is visible
- [ ] UI scales appropriately (if implemented)

### 10.3 Usability Testing

- [ ] Instructions are clear
- [ ] Score is easy to read
- [ ] UI doesn't distract from gameplay
- [ ] Information is accessible when needed
- [ ] Controls are intuitive

# Pinball Game v3.0 - Audio System Design

## Overview

This document specifies the enhanced audio system for v3.0, which includes audio bus separation, dynamic effects, pitch variation, and new sound effects. The system builds upon v1.0's basic sound system and incorporates best practices from Godot audio demos.

## 1. System Architecture

### 1.1 Audio Bus Structure

**Bus Hierarchy**:
```
Master
├── SFX (Bus 1)
│   ├── Reverb Effect (optional)
│   └── Pitch Shift Effect (optional)
├── Music (Bus 2)
│   └── Low-pass Filter (optional)
└── UI (Bus 3)
```

**Bus Configuration**:
- **SFX Bus**: Sound effects (bumpers, flippers, ball hits)
- **Music Bus**: Background music and ambient sounds
- **UI Bus**: UI feedback sounds (button clicks, notifications)

### 1.2 SoundManager Component

**Script**: `scripts/SoundManager.gd` (Enhanced)

**Class**: `extends Node`

**New Properties** (v3.0):
```gdscript
# v3.0: Audio buses
var sfx_bus: String = "Master"
var music_bus: String = "Master"
var ui_bus: String = "Master"

# v3.0: New sound players
var skill_shot_sound: AudioStreamPlayer = null
var multiball_activate_sound: AudioStreamPlayer = null
var multiball_end_sound: AudioStreamPlayer = null
var combo_hit_sound: AudioStreamPlayer = null
var background_music: AudioStreamPlayer = null
```

## 2. Sound Effects

### 2.1 Core Sound Effects (Inherited)

**Inherited from v1.0/v2.0**:
- `flipper_click` - Flipper activation sound
- `obstacle_hit` - Obstacle collision sound
- `ball_launch` - Ball launch sound
- `hold_entry` - Hold capture sound
- `ball_lost` - Ball loss sound

### 2.2 New v3.0 Sound Effects

**Skill Shot Sounds**:
- `skill_shot` - Skill shot success sound
- **Characteristics**: Distinct, rewarding tone
- **Usage**: Played when skill shot is hit

**Multiball Sounds**:
- `multiball_activate` - Multiball activation sound
- `multiball_end` - Multiball end sound
- **Characteristics**: Exciting, energetic
- **Usage**: Played when multiball starts/ends

**Combo Sounds**:
- `combo_hit` - Combo hit sound
- **Characteristics**: Rising pitch with each hit
- **Usage**: Played on each combo hit

### 2.3 Enhanced Sound Effects (v3.0)

**Bumper Hits**:
- **v3.0 Enhancement**: Pitch variation (0.9-1.1)
- **Implementation**: `play_sound_with_pitch("obstacle_hit", randf_range(0.9, 1.1))`
- **Effect**: More dynamic, less repetitive

**Flipper Clicks**:
- **v3.0 Enhancement**: Slight pitch variation
- **Implementation**: Random pitch within 0.95-1.05 range
- **Effect**: More mechanical, realistic feel

## 3. Audio Effects

### 3.1 Reverb Effect (Optional)

**Purpose**: Spatial audio for bumper hits

**Configuration**:
- **Bus**: SFX
- **Type**: AudioEffectReverb
- **Settings**: Room size, damping, wet/dry mix
- **Usage**: Applied to bumper hit sounds for depth

**Implementation**:
```gdscript
# In SoundManager._setup_audio_buses()
var sfx_bus_idx = AudioServer.get_bus_index("SFX")
if sfx_bus_idx != -1:
    var reverb = AudioEffectReverb.new()
    reverb.room_size = 0.5
    reverb.damping = 0.3
    AudioServer.add_bus_effect(sfx_bus_idx, reverb)
```

### 3.2 Pitch Shift Effect (Optional)

**Purpose**: Dynamic pitch variation

**Configuration**:
- **Bus**: SFX
- **Type**: AudioEffectPitchShift
- **Settings**: Pitch scale range
- **Usage**: Applied programmatically for pitch variation

**Implementation**:
```gdscript
# In SoundManager.play_sound_with_pitch()
player.pitch_scale = clamp(pitch_scale, 0.5, 2.0)
player.play()
```

### 3.3 Low-Pass Filter (Optional)

**Purpose**: Muffle audio during pause

**Configuration**:
- **Bus**: Music
- **Type**: AudioEffectLowPassFilter
- **Settings**: Cutoff frequency
- **Usage**: Applied when game is paused

## 4. Music System

### 4.1 Background Music

**Purpose**: Ambient pinball machine sounds or music

**Implementation**:
```gdscript
# In SoundManager
func play_music(music_path: String, loop: bool = true):
    if ResourceLoader.exists(music_path):
        var stream = load(music_path)
        if stream:
            background_music.stream = stream
            background_music.volume_db = -10.0  # Lower volume
            if loop and stream is AudioStreamOggVorbis:
                stream.loop = true
            background_music.play()
```

### 4.2 Dynamic Music

**Concept**: Music intensity increases during special modes

**Implementation**:
- Base music track plays normally
- During multiball/multiplier: Increase volume or switch to intense track
- Crossfade between tracks for smooth transitions

## 5. Sound Design Specifications

### 5.1 Bumper Hit Sound

**Characteristics**:
- Sharp, percussive
- Short duration (0.1-0.2 seconds)
- Pitch variation: 0.9-1.1
- Multiple variations for variety

**Implementation**:
```gdscript
# In Obstacle._play_hit_effect()
var sound_manager = get_tree().get_first_node_in_group("sound_manager")
if sound_manager:
    if sound_manager.has_method("play_sound_with_pitch"):
        var pitch = randf_range(0.9, 1.1)
        sound_manager.play_sound_with_pitch("obstacle_hit", pitch)
```

### 5.2 Skill Shot Sound

**Characteristics**:
- Distinct, rewarding
- Medium duration (0.3-0.5 seconds)
- Higher pitch (1.2-1.5)
- Success tone

### 5.3 Multiball Sound

**Characteristics**:
- Exciting, energetic
- Longer duration (1.0-2.0 seconds)
- Multiple layers
- Builds anticipation

### 5.4 Combo Sound

**Characteristics**:
- Rising pitch with each hit
- Short duration (0.1-0.2 seconds)
- Pitch range: 1.0 → 2.0 (with combo count)
- Satisfying feedback

**Implementation**:
```gdscript
# In ComboSystem._play_combo_sound()
var pitch = 1.0 + (current_combo * 0.05)
if pitch > 2.0:
    pitch = 2.0
sound_manager.play_sound_with_pitch("combo_hit", pitch)
```

## 6. Audio File Organization

### 6.1 File Structure

```
assets/sounds/
├── flipper_click.wav (v1.0)
├── obstacle_hit.wav (v1.0)
├── ball_launch.wav (v1.0)
├── hold_entry.wav (v1.0)
├── ball_lost.wav (v1.0)
├── skill_shot.wav (v3.0 NEW)
├── multiball_activate.wav (v3.0 NEW)
├── multiball_end.wav (v3.0 NEW)
└── combo_hit.wav (v3.0 NEW)
```

### 6.2 File Format

**Preferred**: OGG Vorbis (compressed, good quality)
**Alternative**: WAV (uncompressed, larger files)

**Settings**:
- **Sample Rate**: 44100 Hz
- **Bit Depth**: 16-bit
- **Channels**: Mono or Stereo

### 6.3 Expected Sound Files (v3.0)

**Required v3.0 Sound Files** (may not exist yet, code handles missing files gracefully):
- `skill_shot.wav` or `skill_shot.ogg` - Skill shot success sound
- `multiball_activate.wav` or `multiball_activate.ogg` - Multiball activation sound
- `multiball_end.wav` or `multiball_end.ogg` - Multiball end sound
- `combo_hit.wav` or `combo_hit.ogg` - Combo hit sound

**Note**: SoundManager gracefully handles missing files - if a sound file doesn't exist, the sound simply won't play. No errors are thrown.

## 7. Performance Considerations

### 7.1 Audio Bus Separation

- Reduces processing overhead
- Allows independent volume control
- Enables bus-specific effects

### 7.2 Sound Pooling

- Reuse AudioStreamPlayer instances
- Pre-create players for frequently used sounds
- Avoid creating players at runtime

### 7.3 Pitch Variation Efficiency

- Pitch calculations are lightweight
- No additional audio processing required
- Minimal performance impact

## 8. Integration Points

### 8.1 GameManager Integration

```gdscript
# In GameManager._on_skill_shot_hit()
play_sound("skill_shot")

# In GameManager._on_multiball_activated()
# Sound played by MultiballManager
```

### 8.2 Obstacle Integration

```gdscript
# In Obstacle._play_hit_effect()
if sound_manager.has_method("play_sound_with_pitch"):
    var pitch = randf_range(0.9, 1.1)
    sound_manager.play_sound_with_pitch("obstacle_hit", pitch)
```

### 8.3 ComboSystem Integration

```gdscript
# In ComboSystem._play_combo_sound()
var pitch = 1.0 + (current_combo * 0.05)
sound_manager.play_sound_with_pitch("combo_hit", pitch)
```

## 9. Accessibility

### 9.1 Volume Controls

- Master volume control
- Individual bus volume controls
- Per-sound volume adjustments (if needed)

### 9.2 Sound Toggle

- Enable/disable all sounds
- Enable/disable specific sound categories
- Mute option for background music

## 10. Future Enhancements

### 10.1 Spatial Audio

- 3D positioning for sound effects
- Distance-based volume attenuation
- Directional audio cues

### 10.2 Dynamic Mixing

- Automatic volume ducking
- Music fades during important events
- Context-aware audio mixing

---

*This document specifies the v3.0 audio system. For base audio design, see GDD.md (v1.0) section 10.*

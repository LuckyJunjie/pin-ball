# Pinball Game v3.0 - Asset Requirements

## Overview

This document specifies all asset requirements for v3.0, including expected sound files, sprite assets, and visual resources. Some assets may not exist yet but are expected by the implementation.

## 1. Audio Assets

### 1.1 Existing Sound Files (v1.0/v2.0)

**Location**: `assets/sounds/`

**Files**:
- `flipper_click.wav` ✅ Exists
- `obstacle_hit.wav` ✅ Exists
- `ball_launch.wav` ✅ Exists
- `hold_entry.wav` ✅ Exists
- `ball_lost.wav` ✅ Exists

### 1.2 Required v3.0 Sound Files

**Location**: `assets/sounds/`

**Status**: Expected but may not exist yet (code handles missing files gracefully)

**Files**:
- `skill_shot.wav` or `skill_shot.ogg` ⚠️ Expected
  - **Purpose**: Played when skill shot is successfully hit
  - **Characteristics**: Distinct, rewarding tone
  - **Duration**: 0.3-0.5 seconds
  - **Format**: WAV or OGG Vorbis

- `multiball_activate.wav` or `multiball_activate.ogg` ⚠️ Expected
  - **Purpose**: Played when multiball mode activates
  - **Characteristics**: Exciting, energetic
  - **Duration**: 1.0-2.0 seconds
  - **Format**: WAV or OGG Vorbis

- `multiball_end.wav` or `multiball_end.ogg` ⚠️ Expected
  - **Purpose**: Played when multiball mode ends
  - **Characteristics**: Concluding tone
  - **Duration**: 0.5-1.0 seconds
  - **Format**: WAV or OGG Vorbis

- `combo_hit.wav` or `combo_hit.ogg` ⚠️ Expected
  - **Purpose**: Played on each combo hit (with rising pitch)
  - **Characteristics**: Short, satisfying
  - **Duration**: 0.1-0.2 seconds
  - **Format**: WAV or OGG Vorbis
  - **Note**: Pitch will be varied programmatically (1.0 → 2.0)

### 1.3 Optional Audio Assets

**Background Music** (Optional):
- `background_music.ogg` - Ambient pinball machine sounds or music
- **Format**: OGG Vorbis (for looping support)
- **Volume**: Lower than SFX (-10 dB default)

## 2. Visual Assets

### 2.1 Existing Sprite Assets (v1.0/v2.0)

**Location**: `assets/sprites/`

**Files**:
- `ball.png` ✅ Exists
- `flipper.png` ✅ Exists
- `basketball_hoop.png` ✅ Exists
- `baseball_player.png` ✅ Exists
- `baseball_bat.png` ✅ Exists
- `soccer_goal.png` ✅ Exists
- `bumper.png` ✅ Exists
- `wall.png` ✅ Exists
- `background.png` ✅ Exists
- `plunger.png` ✅ Exists
- `launcher_base.png` ✅ Exists

### 2.2 Optional v3.0 Visual Assets

**Skill Shot Target Sprites** (Optional Enhancement):
- `skill_shot_target.png` - Visual sprite for skill shot targets
  - **Size**: 40×40 pixels (or larger)
  - **Style**: Glowing target, ring, or bullseye
  - **States**: Active (glowing) and inactive (dimmed)
  - **Note**: Currently uses programmatic ColorRect, sprite would enhance visuals

**Particle Textures** (Optional Enhancement):
- `particle_spark.png` - Spark texture for particle effects
- `particle_trail.png` - Trail texture for ball trails
- **Note**: Currently uses default particle rendering, custom textures would enhance visuals

## 3. Asset Loading Behavior

### 3.1 Sound File Loading

**Implementation**: `SoundManager._load_sound_files()`

**Behavior**:
- Checks both `.wav` and `.ogg` formats
- Prefers OGG, falls back to WAV
- If file doesn't exist, sound simply won't play (no error)
- Graceful degradation - game continues without sound

**Code**:
```gdscript
# Try to load sounds - check both WAV and OGG formats
for sound_name in sound_names:
	var wav_path = "res://assets/sounds/" + sound_name + ".wav"
	var ogg_path = "res://assets/sounds/" + sound_name + ".ogg"
	var sound_path = null
	
	# Prefer OGG, fall back to WAV
	if ResourceLoader.exists(ogg_path):
		sound_path = ogg_path
	elif ResourceLoader.exists(wav_path):
		sound_path = wav_path
	
	if sound_path:
		var stream = load(sound_path)
		if stream:
			sound_players[sound_name].stream = stream
```

### 3.2 Visual Asset Loading

**Skill Shot Visuals**:
- Currently created programmatically (ColorRect)
- Can be enhanced with sprite textures if provided
- Falls back to ColorRect if sprite not found

**Particle Effects**:
- Created programmatically (GPUParticles2D)
- No texture files required (uses default particle rendering)
- Can be enhanced with custom textures if provided

## 4. Asset Organization

### 4.1 Directory Structure

```
assets/
├── sounds/
│   ├── flipper_click.wav ✅
│   ├── obstacle_hit.wav ✅
│   ├── ball_launch.wav ✅
│   ├── hold_entry.wav ✅
│   ├── ball_lost.wav ✅
│   ├── skill_shot.wav ⚠️ (expected)
│   ├── multiball_activate.wav ⚠️ (expected)
│   ├── multiball_end.wav ⚠️ (expected)
│   └── combo_hit.wav ⚠️ (expected)
├── sprites/
│   ├── [existing v1.0/v2.0 sprites] ✅
│   └── skill_shot_target.png (optional enhancement)
└── particles/ (optional, for future enhancements)
	├── particle_spark.png
	└── particle_trail.png
```

## 5. Asset Creation Guidelines

### 5.1 Sound File Guidelines

**Format**:
- **Preferred**: OGG Vorbis (compressed, good quality, supports looping)
- **Alternative**: WAV (uncompressed, larger files)

**Specifications**:
- **Sample Rate**: 44100 Hz
- **Bit Depth**: 16-bit
- **Channels**: Mono (preferred) or Stereo
- **File Size**: Keep under 500 KB per file when possible

**Creation Tips**:
- Use audio editing software (Audacity, Reaper, etc.)
- Normalize audio levels
- Remove silence at start/end
- Test pitch variation (combo_hit should work well at 0.5x to 2.0x pitch)

### 5.2 Visual Asset Guidelines

**Skill Shot Target**:
- **Size**: 40×40 pixels minimum (can be larger, will be scaled)
- **Format**: PNG with transparency
- **Style**: Glowing ring, bullseye, or target design
- **Colors**: Yellow/gold when active, gray when inactive

**Particle Textures** (if creating):
- **Size**: 32×32 to 64×64 pixels
- **Format**: PNG with transparency
- **Style**: Spark, star, or circular glow
- **Background**: Transparent

## 6. Testing Without Assets

### 6.1 Missing Sound Files

**Behavior**: Game continues normally, sounds simply don't play
**Testing**: All v3.0 features work without sound files
**Note**: Visual feedback still works (animations, particles, UI)

### 6.2 Missing Visual Assets

**Behavior**: Programmatic visuals used as fallback
**Testing**: All v3.0 features work with programmatic visuals
**Enhancement**: Custom sprites improve visual quality but aren't required

## 7. Asset Status Summary

| Asset Type | Status | Required | Notes |
|------------|--------|----------|-------|
| **v1.0/v2.0 Sounds** | ✅ Complete | Yes | All exist |
| **skill_shot.wav** | ⚠️ Expected | No | Graceful degradation |
| **multiball_activate.wav** | ⚠️ Expected | No | Graceful degradation |
| **multiball_end.wav** | ⚠️ Expected | No | Graceful degradation |
| **combo_hit.wav** | ⚠️ Expected | No | Graceful degradation |
| **v1.0/v2.0 Sprites** | ✅ Complete | Yes | All exist |
| **skill_shot_target.png** | ⚠️ Optional | No | Enhancement only |
| **Particle Textures** | ⚠️ Optional | No | Enhancement only |

## 8. Implementation Notes

### 8.1 Graceful Degradation

- All v3.0 features work without new sound files
- Visual effects work with programmatic rendering
- Game is fully playable without new assets
- Assets enhance experience but aren't required

### 8.2 Asset Loading

- SoundManager checks for files and loads if available
- Missing files don't cause errors
- Visual systems use programmatic fallbacks
- Custom assets can be added later without code changes

---

*This document specifies asset requirements for v3.0. Assets marked with ⚠️ are expected but not required - the game works without them.*

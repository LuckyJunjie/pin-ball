# Pinball Game Asset Download Guide

This guide provides direct links and instructions for downloading free, open-source sounds and images for your pinball game.

## Table of Contents
1. [Sound Effects](#sound-effects)
2. [Sprite/Image Assets](#spriteimage-assets)
3. [Download Script Usage](#download-script-usage)
4. [Manual Download Instructions](#manual-download-instructions)
5. [Importing into Godot](#importing-into-godot)

---

## Sound Effects

### Recommended Sources

#### 1. Freesound.org (Primary Source)
**Website**: https://freesound.org  
**License**: Various Creative Commons licenses (CC0, CC-BY, etc.)  
**Account Required**: Yes (free registration)

**Specific Pinball Sound Packs:**
- **GameBoy's Pinball Sounds Pack**: https://freesound.org/people/GameBoy/packs/36080/
  - Contains: Bumper hits, rebound sounds
  - License: Check individual files
- **relwin's Pinball Pack**: https://freesound.org/people/relwin/packs/10675/
  - Contains: Vintage pinball sounds (bells, solenoids, flippers)
  - License: Check individual files

**Search Terms to Use:**
- "pinball flipper"
- "pinball bumper"
- "pinball click"
- "ball bounce"
- "arcade click"
- "mechanical click"

**Required Sounds for Your Game:**
1. `flipper_click.wav` - Flipper activation sound
2. `obstacle_hit.wav` - Bumper/obstacle hit sound
3. `ball_launch.wav` - Ball launch sound
4. `hold_entry.wav` - Success chime for hold entry
5. `ball_lost.wav` - Ball lost/failure sound

#### 2. OpenGameArt.org
**Website**: https://opengameart.org  
**License**: Various (CC0, CC-BY, GPL)  
**Account Required**: Optional (for downloads)

**Search**: "pinball", "arcade", "click", "bounce"

#### 3. Kenney.nl
**Website**: https://kenney.nl/assets  
**License**: CC0 (Public Domain)  
**Account Required**: No

**Note**: Kenney doesn't have a specific pinball pack, but has general game sounds that might work.

#### 4. Incompetech (Music)
**Website**: https://incompetech.com/music/royalty-free/  
**License**: CC-BY (requires attribution)  
**Account Required**: No

**Use for**: Background music tracks

---

## Sprite/Image Assets

### Recommended Sources

#### 1. OpenGameArt.org (Primary Source)
**Website**: https://opengameart.org  
**License**: Various (CC0, CC-BY, GPL)  
**Account Required**: Optional

**Specific Pinball Sprite Collections:**

1. **2D Pinball Sprites** by rounddroid
   - URL: https://opengameart.org/content/2d-pinball-sprites
   - Contains: Flippers, bumpers
   - License: Check page for details

2. **Horror Themed Pinball Game Sprites** by Keiffer
   - URL: https://opengameart.org/content/horror-themed-pinball-game-sprites
   - License: CC0 (Public Domain)
   - Contains: Various pinball sprites

3. **Beach Side Pinball Assets** by ChiliGames
   - URL: https://opengameart.org/content/beach-side-pinball-assets
   - License: CC0 (Public Domain)
   - Contains: Ocean-themed pinball sprites

**Search Terms:**
- "pinball"
- "arcade"
- "game table"
- "flipper"
- "bumper"

#### 2. Kenney.nl
**Website**: https://kenney.nl/assets  
**License**: CC0 (Public Domain)  
**Account Required**: No

**Relevant Asset Packs:**
- **Rolling Ball Assets**: https://kenney.nl/assets/rolling-ball-assets
  - Contains: Ball-related sprites (60 files)
- **Platformer Kit**: https://kenney.nl/assets/platformer-kit
  - Contains: General game sprites that might be useful

#### 3. Itch.io
**Website**: https://itch.io/game-assets/free  
**License**: Varies (check individual packs)  
**Account Required**: Optional

**Search**: "pinball", "arcade", "retro"

#### 4. Pixabay
**Website**: https://pixabay.com  
**License**: Pixabay License (free for commercial use)  
**Account Required**: No

**Search**: "pinball", "arcade background"

---

## Download Script Usage

A Python script (`scripts/download_assets.py`) is provided to help download assets from direct URLs.

### Prerequisites
```bash
pip install requests pillow
```

### Usage
```bash
cd /Users/junjiepan/Game/pin-ball
python3 scripts/download_assets.py
```

The script will:
1. Download sounds from direct URLs (if available)
2. Download sprites from direct URLs (if available)
3. Place them in the correct directories
4. Convert sounds to OGG format (if ffmpeg is available)

---

## Manual Download Instructions

### For Freesound.org:

1. **Create Account**: Go to https://freesound.org and create a free account
2. **Search**: Use the search terms listed above
3. **Filter**: 
   - Check "Commercial use allowed" filter
   - Prefer CC0 or CC-BY licenses
4. **Download**: Click download button on each sound
5. **Save**: Save files to `assets/sounds/` with appropriate names:
   - `flipper_click.wav` or `flipper_click.ogg`
   - `obstacle_hit.wav` or `obstacle_hit.ogg`
   - `ball_launch.wav` or `ball_launch.ogg`
   - `hold_entry.wav` or `hold_entry.ogg`
   - `ball_lost.wav` or `ball_lost.ogg`

### For OpenGameArt.org:

1. **Browse**: Go to the URLs listed above
2. **Download**: Click the download button
3. **Extract**: If downloaded as ZIP, extract files
4. **Select**: Choose appropriate sprites for your needs
5. **Save**: Place in `assets/sprites/` with appropriate names:
   - `ball.png`
   - `flipper.png`
   - `bumper.png`
   - `background.png`
   - etc.

### For Kenney.nl:

1. **Browse**: Go to https://kenney.nl/assets
2. **Download**: Click download button on asset packs
3. **Extract**: Extract ZIP files
4. **Select**: Choose relevant sprites
5. **Save**: Place in `assets/sprites/`

---

## Importing into Godot

### Automatic Import
Godot automatically imports assets when you:
1. Place files in `assets/sounds/` or `assets/sprites/`
2. Open the project in Godot
3. Godot will create `.import` files automatically

### Manual Reimport
If assets don't appear:
1. In Godot, go to **File System** panel
2. Right-click on the asset file
3. Select **Reimport**
4. Adjust import settings if needed

### Sound Import Settings
- **Format**: OGG Vorbis (preferred) or WAV
- **Loop**: Set per sound (usually false for SFX)
- **Compression**: Use compression for OGG files

### Sprite Import Settings
- **Format**: PNG (with transparency)
- **Filter**: Enable for smooth scaling
- **Compress**: Use compression for smaller file sizes

---

## Asset Specifications

### Sound Effects
- **Format**: OGG Vorbis (preferred) or WAV
- **Sample Rate**: 44100 Hz (standard)
- **Bit Depth**: 16-bit
- **Channels**: Mono or Stereo
- **Duration**: 
  - Flipper click: 0.05-0.1 seconds
  - Obstacle hit: 0.1-0.3 seconds
  - Ball launch: 0.2-0.5 seconds
  - Hold entry: 0.5-1.0 seconds
  - Ball lost: 0.5-1.5 seconds

### Sprites
- **Format**: PNG with transparency (alpha channel)
- **Sizes**:
  - Ball: 16x16 or larger
  - Flipper: 60x12 or larger
  - Bumper: 60x60 or larger
  - Background: 800x600 or larger
- **Color Depth**: 32-bit RGBA
- **Style**: Consistent art style across all sprites

---

## Quick Start Checklist

- [ ] Create Freesound.org account
- [ ] Download 5 required sound effects from Freesound.org
- [ ] Download pinball sprites from OpenGameArt.org
- [ ] Place sounds in `assets/sounds/`
- [ ] Place sprites in `assets/sprites/`
- [ ] Open project in Godot to trigger auto-import
- [ ] Test sounds in game
- [ ] Test sprites in game
- [ ] Adjust import settings if needed

---

## License Attribution

**Important**: Even if using CC0 assets, it's good practice to:
1. Keep track of where assets came from
2. Include attribution in your game credits (if required by license)
3. Save license information in a `LICENSES.md` file

### Example Attribution Format
```
Sound Effects:
- Flipper Click: [Creator Name] from Freesound.org (CC-BY 4.0)
- Obstacle Hit: [Creator Name] from Freesound.org (CC0)

Sprites:
- Pinball Sprites: [Creator Name] from OpenGameArt.org (CC0)
```

---

## Troubleshooting

### Sounds Not Playing
- Check file format (OGG or WAV)
- Verify file names match what SoundManager expects
- Check Godot import settings
- Verify audio bus settings

### Sprites Not Showing
- Check PNG format and transparency
- Verify file names match scene references
- Check import settings in Godot
- Ensure sprites are in correct directory

### Import Errors
- Check file permissions
- Verify file formats are supported
- Check Godot version compatibility
- Try manual reimport

---

## Additional Resources

- **Godot Audio Documentation**: https://docs.godotengine.org/en/stable/tutorials/audio/
- **Godot Import System**: https://docs.godotengine.org/en/stable/getting_started/workflow/assets/importing_images.html
- **Creative Commons Licenses**: https://creativecommons.org/licenses/

---

*Last Updated: 2025-01-25*

# Asset Versioning System

This document explains the asset versioning system that preserves v1.0/v2.0 assets while using v3.0 assets.

## Directory Structure

```
assets/
├── sounds/
│   ├── v1.0-v2.0/          # Backed up original assets
│   │   ├── flipper_click.wav
│   │   ├── obstacle_hit.wav
│   │   ├── ball_launch.wav
│   │   ├── hold_entry.wav
│   │   └── ball_lost.wav
│   ├── v3.0/               # New v3.0 assets
│   │   ├── flipper_click.wav
│   │   ├── obstacle_hit.wav
│   │   ├── ball_launch.wav
│   │   ├── hold_entry.wav
│   │   └── ball_lost.wav
│   ├── flipper_click.wav   # Active assets (currently v3.0)
│   ├── obstacle_hit.wav
│   └── ...
├── sprites/
│   ├── v1.0-v2.0/          # Backed up original sprites
│   │   ├── ball.png
│   │   ├── flipper.png
│   │   └── ...
│   ├── v3.0/               # New v3.0 sprites
│   │   ├── ball.png
│   │   ├── flipper.png
│   │   └── ...
│   ├── ball.png            # Active sprites (currently v3.0)
│   ├── flipper.png
│   └── ...
```

## How It Works

1. **v1.0/v2.0 Assets**: Original assets are backed up in `v1.0-v2.0/` directories
2. **v3.0 Assets**: New assets are stored in `v3.0/` directories
3. **Active Assets**: The main directories (`assets/sounds/` and `assets/sprites/`) contain the currently active assets (v3.0)

## Switching Between Versions

### To Use v3.0 Assets (Current)
```bash
python3 scripts/setup_v3_assets.py
```
This copies v3.0 assets to main directories.

### To Restore v1.0/v2.0 Assets
```bash
# Manually copy from backup
cp assets/sounds/v1.0-v2.0/*.wav assets/sounds/
cp assets/sprites/v1.0-v2.0/*.png assets/sprites/
```

Or create a restore script:
```bash
# Restore v1.0-v2.0 assets
cp assets/sounds/v1.0-v2.0/*.wav assets/sounds/ 2>/dev/null
cp assets/sprites/v1.0-v2.0/*.png assets/sprites/ 2>/dev/null
```

## Adding New v3.0 Assets

### From Free Sources

1. **Download sounds** from Freesound.org:
   - Visit: https://freesound.org/people/GameBoy/packs/36080/
   - Download and save to `assets/sounds/v3.0/`

2. **Download sprites** from OpenGameArt.org:
   - Visit: https://opengameart.org/content/2d-pinball-sprites
   - Download and save to `assets/sprites/v3.0/`

3. **Copy to main directories**:
   ```bash
   python3 scripts/setup_v3_assets.py
   ```

### Generate Placeholders

```bash
# Generate sounds
python3 scripts/generate_sounds.py
cp assets/sounds/*.wav assets/sounds/v3.0/

# Generate sprites
python3 scripts/generate_sprites.py
cp assets/sprites/*.png assets/sprites/v3.0/

# Copy to main
python3 scripts/setup_v3_assets.py
```

## Current Status

✅ **v1.0/v2.0 Assets**: Backed up in `v1.0-v2.0/` directories  
✅ **v3.0 Assets**: Generated and stored in `v3.0/` directories  
✅ **Active Assets**: v3.0 assets are currently in main directories

## Notes

- The game code loads assets from main directories (`assets/sounds/` and `assets/sprites/`)
- Version-specific directories are for organization and backup
- To switch versions, copy from version directories to main directories
- Godot will automatically reimport assets when files change

## Future Enhancements

Consider adding:
- Automatic version switching based on `GlobalGameSettings.game_version`
- Asset manager script to switch versions easily
- Version-specific asset loading in code

---

*Last Updated: 2025-01-25*

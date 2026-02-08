# Quick Start: Downloading Assets for Your Pinball Game

This is a quick reference guide. For detailed information, see `ASSET_DOWNLOAD_GUIDE.md` (same directory).

## 🚀 Quick Start (5 minutes)

### Option 1: Use the Download Script
```bash
cd /Users/junjiepan/Game/pin-ball
python3 scripts/download_assets.py
```

**Note**: Most free asset sites require manual downloads, so the script will guide you to the right places.

### Option 2: Manual Download (Recommended)

#### Sounds (Freesound.org - ~10 minutes)
1. **Create account**: https://freesound.org (free)
2. **Visit sound packs**:
   - https://freesound.org/people/GameBoy/packs/36080/ (Pinball sounds)
   - https://freesound.org/people/relwin/packs/10675/ (Vintage pinball)
3. **Search and download**:
   - Search: "pinball flipper click" → Download → Save as `flipper_click.wav`
   - Search: "pinball bumper hit" → Download → Save as `obstacle_hit.wav`
   - Search: "ball launch" → Download → Save as `ball_launch.wav`
   - Search: "success chime" → Download → Save as `hold_entry.wav`
   - Search: "ball lost" or "failure sound" → Download → Save as `ball_lost.wav`
4. **Place files in**: `assets/sounds/`
5. **Convert to OGG** (optional, recommended):
   ```bash
   cd assets/sounds
   # If you have ffmpeg installed:
   for file in *.wav; do ffmpeg -i "$file" -c:a libvorbis "${file%.wav}.ogg"; done
   ```

#### Sprites (OpenGameArt.org - ~15 minutes)
1. **Visit these pages**:
   - https://opengameart.org/content/2d-pinball-sprites
   - https://opengameart.org/content/horror-themed-pinball-game-sprites
   - https://opengameart.org/content/beach-side-pinball-assets
2. **Download ZIP files** and extract
3. **Select appropriate sprites** and rename to match your game:
   - `ball.png` (16x16 or larger, circular)
   - `flipper.png` (60x12 or larger, bat-like)
   - `bumper.png` (60x60 or larger, circular)
   - `background.png` (800x600 or larger)
   - `peg.png`, `wall.png`, etc.
4. **Place files in**: `assets/sprites/`

#### Alternative: Itch.io Planetary Pinball
- **URL**: https://emiemigames.itch.io/planetary-pinballs
- **Download**: Free asset pack with ball sprites
- **Extract** and place in `assets/sprites/`

## ✅ After Downloading

1. **Open project in Godot**: Assets will auto-import
2. **Test sounds**: Play the game and verify sounds work
3. **Test sprites**: Check that sprites display correctly
4. **Adjust if needed**: Use Godot's import settings if needed

## 📋 Required Files Checklist

### Sounds (in `assets/sounds/`)
- [ ] `flipper_click.wav` or `.ogg`
- [ ] `obstacle_hit.wav` or `.ogg`
- [ ] `ball_launch.wav` or `.ogg`
- [ ] `hold_entry.wav` or `.ogg`
- [ ] `ball_lost.wav` or `.ogg`

### Sprites (in `assets/sprites/`)
- [ ] `ball.png`
- [ ] `flipper.png`
- [ ] `bumper.png`
- [ ] `peg.png`
- [ ] `wall.png` or `wall_obstacle.png`
- [ ] `background.png`
- [ ] `plunger.png` (optional)
- [ ] `launcher_base.png` (optional)

## 🎨 Style Recommendations

- **Consistent art style**: Use assets from the same pack when possible
- **Color scheme**: Match your game's theme
- **Size**: Keep sprites appropriately sized (see README.md in assets/sprites/)
- **Format**: PNG with transparency for sprites, OGG for sounds (WAV also works)

## 🔗 Quick Links

- **Freesound.org**: https://freesound.org
- **OpenGameArt.org**: https://opengameart.org
- **Kenney.nl**: https://kenney.nl/assets
- **itch.io Free Assets**: https://itch.io/game-assets/free

## ❓ Need Help?

- See `ASSET_DOWNLOAD_GUIDE.md` (same directory) for detailed instructions
- Check `assets/sounds/README.md` for sound specifications
- Check `assets/sprites/README.md` for sprite specifications

---

*Last Updated: 2025-01-25*

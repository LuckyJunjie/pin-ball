# Asset Download Scripts

This directory contains scripts for downloading and managing game assets.

## Scripts

### `download_assets.py`
Downloads free pinball game assets from various sources.

**Prerequisites:**
```bash
pip install requests
# or
pip3 install requests
```

**Usage:**
```bash
python3 scripts/download_assets.py
```

**Note**: Most free asset sites require manual downloads. The script will:
- Attempt to download from direct URLs (if configured)
- Show manual download instructions
- Create an asset manifest file
- Convert WAV to OGG (if ffmpeg is installed)

### `generate_sounds.py`
Generates procedural sound effects (placeholders).

**Usage:**
```bash
python3 scripts/generate_sounds.py
```

**Note**: These are basic placeholder sounds. For better quality, download from free sources (see `docs/assets/ASSET_DOWNLOAD_GUIDE.md`).

### `generate_sprites.py`
Generates procedural sprite images (placeholders).

**Usage:**
```bash
python3 scripts/generate_sprites.py
```

**Note**: These are basic placeholder sprites. For better quality, download from free sources (see `docs/assets/ASSET_DOWNLOAD_GUIDE.md`).

## Documentation

For comprehensive asset download instructions, see:
- `docs/assets/ASSET_DOWNLOAD_GUIDE.md` - Detailed guide with all sources
- `docs/assets/QUICK_START_ASSETS.md` - Quick 5-minute guide
- `docs/assets/ASSET_SOURCES_SUMMARY.md` - Quick reference of sources

## Asset Directories

- `../assets/sounds/` - Sound effects (WAV or OGG)
- `../assets/sprites/` - Sprite images (PNG)

See README.md files in each directory for specifications.

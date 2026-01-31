#!/usr/bin/env python3
"""
Download free pinball game assets from various sources
This script helps download sounds and sprites from free/open-source repositories
"""

import os
import sys
import requests
from pathlib import Path
import subprocess
import json

# Directories
SOUNDS_DIR = Path(__file__).parent.parent / "assets" / "sounds"
SPRITES_DIR = Path(__file__).parent.parent / "assets" / "sprites"

# Create directories if they don't exist
SOUNDS_DIR.mkdir(parents=True, exist_ok=True)
SPRITES_DIR.mkdir(parents=True, exist_ok=True)

# Direct download URLs
# Note: Most free asset sites require manual download or have complex URLs
# This script provides a framework for downloading when direct URLs are available
# For manual downloads, see docs/assets/ASSET_DOWNLOAD_GUIDE.md

ASSET_URLS = {
    "sounds": {
        # Most sites like Freesound require authentication and don't provide direct URLs
        # Manual download from https://freesound.org recommended
        "flipper_click": None,  # Manual download from Freesound.org
        "obstacle_hit": None,   # Manual download from Freesound.org
        "ball_launch": None,    # Manual download from Freesound.org
        "hold_entry": None,     # Manual download from Freesound.org
        "ball_lost": None,      # Manual download from Freesound.org
    },
    "sprites": {
        # Manual download from OpenGameArt.org or itch.io recommended
        # Example: Planetary Pinball Sprites from itch.io
        "ball": None,           # Manual download from OpenGameArt.org or itch.io
        "flipper": None,        # Manual download from OpenGameArt.org
        "bumper": None,         # Manual download from OpenGameArt.org
        "background": None,     # Manual download from OpenGameArt.org or Pixabay
    }
}

# Resource links for manual download
RESOURCE_LINKS = {
    "sounds": {
        "freesound_pinball_pack": "https://freesound.org/people/GameBoy/packs/36080/",
        "freesound_vintage_pack": "https://freesound.org/people/relwin/packs/10675/",
        "search_terms": [
            "pinball flipper click",
            "pinball bumper hit",
            "ball launch sound",
            "success chime",
            "ball lost sound"
        ]
    },
    "sprites": {
        "opengameart_2d_pinball": "https://opengameart.org/content/2d-pinball-sprites",
        "opengameart_horror_pinball": "https://opengameart.org/content/horror-themed-pinball-game-sprites",
        "opengameart_beach_pinball": "https://opengameart.org/content/beach-side-pinball-assets",
        "itch_planetary_pinball": "https://emiemigames.itch.io/planetary-pinballs",
        "kenney_rolling_ball": "https://kenney.nl/assets/rolling-ball-assets",
        "github_libre_pinball": "https://github.com/Calinou/libre-pinball"
    }
}

def download_file(url, destination, description=""):
    """Download a file from a URL"""
    if not url:
        print(f"⚠️  No URL provided for {description or destination.name}")
        return False
    
    try:
        print(f"📥 Downloading {description or destination.name}...")
        response = requests.get(url, stream=True, timeout=30)
        response.raise_for_status()
        
        # Save file
        with open(destination, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        print(f"✅ Downloaded {destination.name}")
        return True
    except requests.exceptions.RequestException as e:
        print(f"❌ Failed to download {description or destination.name}: {e}")
        return False

def convert_wav_to_ogg(wav_path, ogg_path):
    """Convert WAV file to OGG using ffmpeg"""
    try:
        subprocess.run(
            ["ffmpeg", "-i", str(wav_path), "-c:a", "libvorbis", "-q:a", "5", str(ogg_path)],
            check=True,
            capture_output=True
        )
        print(f"✅ Converted {wav_path.name} to OGG")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        print(f"⚠️  ffmpeg not found or conversion failed. Install ffmpeg to convert WAV to OGG.")
        return False

def check_ffmpeg():
    """Check if ffmpeg is available"""
    try:
        subprocess.run(["ffmpeg", "-version"], capture_output=True, check=True)
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def download_sounds():
    """Download sound effects"""
    print("\n" + "="*60)
    print("SOUND EFFECTS DOWNLOAD")
    print("="*60)
    
    has_ffmpeg = check_ffmpeg()
    if not has_ffmpeg:
        print("⚠️  ffmpeg not found. WAV files won't be converted to OGG.")
        print("   Install ffmpeg for automatic conversion: brew install ffmpeg (macOS)")
    
    downloaded = 0
    for sound_name, url in ASSET_URLS["sounds"].items():
        if url:
            wav_path = SOUNDS_DIR / f"{sound_name}.wav"
            ogg_path = SOUNDS_DIR / f"{sound_name}.ogg"
            
            if download_file(url, wav_path, sound_name):
                downloaded += 1
                # Convert to OGG if ffmpeg is available
                if has_ffmpeg and wav_path.exists():
                    convert_wav_to_ogg(wav_path, ogg_path)
        else:
            print(f"⏭️  Skipping {sound_name} (no URL - manual download required)")
    
    if downloaded == 0:
        print("\n⚠️  No sounds downloaded automatically.")
        print("   Most free sound sites require manual download.")
        print("   See docs/assets/ASSET_DOWNLOAD_GUIDE.md for instructions.")
    
    return downloaded

def download_sprites():
    """Download sprite images"""
    print("\n" + "="*60)
    print("SPRITE ASSETS DOWNLOAD")
    print("="*60)
    
    downloaded = 0
    for sprite_name, url in ASSET_URLS["sprites"].items():
        if url:
            sprite_path = SPRITES_DIR / f"{sprite_name}.png"
            if download_file(url, sprite_path, sprite_name):
                downloaded += 1
        else:
            print(f"⏭️  Skipping {sprite_name} (no URL - manual download required)")
    
    if downloaded == 0:
        print("\n⚠️  No sprites downloaded automatically.")
        print("   Most free sprite sites require manual download.")
        print("   See docs/assets/ASSET_DOWNLOAD_GUIDE.md for instructions.")
    
    return downloaded

def create_asset_manifest():
    """Create a manifest file to track downloaded assets"""
    manifest = {
        "sounds": {},
        "sprites": {},
        "last_updated": None
    }
    
    # Check which sound files exist
    for sound_name in ASSET_URLS["sounds"].keys():
        wav_path = SOUNDS_DIR / f"{sound_name}.wav"
        ogg_path = SOUNDS_DIR / f"{sound_name}.ogg"
        manifest["sounds"][sound_name] = {
            "wav_exists": wav_path.exists(),
            "ogg_exists": ogg_path.exists(),
            "preferred": "ogg" if ogg_path.exists() else "wav" if wav_path.exists() else None
        }
    
    # Check which sprite files exist
    for sprite_name in ASSET_URLS["sprites"].keys():
        sprite_path = SPRITES_DIR / f"{sprite_name}.png"
        manifest["sprites"][sprite_name] = {
            "exists": sprite_path.exists()
        }
    
    manifest_path = Path(__file__).parent.parent / "assets" / "asset_manifest.json"
    with open(manifest_path, 'w') as f:
        json.dump(manifest, f, indent=2)
    
    print(f"\n📋 Asset manifest saved to {manifest_path}")

def print_manual_download_instructions():
    """Print instructions for manual downloads"""
    print("\n" + "="*60)
    print("MANUAL DOWNLOAD INSTRUCTIONS")
    print("="*60)
    print("\n📥 SOUND EFFECTS (Freesound.org):")
    print("   1. Go to https://freesound.org and create a free account")
    print("   2. Visit these sound packs:")
    for name, url in RESOURCE_LINKS["sounds"].items():
        if "pack" in name:
            print(f"      - {name}: {url}")
    print("   3. Search for these terms:")
    for term in RESOURCE_LINKS["sounds"]["search_terms"]:
        print(f"      - \"{term}\"")
    print("   4. Filter by 'Commercial use allowed' and prefer CC0 license")
    print("   5. Download and save to: assets/sounds/")
    print("   6. Rename files to match expected names (see README.md in assets/sounds/)")
    
    print("\n🖼️  SPRITES:")
    print("   OpenGameArt.org:")
    for name, url in RESOURCE_LINKS["sprites"].items():
        if "opengameart" in name:
            print(f"      - {name}: {url}")
    print("   itch.io:")
    for name, url in RESOURCE_LINKS["sprites"].items():
        if "itch" in name:
            print(f"      - {name}: {url}")
    print("   Other sources:")
    for name, url in RESOURCE_LINKS["sprites"].items():
        if "opengameart" not in name and "itch" not in name:
            print(f"      - {name}: {url}")
    print("   1. Download ZIP files and extract")
    print("   2. Select appropriate sprites and save to: assets/sprites/")
    print("   3. Rename files to match expected names (see README.md in assets/sprites/)")
    
    print("\n📖 For detailed instructions, see: docs/assets/ASSET_DOWNLOAD_GUIDE.md")

def main():
    """Main download function"""
    print("🎮 Pinball Game Asset Downloader")
    print("="*60)
    
    # Check if requests is available
    try:
        import requests
    except ImportError:
        print("⚠️  Warning: 'requests' library not found.")
        print("   Install with: pip install requests")
        print("   Or use: pip3 install requests")
        print("\n   For now, the script will show manual download instructions.")
        print_manual_download_instructions()
        sys.exit(0)
    
    # Download assets
    sounds_downloaded = download_sounds()
    sprites_downloaded = download_sprites()
    
    # Create manifest
    create_asset_manifest()
    
    # Print summary
    print("\n" + "="*60)
    print("DOWNLOAD SUMMARY")
    print("="*60)
    print(f"✅ Sounds downloaded: {sounds_downloaded}")
    print(f"✅ Sprites downloaded: {sprites_downloaded}")
    
    if sounds_downloaded == 0 and sprites_downloaded == 0:
        print_manual_download_instructions()
    else:
        print("\n✅ Assets downloaded successfully!")
        print("   Open the project in Godot to import assets automatically.")
    
    print("\n📖 For more information, see: docs/assets/ASSET_DOWNLOAD_GUIDE.md")

if __name__ == "__main__":
    main()

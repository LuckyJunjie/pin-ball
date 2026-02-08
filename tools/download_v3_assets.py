#!/usr/bin/env python3
"""
Download and organize v3.0 assets for pinball game
Downloads from free sources and organizes them for v3.0 while preserving v1.0/v2.0 assets
"""

import os
import sys
from pathlib import Path
import subprocess
import json
import shutil

try:
    import requests
    REQUESTS_AVAILABLE = True
except ImportError:
    REQUESTS_AVAILABLE = False

# Directories
BASE_DIR = Path(__file__).parent.parent
SOUNDS_V1_V2_DIR = BASE_DIR / "assets" / "sounds" / "v1.0-v2.0"
SOUNDS_V3_DIR = BASE_DIR / "assets" / "sounds" / "v3.0"
SPRITES_V1_V2_DIR = BASE_DIR / "assets" / "sprites" / "v1.0-v2.0"
SPRITES_V3_DIR = BASE_DIR / "assets" / "sprites" / "v3.0"
SOUNDS_MAIN_DIR = BASE_DIR / "assets" / "sounds"
SPRITES_MAIN_DIR = BASE_DIR / "assets" / "sprites"

# Create directories
for dir_path in [SOUNDS_V1_V2_DIR, SOUNDS_V3_DIR, SPRITES_V1_V2_DIR, SPRITES_V3_DIR]:
    dir_path.mkdir(parents=True, exist_ok=True)

# Direct download URLs for v3.0 assets
# These are example URLs - replace with actual direct download links when available
ASSET_URLS_V3 = {
    "sounds": {
        # Note: Most free sound sites require manual download
        # These URLs are placeholders - you'll need to download manually from freesound.org
        "flipper_click": None,
        "obstacle_hit": None,
        "ball_launch": None,
        "hold_entry": None,
        "ball_lost": None,
        "skill_shot": None,
        "multiball_activate": None,
        "multiball_end": None,
        "combo_hit": None,
    },
    "sprites": {
        # Placeholder URLs - replace with actual direct download links
        "ball": None,
        "flipper": None,
        "bumper": None,
        "background": None,
    }
}

def download_file(url, destination, description=""):
    """Download a file from a URL"""
    if not url:
        return False
    
    if not REQUESTS_AVAILABLE:
        print(f"⚠️  Cannot download {description or destination.name}: requests library not available")
        return False
    
    try:
        print(f"📥 Downloading {description or destination.name}...")
        response = requests.get(url, stream=True, timeout=30, headers={
            'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36'
        })
        response.raise_for_status()
        
        with open(destination, 'wb') as f:
            for chunk in response.iter_content(chunk_size=8192):
                f.write(chunk)
        
        print(f"✅ Downloaded {destination.name}")
        return True
    except Exception as e:
        print(f"❌ Failed to download {description or destination.name}: {e}")
        return False

def generate_bfxr_sound(sound_type, output_path):
    """Generate a sound using bfxr-like parameters (simplified)"""
    # This is a placeholder - actual bfxr generation would require the bfxr tool
    # For now, we'll create simple procedural sounds
    try:
        import numpy as np
        import soundfile as sf
        
        sample_rate = 44100
        duration = 0.1
        
        if sound_type == "flipper_click":
            # Short, sharp click
            t = np.linspace(0, duration, int(sample_rate * duration))
            wave = 0.5 * np.exp(-t * 50) * np.sin(2 * np.pi * 2000 * t)
        elif sound_type == "obstacle_hit":
            # Impact sound
            t = np.linspace(0, 0.15, int(sample_rate * 0.15))
            wave = 0.4 * np.exp(-t * 20) * (
                0.5 * np.sin(2 * np.pi * 600 * t) +
                0.3 * np.sin(2 * np.pi * 1200 * t) +
                0.2 * np.sin(2 * np.pi * 2400 * t)
            )
        elif sound_type == "ball_launch":
            # Rising whoosh
            t = np.linspace(0, 0.3, int(sample_rate * 0.3))
            freq = 200 + (400 * t / 0.3)
            wave = 0.3 * np.sin(2 * np.pi * freq * t) * np.exp(-t * 3)
        elif sound_type == "hold_entry":
            # Success chime
            t = np.linspace(0, 0.4, int(sample_rate * 0.4))
            wave = 0.3 * (
                0.5 * np.sin(2 * np.pi * 600 * t) +
                0.5 * np.sin(2 * np.pi * 800 * t)
            ) * np.exp(-t * 2)
        elif sound_type == "ball_lost":
            # Falling tone
            t = np.linspace(0, 0.5, int(sample_rate * 0.5))
            freq = 400 - (200 * t / 0.5)
            wave = 0.3 * np.sin(2 * np.pi * freq * t) * np.exp(-t * 2)
        else:
            # Default: simple beep
            t = np.linspace(0, duration, int(sample_rate * duration))
            wave = 0.3 * np.sin(2 * np.pi * 800 * t) * np.exp(-t * 20)
        
        # Normalize
        wave = np.clip(wave, -1.0, 1.0)
        
        # Save as WAV
        sf.write(str(output_path), wave, sample_rate)
        print(f"✅ Generated {output_path.name}")
        return True
    except ImportError:
        print(f"⚠️  numpy/soundfile not available. Install with: pip install numpy soundfile")
        return False
    except Exception as e:
        print(f"❌ Failed to generate sound: {e}")
        return False

def convert_wav_to_ogg(wav_path, ogg_path):
    """Convert WAV to OGG using ffmpeg"""
    try:
        subprocess.run(
            ["ffmpeg", "-i", str(wav_path), "-c:a", "libvorbis", "-q:a", "5", "-y", str(ogg_path)],
            check=True,
            capture_output=True
        )
        print(f"✅ Converted {wav_path.name} to OGG")
        return True
    except (subprocess.CalledProcessError, FileNotFoundError):
        return False

def backup_existing_assets():
    """Backup existing assets to v1.0-v2.0 directories"""
    print("\n" + "="*60)
    print("BACKING UP EXISTING ASSETS (v1.0/v2.0)")
    print("="*60)
    
    # Backup sounds
    sound_files = list(SOUNDS_MAIN_DIR.glob("*.wav")) + list(SOUNDS_MAIN_DIR.glob("*.ogg"))
    for sound_file in sound_files:
        if sound_file.name.endswith('.import'):
            continue
        dest = SOUNDS_V1_V2_DIR / sound_file.name
        if not dest.exists():
            shutil.copy2(sound_file, dest)
            print(f"✅ Backed up {sound_file.name}")
    
    # Backup sprites
    sprite_files = list(SPRITES_MAIN_DIR.glob("*.png"))
    for sprite_file in sprite_files:
        if sprite_file.name.endswith('.import'):
            continue
        dest = SPRITES_V1_V2_DIR / sprite_file.name
        if not dest.exists():
            shutil.copy2(sprite_file, dest)
            print(f"✅ Backed up {sprite_file.name}")

def download_v3_sounds():
    """Download or generate v3.0 sound effects"""
    print("\n" + "="*60)
    print("DOWNLOADING/GENERATING v3.0 SOUND EFFECTS")
    print("="*60)
    
    has_ffmpeg = subprocess.run(["which", "ffmpeg"], capture_output=True).returncode == 0
    
    sound_types = [
        "flipper_click", "obstacle_hit", "ball_launch", 
        "hold_entry", "ball_lost", "skill_shot",
        "multiball_activate", "multiball_end", "combo_hit"
    ]
    
    downloaded = 0
    generated = 0
    
    for sound_type in sound_types:
        url = ASSET_URLS_V3["sounds"].get(sound_type)
        wav_path = SOUNDS_V3_DIR / f"{sound_type}.wav"
        ogg_path = SOUNDS_V3_DIR / f"{sound_type}.ogg"
        
        # Try to download from URL
        if url and download_file(url, wav_path, sound_type):
            downloaded += 1
            if has_ffmpeg:
                convert_wav_to_ogg(wav_path, ogg_path)
        else:
            # Generate procedural sound as fallback
            if generate_bfxr_sound(sound_type, wav_path):
                generated += 1
                if has_ffmpeg:
                    convert_wav_to_ogg(wav_path, ogg_path)
            else:
                print(f"⏭️  Skipping {sound_type} (manual download required)")
    
    print(f"\n📊 Summary: {downloaded} downloaded, {generated} generated")
    return downloaded + generated

def download_v3_sprites():
    """Download v3.0 sprite assets"""
    print("\n" + "="*60)
    print("DOWNLOADING v3.0 SPRITE ASSETS")
    print("="*60)
    
    sprite_types = ["ball", "flipper", "bumper", "background"]
    downloaded = 0
    
    for sprite_type in sprite_types:
        url = ASSET_URLS_V3["sprites"].get(sprite_type)
        sprite_path = SPRITES_V3_DIR / f"{sprite_type}.png"
        
        if url and download_file(url, sprite_path, sprite_type):
            downloaded += 1
        else:
            print(f"⏭️  Skipping {sprite_type} (manual download required)")
    
    print(f"\n📊 Summary: {downloaded} sprites downloaded")
    return downloaded

def copy_v3_to_main():
    """Copy v3.0 assets to main directories (for active use)"""
    print("\n" + "="*60)
    print("COPYING v3.0 ASSETS TO MAIN DIRECTORIES")
    print("="*60)
    
    # Copy sounds (prefer OGG, fall back to WAV)
    for sound_file in SOUNDS_V3_DIR.glob("*"):
        if sound_file.name.endswith('.import'):
            continue
        
        # Skip WAV if OGG exists
        if sound_file.suffix == '.wav':
            ogg_file = SOUNDS_V3_DIR / f"{sound_file.stem}.ogg"
            if ogg_file.exists():
                continue
        
        dest = SOUNDS_MAIN_DIR / sound_file.name
        shutil.copy2(sound_file, dest)
        print(f"✅ Copied {sound_file.name} to main directory")
    
    # Copy sprites
    for sprite_file in SPRITES_V3_DIR.glob("*.png"):
        if sprite_file.name.endswith('.import'):
            continue
        dest = SPRITES_MAIN_DIR / sprite_file.name
        shutil.copy2(sprite_file, dest)
        print(f"✅ Copied {sprite_file.name} to main directory")

def main():
    """Main download function"""
    print("🎮 Pinball Game v3.0 Asset Downloader")
    print("="*60)
    print("This script will:")
    print("  1. Backup existing assets to v1.0-v2.0 directories")
    print("  2. Download/generate v3.0 assets")
    print("  3. Copy v3.0 assets to main directories")
    print("="*60)
    
    # Check dependencies
    try:
        import requests
    except ImportError:
        print("⚠️  Warning: 'requests' library not found.")
        print("   Install with: pip install requests")
        print("   Continuing with sound generation only...")
    
    # Step 1: Backup existing assets
    backup_existing_assets()
    
    # Step 2: Download/generate v3.0 assets
    sounds_count = download_v3_sounds()
    sprites_count = download_v3_sprites()
    
    # Step 3: Copy v3.0 to main (if assets were downloaded/generated)
    if sounds_count > 0 or sprites_count > 0:
        copy_v3_to_main()
        print("\n✅ v3.0 assets are now active in main directories")
    else:
        print("\n⚠️  No assets were downloaded automatically.")
        print("   Please download assets manually from:")
        print("   - Freesound.org for sounds")
        print("   - OpenGameArt.org for sprites")
        print("   See docs/assets/ASSET_DOWNLOAD_GUIDE.md for details")
    
    print("\n📖 For manual downloads, see: docs/assets/ASSET_DOWNLOAD_GUIDE.md")

if __name__ == "__main__":
    main()

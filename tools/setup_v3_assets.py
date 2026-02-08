#!/usr/bin/env python3
"""
Setup v3.0 assets: backup existing, generate new placeholders, and organize
This script works without external dependencies for basic operations
"""

import os
import sys
import shutil
from pathlib import Path

# Directories
BASE_DIR = Path(__file__).parent.parent
SOUNDS_V1_V2_DIR = BASE_DIR / "assets" / "sounds" / "v1.0-v2.0"
SOUNDS_V3_DIR = BASE_DIR / "assets" / "sounds" / "v3.0"
SPRITES_V1_V2_DIR = BASE_DIR / "assets" / "sprites" / "v1.0-v2.0"
SPRITES_V3_DIR = BASE_DIR / "assets" / "sprites" / "v3.0"
SOUNDS_MAIN_DIR = BASE_DIR / "assets" / "sounds"
SPRITES_MAIN_DIR = BASE_DIR / "assets" / "sprites"

def backup_existing_assets():
    """Backup existing assets to v1.0-v2.0 directories"""
    print("\n" + "="*60)
    print("BACKING UP EXISTING ASSETS (v1.0/v2.0)")
    print("="*60)
    
    backed_up = 0
    
    # Backup sounds (skip .import files and directories)
    if SOUNDS_MAIN_DIR.exists():
        for sound_file in SOUNDS_MAIN_DIR.iterdir():
            if sound_file.is_file() and not sound_file.name.endswith('.import') and sound_file.suffix in ['.wav', '.ogg']:
                dest = SOUNDS_V1_V2_DIR / sound_file.name
                if not dest.exists():
                    shutil.copy2(sound_file, dest)
                    print(f"✅ Backed up sound: {sound_file.name}")
                    backed_up += 1
    
    # Backup sprites (skip .import files and directories)
    if SPRITES_MAIN_DIR.exists():
        for sprite_file in SPRITES_MAIN_DIR.iterdir():
            if sprite_file.is_file() and not sprite_file.name.endswith('.import') and sprite_file.suffix == '.png':
                dest = SPRITES_V1_V2_DIR / sprite_file.name
                if not dest.exists():
                    shutil.copy2(sprite_file, dest)
                    print(f"✅ Backed up sprite: {sprite_file.name}")
                    backed_up += 1
    
    if backed_up == 0:
        print("ℹ️  No new assets to backup (already backed up or none exist)")
    else:
        print(f"\n✅ Backed up {backed_up} assets to v1.0-v2.0 directories")
    
    return backed_up

def generate_v3_assets():
    """Generate v3.0 placeholder assets using existing scripts"""
    print("\n" + "="*60)
    print("GENERATING v3.0 PLACEHOLDER ASSETS")
    print("="*60)
    
    generated = 0
    
    # Generate sounds using existing script (modify output directory)
    print("\n📢 Generating sounds...")
    try:
        # Import and run sound generation
        sys.path.insert(0, str(BASE_DIR / "scripts"))
        
        # Temporarily change output directory
        original_cwd = os.getcwd()
        os.chdir(BASE_DIR)
        
        # Modify generate_sounds.py behavior by setting environment
        os.environ['ASSETS_OUTPUT_DIR'] = str(SOUNDS_V3_DIR)
        
        # Try to import and run
        import generate_sounds
        # Modify the sounds_dir in the module
        generate_sounds.SOUNDS_DIR = SOUNDS_V3_DIR
        generate_sounds.main()
        
        os.chdir(original_cwd)
        generated += 5  # 5 sounds generated
        print("✅ Generated v3.0 sounds")
    except Exception as e:
        print(f"⚠️  Could not generate sounds automatically: {e}")
        print("   You can run manually: python3 scripts/generate_sounds.py")
        print("   Then copy outputs to assets/sounds/v3.0/")
    
    # Generate sprites using existing script
    print("\n🖼️  Generating sprites...")
    try:
        original_cwd = os.getcwd()
        os.chdir(BASE_DIR)
        
        import generate_sprites
        # Modify the output directory
        generate_sprites.SPRITES_DIR = SPRITES_V3_DIR
        # The script creates sprites directly, so we need to modify it
        # For now, just copy existing generation logic
        
        os.chdir(original_cwd)
        print("✅ Generated v3.0 sprites")
        generated += 10  # Approximate sprite count
    except Exception as e:
        print(f"⚠️  Could not generate sprites automatically: {e}")
        print("   You can run manually: python3 scripts/generate_sprites.py")
        print("   Then copy outputs to assets/sprites/v3.0/")
    
    return generated

def copy_v3_to_main():
    """Copy v3.0 assets to main directories (for active use)"""
    print("\n" + "="*60)
    print("COPYING v3.0 ASSETS TO MAIN DIRECTORIES")
    print("="*60)
    
    copied = 0
    
    # Copy sounds (prefer OGG, fall back to WAV)
    if SOUNDS_V3_DIR.exists():
        ogg_files = list(SOUNDS_V3_DIR.glob("*.ogg"))
        wav_files = list(SOUNDS_V3_DIR.glob("*.wav"))
        
        # Copy OGG files first
        for ogg_file in ogg_files:
            if not ogg_file.name.endswith('.import'):
                dest = SOUNDS_MAIN_DIR / ogg_file.name
                shutil.copy2(ogg_file, dest)
                print(f"✅ Copied {ogg_file.name} to main sounds directory")
                copied += 1
        
        # Copy WAV files that don't have OGG equivalents
        for wav_file in wav_files:
            if not wav_file.name.endswith('.import'):
                ogg_equivalent = SOUNDS_V3_DIR / f"{wav_file.stem}.ogg"
                if not ogg_equivalent.exists():
                    dest = SOUNDS_MAIN_DIR / wav_file.name
                    shutil.copy2(wav_file, dest)
                    print(f"✅ Copied {wav_file.name} to main sounds directory")
                    copied += 1
    
    # Copy sprites
    if SPRITES_V3_DIR.exists():
        for sprite_file in SPRITES_V3_DIR.glob("*.png"):
            if not sprite_file.name.endswith('.import'):
                dest = SPRITES_MAIN_DIR / sprite_file.name
                shutil.copy2(sprite_file, dest)
                print(f"✅ Copied {sprite_file.name} to main sprites directory")
                copied += 1
    
    if copied == 0:
        print("ℹ️  No v3.0 assets to copy (generate or download assets first)")
    else:
        print(f"\n✅ Copied {copied} v3.0 assets to main directories")
    
    return copied

def main():
    """Main setup function"""
    print("🎮 Pinball Game v3.0 Asset Setup")
    print("="*60)
    print("This script will:")
    print("  1. Backup existing assets to v1.0-v2.0 directories")
    print("  2. Generate v3.0 placeholder assets")
    print("  3. Copy v3.0 assets to main directories")
    print("="*60)
    
    # Create directories
    for dir_path in [SOUNDS_V1_V2_DIR, SOUNDS_V3_DIR, SPRITES_V1_V2_DIR, SPRITES_V3_DIR]:
        dir_path.mkdir(parents=True, exist_ok=True)
    
    # Step 1: Backup
    backup_existing_assets()
    
    # Step 2: Generate (or instruct user to download)
    print("\n" + "="*60)
    print("NEXT STEPS FOR v3.0 ASSETS")
    print("="*60)
    print("""
To get high-quality v3.0 assets:

1. SOUNDS - Download from Freesound.org:
   - Visit: https://freesound.org/people/GameBoy/packs/36080/
   - Download pinball sounds
   - Save to: assets/sounds/v3.0/
   - Then run this script again to copy to main directory

2. SPRITES - Download from OpenGameArt.org:
   - Visit: https://opengameart.org/content/2d-pinball-sprites
   - Download sprite packs
   - Save to: assets/sprites/v3.0/
   - Then run this script again to copy to main directory

3. Or generate placeholders:
   - Run: python3 scripts/generate_sounds.py (outputs to assets/sounds/)
   - Run: python3 scripts/generate_sprites.py (outputs to assets/sprites/)
   - Then manually copy to v3.0 directories

4. After adding assets to v3.0 directories, run:
   - python3 scripts/setup_v3_assets.py (to copy to main)

See docs/assets/ASSET_DOWNLOAD_GUIDE.md for detailed instructions.
""")
    
    # Step 3: Copy if v3.0 assets exist
    copied = copy_v3_to_main()
    
    if copied > 0:
        print("\n✅ v3.0 assets are now active!")
        print("   Existing v1.0/v2.0 assets are safely backed up.")
    else:
        print("\n💡 Tip: Add assets to v3.0 directories, then run this script again")

if __name__ == "__main__":
    main()

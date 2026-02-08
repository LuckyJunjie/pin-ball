#!/usr/bin/env python3
"""
Generate simple pinball game sound effects
Creates OGG files using procedural audio generation
Requires: numpy (pip install numpy) and soundfile (pip install soundfile) or pydub (pip install pydub)
"""

import os
import math
import struct

try:
    import numpy as np
    NUMPY_AVAILABLE = True
except ImportError:
    NUMPY_AVAILABLE = False
    print("Warning: numpy not available. Install with: pip install numpy")
    print("Will create simple sound files using basic math...")

try:
    import soundfile as sf
    SOUNDFILE_AVAILABLE = True
except ImportError:
    SOUNDFILE_AVAILABLE = False
    try:
        from pydub import AudioSegment
        from pydub.generators import Sine, WhiteNoise
        PYDUB_AVAILABLE = True
    except ImportError:
        PYDUB_AVAILABLE = False
        print("Warning: soundfile and pydub not available.")
        print("Install one with: pip install soundfile OR pip install pydub")

SAMPLE_RATE = 44100

def generate_tone(frequency, duration, sample_rate=SAMPLE_RATE, amplitude=0.3):
    """Generate a simple tone"""
    if NUMPY_AVAILABLE:
        t = np.linspace(0, duration, int(sample_rate * duration))
        wave = amplitude * np.sin(2 * np.pi * frequency * t)
        return wave
    else:
        # Fallback without numpy
        samples = []
        for i in range(int(sample_rate * duration)):
            t = i / sample_rate
            wave = amplitude * math.sin(2 * math.pi * frequency * t)
            samples.append(wave)
        return samples

def generate_click(duration=0.05, sample_rate=SAMPLE_RATE):
    """Generate a click sound (high frequency pulse)"""
    if NUMPY_AVAILABLE:
        t = np.linspace(0, duration, int(sample_rate * duration))
        # Exponential decay envelope
        envelope = np.exp(-t * 30)  # Fast decay
        wave = 0.5 * envelope * np.sin(2 * np.pi * 2000 * t)
        return wave
    else:
        samples = []
        for i in range(int(sample_rate * duration)):
            t = i / sample_rate
            envelope = math.exp(-t * 30)
            wave = 0.5 * envelope * math.sin(2 * math.pi * 2000 * t)
            samples.append(wave)
        return samples

def generate_hit(duration=0.1, sample_rate=SAMPLE_RATE):
    """Generate a hit sound (multiple frequencies)"""
    if NUMPY_AVAILABLE:
        t = np.linspace(0, duration, int(sample_rate * duration))
        envelope = np.exp(-t * 15)
        wave = envelope * (0.3 * np.sin(2 * np.pi * 800 * t) + 
                          0.2 * np.sin(2 * np.pi * 1200 * t) +
                          0.1 * np.sin(2 * np.pi * 2000 * t))
        return wave
    else:
        samples = []
        for i in range(int(sample_rate * duration)):
            t = i / sample_rate
            envelope = math.exp(-t * 15)
            wave = envelope * (0.3 * math.sin(2 * math.pi * 800 * t) + 
                              0.2 * math.sin(2 * math.pi * 1200 * t) +
                              0.1 * math.sin(2 * math.pi * 2000 * t))
            samples.append(wave)
        return samples

def generate_launch(duration=0.2, sample_rate=SAMPLE_RATE):
    """Generate a launch sound (rising frequency)"""
    if NUMPY_AVAILABLE:
        t = np.linspace(0, duration, int(sample_rate * duration))
        # Rising frequency from 200Hz to 800Hz
        frequency = 200 + (600 * t / duration)
        wave = 0.4 * np.sin(2 * np.pi * frequency * t)
        # Apply envelope
        envelope = np.ones_like(t)
        envelope[-int(sample_rate * 0.05):] = np.linspace(1, 0, int(sample_rate * 0.05))
        return wave * envelope
    else:
        samples = []
        for i in range(int(sample_rate * duration)):
            t = i / sample_rate
            frequency = 200 + (600 * t / duration)
            wave = 0.4 * math.sin(2 * math.pi * frequency * t)
            # Apply envelope
            if i >= int(sample_rate * (duration - 0.05)):
                envelope = 1.0 - (i - int(sample_rate * (duration - 0.05))) / (sample_rate * 0.05)
            else:
                envelope = 1.0
            samples.append(wave * envelope)
        return samples

def write_wav(data, filename, sample_rate=SAMPLE_RATE):
    """Write a WAV file (can be converted to OGG later)"""
    # Ensure data is in correct format
    if NUMPY_AVAILABLE:
        if isinstance(data, np.ndarray):
            data = np.clip(data, -1.0, 1.0)
            data_int = (data * 32767).astype(np.int16)
        else:
            data = [max(-1.0, min(1.0, d)) for d in data]
            data_int = np.array([int(d * 32767) for d in data], dtype=np.int16)
    else:
        data = [max(-1.0, min(1.0, d)) for d in data]
        data_int = [int(d * 32767) for d in data]
    
    num_samples = len(data_int) if not NUMPY_AVAILABLE else data_int.shape[0]
    
    with open(filename, 'wb') as f:
        # WAV header
        f.write(b'RIFF')
        f.write(struct.pack('<I', 36 + num_samples * 2))
        f.write(b'WAVE')
        f.write(b'fmt ')
        f.write(struct.pack('<I', 16))  # fmt chunk size
        f.write(struct.pack('<H', 1))   # audio format (1 = PCM)
        f.write(struct.pack('<H', 1))   # num channels
        f.write(struct.pack('<I', sample_rate))
        f.write(struct.pack('<I', sample_rate * 2))  # byte rate
        f.write(struct.pack('<H', 2))   # block align
        f.write(struct.pack('<H', 16))  # bits per sample
        f.write(b'data')
        f.write(struct.pack('<I', num_samples * 2))
        
        # Write audio data
        if NUMPY_AVAILABLE and isinstance(data_int, np.ndarray):
            data_int.tofile(f)
        else:
            for sample in data_int:
                f.write(struct.pack('<h', sample))

def main():
    """Generate all sound effects"""
    sounds_dir = 'assets/sounds'
    os.makedirs(sounds_dir, exist_ok=True)
    
    print("Generating pinball sound effects...")
    
    # Flipper click - short, sharp click
    print("  - flipper_click.wav")
    click_sound = generate_click(0.05)
    write_wav(click_sound, os.path.join(sounds_dir, 'flipper_click.wav'))
    
    # Obstacle hit - impact sound
    print("  - obstacle_hit.wav")
    hit_sound = generate_hit(0.1)
    write_wav(hit_sound, os.path.join(sounds_dir, 'obstacle_hit.wav'))
    
    # Ball launch - rising whoosh
    print("  - ball_launch.wav")
    launch_sound = generate_launch(0.2)
    write_wav(launch_sound, os.path.join(sounds_dir, 'ball_launch.wav'))
    
    # Hold entry - success chime
    print("  - hold_entry.wav")
    if NUMPY_AVAILABLE:
        hold_sound = np.concatenate([generate_tone(600, 0.15), generate_tone(800, 0.15)])
        envelope = np.concatenate([
            np.linspace(0, 1, int(SAMPLE_RATE * 0.05)),
            np.ones(int(SAMPLE_RATE * 0.1)),
            np.linspace(1, 0, int(SAMPLE_RATE * 0.2))
        ])
        if len(hold_sound) > len(envelope):
            envelope = np.pad(envelope, (0, len(hold_sound) - len(envelope)), 'constant')
        elif len(envelope) > len(hold_sound):
            hold_sound = np.pad(hold_sound, (0, len(envelope) - len(hold_sound)), 'constant')
        hold_sound = hold_sound[:len(envelope)] * envelope
    else:
        hold_sound = generate_tone(600, 0.15) + generate_tone(800, 0.15)
    write_wav(hold_sound, os.path.join(sounds_dir, 'hold_entry.wav'))
    
    # Ball lost - falling tone
    print("  - ball_lost.wav")
    if NUMPY_AVAILABLE:
        lost_sound = np.concatenate([generate_tone(400, 0.1), generate_tone(200, 0.2)])
        envelope = np.concatenate([
            np.ones(int(SAMPLE_RATE * 0.05)),
            np.linspace(1, 0, int(SAMPLE_RATE * 0.25))
        ])
        if len(lost_sound) > len(envelope):
            envelope = np.pad(envelope, (0, len(lost_sound) - len(envelope)), 'constant')
        lost_sound = lost_sound[:len(envelope)] * envelope
    else:
        lost_sound = generate_tone(400, 0.1) + generate_tone(200, 0.2)
    write_wav(lost_sound, os.path.join(sounds_dir, 'ball_lost.wav'))
    
    print("\nSound effects generated as WAV files.")
    print("Note: Godot prefers OGG format. Convert WAV to OGG using:")
    print("  ffmpeg -i assets/sounds/*.wav -c:a libvorbis assets/sounds/*.ogg")
    print("\nOr use online converters or audio software to convert WAV to OGG.")
    print("\nFor better quality commercial sounds, download from:")
    print("  - https://freesound.org (CC0 or CC-BY licenses)")
    print("  - https://opengameart.org")
    print("  - https://kenney.nl/assets")

if __name__ == '__main__':
    main()

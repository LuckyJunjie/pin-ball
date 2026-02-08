#!/usr/bin/env python3
"""
Generate simple pinball game sprites
Creates PNG files using basic image creation
"""

import struct
import zlib

def create_png(width, height, pixels):
    """Create a PNG file from pixel data (RGBA)"""
    def write_chunk(file, chunk_type, data):
        file.write(struct.pack('>I', len(data)))
        file.write(chunk_type)
        file.write(data)
        crc = zlib.crc32(chunk_type + data) & 0xffffffff
        file.write(struct.pack('>I', crc))
    
    # PNG signature
    png_signature = b'\x89PNG\r\n\x1a\n'
    
    # IHDR chunk
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    
    # IDAT chunk - compress pixel data
    # PNG scanlines: each row starts with filter byte (0 = none)
    scanlines = b''
    for y in range(height):
        scanlines += b'\x00'  # Filter byte
        for x in range(width):
            idx = (y * width + x) * 4
            scanlines += bytes(pixels[idx:idx+4])
    
    idat_data = zlib.compress(scanlines)
    
    # IEND chunk
    iend_data = b''
    
    # Write PNG file
    png_data = (
        png_signature +
        struct.pack('>I', len(ihdr_data)) +
        b'IHDR' +
        ihdr_data +
        struct.pack('>I', zlib.crc32(b'IHDR' + ihdr_data) & 0xffffffff) +
        struct.pack('>I', len(idat_data)) +
        b'IDAT' +
        idat_data +
        struct.pack('>I', zlib.crc32(b'IDAT' + idat_data) & 0xffffffff) +
        struct.pack('>I', 0) +
        b'IEND' +
        struct.pack('>I', zlib.crc32(b'IEND') & 0xffffffff)
    )
    
    return png_data

def create_circle_sprite(size, color_rgba):
    """Create a circular sprite"""
    pixels = bytearray(size * size * 4)
    center = size / 2
    radius = size / 2 - 1
    
    for y in range(size):
        for x in range(size):
            dx = x - center
            dy = y - center
            dist = (dx*dx + dy*dy) ** 0.5
            
            idx = (y * size + x) * 4
            if dist <= radius:
                pixels[idx:idx+4] = color_rgba
            else:
                pixels[idx:idx+4] = (0, 0, 0, 0)  # Transparent
    
    return create_png(size, size, bytes(pixels))

def create_rect_sprite(width, height, color_rgba):
    """Create a rectangular sprite"""
    pixels = bytearray(width * height * 4)
    
    for y in range(height):
        for x in range(width):
            idx = (y * width + x) * 4
            pixels[idx:idx+4] = color_rgba
    
    return create_png(width, height, bytes(pixels))

def create_gradient_background(width, height, color1_rgba, color2_rgba):
    """Create a gradient background"""
    pixels = bytearray(width * height * 4)
    
    for y in range(height):
        t = y / height
        r = int(color1_rgba[0] * (1-t) + color2_rgba[0] * t)
        g = int(color1_rgba[1] * (1-t) + color2_rgba[1] * t)
        b = int(color1_rgba[2] * (1-t) + color2_rgba[2] * t)
        a = int(color1_rgba[3] * (1-t) + color2_rgba[3] * t)
        
        for x in range(width):
            idx = (y * width + x) * 4
            pixels[idx:idx+4] = (r, g, b, a)
    
    return create_png(width, height, bytes(pixels))

def create_basketball_hoop(width, height):
    """Create a basketball hoop/stand sprite"""
    pixels = bytearray(width * height * 4)
    center_x = width / 2
    center_y = height / 2
    hoop_radius = min(width, height) / 2 - 10
    pole_width = 6
    
    for y in range(height):
        for x in range(width):
            idx = (y * width + x) * 4
            dx = x - center_x
            dy = y - center_y
            
            # Draw pole (vertical rectangle at center)
            if abs(dx) < pole_width / 2 and y > center_y:
                pixels[idx:idx+4] = (120, 80, 40, 255)  # Brown pole
            # Draw hoop (circle/ring at top)
            elif y < center_y + 15:
                dist = (dx*dx + dy*dy) ** 0.5
                # Outer circle
                if hoop_radius - 3 <= dist <= hoop_radius + 3:
                    pixels[idx:idx+4] = (255, 140, 0, 255)  # Orange hoop
                # Inner rim
                elif hoop_radius - 1 <= dist <= hoop_radius + 1:
                    pixels[idx:idx+4] = (200, 100, 0, 255)  # Darker orange
            else:
                pixels[idx:idx+4] = (0, 0, 0, 0)  # Transparent
    
    return create_png(width, height, bytes(pixels))

def create_baseball_player(width, height):
    """Create a baseball player silhouette"""
    pixels = bytearray(width * height * 4)
    center_x = width / 2
    head_y = 8
    body_start_y = head_y + 6
    body_end_y = height - 8
    
    for y in range(height):
        for x in range(width):
            idx = (y * width + x) * 4
            dx = x - center_x
            
            # Draw head (circle at top)
            if y < body_start_y:
                dist = ((x - center_x)**2 + (y - head_y)**2) ** 0.5
                if dist <= 5:
                    pixels[idx:idx+4] = (60, 60, 80, 255)  # Dark blue head
                else:
                    pixels[idx:idx+4] = (0, 0, 0, 0)
            # Draw body (rounded rectangle/oval)
            elif body_start_y <= y < body_end_y - 8:
                body_width = 10 - abs(dx) * 0.3
                if abs(dx) < body_width:
                    pixels[idx:idx+4] = (60, 60, 80, 255)  # Dark blue body
                else:
                    pixels[idx:idx+4] = (0, 0, 0, 0)
            # Draw legs (two rectangles at bottom)
            else:
                leg_width = 3
                if abs(dx - 2) < leg_width or abs(dx + 2) < leg_width:
                    pixels[idx:idx+4] = (60, 60, 80, 255)  # Dark blue legs
                else:
                    pixels[idx:idx+4] = (0, 0, 0, 0)
    
    return create_png(width, height, bytes(pixels))

def create_baseball_bat(width, height):
    """Create a baseball bat shape"""
    pixels = bytearray(width * height * 4)
    center_x = width / 2
    handle_y = height - 8
    barrel_y = 4
    
    for y in range(height):
        for x in range(width):
            idx = (y * width + x) * 4
            dx = abs(x - center_x)
            
            # Draw handle (narrow at bottom)
            if y > handle_y:
                width_at_y = 2 + (y - handle_y) * 0.2
                if dx < width_at_y:
                    pixels[idx:idx+4] = (120, 80, 40, 255)  # Brown handle
                else:
                    pixels[idx:idx+4] = (0, 0, 0, 0)
            # Draw barrel (wider at top)
            elif y < barrel_y + 2:
                width_at_y = 6 - (y - barrel_y) * 0.5
                if dx < width_at_y:
                    pixels[idx:idx+4] = (120, 80, 40, 255)  # Brown barrel
                else:
                    pixels[idx:idx+4] = (0, 0, 0, 0)
            # Draw middle section (tapered)
            else:
                t = (y - barrel_y) / (handle_y - barrel_y)
                width_at_y = 6 - t * 4
                if dx < width_at_y:
                    pixels[idx:idx+4] = (120, 80, 40, 255)  # Brown middle
                else:
                    pixels[idx:idx+4] = (0, 0, 0, 0)
    
    return create_png(width, height, bytes(pixels))

def create_soccer_goal(width, height):
    """Create a soccer goal sprite (two posts with crossbar)"""
    pixels = bytearray(width * height * 4)
    post_width = 4
    left_post_x = width * 0.2
    right_post_x = width * 0.8
    crossbar_y = height * 0.3
    
    for y in range(height):
        for x in range(width):
            idx = (y * width + x) * 4
            
            # Draw left post (vertical)
            if abs(x - left_post_x) < post_width and y > crossbar_y:
                pixels[idx:idx+4] = (200, 200, 200, 255)  # White post
            # Draw right post (vertical)
            elif abs(x - right_post_x) < post_width and y > crossbar_y:
                pixels[idx:idx+4] = (200, 200, 200, 255)  # White post
            # Draw crossbar (horizontal)
            elif abs(y - crossbar_y) < 2 and left_post_x <= x <= right_post_x:
                pixels[idx:idx+4] = (200, 200, 200, 255)  # White crossbar
            # Draw net (dashed lines)
            elif crossbar_y < y < height - 5 and (left_post_x + post_width) < x < (right_post_x - post_width):
                if (x + y) % 8 < 3:
                    pixels[idx:idx+4] = (180, 180, 180, 150)  # Semi-transparent net
                else:
                    pixels[idx:idx+4] = (0, 0, 0, 0)
            else:
                pixels[idx:idx+4] = (0, 0, 0, 0)  # Transparent
    
    return create_png(width, height, bytes(pixels))

# Create sprites
import os
os.makedirs('assets/sprites', exist_ok=True)

# Ball: 16x16 (8px radius), red (1, 0.2, 0.2, 1)
with open('assets/sprites/ball.png', 'wb') as f:
    f.write(create_circle_sprite(16, (255, 51, 51, 255)))

# Flipper: 60x12, light blue (0.2, 0.6, 1, 1)
with open('assets/sprites/flipper.png', 'wb') as f:
    f.write(create_rect_sprite(60, 12, (51, 153, 255, 255)))

# Bumper: 60x60, yellow (1, 1, 0.2, 1)
with open('assets/sprites/bumper.png', 'wb') as f:
    f.write(create_circle_sprite(60, (255, 255, 51, 255)))

# Peg: 16x16, white (1, 1, 1, 1)
with open('assets/sprites/peg.png', 'wb') as f:
    f.write(create_circle_sprite(16, (255, 255, 255, 255)))

# Wall obstacle: 40x10, gray (0.5, 0.5, 0.5, 1)
with open('assets/sprites/wall_obstacle.png', 'wb') as f:
    f.write(create_rect_sprite(40, 10, (128, 128, 128, 255)))

# Wall: 20x20 tileable, gray-blue (0.3, 0.3, 0.4, 1)
with open('assets/sprites/wall.png', 'wb') as f:
    f.write(create_rect_sprite(20, 20, (77, 77, 102, 255)))

# Background: 800x600, dark blue-gray (0.1, 0.1, 0.2, 1)
with open('assets/sprites/background.png', 'wb') as f:
    f.write(create_rect_sprite(800, 600, (26, 26, 51, 255)))

# Plunger: 10x30, red (0.8, 0.2, 0.2, 1)
with open('assets/sprites/plunger.png', 'wb') as f:
    f.write(create_rect_sprite(10, 30, (204, 51, 51, 255)))

# Launcher base: 60x10, gray (0.4, 0.4, 0.4, 1)
with open('assets/sprites/launcher_base.png', 'wb') as f:
    f.write(create_rect_sprite(60, 10, (102, 102, 102, 255)))

# Sports-themed obstacles
# Basketball hoop: 60x60 (replaces bumper)
with open('assets/sprites/basketball_hoop.png', 'wb') as f:
    f.write(create_basketball_hoop(60, 60))

# Baseball player: 20x40 (replaces peg)
with open('assets/sprites/baseball_player.png', 'wb') as f:
    f.write(create_baseball_player(20, 40))

# Baseball bat: 40x12 (replaces wall obstacle)
with open('assets/sprites/baseball_bat.png', 'wb') as f:
    f.write(create_baseball_bat(40, 12))

# Soccer goal: 50x30 (additional sports obstacle)
with open('assets/sprites/soccer_goal.png', 'wb') as f:
    f.write(create_soccer_goal(50, 30))

print("Sprites generated successfully!")


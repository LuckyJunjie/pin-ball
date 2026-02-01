#!/usr/bin/env python3
"""
Calculate Flutter Pinball coordinates to Godot coordinates conversion.
"""

SCALE = 5.0  # Meters to pixels (adjusted to fit screen)
CENTER_X = 400.0
CENTER_Y = 300.0

def flutter_to_godot(flutter_x, flutter_y):
    """Convert Flutter Forge2D coordinates to Godot pixel coordinates."""
    godot_x = flutter_x * SCALE + CENTER_X
    godot_y = flutter_y * SCALE + CENTER_Y  # Same Y direction (both positive down)
    return godot_x, godot_y

def print_position(name, flutter_x, flutter_y):
    godot_x, godot_y = flutter_to_godot(flutter_x, flutter_y)
    print(f"{name:30} Flutter: ({flutter_x:6.2f}, {flutter_y:6.2f}) -> Godot: ({godot_x:6.1f}, {godot_y:6.1f})")

print("=== Flutter Pinball to Godot Coordinate Conversion ===")
print(f"Scale: {SCALE}, Center: ({CENTER_X}, {CENTER_Y})")
print()

print("=== Flippers ===")
print_position("Left Flipper", -18.65, 43.6)
print_position("Right Flipper", 4.75, 43.6)
print()

print("=== Android Acres Components ===")
print_position("Android Spaceship", -26.5, -28.5)
print_position("Android Bumper A", -25.2, 1.5)
print_position("Android Bumper B", -32.9, -13.0)  # Estimated
print_position("Android Bumper Cow", -20.7, -8.0)  # Estimated
print()

print("=== Zone Centers (Approximate) ===")
print("Note: These are quadrant-based approximations")
print("Android Acres (upper left): (200, 150)")
print("Dino Desert (upper right): (600, 150)")
print("Flutter Forest (lower left): (200, 400)")
print("Sparky Scorch (lower right): (600, 400)")
print("Google Gallery (center top): (400, 250)")
print()

print("=== Other Components ===")
print("Launcher (bottom center): (400, 550)")
print("Drain (bottom center): (400, 605)")
print("Skill Shot (center): (400, 200)")
print("Ramp (left side): (180, 180)")
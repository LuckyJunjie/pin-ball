extends Node
## v4.0 Coordinate conversion: Flutter Forge2D → Godot 4.x pixel coordinates.
## Reference: design/FLUTTER-LAYOUT-AND-ASSETS.md
##
## Flutter: board 101.6×143.8, center (0,0), Y positive down.
## Godot: viewport 800×600, center (400,300).
## Formula: Godot = (400 + Flutter.x * SCALE, 300 + Flutter.y * SCALE)

const SCALE: float = 5.0
const CENTER_X: float = 400.0
const CENTER_Y: float = 300.0

## Convert Flutter Forge2D coordinates to Godot pixel coordinates.
static func flutter_to_godot(flutter_pos: Vector2) -> Vector2:
	return Vector2(flutter_pos.x * SCALE + CENTER_X, flutter_pos.y * SCALE + CENTER_Y)

## Convert Godot pixel coordinates to Flutter Forge2D.
static func godot_to_flutter(godot_pos: Vector2) -> Vector2:
	return Vector2((godot_pos.x - CENTER_X) / SCALE, (godot_pos.y - CENTER_Y) / SCALE)

## Flutter impulse/force scale to Godot RigidBody2D units (approx. SCALE for position-equivalent).
static func flutter_impulse_to_godot(flutter_impulse: Vector2) -> Vector2:
	return flutter_impulse * SCALE

## Get Godot positions from Flutter layout (FLUTTER-LAYOUT-AND-ASSETS.md).
static func get_component_position(component_name: String) -> Vector2:
	match component_name:
		# Flippers (Flutter: Flipper L -12.05,43.6 | R 4.8,43.6)
		"flipper_left":
			return flutter_to_godot(Vector2(-12.05, 43.6))
		"flipper_right":
			return flutter_to_godot(Vector2(4.8, 43.6))
		# Plunger (Flutter: 41, 43.7) – right side of board
		"launcher":
			return flutter_to_godot(Vector2(41, 43.7))
		"launcher_flutter":
			return flutter_to_godot(Vector2(41, 43.7))

		# Android Acres (Flutter table)
		"android_spaceship":
			return flutter_to_godot(Vector2(-26.5, -28.5))
		"android_bumper_a":
			return flutter_to_godot(Vector2(-25.2, 1.5))
		"android_bumper_b":
			return flutter_to_godot(Vector2(-32.9, -9.3))
		"android_bumper_cow":
			return flutter_to_godot(Vector2(-20.7, -13.0))

		# Zone centers (Godot-adapted quadrants for 800×600)
		"android_acres_zone":
			return Vector2(200, 150)
		"dino_desert_zone":
			return Vector2(600, 150)
		"flutter_forest_zone":
			return Vector2(200, 400)
		"sparky_scorch_zone":
			return Vector2(600, 400)
		"google_gallery":
			return Vector2(400, 250)

		# Playfield fixtures (Flutter: bottom y=71.9 -> Godot y=660)
		"drain":
			return Vector2(400, 660)
		"skill_shot":
			return Vector2(400, 200)
		"ramp":
			return Vector2(180, 180)  # Left-side ramp (Godot layout; no Flutter single main ramp)

		_:
			push_warning("CoordinateConverterV4: Unknown component '%s'" % component_name)
			return Vector2.ZERO

## Test the coordinate conversion.
static func test_conversion() -> void:
	print("=== CoordinateConverterV4 Test ===")
	var flutter_left = Vector2(-12.05, 43.6)
	print("Left flipper: Flutter %s -> Godot %s" % [flutter_left, flutter_to_godot(flutter_left)])
	var flutter_right = Vector2(4.8, 43.6)
	print("Right flipper: Flutter %s -> Godot %s" % [flutter_right, flutter_to_godot(flutter_right)])
	print("Launcher: %s" % get_component_position("launcher"))
	print("Bonus spawn: Flutter (29.2,-24.5) -> %s" % flutter_to_godot(Vector2(29.2, -24.5)))
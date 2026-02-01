extends Node
## v4.0 Coordinate conversion utility for Flutter Pinball to Godot.
## Converts Forge2D physics coordinates (used in Flutter Pinball) to Godot pixel coordinates.

# Flutter Pinball uses Forge2D physics coordinates with:
# - Origin at center of board
# - X: negative left, positive right
# - Y: negative up, positive down
# - Gravity: Vector2(0, 30) (downward)

# Godot uses:
# - Origin at top-left
# - X: positive right
# - Y: positive down
# - Screen size: 800x600 for MainV4.tscn
# - Center: Vector2(400, 300)

# Conversion formula:
# Godot X = Flutter X * scale + center_x
# Godot Y = Flutter Y * scale + center_y (same Y direction - both positive down)

const SCALE: float = 5.0  # Meters to pixels scaling factor (adjusted to fit 800x600 screen)
const CENTER_X: float = 400.0
const CENTER_Y: float = 300.0

## Convert Flutter Forge2D coordinates to Godot pixel coordinates.
static func flutter_to_godot(flutter_pos: Vector2) -> Vector2:
	var godot_x = flutter_pos.x * SCALE + CENTER_X
	var godot_y = flutter_pos.y * SCALE + CENTER_Y  # Same Y direction
	return Vector2(godot_x, godot_y)

## Convert Godot pixel coordinates to Flutter Forge2D coordinates.
static func godot_to_flutter(godot_pos: Vector2) -> Vector2:
	var flutter_x = (godot_pos.x - CENTER_X) / SCALE
	var flutter_y = (godot_pos.y - CENTER_Y) / SCALE  # Same Y direction
	return Vector2(flutter_x, flutter_y)

## Get component positions based on Flutter Pinball analysis.
static func get_component_position(component_name: String) -> Vector2:
	match component_name:
		# Flippers (from analysis)
		"flipper_left":
			# Flutter: X ≈ -18.65, Y = 43.6
			return flutter_to_godot(Vector2(-18.65, 43.6))
		"flipper_right":
			# Flutter: X ≈ 4.75, Y = 43.6
			return flutter_to_godot(Vector2(4.75, 43.6))
		
		# Android Acres components
		"android_spaceship":
			# Flutter: Vector2(-26.5, -28.5)
			return flutter_to_godot(Vector2(-26.5, -28.5))
		"android_bumper_a":
			# Flutter: Vector2(-25.2, 1.5)
			return flutter_to_godot(Vector2(-25.2, 1.5))
		"android_bumper_b":
			# Flutter: Vector2(-32.9, -13.0) (estimated)
			return flutter_to_godot(Vector2(-32.9, -13.0))
		"android_bumper_cow":
			# Flutter: Vector2(-20.7, -8.0) (estimated)
			return flutter_to_godot(Vector2(-20.7, -8.0))
		
		# Zone centers (approximate)
		"android_acres_zone":
			# Upper left quadrant
			return Vector2(200, 150)
		"dino_desert_zone":
			# Upper right quadrant
			return Vector2(600, 150)
		"flutter_forest_zone":
			# Lower left quadrant
			return Vector2(200, 400)
		"sparky_scorch_zone":
			# Lower right quadrant
			return Vector2(600, 400)
		"google_gallery":
			# Center top
			return Vector2(400, 250)
		
		# Other components
		"launcher":
			# Bottom center
			return Vector2(400, 550)
		"drain":
			# Bottom center
			return Vector2(400, 605)
		"skill_shot":
			# Center
			return Vector2(400, 200)
		"ramp":
			# Left side
			return Vector2(180, 180)
		
		_:
			push_warning("CoordinateConverterV4: Unknown component '%s'" % component_name)
			return Vector2.ZERO

## Test the coordinate conversion.
static func test_conversion() -> void:
	print("=== CoordinateConverterV4 Test ===")
	
	# Test flipper conversion
	var flutter_left = Vector2(-18.65, 43.6)
	var godot_left = flutter_to_godot(flutter_left)
	print("Left flipper:")
	print("  Flutter: %s" % flutter_left)
	print("  Godot: %s" % godot_left)
	print("  Back to Flutter: %s" % godot_to_flutter(godot_left))
	
	var flutter_right = Vector2(4.75, 43.6)
	var godot_right = flutter_to_godot(flutter_right)
	print("Right flipper:")
	print("  Flutter: %s" % flutter_right)
	print("  Godot: %s" % godot_right)
	
	# Test Android Spaceship
	var flutter_spaceship = Vector2(-26.5, -28.5)
	var godot_spaceship = flutter_to_godot(flutter_spaceship)
	print("Android Spaceship:")
	print("  Flutter: %s" % flutter_spaceship)
	print("  Godot: %s" % godot_spaceship)
	
	print("=== Component Positions ===")
	print("Left flipper: %s" % get_component_position("flipper_left"))
	print("Right flipper: %s" % get_component_position("flipper_right"))
	print("Android Spaceship: %s" % get_component_position("android_spaceship"))
	print("Android Bumper A: %s" % get_component_position("android_bumper_a"))
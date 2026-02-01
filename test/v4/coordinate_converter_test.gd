extends Node

func _ready():
	print("=== CoordinateConverterV4 Test ===")
	
	# Test flipper conversion
	var flutter_left = Vector2(-18.65, 43.6)
	var godot_left = CoordinateConverterV4.flutter_to_godot(flutter_left)
	print("Left flipper:")
	print("  Flutter: %s" % flutter_left)
	print("  Godot: %s" % godot_left)
	print("  Back to Flutter: %s" % CoordinateConverterV4.godot_to_flutter(godot_left))
	
	var flutter_right = Vector2(4.75, 43.6)
	var godot_right = CoordinateConverterV4.flutter_to_godot(flutter_right)
	print("Right flipper:")
	print("  Flutter: %s" % flutter_right)
	print("  Godot: %s" % godot_right)
	
	# Test Android Spaceship
	var flutter_spaceship = Vector2(-26.5, -28.5)
	var godot_spaceship = CoordinateConverterV4.flutter_to_godot(flutter_spaceship)
	print("Android Spaceship:")
	print("  Flutter: %s" % flutter_spaceship)
	print("  Godot: %s" % godot_spaceship)
	
	print("=== Component Positions ===")
	print("Left flipper: %s" % CoordinateConverterV4.get_component_position("flipper_left"))
	print("Right flipper: %s" % CoordinateConverterV4.get_component_position("flipper_right"))
	print("Android Spaceship: %s" % CoordinateConverterV4.get_component_position("android_spaceship"))
	print("Android Bumper A: %s" % CoordinateConverterV4.get_component_position("android_bumper_a"))
	
	get_tree().quit()
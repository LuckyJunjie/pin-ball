extends RigidBody2D

## Flipper script for pinball game
## Handles flipper input and rotation animation

@export var flipper_side: String = "left"  # "left" or "right"
@export var rest_angle: float = 30.0  # Left: 30° (points up-right like \), Right: -30° (points up-left like /)
@export var pressed_angle: float = -10.0  # When pressed, tip moves toward center (left: -10°, right: 10°)
@export var rotation_speed: float = 20.0

var is_pressed: bool = false
var target_angle: float = 0.0

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	# Configure physics properties
	gravity_scale = 0.0
	lock_rotation = false
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true  # Freeze the body, we'll control rotation manually
	collision_layer = 2  # Flipper layer
	collision_mask = 1  # Collide with ball
	mass = 1.0
	
	# Adjust angles based on side for \ / shape pointing toward center
	# Left flipper: points up-right like \ (positive angle at rest)
	# Right flipper: points up-left like / (negative angle at rest)
	# When pressed, tips rotate TOWARD center (left rotates to negative, right rotates to positive)
	if flipper_side == "right":
		# Right flipper: points up-left toward center (like /)
		# Rest: negative angle pointing up-left (-30°)
		# Pressed: tip moves toward center by rotating to positive angle (10°)
		if rest_angle > 0:
			rest_angle = -abs(rest_angle)  # Convert to negative (default -30°)
		if pressed_angle < 0:
			pressed_angle = abs(pressed_angle)  # Convert to positive (default 10°) - tip moves left toward center
	else:
		# Left flipper: points up-right toward center (like \)
		# Rest: positive angle pointing up-right (30°)
		# Pressed: tip moves toward center by rotating to negative angle (-10°)
		if rest_angle < 0:
			rest_angle = abs(rest_angle)  # Convert to positive (default 30°)
		if pressed_angle > 0:
			pressed_angle = -abs(pressed_angle)  # Convert to negative (default -10°) - tip moves right toward center
	
	# Set initial angle
	target_angle = rest_angle
	rotation_degrees = rest_angle
	
	# Configure physics material for bounce
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.6
	physics_material.friction = 0.5
	physics_material_override = physics_material
	
	# Add visual label if debug mode enabled
	if _get_debug_mode():
		add_visual_label("FLIPPER\n" + flipper_side.to_upper())

func _physics_process(delta):
	# Get input based on flipper side
	var input_pressed = false
	if flipper_side == "left":
		input_pressed = Input.is_action_pressed("flipper_left")
		if input_pressed and not is_pressed:
			if _get_debug_mode():
				print("[Flipper] Left flipper pressed")
			_play_flipper_sound()
	else:
		input_pressed = Input.is_action_pressed("flipper_right")
		if input_pressed and not is_pressed:
			if _get_debug_mode():
				print("[Flipper] Right flipper pressed")
			_play_flipper_sound()
	
	# Update target angle based on input
	if input_pressed:
		target_angle = pressed_angle
		if not is_pressed and _get_debug_mode():
			print("[Flipper] ", flipper_side, " flipper activating - target angle: ", target_angle)
		is_pressed = true
	else:
		if is_pressed and _get_debug_mode():
			print("[Flipper] ", flipper_side, " flipper released - returning to rest")
		target_angle = rest_angle
		is_pressed = false
	
	# Smoothly rotate towards target angle (only rotate when needed)
	var angle_diff = target_angle - rotation_degrees
	if abs(angle_diff) > 0.1:
		var rotation_dir = sign(angle_diff)
		var rotation_amount = min(abs(angle_diff), rotation_speed * delta * 60.0)
		rotation_degrees += rotation_dir * rotation_amount

func _play_flipper_sound():
	"""Play flipper click sound"""
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager and sound_manager.has_method("play_sound"):
		sound_manager.play_sound("flipper_click")

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "VisualLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.2, 0.8, 1, 1))  # Light blue
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-30, -20)  # Offset from center
	add_child(label)

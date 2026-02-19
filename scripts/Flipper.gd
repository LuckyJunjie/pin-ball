extends RigidBody2D

## Flipper script for pinball game
## Handles flipper input and rotation animation

@export var flipper_side: String = "left"  # "left" or "right"
@export var rest_angle: float = 30.0  # Left: 30° (points up-right like \), Right: -30° (points up-left like /)
@export var pressed_angle: float = -10.0  # When pressed, tip moves toward center (left: -10°, right: 10°)
@export var rotation_speed: float = 20.0

# v3.0: Enhanced physics properties from vpinball
@export var flipper_strength: float = 2200.0  # 1200-1800 (EM) or 2200-2800 (modern)
@export var elasticity: float = 0.7  # 0.55-0.8
@export var elasticity_falloff: float = 0.3  # 0.1-0.43 (new property for realistic flipper feel)
@export var flipper_friction: float = 0.3  # 0.1-0.6
@export var return_strength: float = 0.058  # Smooth return
@export var coil_up_ramp: float = 3.0  # 2.4-3.5 (gradual power increase)

var is_pressed: bool = false
var target_angle: float = 0.0
var angle_diff: float = 0.0  # v3.0: Track angle difference for force calculation

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GlobalGameSettings"""
	# Check GlobalGameSettings singleton (autoload)
	if has_node("/root/GlobalGameSettings"):
		var global_settings = get_node("/root/GlobalGameSettings")
		if global_settings.has_method("get") and global_settings.get("debug_mode") != null:
			return bool(global_settings.debug_mode)
	# Fallback to checking game_manager group
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
	freeze = false  # DON'T freeze - we need physics collision!
	collision_layer = 2  # Flipper layer
	collision_mask = 1  # Collide with ball
	mass = 1.0
	
	# v3.0: Add glow effect to flippers
	_add_glow_effect()
	
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
	
	# v4: Use Flutter parity textures - left.png for left, right.png for right
	var visual = get_node_or_null("Visual")
	if visual is Sprite2D:
		var tex = load("res://assets/sprites/flipper/right.png") as Texture2D if flipper_side == "right" else load("res://assets/sprites/flipper/left.png") as Texture2D
		if tex:
			visual.texture = tex
	
	# Configure physics material for bounce (v3.0: enhanced values)
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = elasticity
	physics_material.friction = flipper_friction
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
	# v3.0: Apply coil up ramp for gradual power increase
	angle_diff = target_angle - rotation_degrees
	if abs(angle_diff) > 0.1:
		var rotation_dir = sign(angle_diff)
		# Apply coil up ramp: faster at start, slower as approaching target
		var ramp_factor = 1.0 + (coil_up_ramp - 1.0) * (1.0 - abs(angle_diff) / abs(pressed_angle - rest_angle))
		var rotation_amount = min(abs(angle_diff), rotation_speed * delta * 60.0 * ramp_factor)
		rotation_degrees += rotation_dir * rotation_amount
		
		# v3.0: Apply force to ball when flipper is moving (realistic flipper physics)
		if is_pressed:
			_apply_flipper_force(delta)

func _play_flipper_sound():
	"""Play flipper click sound"""
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager and sound_manager.has_method("play_sound"):
		sound_manager.play_sound("flipper_click")

func _apply_flipper_force(delta: float):
	"""v3.0: Apply realistic flipper force to ball when flipper is moving"""
	# Get collision shape
	var collision_shape = get_node_or_null("CollisionShape2D")
	if not collision_shape or not collision_shape.shape:
		return
	
	# Get all bodies in contact with flipper
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = collision_shape.shape
	query.transform = global_transform
	query.collision_mask = 1  # Ball layer
	query.exclude = [self]
	
	var results = space_state.intersect_shape(query)
	for result in results:
		var body = result.collider
		if body is RigidBody2D and body.collision_layer == 1:  # Ball
			# Calculate force direction (perpendicular to flipper surface)
			var flipper_direction = Vector2(cos(rotation), sin(rotation))
			var force_direction = Vector2(-flipper_direction.y, flipper_direction.x)  # Perpendicular
			
			# Apply force based on flipper strength and elasticity falloff
			var angle_range = abs(pressed_angle - rest_angle)
			if angle_range > 0.1:
				var distance_factor = 1.0 - (abs(angle_diff) / angle_range)
				var falloff_factor = 1.0 - (elasticity_falloff * (1.0 - distance_factor))
				var force_magnitude = flipper_strength * falloff_factor * delta
				body.apply_impulse(force_direction * force_magnitude)

func _add_glow_effect():
	"""v3.0: Add glow effect to flipper"""
	var glow_script = load("res://scripts/GlowEffect.gd")
	if glow_script:
		var glow = Node2D.new()
		glow.set_script(glow_script)
		glow.glow_color = Color(0.2, 0.6, 1.0, 1.0)  # Blue glow for flippers
		glow.glow_size = 1.2
		glow.glow_intensity = 1.0
		glow.pulse_enabled = false  # No pulse, just steady glow
		add_child(glow)
		
		# Update glow intensity when pressed
		if is_pressed:
			glow.set_glow_intensity(1.5)  # Brighter when active

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

# TC-010: Quick succession test helper
var last_press_time: float = 0.0

func _test_quick_press_detection():
	"""TC-010: Test quick succession response time"""
	var current_time = Time.get_ticks_msec()
	var time_diff = current_time - last_press_time
	last_press_time = current_time
	
	# Log for TC-010: should be < 100ms for good response
	if time_diff < 100:
		if _get_debug_mode():
			print("TC-010-PASS: Quick press detected: %d ms" % time_diff)
	return time_diff

func _get_test_results() -> Dictionary:
	"""Return test results for CI/CD validation"""
	return {
		"flipper_side": flipper_side,
		"rest_angle": rest_angle,
		"pressed_angle": pressed_angle,
		"rotation_speed": rotation_speed,
		"flipper_strength": flipper_strength,
		"is_ready": true
	}


func get_flipper_side() -> String:
	"""Return the flipper side for collision detection"""
	return flipper_side

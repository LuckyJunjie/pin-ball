extends Area2D

## Hold (target hole) script for pinball game
## Detects when ball enters hold and awards final scoring

signal hold_entered(points: int)

@export var points_value: int = 10  # Point value for this hold (10, 15, 20, 25, 30, etc.)

var captured_ball: RigidBody2D = null

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	# Add to holds group
	add_to_group("holds")
	
	# Set up Area2D for detection
	collision_layer = 0  # No collision layer (detection only)
	collision_mask = 1  # Detect ball layer (layer 1)
	# Area2D will detect via body_entered signal when ball enters
	
	# Connect body_entered signal
	body_entered.connect(_on_body_entered)
	
	# Add visual representation
	_create_visual()
	
	# Add visual label if debug mode enabled
	if _get_debug_mode():
		add_visual_label("HOLD\n" + str(points_value))
	
	if _get_debug_mode():
		print("[Hold] Hold created at position: ", global_position, " with points: ", points_value)

func _create_visual():
	"""Create visual representation of hold"""
	# Create a circular visual (hole)
	var visual = ColorRect.new()
	visual.name = "Visual"
	visual.color = Color(0.1, 0.1, 0.1, 1)  # Dark hole color
	# Size will be set by collision shape if available
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape and collision_shape.shape:
		if collision_shape.shape is CircleShape2D:
			var radius = collision_shape.shape.radius
			visual.offset_left = -radius
			visual.offset_top = -radius
			visual.offset_right = radius
			visual.offset_bottom = radius
		elif collision_shape.shape is RectangleShape2D:
			var size = collision_shape.shape.size
			visual.offset_left = -size.x / 2.0
			visual.offset_top = -size.y / 2.0
			visual.offset_right = size.x / 2.0
			visual.offset_bottom = size.y / 2.0
	else:
		# Default size
		visual.offset_left = -15.0
		visual.offset_top = -15.0
		visual.offset_right = 15.0
		visual.offset_bottom = 15.0
	add_child(visual)
	
	# Add point value label
	var point_label = Label.new()
	point_label.name = "PointLabel"
	point_label.text = str(points_value)
	point_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	point_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	point_label.add_theme_font_size_override("font_size", 16)
	point_label.add_theme_color_override("font_color", Color(1, 1, 0, 1))  # Yellow
	point_label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	point_label.add_theme_constant_override("outline_size", 2)
	point_label.position = Vector2(-20, -10)
	add_child(point_label)

func _on_body_entered(body: Node2D):
	"""Called when a body enters the hold - capture the ball"""
	if body is RigidBody2D and body.collision_layer == 1:  # Ball layer
		if captured_ball != null:
			# Already captured a ball, ignore additional entries
			return
		
		captured_ball = body
		
		if _get_debug_mode():
			print("[Hold] Ball entered hold at position: ", global_position, " - capturing ball and awarding ", points_value, " points")
		
		# Capture the ball: freeze it and position at hold center
		body.freeze = true
		body.linear_velocity = Vector2.ZERO
		body.angular_velocity = 0.0
		body.global_position = global_position
		
		# Emit signal to award points and end round
		hold_entered.emit(points_value)

func add_visual_label(text: String):
	"""Add a visual label to identify this object (debug mode)"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "DebugLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1, 0.5, 0, 1))  # Orange
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-30, -40)  # Offset from center
	add_child(label)


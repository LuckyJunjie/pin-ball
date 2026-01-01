extends RigidBody2D

## Ball script for pinball game
## Handles ball physics, collision, and respawn logic

signal ball_lost

@export var respawn_y_threshold: float = 800.0
@export var initial_position: Vector2 = Vector2(400, 200)
@export var boundary_left: float = 20.0
@export var boundary_right: float = 780.0
@export var boundary_top: float = 20.0
@export var boundary_bottom: float = 580.0

func _ready():
	# Configure physics properties
	gravity_scale = 1.0
	linear_damp = 0.05  # Low damping for more realistic ball movement
	angular_damp = 0.05
	mass = 0.5  # Light ball
	
	# Set collision layers
	collision_layer = 1  # Ball layer
	collision_mask = 2 | 4 | 8  # Collide with flippers (2), walls (4), and obstacles (8)
	
	# Configure physics material for bounce
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.8  # High bounce
	physics_material.friction = 0.3  # Low friction
	physics_material_override = physics_material
	
	# Add visual label
	add_visual_label("BALL")
	
	# Debug: Check visual components
	print("[Ball] _ready() - Position: ", global_position, ", Visible: ", visible, ", Modulate: ", modulate)
	var sprite = get_node_or_null("Visual")
	if sprite:
		print("[Ball] Visual sprite found - texture: ", sprite.texture, ", visible: ", sprite.visible, ", position: ", sprite.position)
		if sprite.texture == null:
			print("[Ball] WARNING: Visual sprite has no texture!")
	else:
		print("[Ball] WARNING: No Visual sprite found!")
	
	var color_rect = get_node_or_null("ColorRectFallback")
	if color_rect:
		print("[Ball] ColorRectFallback found - visible: ", color_rect.visible, ", color: ", color_rect.color)
	
	# Check if ball is in viewport
	var viewport = get_viewport()
	if viewport:
		var visible_rect = viewport.get_visible_rect()
		print("[Ball] Viewport visible rect: ", visible_rect)
		print("[Ball] Ball position in viewport: ", visible_rect.has_point(global_position))

func _physics_process(_delta):
	# Debug: Log ball position periodically (every 60 frames ~ 1 second at 60fps)
	if Engine.get_process_frames() % 60 == 0:
		print("[Ball] Position: ", global_position, ", Velocity: ", linear_velocity, ", Visible: ", visible)
	
	# Ensure ball stays within boundaries (safety check)
	var clamped_x = clamp(global_position.x, boundary_left, boundary_right)
	var clamped_y = clamp(global_position.y, boundary_top, boundary_bottom)
	
	# If ball somehow escaped, push it back in
	if global_position.x != clamped_x or global_position.y != clamped_y:
		print("[Ball] WARNING: Ball escaped boundaries! Position: ", global_position, ", Clamped to: ", Vector2(clamped_x, clamped_y))
		global_position = Vector2(clamped_x, clamped_y)
		# Apply a small correction impulse away from boundary
		if global_position.x <= boundary_left:
			apply_impulse(Vector2(50, 0))
		elif global_position.x >= boundary_right:
			apply_impulse(Vector2(-50, 0))
		if global_position.y <= boundary_top:
			apply_impulse(Vector2(0, 50))
		elif global_position.y >= boundary_bottom:
			apply_impulse(Vector2(0, -50))
	
	# Check if ball fell below the table
	if global_position.y > respawn_y_threshold:
		print("[Ball] Ball lost! Position: ", global_position, " (threshold: ", respawn_y_threshold, ")")
		ball_lost.emit()

func reset_ball():
	"""Reset ball to initial position with zero velocity"""
	global_position = initial_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = false

func launch_ball(force: Vector2 = Vector2(0, -500)):
	"""Launch the ball with a given force"""
	print("[Ball] launch_ball() called - force: ", force, ", position: ", global_position, ", velocity before: ", linear_velocity)
	apply_impulse(force)
	print("[Ball] Velocity after launch: ", linear_velocity)

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	var label = Label.new()
	label.name = "VisualLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-30, -30)  # Offset from center
	add_child(label)

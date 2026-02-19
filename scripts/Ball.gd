extends RigidBody2D

## Ball script for pinball game
## Handles ball physics, collision, and respawn logic

signal ball_lost

@export var respawn_y_threshold: float = 680.0  # Below drain (y=660); ball_lost if falls past
@export var initial_position: Vector2 = Vector2(400, 200)
@export var boundary_left: float = 20.0
@export var boundary_right: float = 780.0
@export var boundary_top: float = 20.0
@export var boundary_bottom: float = 650.0  # Increased to allow fall-through

var has_emitted_lost: bool = false  # Prevent multiple ball_lost emissions

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
	# Add to balls group for easy access by other systems (e.g., Launcher)
	add_to_group("balls")
	
	# Configure physics properties (v3.0: enhanced values)
	gravity_scale = 1.0  # Gravity constant normalized to 0.97-1.0 range
	linear_damp = 0.02  # Very low damping for longer ball travel across playfield
	angular_damp = 0.02
	mass = 0.4  # Slightly lighter ball for better movement
	
	# Enable continuous collision detection to prevent tunneling through walls
	continuous_cd = RigidBody2D.CCD_MODE_CAST_SHAPE
	max_contacts_reported = 4
	contact_monitor = true  # Enable collision signal monitoring
	
	# Connect collision signal
	body_entered.connect(_on_body_entered)
	
	# Set collision layers
	collision_layer = 1  # Ball layer
	collision_mask = 2 | 4 | 8 | 16  # Collide with flippers (2), walls (4), obstacles (8), and holds (16)
	
	# Configure physics material for better bounce and reflection (v3.0: realistic values)
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.85  # Higher bounce for better reflection
	physics_material.friction = 0.075  # v3.0: Playfield friction 0.075+ (adjustable for ball speed)
	physics_material_override = physics_material
	
	# Add visual label if debug mode enabled
	if _get_debug_mode():
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
		
		# Debug CCD and collision settings
		print("[Ball] CCD mode: ", continuous_cd, ", max contacts: ", max_contacts_reported)
		print("[Ball] Collision layer: ", collision_layer, ", mask: ", collision_mask)

func _physics_process(_delta):
	# Debug: Log ball position periodically (every 300 frames ~ 5 seconds at 60fps)
	if _get_debug_mode() and Engine.get_process_frames() % 300 == 0:
		print("[Ball] Position: ", global_position, ", Velocity: ", linear_velocity, ", Visible: ", visible)
	
	# Ensure ball stays within horizontal boundaries (safety check)
	# Allow ball to fall through bottom boundary to end game
	var clamped_x = clamp(global_position.x, boundary_left, boundary_right)
	
	# Only clamp Y if above bottom boundary (allow fall-through below)
	var clamped_y = global_position.y
	if global_position.y < boundary_top:
		clamped_y = boundary_top
	# Don't clamp Y at bottom - allow ball to fall through
	
	# If ball escaped horizontally or vertically (top only), push it back
	if global_position.x != clamped_x or (global_position.y < boundary_top and global_position.y != clamped_y):
		if _get_debug_mode() and Engine.get_process_frames() % 300 == 0:
			print("[Ball] WARNING: Ball escaped boundaries! Position: ", global_position, ", Clamped to: ", Vector2(clamped_x, clamped_y))
		global_position = Vector2(clamped_x, clamped_y)
		# Apply a small correction impulse away from boundary
		if global_position.x <= boundary_left:
			apply_impulse(Vector2(50, 0))
		elif global_position.x >= boundary_right:
			apply_impulse(Vector2(-50, 0))
		if global_position.y < boundary_top:
			apply_impulse(Vector2(0, 50))
	
	# Check if ball fell below the table (triggers ball lost)
	if global_position.y > respawn_y_threshold and not has_emitted_lost:
		if _get_debug_mode():
			print("[Ball] Ball lost! Position: ", global_position, " (threshold: ", respawn_y_threshold, ")")
		has_emitted_lost = true
		ball_lost.emit()

func _on_body_entered(body: Node2D):
	"""Handle collision with other bodies"""
	if _get_debug_mode():
		print("[Ball] Collision with: ", body.name, " (type: ", body.get_class(), ")")
	
	# Check if collision is with a flipper
	if body.has_method("get_flipper_side"):
		var flipper_side = body.get_flipper_side()
		var flipper_strength = body.get("flipper_strength") if body.has("flipper_strength") else 1500.0
		
		# Apply impulse based on flipper direction
		var impulse_direction = Vector2.UP
		if flipper_side == "right":
			impulse_direction = Vector2.UP.rotated(deg_to_rad(-30))
		else:
			impulse_direction = Vector2.UP.rotated(deg_to_rad(30))
		
		# Apply stronger impulse for flipper hit
		apply_impulse(impulse_direction * flipper_strength * 0.5)
		
		if _get_debug_mode():
			print("[Ball] Flipper hit! Side: ", flipper_side, ", Strength: ", flipper_strength)

func reset_ball():
	"""Reset ball to initial position with zero velocity"""
	global_position = initial_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = false
	has_emitted_lost = false

func launch_ball(force: Vector2 = Vector2(0, -500)):
	"""Launch the ball with a given force"""
	if _get_debug_mode():
		print("[Ball] launch_ball called with force: ", force, ", freeze: ", freeze, ", position: ", global_position)
	freeze = false  # Must unfreeze before impulse
	sleeping = false
	linear_velocity = Vector2.ZERO  # Clear any residual velocity
	apply_impulse(force)  # Applies at center when position is default

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	if not _get_debug_mode():
		return
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

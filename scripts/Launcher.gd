extends Node2D

## Launcher script for pinball game
## Handles visual plunger mechanism with charge mechanics

signal ball_launched(force: Vector2)

@export var base_launch_force: Vector2 = Vector2(0, -400)
@export var max_launch_force: Vector2 = Vector2(0, -800)
@export var charge_rate: float = 2.0  # Charge per second
@export var launcher_position: Vector2 = Vector2(605, 518)  # Flutter: right side (41, 43.7)->(605,518); overridden in _ready
@export var horizontal_launch_angle: float = -25.0  # Launch left toward center from right-side plunger (negative=left)
@export var plunger_rest_position: Vector2 = Vector2(0, 0)
@export var plunger_max_pull: Vector2 = Vector2(0, 30)  # How far back the plunger can go

var current_charge: float = 0.0
var max_charge: float = 1.0
var is_charging: bool = false
var current_ball: RigidBody2D = null
var plunger_node: Node2D = null
var charge_meter_node: ProgressBar = null
var capture_cooldown: float = 0.0

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager or GameManagerV4"""
	# Temporary: always return true for debugging
	return true
	# var game_manager = get_tree().get_first_node_in_group("game_manager")
	# if game_manager:
	# 	# Access debug_mode property directly (it's an @export var in GameManager)
	# 	var debug = game_manager.get("debug_mode")
	# 	if debug != null:
	# 		return bool(debug)
	# # Fallback to GameManagerV4
	# var game_manager_v4 = get_node_or_null("/root/GameManagerV4")
	# if game_manager_v4:
	# 	var debug = game_manager_v4.get("debug_mode")
	# 	if debug != null:
	# 		return bool(debug)
	# return false

func _ready():
	if _get_debug_mode():
		print("[Launcher] _ready() called")
	if _get_debug_mode():
		print("[Launcher] Global position: ", global_position)
		print("[Launcher] Position: ", position)
		print("[Launcher] Visible: ", visible)
		print("[Launcher] Launcher position: ", launcher_position)
	
	# v4: Use node's global position as launcher position (pinball layout)
	launcher_position = global_position
	
	# Find plunger visual node - plunger.png is a 20-frame sprite sheet; show 1 frame only
	var plunger_visual = get_node_or_null("Plunger/Visual")
	if plunger_visual and plunger_visual is Sprite2D:
		var tex = plunger_visual.texture
		if tex:
			var fw = tex.get_width() / 20.0  # 20 frames per Flutter plunger
			plunger_visual.region_enabled = true
			plunger_visual.region_rect = Rect2(0, 0, fw, tex.get_height())
	
	# Find plunger visual node
	plunger_node = get_node_or_null("Plunger")
	if not plunger_node:
		if _get_debug_mode():
			print("[Launcher] WARNING: Plunger node not found, creating fallback")
		# Create a simple visual plunger if not found (fallback)
		plunger_node = Node2D.new()
		plunger_node.name = "Plunger"
		add_child(plunger_node)
		# Add a simple visual representation (Sprite2D with fallback)
		var visual = Sprite2D.new()
		var texture = load("res://assets/sprites/plunger/plunger.png") as Texture2D
		if texture:
			visual.texture = texture
		else:
			# Fallback to ColorRect if sprite not found
			var color_rect = ColorRect.new()
			color_rect.offset_left = -5.0
			color_rect.offset_top = -20.0
			color_rect.offset_right = 5.0
			color_rect.offset_bottom = 0.0
			color_rect.color = Color(0.8, 0.2, 0.2, 1)
			plunger_node.add_child(color_rect)
			return
		visual.offset = Vector2(0, -15)
		plunger_node.add_child(visual)
		if _get_debug_mode():
			print("[Launcher] Plunger node found/created at: ", plunger_node.position)
	
	# Charge meter removed - Flutter uses pull/release without % display

func _physics_process(delta):
	# Update capture cooldown
	if capture_cooldown > 0.0:
		capture_cooldown -= delta
	
	# Check for ball arrival (when no ball assigned)
	if (not current_ball or not is_instance_valid(current_ball)) and capture_cooldown <= 0.0:
		_check_ball_arrival()
	
	var has_valid_ball = current_ball != null and is_instance_valid(current_ball)
	var launch_pressed = Input.is_action_pressed("launch_ball")
	var launch_just_released = Input.is_action_just_released("launch_ball")
	
	if launch_pressed and has_valid_ball:
		# Start or continue charging
		if not is_charging:
			is_charging = true
			current_charge = 0.0
		current_charge = min(current_charge + charge_rate * delta, max_charge)
		update_plunger_visual()
		update_charge_meter()
	else:
		# Key released or not pressed - launch if we have a ball ready
		if has_valid_ball and (is_charging or launch_just_released):
			if current_charge <= 0.0:
				current_charge = 0.2  # Minimum launch on tap
			launch_ball()
		is_charging = false
		current_charge = 0.0
		update_plunger_visual()
		update_charge_meter()

func set_ball(ball: RigidBody2D):
	"""Set the ball to be launched - position ball in channel above plunger"""
	if _get_debug_mode():
		print("[Launcher] set_ball called with ball: ", ball, " at launcher_position: ", launcher_position)
	current_ball = ball
	if ball:
		var ball_pos = launcher_position + Vector2(-3, -35)
		if _get_debug_mode():
			print("[Launcher] Placing ball at position: ", ball_pos, " (global: ", ball.global_position, ")")
		ball.global_position = ball_pos
		if ball.get("initial_position") != null:
			ball.initial_position = ball_pos
		ball.freeze = true
		ball.linear_velocity = Vector2.ZERO
		if ball.has_method("reset_ball"):
			ball.reset_ball()

func update_plunger_visual():
	"""Update the visual position of the plunger based on charge"""
	if plunger_node:
		var pull_amount = plunger_max_pull * current_charge
		plunger_node.position = plunger_rest_position + pull_amount

func update_charge_meter():
	"""Update the charge meter display"""
	if charge_meter_node:
		charge_meter_node.value = current_charge

func launch_ball():
	"""Launch the ball with current charge"""
	if _get_debug_mode():
		print("[Launcher] launch_ball called, current_ball: ", current_ball, ", charge: ", current_charge)
	if not current_ball or not is_instance_valid(current_ball):
		if _get_debug_mode():
			print("[Launcher] No valid ball to launch")
		return
	var ball_to_launch = current_ball
	current_ball = null  # Clear before launch so we don't double-launch
	
	# Calculate launch force based on charge
	var force_range = max_launch_force - base_launch_force
	var vertical_force = base_launch_force.y + (force_range.y * current_charge)
	var angle_rad = deg_to_rad(horizontal_launch_angle)
	var horizontal_force = vertical_force * tan(angle_rad)
	var launch_force = Vector2(horizontal_force, vertical_force)
	if _get_debug_mode():
		print("[Launcher] Launch force: ", launch_force)
	
	ball_to_launch.launch_ball(launch_force)
	ball_launched.emit(launch_force)
	
	current_charge = 0.0
	is_charging = false
	capture_cooldown = 1.5  # Prevent immediate recapture (increased from 0.5)

func _check_ball_arrival():
	"""Check if a ball has arrived at launcher area (spawned or returned)"""
	if _get_debug_mode():
		print("[Launcher] _check_ball_arrival called, launcher_position: ", launcher_position)
	var balls = get_tree().get_nodes_in_group("balls")
	if _get_debug_mode():
		print("[Launcher] Found ", balls.size(), " balls in group")
	for ball in balls:
		if ball is RigidBody2D and ball.collision_layer == 1:
			var dist = ball.global_position.distance_to(launcher_position)
			# Accept balls near launcher (right side: x>500, y in launcher range)
			if _get_debug_mode():
				print("[Launcher] Checking ball at ", ball.global_position, " dist=", dist, " y>200? ", ball.global_position.y > 200.0, " x>450? ", ball.global_position.x > 450.0)
			# Capture only if ball is near launcher both horizontally and vertically
			var y_threshold = launcher_position.y - 30.0  # Ball must be below launcher (higher Y = lower on screen)
			var x_threshold = 50.0  # Horizontal tolerance
			var within_y = ball.global_position.y > y_threshold and ball.global_position.y < launcher_position.y + 30.0
			var within_x = ball.global_position.x > launcher_position.x - x_threshold and ball.global_position.x < launcher_position.x + x_threshold
			if dist < 100.0 and within_y and within_x:
				if _get_debug_mode():
					print("[Launcher] Ball at launcher area, distance: ", dist, " within_y:", within_y, " within_x:", within_x)
				set_ball(ball)
				break

func has_ball() -> bool:
	"""Check if launcher has a ball ready"""
	return current_ball != null and is_instance_valid(current_ball)

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "VisualLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 20)
	label.add_theme_color_override("font_color", Color(1, 1, 0, 1))  # Yellow
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-50, -60)  # Offset from center
	add_child(label)

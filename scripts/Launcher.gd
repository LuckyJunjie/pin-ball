extends Node2D

## Launcher script for pinball game
## Handles visual plunger mechanism with charge mechanics

signal ball_launched(force: Vector2)

@export var base_launch_force: Vector2 = Vector2(0, -500)
@export var max_launch_force: Vector2 = Vector2(0, -1000)
@export var charge_rate: float = 2.0  # Charge per second
@export var launcher_position: Vector2 = Vector2(720, 450)  # Positioned below queue (right side)
@export var horizontal_launch_angle: float = -15.0  # Angle in degrees (0 = straight up, negative = left toward center)
@export var plunger_rest_position: Vector2 = Vector2(0, 0)
@export var plunger_max_pull: Vector2 = Vector2(0, 30)  # How far back the plunger can go

var current_charge: float = 0.0
var max_charge: float = 1.0
var is_charging: bool = false
var current_ball: RigidBody2D = null
var plunger_node: Node2D = null
var charge_meter_node: ProgressBar = null

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		# Access debug_mode property directly (it's an @export var in GameManager)
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	if _get_debug_mode():
		print("[Launcher] _ready() called")
	if _get_debug_mode():
		print("[Launcher] Global position: ", global_position)
		print("[Launcher] Position: ", position)
		print("[Launcher] Visible: ", visible)
		print("[Launcher] Launcher position: ", launcher_position)
	
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
		var texture = load("res://assets/sprites/plunger.png")
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
	
	# Find or create charge meter
	charge_meter_node = get_node_or_null("ChargeMeter")
	if not charge_meter_node:
		if _get_debug_mode():
			print("[Launcher] WARNING: ChargeMeter not found, creating fallback")
		charge_meter_node = ProgressBar.new()
		charge_meter_node.name = "ChargeMeter"
		charge_meter_node.min_value = 0.0
		charge_meter_node.max_value = 1.0
		charge_meter_node.value = 0.0
		charge_meter_node.size = Vector2(100, 10)
		charge_meter_node.position = Vector2(-50, -40)
		add_child(charge_meter_node)
	
		if _get_debug_mode():
			print("[Launcher] ChargeMeter position: ", charge_meter_node.position)
	
	# Add visual label if debug mode enabled
	if _get_debug_mode():
		add_visual_label("LAUNCHER")
		print("[Launcher] _ready() completed")

func _process(delta):
	# Check for ball arrival (ball falling from queue)
	if not current_ball or not is_instance_valid(current_ball):
		_check_ball_arrival()
	
	# Handle input for charging (only Space key now, Down Arrow releases ball)
	var launch_action = Input.is_action_pressed("launch_ball")
	# Check if Space is pressed (not Down Arrow)
	var charge_input = launch_action and not Input.is_action_pressed("ui_down")
	
	# Check if we have a valid ball
	var has_valid_ball = current_ball != null and is_instance_valid(current_ball)
	
	if charge_input and has_valid_ball:
		# Start or continue charging
		if not is_charging:
			if _get_debug_mode():
				print("[Launcher] Starting to charge - ball at: ", current_ball.global_position)
			is_charging = true
			current_charge = 0.0
		
		# Increase charge
		current_charge = min(current_charge + charge_rate * delta, max_charge)
		
		# Update visual feedback
		update_plunger_visual()
		update_charge_meter()
	else:
		# Release and launch if we were charging
		if is_charging and has_valid_ball:
			if _get_debug_mode():
				print("[Launcher] Releasing charge - launching ball with charge: ", current_charge)
			launch_ball()
		is_charging = false
		current_charge = 0.0
		update_plunger_visual()
		update_charge_meter()

func set_ball(ball: RigidBody2D):
	"""Set the ball to be launched - position ball at launcher"""
	print("[Launcher] set_ball() called with ball: ", ball)
	current_ball = ball
	if ball:
		print("[Launcher] Ball global position: ", ball.global_position, ", launcher position: ", launcher_position)
		# Always position ball at launcher when set_ball is called
		# This ensures ball is ready for launch
		if _get_debug_mode():
			print("[Launcher] Positioning ball at launcher position: ", launcher_position)
		ball.global_position = launcher_position
		ball.freeze = true  # Freeze ball at launcher
		ball.reset_ball()
		if _get_debug_mode():
			print("[Launcher] Ball positioned and ready for launch at: ", launcher_position)

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
		print("[Launcher] launch_ball() called")
	if not current_ball:
		if _get_debug_mode():
			print("[Launcher] ERROR: launch_ball() called but current_ball is null!")
		return
	
	if _get_debug_mode():
		print("[Launcher] Launching ball at position: ", current_ball.global_position, " with charge: ", current_charge)
	
	# Unfreeze ball before launching
	current_ball.freeze = false
	
	# Calculate launch force based on charge
	var force_range = max_launch_force - base_launch_force
	var vertical_force = base_launch_force.y + (force_range.y * current_charge)
	
	# Add horizontal component based on angle
	var angle_rad = deg_to_rad(horizontal_launch_angle)
	var horizontal_force = vertical_force * tan(angle_rad)  # Horizontal component
	var launch_force = Vector2(horizontal_force, vertical_force)
	if _get_debug_mode():
		print("[Launcher] Calculated launch force: ", launch_force, " (angle: ", horizontal_launch_angle, "°)")
	
	# Launch the ball
	current_ball.launch_ball(launch_force)
	if _get_debug_mode():
		print("[Launcher] Ball launched successfully")
	
	# Emit signal
	ball_launched.emit(launch_force)
	
	# Reset charge
	current_charge = 0.0
	is_charging = false
	current_ball = null
	if _get_debug_mode():
		print("[Launcher] Launcher reset, ready for next ball")

func _check_ball_arrival():
	"""Check if a ball has arrived at launcher area"""
	# Find all balls in scene
	var balls = get_tree().get_nodes_in_group("balls")
	
	# Check balls in group
	for ball in balls:
		if ball is RigidBody2D and ball.collision_layer == 1:  # Ball layer
			var distance = ball.global_position.distance_to(launcher_position)
			if distance < 50.0 and not ball.freeze:  # Only catch unfrozen balls (falling from queue)
				if _get_debug_mode():
					print("[Launcher] Ball arrived at launcher area, distance: ", distance)
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

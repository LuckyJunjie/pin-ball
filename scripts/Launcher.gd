extends Node2D

## Launcher script for pinball game
## Handles visual plunger mechanism with charge mechanics

signal ball_launched(force: Vector2)

@export var base_launch_force: Vector2 = Vector2(0, -500)
@export var max_launch_force: Vector2 = Vector2(0, -1000)
@export var charge_rate: float = 2.0  # Charge per second
@export var launcher_position: Vector2 = Vector2(400, 570)
@export var horizontal_launch_angle: float = 5.0  # Angle in degrees (0 = straight up, positive = right, slight angle for horizontal movement)
@export var plunger_rest_position: Vector2 = Vector2(0, 0)
@export var plunger_max_pull: Vector2 = Vector2(0, 30)  # How far back the plunger can go

var current_charge: float = 0.0
var max_charge: float = 1.0
var is_charging: bool = false
var current_ball: RigidBody2D = null
var plunger_node: Node2D = null
var charge_meter_node: ProgressBar = null

func _ready():
	print("[Launcher] _ready() called")
	print("[Launcher] Global position: ", global_position)
	print("[Launcher] Position: ", position)
	print("[Launcher] Visible: ", visible)
	print("[Launcher] Launcher position: ", launcher_position)
	
	# Find plunger visual node
	plunger_node = get_node_or_null("Plunger")
	if not plunger_node:
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
		print("[Launcher] Plunger node found/created at: ", plunger_node.position)
	
	# Find or create charge meter
	charge_meter_node = get_node_or_null("ChargeMeter")
	if not charge_meter_node:
		print("[Launcher] WARNING: ChargeMeter not found, creating fallback")
		charge_meter_node = ProgressBar.new()
		charge_meter_node.name = "ChargeMeter"
		charge_meter_node.min_value = 0.0
		charge_meter_node.max_value = 1.0
		charge_meter_node.value = 0.0
		charge_meter_node.size = Vector2(100, 10)
		charge_meter_node.position = Vector2(-50, -40)
		add_child(charge_meter_node)
	
		print("[Launcher] ChargeMeter position: ", charge_meter_node.position)
		print("[Launcher] LauncherBase node exists: ", get_node_or_null("LauncherBase") != null)
		var launcher_base = get_node_or_null("LauncherBase")
		if launcher_base:
			print("[Launcher] LauncherBase position: ", launcher_base.position)
			print("[Launcher] LauncherBase global_position: ", launcher_base.global_position)
			print("[Launcher] LauncherBase visible: ", launcher_base.visible)
		print("[Launcher] All children: ", get_children())
		
		# Check all visual nodes
		for child in get_children():
			if child is Node2D:
				print("[Launcher] Child ", child.name, " - position: ", child.position, ", visible: ", child.visible)
	
	# Check viewport and scene tree info
	var viewport = get_viewport()
	if viewport:
		print("[Launcher] Viewport size: ", viewport.get_visible_rect().size)
		print("[Launcher] Viewport visible rect: ", viewport.get_visible_rect())
	
	print("[Launcher] Is in scene tree: ", is_inside_tree())
	print("[Launcher] Scene tree path: ", get_path() if is_inside_tree() else "Not in tree")
	
	# Add visual label
	add_visual_label("LAUNCHER")
	
	print("[Launcher] _ready() completed")

func _process(delta):
	# Handle input for charging
	var launch_action = Input.is_action_pressed("launch_ball")
	var ui_down = Input.is_action_pressed("ui_down")
	var charge_input = launch_action or ui_down
	
	# Debug input
	if launch_action or ui_down:
		if not is_charging:  # Only log when starting to charge
			print("[Launcher] Input detected - launch_ball: ", launch_action, ", ui_down: ", ui_down)
	
	# Check if we have a valid ball
	var has_valid_ball = current_ball != null and is_instance_valid(current_ball)
	if charge_input and not has_valid_ball:
		print("[Launcher] Input detected but no valid ball! current_ball: ", current_ball)
	
	if charge_input and has_valid_ball:
		# Start or continue charging
		if not is_charging:
			print("[Launcher] Starting to charge - ball at: ", current_ball.global_position)
			is_charging = true
			current_charge = 0.0
			# Only position ball at launcher if it's near the launcher area
			# Don't interfere with ball dropping from queue
			if current_ball:
				var distance_to_launcher = current_ball.global_position.distance_to(launcher_position)
				var queue_position = Vector2(750, 300)
				var distance_to_queue = current_ball.global_position.distance_to(queue_position)
				
				# Only position at launcher if ball is close to launcher and not at queue
				if distance_to_launcher < 100.0 and distance_to_queue > 50.0:
					current_ball.global_position = launcher_position
					current_ball.reset_ball()
		
		# Increase charge
		current_charge = min(current_charge + charge_rate * delta, max_charge)
		
		# Update visual feedback
		update_plunger_visual()
		update_charge_meter()
	else:
		# Release and launch if we were charging
		if is_charging and has_valid_ball:
			print("[Launcher] Releasing charge - launching ball with charge: ", current_charge)
			launch_ball()
		elif is_charging:
			print("[Launcher] Input released but no valid ball to launch")
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
		print("[Launcher] Positioning ball at launcher position: ", launcher_position)
		ball.global_position = launcher_position
		ball.reset_ball()
		print("[Launcher] Ball positioned and ready for launch")

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
	print("[Launcher] launch_ball() called")
	if not current_ball:
		print("[Launcher] ERROR: launch_ball() called but current_ball is null!")
		return
	
	print("[Launcher] Launching ball at position: ", current_ball.global_position, " with charge: ", current_charge)
	
	# Calculate launch force based on charge
	var force_range = max_launch_force - base_launch_force
	var vertical_force = base_launch_force.y + (force_range.y * current_charge)
	
	# Add horizontal component based on angle
	var angle_rad = deg_to_rad(horizontal_launch_angle)
	var horizontal_force = vertical_force * tan(angle_rad)  # Horizontal component
	var launch_force = Vector2(horizontal_force, vertical_force)
	print("[Launcher] Calculated launch force: ", launch_force, " (angle: ", horizontal_launch_angle, "°)")
	
	# Launch the ball
	current_ball.launch_ball(launch_force)
	print("[Launcher] Ball launched successfully")
	
	# Emit signal
	ball_launched.emit(launch_force)
	
	# Reset charge
	current_charge = 0.0
	is_charging = false
	current_ball = null
	print("[Launcher] Launcher reset, ready for next ball")

func has_ball() -> bool:
	"""Check if launcher has a ball ready"""
	return current_ball != null and is_instance_valid(current_ball)

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
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

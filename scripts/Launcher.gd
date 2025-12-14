extends Node2D

## Launcher script for pinball game
## Handles visual plunger mechanism with charge mechanics

signal ball_launched(force: Vector2)

@export var base_launch_force: Vector2 = Vector2(0, -500)
@export var max_launch_force: Vector2 = Vector2(0, -1000)
@export var charge_rate: float = 2.0  # Charge per second
@export var launcher_position: Vector2 = Vector2(400, 570)
@export var plunger_rest_position: Vector2 = Vector2(0, 0)
@export var plunger_max_pull: Vector2 = Vector2(0, 30)  # How far back the plunger can go

var current_charge: float = 0.0
var max_charge: float = 1.0
var is_charging: bool = false
var current_ball: RigidBody2D = null
var plunger_node: Node2D = null
var charge_meter_node: ProgressBar = null

func _ready():
	# Find plunger visual node
	plunger_node = get_node_or_null("Plunger")
	if not plunger_node:
		# Create a simple visual plunger if not found
		plunger_node = Node2D.new()
		plunger_node.name = "Plunger"
		add_child(plunger_node)
		# Add a simple visual representation
		var visual = ColorRect.new()
		visual.offset_left = -5.0
		visual.offset_top = -20.0
		visual.offset_right = 5.0
		visual.offset_bottom = 0.0
		visual.color = Color(0.8, 0.2, 0.2, 1)
		plunger_node.add_child(visual)
	
	# Find or create charge meter
	charge_meter_node = get_node_or_null("ChargeMeter")
	if not charge_meter_node:
		charge_meter_node = ProgressBar.new()
		charge_meter_node.name = "ChargeMeter"
		charge_meter_node.min_value = 0.0
		charge_meter_node.max_value = 1.0
		charge_meter_node.value = 0.0
		charge_meter_node.size = Vector2(100, 10)
		charge_meter_node.position = Vector2(-50, -40)
		add_child(charge_meter_node)

func _process(delta):
	# Handle input for charging
	var charge_input = Input.is_action_pressed("launch_ball") or Input.is_action_pressed("ui_down")
	
	if charge_input and current_ball and current_ball.sleeping:
		# Start or continue charging
		if not is_charging:
			is_charging = true
			current_charge = 0.0
		
		# Increase charge
		current_charge = min(current_charge + charge_rate * delta, max_charge)
		
		# Update visual feedback
		update_plunger_visual()
		update_charge_meter()
	else:
		# Release and launch if we were charging
		if is_charging and current_ball:
			launch_ball()
		is_charging = false
		current_charge = 0.0
		update_plunger_visual()
		update_charge_meter()

func set_ball(ball: RigidBody2D):
	"""Set the ball to be launched"""
	current_ball = ball
	if ball:
		# Position ball at launcher
		ball.global_position = launcher_position
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
	if not current_ball:
		return
	
	# Calculate launch force based on charge
	var force_range = max_launch_force - base_launch_force
	var launch_force = base_launch_force + (force_range * current_charge)
	
	# Launch the ball
	current_ball.launch_ball(launch_force)
	
	# Emit signal
	ball_launched.emit(launch_force)
	
	# Reset charge
	current_charge = 0.0
	is_charging = false
	current_ball = null

func has_ball() -> bool:
	"""Check if launcher has a ball ready"""
	return current_ball != null and is_instance_valid(current_ball)

extends RigidBody2D

## Flipper script for pinball game
## Handles flipper input and rotation animation

@export var flipper_side: String = "left"  # "left" or "right"
@export var rest_angle: float = 0.0
@export var pressed_angle: float = -45.0  # Negative for left, positive for right
@export var rotation_speed: float = 20.0
@export var torque_strength: float = 3000.0

var is_pressed: bool = false
var target_angle: float = 0.0

func _ready():
	# Configure physics properties
	gravity_scale = 0.0
	lock_rotation = false
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	collision_layer = 2  # Flipper layer
	collision_mask = 1  # Collide with ball
	mass = 1.0
	
	# Set initial angle
	target_angle = rest_angle
	rotation_degrees = rest_angle
	
	# Adjust pressed angle based on side
	if flipper_side == "right":
		pressed_angle = abs(pressed_angle)
	else:
		pressed_angle = -abs(pressed_angle)
	
	# Configure physics material for bounce
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.6
	physics_material.friction = 0.5
	physics_material_override = physics_material

func _physics_process(delta):
	# Get input based on flipper side
	var input_pressed = false
	if flipper_side == "left":
		input_pressed = Input.is_action_pressed("flipper_left")
	else:
		input_pressed = Input.is_action_pressed("flipper_right")
	
	# Update target angle
	if input_pressed:
		target_angle = pressed_angle
		is_pressed = true
		# Apply torque for more realistic physics
		apply_torque(torque_strength if flipper_side == "right" else -torque_strength)
	else:
		target_angle = rest_angle
		is_pressed = false
		# Apply reverse torque when releasing
		apply_torque(-torque_strength * 0.5 if flipper_side == "right" else torque_strength * 0.5)
	
	# Smoothly rotate towards target angle
	var angle_diff = target_angle - rotation_degrees
	if abs(angle_diff) > 0.5:
		var rotation_dir = sign(angle_diff)
		var rotation_amount = min(abs(angle_diff), rotation_speed)
		rotation_degrees += rotation_dir * rotation_amount
	else:
		# Dampen rotation when close to target
		angular_velocity *= 0.9

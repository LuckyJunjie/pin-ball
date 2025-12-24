extends RigidBody2D

## Flipper script for pinball game
## Handles flipper input and rotation animation

@export var flipper_side: String = "left"  # "left" or "right"
@export var rest_angle: float = 0.0
@export var pressed_angle: float = -45.0  # Negative for left, positive for right
@export var rotation_speed: float = 20.0

var is_pressed: bool = false
var target_angle: float = 0.0

func _ready():
	# Configure physics properties
	gravity_scale = 0.0
	lock_rotation = false
	freeze_mode = RigidBody2D.FREEZE_MODE_KINEMATIC
	freeze = true  # Freeze the body, we'll control rotation manually
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
	
	# Update target angle based on input
	if input_pressed:
		target_angle = pressed_angle
		is_pressed = true
	else:
		target_angle = rest_angle
		is_pressed = false
	
	# Smoothly rotate towards target angle (only rotate when needed)
	var angle_diff = target_angle - rotation_degrees
	if abs(angle_diff) > 0.1:
		var rotation_dir = sign(angle_diff)
		var rotation_amount = min(abs(angle_diff), rotation_speed * delta * 60.0)
		rotation_degrees += rotation_dir * rotation_amount

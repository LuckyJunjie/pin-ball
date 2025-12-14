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

func _physics_process(_delta):
	# Ensure ball stays within boundaries (safety check)
	var clamped_x = clamp(global_position.x, boundary_left, boundary_right)
	var clamped_y = clamp(global_position.y, boundary_top, boundary_bottom)
	
	# If ball somehow escaped, push it back in
	if global_position.x != clamped_x or global_position.y != clamped_y:
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
		ball_lost.emit()

func reset_ball():
	"""Reset ball to initial position with zero velocity"""
	global_position = initial_position
	linear_velocity = Vector2.ZERO
	angular_velocity = 0.0
	sleeping = false

func launch_ball(force: Vector2 = Vector2(0, -500)):
	"""Launch the ball with a given force"""
	apply_impulse(force)

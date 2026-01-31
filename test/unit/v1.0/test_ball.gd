extends GutTest

## v1.0: Ball Physics and Core Mechanics Tests
## Tests ball physics, collision, boundaries, and basic functionality

var ball_scene: PackedScene
var ball_instance: RigidBody2D

func before_each():
	# Load ball scene
	ball_scene = load("res://scenes/Ball.tscn")
	assert_not_null(ball_scene, "Ball scene should load")
	
	# Create ball instance
	ball_instance = ball_scene.instantiate()
	add_child_autofree(ball_instance)
	assert_not_null(ball_instance, "Ball instance should be created")

func after_each():
	# Cleanup handled by add_child_autofree
	pass

func test_ball_initialization():
	"""Test that ball initializes with correct properties"""
	assert_not_null(ball_instance, "Ball should exist")
	assert_eq(ball_instance.collision_layer, 1, "Ball should be on collision layer 1")
	assert_eq(ball_instance.gravity_scale, 1.0, "Ball should have gravity scale 1.0")
	assert_gt(ball_instance.mass, 0.0, "Ball should have mass > 0")

func test_ball_reset():
	"""Test ball reset functionality"""
	var initial_pos = Vector2(400, 200)
	ball_instance.initial_position = initial_pos
	ball_instance.global_position = Vector2(100, 100)
	ball_instance.linear_velocity = Vector2(50, 50)
	ball_instance.angular_velocity = 1.5
	
	ball_instance.reset_ball()
	
	assert_eq(ball_instance.global_position, initial_pos, "Ball should reset to initial position")
	assert_eq(ball_instance.linear_velocity, Vector2.ZERO, "Ball velocity should be zero")
	assert_eq(ball_instance.angular_velocity, 0.0, "Ball angular velocity should be zero")

func test_ball_launch():
	"""Test ball launch with force"""
	var initial_velocity = ball_instance.linear_velocity
	var launch_force = Vector2(0, -500)
	
	ball_instance.launch_ball(launch_force)
	
	# Ball should have velocity after launch
	assert_ne(ball_instance.linear_velocity, initial_velocity, "Ball should have velocity after launch")
	assert_lt(ball_instance.linear_velocity.y, 0, "Ball should move upward after launch")

func test_ball_boundaries():
	"""Test ball boundary constraints"""
	# Test left boundary
	ball_instance.global_position = Vector2(10, 300)  # Below left boundary (20)
	ball_instance._physics_process(0.016)  # Simulate one frame
	assert_ge(ball_instance.global_position.x, 20.0, "Ball should not go below left boundary")
	
	# Test right boundary
	ball_instance.global_position = Vector2(800, 300)  # Above right boundary (780)
	ball_instance._physics_process(0.016)
	assert_le(ball_instance.global_position.x, 780.0, "Ball should not go above right boundary")
	
	# Test top boundary
	ball_instance.global_position = Vector2(400, 10)  # Below top boundary (20)
	ball_instance._physics_process(0.016)
	assert_ge(ball_instance.global_position.y, 20.0, "Ball should not go below top boundary")

func test_ball_lost_signal():
	"""Test ball_lost signal emission"""
	watch_signals(ball_instance)
	
	# Move ball below threshold
	ball_instance.global_position = Vector2(400, 700)  # Below respawn_y_threshold (650)
	ball_instance._physics_process(0.016)
	
	assert_signal_emitted(ball_instance, "ball_lost", "Ball should emit ball_lost signal when below threshold")

func test_ball_physics_material():
	"""Test ball physics material properties"""
	var material = ball_instance.physics_material_override
	assert_not_null(material, "Ball should have physics material")
	assert_gt(material.bounce, 0.0, "Ball should have bounce > 0")
	assert_ge(material.friction, 0.0, "Ball should have friction >= 0")

extends Node2D

func _ready():
	print("=== Testing Falling Issue ===")
	
	# Check physics settings
	print("Physics 2D default gravity: ", ProjectSettings.get_setting("physics/2d/default_gravity"))
	print("Physics 2D default gravity vector: ", ProjectSettings.get_setting("physics/2d/default_gravity_vector"))
	
	# Check if bumpers are RigidBody2D and have gravity
	var bumpers = get_tree().get_nodes_in_group("bumpers")
	print("Found ", bumpers.size(), " bumpers")
	
	for bumper in bumpers:
		if bumper is RigidBody2D:
			print("Bumper ", bumper.name, ": gravity_scale = ", bumper.gravity_scale, ", freeze = ", bumper.freeze)
			print("  Position: ", bumper.global_position)
			
	# Check balls
	var balls = get_tree().get_nodes_in_group("balls")
	print("Found ", balls.size(), " balls")
	
	for ball in balls:
		if ball is RigidBody2D:
			print("Ball ", ball.name, ": gravity_scale = ", ball.gravity_scale, ", freeze = ", ball.freeze)
			print("  Position: ", ball.global_position, ", Velocity: ", ball.linear_velocity)

func _process(delta):
	# Track positions over time
	if Engine.get_process_frames() % 60 == 0:  # Every second at 60fps
		var bumpers = get_tree().get_nodes_in_group("bumpers")
		for bumper in bumpers:
			if bumper is RigidBody2D:
				print("Bumper ", bumper.name, " at position: ", bumper.global_position, ", velocity: ", bumper.linear_velocity)
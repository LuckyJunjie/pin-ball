extends Node

## v3.0: Particle Manager
## Manages particle effects for various game events

var particle_scenes: Dictionary = {}

func _ready():
	add_to_group("particle_manager")
	_load_particle_scenes()

func _load_particle_scenes():
	"""Load particle effect scenes"""
	# Particle scenes will be loaded from assets/particles/ directory
	# For now, create them programmatically

func spawn_bumper_hit(position: Vector2):
	"""Spawn particle effect for bumper hit"""
	var particles = _create_bumper_particles()
	particles.global_position = position
	get_tree().current_scene.add_child(particles)
	
	# Auto-remove after animation
	await get_tree().create_timer(1.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func spawn_multiplier_activation(position: Vector2):
	"""Spawn particle effect for multiplier activation"""
	var particles = _create_multiplier_particles()
	particles.global_position = position
	get_tree().current_scene.add_child(particles)
	
	await get_tree().create_timer(1.5).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func spawn_multiball_launch(position: Vector2):
	"""Spawn particle effect for multiball launch"""
	var particles = _create_multiball_particles()
	particles.global_position = position
	get_tree().current_scene.add_child(particles)
	
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func add_ball_trail(ball: RigidBody2D, color: Color = Color.WHITE):
	"""Add trail effect to ball"""
	# Create simple trail using Line2D or GPUParticles2D
	var trail = GPUParticles2D.new()
	trail.emitting = true
	trail.amount = 50
	trail.lifetime = 0.5
	
	# Configure particle material
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, -1, 0)
	material.initial_velocity_min = 10.0
	material.initial_velocity_max = 20.0
	material.gravity = Vector3(0, 0, 0)
	material.scale_min = 2.0
	material.scale_max = 4.0
	trail.process_material = material
	
	# Set color
	trail.modulate = color
	
	# Attach to ball
	ball.add_child(trail)
	trail.name = "BallTrail"

func _create_bumper_particles() -> GPUParticles2D:
	"""Create particle effect for bumper hits"""
	var particles = GPUParticles2D.new()
	particles.emitting = true
	particles.amount = 30
	particles.lifetime = 0.5
	particles.explosiveness = 1.0  # All particles at once
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 0, 0)
	material.initial_velocity_min = 50.0
	material.initial_velocity_max = 100.0
	material.gravity = Vector3(0, 98, 0)
	material.scale_min = 3.0
	material.scale_max = 6.0
	material.color = Color(1.0, 0.8, 0.0, 1.0)  # Yellow/orange
	particles.process_material = material
	
	return particles

func _create_multiplier_particles() -> GPUParticles2D:
	"""Create particle effect for multiplier activation"""
	var particles = GPUParticles2D.new()
	particles.emitting = true
	particles.amount = 50
	particles.lifetime = 1.0
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, -1, 0)
	material.initial_velocity_min = 20.0
	material.initial_velocity_max = 40.0
	material.gravity = Vector3(0, -20, 0)  # Upward
	material.scale_min = 4.0
	material.scale_max = 8.0
	material.color = Color(0.0, 1.0, 0.0, 1.0)  # Green
	particles.process_material = material
	
	return particles

func _create_multiball_particles() -> GPUParticles2D:
	"""Create particle effect for multiball launch"""
	var particles = GPUParticles2D.new()
	particles.emitting = true
	particles.amount = 100
	particles.lifetime = 1.5
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 0, 0)
	material.initial_velocity_min = 30.0
	material.initial_velocity_max = 60.0
	material.gravity = Vector3(0, 50, 0)
	material.scale_min = 2.0
	material.scale_max = 5.0
	material.color = Color(1.0, 0.5, 0.0, 1.0)  # Orange
	particles.process_material = material
	
	return particles

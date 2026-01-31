extends Node

## v3.0: Enhanced Particle Manager
## Enhanced particle effects with custom textures and improved visuals

const ParticleManager = preload("res://scripts/ParticleManager.gd")

var base_particle_manager: Node = null

func _ready():
	add_to_group("particle_manager")
	# Get or create base particle manager
	base_particle_manager = get_tree().get_first_node_in_group("particle_manager")
	if not base_particle_manager or base_particle_manager == self:
		# Create base particle manager
		base_particle_manager = ParticleManager.new()
		base_particle_manager.name = "BaseParticleManager"
		add_child(base_particle_manager)

func spawn_bumper_hit(position: Vector2, color: Color = Color(1.0, 0.8, 0.0, 1.0)):
	"""Enhanced bumper hit with custom textures and more particles"""
	var particles = GPUParticles2D.new()
	particles.emitting = true
	particles.amount = 60  # More particles
	particles.lifetime = 0.8
	particles.explosiveness = 1.0  # All at once
	
	# Try to load custom texture
	var texture = _load_particle_texture("spark")
	if texture:
		particles.texture = texture
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 0, 0)
	material.initial_velocity_min = 80.0
	material.initial_velocity_max = 150.0
	material.gravity = Vector3(0, 98, 0)
	material.scale_min = 4.0
	material.scale_max = 10.0
	material.color = color
	
	# Add color ramp for gradient effect
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([color, color * Color(1, 1, 1, 0)])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	material.color_ramp = gradient
	
	particles.process_material = material
	particles.global_position = position
	get_tree().current_scene.add_child(particles)
	
	_auto_remove_particles(particles, 1.0)

func spawn_multiplier_activation(position: Vector2):
	"""Enhanced multiplier activation particles"""
	var particles = GPUParticles2D.new()
	particles.emitting = true
	particles.amount = 80
	particles.lifetime = 1.2
	
	var texture = _load_particle_texture("star")
	if texture:
		particles.texture = texture
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, -1, 0)
	material.initial_velocity_min = 30.0
	material.initial_velocity_max = 60.0
	material.gravity = Vector3(0, -30, 0)  # Upward
	material.scale_min = 6.0
	material.scale_max = 12.0
	material.color = Color(0.0, 1.0, 0.0, 1.0)  # Green
	
	# Color ramp
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([Color.GREEN, Color.YELLOW, Color(1, 1, 1, 0)])
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	material.color_ramp = gradient
	
	particles.process_material = material
	particles.global_position = position
	get_tree().current_scene.add_child(particles)
	
	_auto_remove_particles(particles, 1.5)

func spawn_multiball_launch(position: Vector2):
	"""Enhanced multiball launch particles"""
	var particles = GPUParticles2D.new()
	particles.emitting = true
	particles.amount = 150  # More particles
	particles.lifetime = 2.0
	
	var texture = _load_particle_texture("spark")
	if texture:
		particles.texture = texture
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, 0, 0)
	material.initial_velocity_min = 40.0
	material.initial_velocity_max = 80.0
	material.gravity = Vector3(0, 50, 0)
	material.scale_min = 3.0
	material.scale_max = 8.0
	material.color = Color(1.0, 0.5, 0.0, 1.0)  # Orange
	
	# Multi-color gradient
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([
		Color(1.0, 0.5, 0.0, 1.0),  # Orange
		Color(1.0, 1.0, 0.0, 1.0),  # Yellow
		Color(1.0, 1.0, 1.0, 0.0)   # White fade
	])
	gradient.offsets = PackedFloat32Array([0.0, 0.5, 1.0])
	material.color_ramp = gradient
	
	particles.process_material = material
	particles.global_position = position
	get_tree().current_scene.add_child(particles)
	
	_auto_remove_particles(particles, 2.5)

func add_ball_trail(ball: RigidBody2D, color: Color = Color.WHITE):
	"""Enhanced ball trail with custom texture"""
	var trail = GPUParticles2D.new()
	trail.emitting = true
	trail.amount = 80  # More particles
	trail.lifetime = 0.6
	
	var texture = _load_particle_texture("trail")
	if texture:
		trail.texture = texture
	
	var material = ParticleProcessMaterial.new()
	material.direction = Vector3(0, -1, 0)
	material.initial_velocity_min = 15.0
	material.initial_velocity_max = 30.0
	material.gravity = Vector3(0, 0, 0)
	material.scale_min = 2.0
	material.scale_max = 5.0
	material.color = color
	
	# Fade out gradient
	var gradient = Gradient.new()
	gradient.colors = PackedColorArray([color, color * Color(1, 1, 1, 0)])
	gradient.offsets = PackedFloat32Array([0.0, 1.0])
	material.color_ramp = gradient
	
	trail.process_material = material
	trail.modulate = color
	
	ball.add_child(trail)
	trail.name = "BallTrail"

func _load_particle_texture(texture_name: String) -> Texture2D:
	"""Load particle texture, return null if not found (uses default)"""
	var paths = [
		"res://assets/particles/" + texture_name + ".png",
		"res://assets/sprites/" + texture_name + ".png",
		"res://assets/particles/particle_" + texture_name + ".png"
	]
	
	for path in paths:
		if ResourceLoader.exists(path):
			return load(path) as Texture2D
	
	return null  # Use default particle rendering

func _auto_remove_particles(particles: GPUParticles2D, delay: float):
	"""Auto-remove particles after animation"""
	await get_tree().create_timer(delay).timeout
	if is_instance_valid(particles):
		particles.queue_free()

# Delegate to base manager for compatibility
func _get(property: StringName) -> Variant:
	"""Delegate missing properties to base particle manager"""
	if base_particle_manager:
		return base_particle_manager.get(property)
	return null

func _call(method: StringName, args: Array) -> Variant:
	"""Delegate missing methods to base particle manager"""
	if base_particle_manager and base_particle_manager.has_method(method):
		return base_particle_manager.callv(method, args)
	return null

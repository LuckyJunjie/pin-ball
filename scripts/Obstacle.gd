extends StaticBody2D

## Obstacle script for pinball game
## Handles obstacle collision, bounce, and scoring

signal obstacle_hit(points: int)

@export var obstacle_type: String = "basketball" : set = set_obstacle_type  # "basketball", "baseball_player", "baseball_bat", "soccer_goal"
@export var points_value: int = 10
@export var bounce_strength: float = 0.9

# v3.0: Enhanced bumper properties
@export var is_bumper: bool = false  # True for bumpers (basketball hoops)
@export var bumping_strength: float = 20.0  # Active force application (15-25)
@export var blinking_enabled: bool = true  # Enable blinking behavior
@export var blink_speed: float = 2.0  # Blink speed multiplier

func set_obstacle_type(value: String):
	"""Setter for obstacle_type that updates sprite when changed"""
	obstacle_type = value
	if is_inside_tree():
		update_sprite()
		# v3.0: Set is_bumper based on type
		is_bumper = (obstacle_type == "basketball" or obstacle_type == "bumper")

var hit_cooldown: float = 0.0
var cooldown_time: float = 0.5  # Prevent multiple hits in quick succession
var is_lit: bool = true  # v3.0: Visual state (lit vs dimmed)
var blink_timer: float = 0.0  # v3.0: Blink animation timer

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	# Add to obstacles group
	add_to_group("obstacles")
	
	# Set collision layer for obstacles (layer 8)
	collision_layer = 8
	collision_mask = 0  # Static body doesn't need collision mask (Area2D handles detection)
	
	# Configure physics material based on type
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = bounce_strength
	physics_material.friction = 0.2
	physics_material_override = physics_material
	
	# Load sprite - will be called again if obstacle_type changes
	update_sprite()
	
	# v3.0: Add glow effect for bumpers
	if is_bumper:
		_add_glow_effect()
	
	# Add Area2D for collision detection
	var area = Area2D.new()
	area.name = "DetectionArea"
	area.collision_layer = 0
	area.collision_mask = 1  # Detect ball
	add_child(area)
	
	# Copy collision shape to area
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		var area_shape = CollisionShape2D.new()
		area_shape.shape = collision_shape.shape.duplicate()
		area.add_child(area_shape)
		area.body_entered.connect(_on_body_entered)
	
	# Add visual label if debug mode enabled
	if _get_debug_mode():
		add_visual_label("OBSTACLE\n" + obstacle_type.to_upper())

func update_sprite():
	"""Update sprite based on obstacle type and add ColorRect fallback"""
	var visual_node = get_node_or_null("Visual")
	if visual_node and visual_node is Sprite2D:
		var sprite_path = ""
		
		match obstacle_type:
			"basketball":
				sprite_path = "res://assets/sprites/basketball_hoop.png"
			"baseball_player":
				sprite_path = "res://assets/sprites/baseball_player.png"
			"baseball_bat":
				sprite_path = "res://assets/sprites/baseball_bat.png"
			"soccer_goal":
				sprite_path = "res://assets/sprites/soccer_goal.png"
			# Fallback to old types for backwards compatibility
			"bumper":
				sprite_path = "res://assets/sprites/basketball_hoop.png"
			"peg":
				sprite_path = "res://assets/sprites/baseball_player.png"
			"wall":
				sprite_path = "res://assets/sprites/baseball_bat.png"
		
		if sprite_path != "":
			var texture = load(sprite_path)
			if texture:
				visual_node.texture = texture
				# Initial scale is 1,1 - ObstacleSpawner will adjust if needed
				visual_node.scale = Vector2(1, 1)
	
	# Add or update ColorRect fallback (only visible if sprite fails to load)
	var fallback_node = get_node_or_null("ColorRectFallback")
	if not fallback_node:
		fallback_node = ColorRect.new()
		fallback_node.name = "ColorRectFallback"
		add_child(fallback_node)
	
	# Hide fallback by default - only show if sprite is missing
	fallback_node.visible = false
	
	# Check if sprite loaded successfully, if not, show fallback
	var sprite_loaded = false
	if visual_node and visual_node is Sprite2D:
		if visual_node.texture != null:
			sprite_loaded = true
	
	# Set color and size based on obstacle type
	match obstacle_type:
		"basketball":
			fallback_node.color = Color(1, 0.5, 0, 1)  # Orange (basketball hoop)
			fallback_node.offset_left = -30.0
			fallback_node.offset_top = -30.0
			fallback_node.offset_right = 30.0
			fallback_node.offset_bottom = 30.0
		"baseball_player":
			fallback_node.color = Color(0.2, 0.2, 0.4, 1)  # Dark blue (player)
			fallback_node.offset_left = -10.0
			fallback_node.offset_top = -20.0
			fallback_node.offset_right = 10.0
			fallback_node.offset_bottom = 20.0
		"baseball_bat":
			fallback_node.color = Color(0.5, 0.3, 0.2, 1)  # Brown (bat)
			fallback_node.offset_left = -20.0
			fallback_node.offset_top = -6.0
			fallback_node.offset_right = 20.0
			fallback_node.offset_bottom = 6.0
		"soccer_goal":
			fallback_node.color = Color(0.8, 0.8, 0.8, 1)  # Light gray (goal)
			fallback_node.offset_left = -25.0
			fallback_node.offset_top = -15.0
			fallback_node.offset_right = 25.0
			fallback_node.offset_bottom = 15.0
		# Fallback to old types for backwards compatibility
		"bumper":
			fallback_node.color = Color(1, 0.5, 0, 1)  # Orange
			fallback_node.offset_left = -30.0
			fallback_node.offset_top = -30.0
			fallback_node.offset_right = 30.0
			fallback_node.offset_bottom = 30.0
		"peg":
			fallback_node.color = Color(0.2, 0.2, 0.4, 1)  # Dark blue
			fallback_node.offset_left = -8.0
			fallback_node.offset_top = -8.0
			fallback_node.offset_right = 8.0
			fallback_node.offset_bottom = 8.0
		"wall":
			fallback_node.color = Color(0.5, 0.3, 0.2, 1)  # Brown
			fallback_node.offset_left = -20.0
			fallback_node.offset_top = -5.0
			fallback_node.offset_right = 20.0
			fallback_node.offset_bottom = 5.0
	
	# Show fallback only if sprite failed to load
	if not sprite_loaded:
		fallback_node.visible = true
	
func _process(delta):
	if hit_cooldown > 0.0:
		hit_cooldown -= delta
		# v3.0: Dimmed state during cooldown
		is_lit = false
	else:
		# v3.0: Lit state when ready
		is_lit = true
	
	# v3.0: Blinking behavior for bumpers
	if is_bumper and blinking_enabled and is_lit:
		blink_timer += delta * blink_speed
		var alpha = 0.7 + 0.3 * sin(blink_timer * 5.0)
		modulate = Color(1.0, 1.0, 1.0, alpha)
	elif not is_lit:
		# Dimmed during cooldown
		modulate = Color(0.5, 0.5, 0.5, 0.7)
	else:
		# Normal state
		modulate = Color(1.0, 1.0, 1.0, 1.0)

func _on_body_entered(body: Node2D):
	"""Called when a body enters the obstacle detection area"""
	if hit_cooldown > 0.0:
		return
	
	if body is RigidBody2D and body.collision_layer == 1:  # Ball layer
		hit_cooldown = cooldown_time
		
		# v3.0: Apply bumping force for bumpers
		if is_bumper:
			_apply_bumping_force(body)
		
		# v3.0: Play hit effect
		_play_hit_effect(body)
		
		obstacle_hit.emit(points_value)
		# Visual feedback could be added here (flash, animation, etc.)

func _apply_bumping_force(ball: RigidBody2D):
	"""v3.0: Apply active bumping force to ball"""
	if not ball:
		return
	
	# Calculate direction away from obstacle center
	var direction = (ball.global_position - global_position).normalized()
	if direction.length() < 0.1:
		direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	
	# Apply impulse
	var force = direction * bumping_strength
	ball.apply_impulse(force)
	
	if _get_debug_mode():
		print("[Obstacle] Applied bumping force: ", force)

func _play_hit_effect(ball: RigidBody2D):
	"""v3.0: Play visual/audio effect on hit"""
	# Flash effect
	var tween = create_tween()
	var original_modulate = modulate
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 0.0, 1.0), 0.1)  # Yellow flash
	tween.tween_property(self, "modulate", original_modulate, 0.2)
	
	# Play particle effect (if particle system exists)
	_spawn_hit_particles(ball.global_position)
	
	# v3.0: Add screen shake for big hits (bumpers)
	if is_bumper:
		var camera = get_tree().get_first_node_in_group("camera")
		if not camera:
			camera = get_tree().get_first_node_in_group("Camera2D")
		if camera:
			var anim_mgr = get_tree().get_first_node_in_group("animation_manager")
			if anim_mgr and anim_mgr.has_method("screen_shake"):
				anim_mgr.screen_shake(camera, 8.0, 0.2)  # Strong shake for bumpers
	
	# Play sound with pitch variation
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager:
		if sound_manager.has_method("play_sound_with_pitch"):
			var pitch = randf_range(0.9, 1.1)
			sound_manager.play_sound_with_pitch("obstacle_hit", pitch)
		elif sound_manager.has_method("play_sound"):
			sound_manager.play_sound("obstacle_hit")

func _spawn_hit_particles(position: Vector2):
	"""v3.0: Spawn particle effect on hit"""
	# Check if enhanced particle manager exists
	var particle_manager = get_tree().get_first_node_in_group("particle_manager")
	if not particle_manager:
		# Try to find in GameManager
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			particle_manager = game_manager.get_node_or_null("ParticleManager")
			# Try enhanced particle manager
			if not particle_manager:
				particle_manager = game_manager.get_node_or_null("EnhancedParticleManager")
	
	# Use enhanced particles if available, fallback to base
	if particle_manager:
		if particle_manager.has_method("spawn_bumper_hit"):
			# Enhanced version with color
			var color = Color(1.0, 0.8, 0.0, 1.0)  # Orange/yellow
			if is_bumper:
				match obstacle_type:
					"basketball", "bumper":
						color = Color(1.0, 0.8, 0.0, 1.0)  # Orange
					_:
						color = Color(0.0, 1.0, 1.0, 1.0)  # Cyan
			particle_manager.spawn_bumper_hit(position, color)
		elif particle_manager.has_method("spawn_bumper_hit"):
			# Base version
			particle_manager.spawn_bumper_hit(position)

func _add_glow_effect():
	"""v3.0: Add glow effect to bumper"""
	var glow_script = load("res://scripts/GlowEffect.gd")
	if glow_script:
		var glow = Node2D.new()
		glow.set_script(glow_script)
		
		# Set glow color based on obstacle type
		match obstacle_type:
			"basketball", "bumper":
				glow.glow_color = Color(1.0, 0.8, 0.0, 1.0)  # Orange/yellow
			_:
				glow.glow_color = Color(0.0, 1.0, 1.0, 1.0)  # Cyan default
		
		glow.glow_size = 1.5
		glow.glow_intensity = 1.2
		glow.pulse_enabled = true
		glow.pulse_speed = blink_speed
		
		add_child(glow)

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "VisualLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-40, -40)  # Offset from center
	add_child(label)

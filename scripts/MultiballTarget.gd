extends StaticBody2D

## v3.0: Multiball Target Indicator
## Visual indicator for multiball activation targets

signal multiball_target_hit

@export var target_name: String = "MULTI BALL"
@export var glow_color: Color = Color(1.0, 0.5, 0.0, 1.0)  # Orange
@export var points_value: int = 50  # Points for hitting this target

var is_lit: bool = true
var glow_effect: Node2D = null

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	# Add to multiball_targets group
	add_to_group("multiball_targets")
	
	# Set collision layer
	collision_layer = 8  # Obstacle layer
	collision_mask = 0
	
	# Create collision shape
	var circle = CircleShape2D.new()
	circle.radius = 25.0
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle
	add_child(collision_shape)
	
	# Create visual indicator
	_create_visual_indicator()
	
	# Add glow effect
	_add_glow_effect()
	
	# Add Area2D for detection
	var area = Area2D.new()
	area.name = "DetectionArea"
	area.collision_layer = 0
	area.collision_mask = 1  # Detect ball
	add_child(area)
	
	var area_shape = CollisionShape2D.new()
	area_shape.shape = circle.duplicate()
	area.add_child(area_shape)
	area.body_entered.connect(_on_body_entered)

func _create_visual_indicator():
	"""Create visual indicator for multiball target"""
	# Create background circle
	var bg = ColorRect.new()
	bg.size = Vector2(50, 50)
	bg.position = Vector2(-25, -25)
	bg.color = Color(0.2, 0.2, 0.2, 0.8)
	add_child(bg)
	
	# Create label
	var label = Label.new()
	label.name = "TargetLabel"
	label.text = target_name
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color.YELLOW)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-40, -10)
	add_child(label)

func _add_glow_effect():
	"""v3.0: Add glow effect to multiball target"""
	var glow_script = load("res://scripts/GlowEffect.gd")
	if glow_script:
		glow_effect = Node2D.new()
		glow_effect.set_script(glow_script)
		glow_effect.glow_color = glow_color
		glow_effect.glow_size = 1.8
		glow_effect.glow_intensity = 1.3
		glow_effect.pulse_enabled = true
		glow_effect.pulse_speed = 2.5
		add_child(glow_effect)

func _process(delta):
	"""Pulse animation"""
	if is_lit and glow_effect:
		# Glow already handles pulsing
		pass

func _on_body_entered(body: Node2D):
	"""Called when ball enters target"""
	if body is RigidBody2D and body.collision_layer == 1:  # Ball
		# Flash effect
		var tween = create_tween()
		var original_modulate = modulate
		tween.tween_property(self, "modulate", Color.WHITE, 0.1)
		tween.tween_property(self, "modulate", original_modulate, 0.2)
		
		# Emit signal
		multiball_target_hit.emit()
		
		# Award points
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager and game_manager.has_method("add_score"):
			game_manager.add_score(points_value)
		
		# Play sound
		var sound_manager = get_tree().get_first_node_in_group("sound_manager")
		if sound_manager and sound_manager.has_method("play_sound"):
			sound_manager.play_sound("multiball_activate")
		
		# Spawn particles
		var particle_manager = get_tree().get_first_node_in_group("particle_manager")
		if particle_manager:
			if particle_manager.has_method("spawn_multiball_launch"):
				particle_manager.spawn_multiball_launch(body.global_position)
		
		if _get_debug_mode():
			print("[MultiballTarget] Hit! Awarded ", points_value, " points")

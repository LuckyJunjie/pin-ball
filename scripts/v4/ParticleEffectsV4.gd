extends Node2D
## v4.0 Particle Effects System
## Provides visual particle effects for gameplay feedback

signal particle_effect_completed(effect_type: String)

@export var default_particle_color: Color = Color(1.0, 0.9, 0.2, 1.0)  # Yellow-gold
@export var bonus_particle_color: Color = Color(0.2, 1.0, 0.4, 1.0)    # Green
@export var score_popup_color: Color = Color(1.0, 1.0, 1.0, 1.0)     # White
@export var default_lifetime: float = 0.5

var _particle_container: Node2D = null

func _ready() -> void:
	add_to_group("particle_system")
	_create_container()

func _create_container() -> void:
	_particle_container = Node2D.new()
	_particle_container.name = "ParticleContainer"
	add_child(_particle_container)

func _get_debug_mode() -> bool:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		var debug = gm.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

# ============================================
# Effect Spawners
# ============================================

func spawn_hit_effect(position: Vector2, color: Color = default_particle_color, count: int = 10) -> void:
	## Spawn particle burst on hit
	var particles = _create_cpu_particles(count)
	particles.position = position
	particles.color = color
	particles.amount = count
	particles.lifetime = default_lifetime * 0.5
	particles.gravity = Vector2(0, 200)
	particles.scale_amount = 3.0
	particles.initial_velocity_min = 50.0
	particles.initial_velocity_max = 150.0
	particles.spread = 180.0
	_particle_container.add_child(particles)
	
	# Auto-remove after emission
	_emit_and_free(particles, 0.2)

func spawn_score_popup(position: Vector2, score: int) -> void:
	## Spawn floating score number
	var label = Label.new()
	label.name = "ScorePopup"
	label.text = "+%d" % score
	label.position = position
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", score_popup_color)
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Animate floating up
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "position:y", position.y - 50, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "modulate:a", 0.0, 1.0).set_delay(0.5)
	
	tween.chain().tween_callback(func():
		if is_instance_valid(label):
			label.queue_free()
	)
	
	_particle_container.add_child(label)

func spawn_bonus_effect(position: Vector2) -> void:
	## Spawn celebration effect for bonus activation
	var particles = _create_cpu_particles(30)
	particles.position = position
	particles.color = bonus_particle_color
	particles.amount = 30
	particles.lifetime = default_lifetime * 2
	particles.gravity = Vector2(0, -100)
	particles.scale_amount = 5.0
	particles.initial_velocity_min = 100.0
	particles.initial_velocity_max = 200.0
	particles.spread = 360.0
	_particle_container.add_child(particles)
	
	_emit_and_free(particles, 0.3)

func spawn_letter_effect(position: Vector2, letter: String) -> void:
	## Spawn letter activation effect
	var label = Label.new()
	label.name = "LetterEffect"
	label.text = letter
	label.position = position
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", Color(0.2, 0.8, 1.0, 1.0))  # Cyan
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Scale up animation
	var tween = create_tween()
	tween.tween_property(label, "scale", Vector2(1.5, 1.5), 0.2).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1)
	tween.tween_property(label, "modulate:a", 0.0, 0.3).set_delay(0.5)
	
	tween.chain().tween_callback(func():
		if is_instance_valid(label):
			label.queue_free()
	)
	
	_particle_container.add_child(label)

func spawn_multiplier_effect(multiplier: int) -> void:
	## Spawn multiplier increase effect at screen center
	var label = Label.new()
	label.name = "MultiplierEffect"
	label.text = "%dx MULTIPLIER!" % multiplier
	label.position = Vector2(400, 100)  # Top center
	label.add_theme_font_size_override("font_size", 48)
	label.add_theme_color_override("font_color", Color(1.0, 0.8, 0.0, 1.0))  # Gold
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 4)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Pop and fade animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.1).set_trans(Tween.TRANS_BOUNCE)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.1)
	tween.tween_property(label, "position:y", 50, 1.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "modulate:a", 0.0, 0.8).set_delay(0.5)
	
	tween.chain().tween_callback(func():
		if is_instance_valid(label):
			label.queue_free()
	)
	
	_particle_container.add_child(label)
	
	particle_effect_completed.emit("multiplier_%dx" % multiplier)

func spawn_ball_drain_effect(position: Vector2) -> void:
	## Spawn effect when ball drains
	var particles = _create_cpu_particles(20)
	particles.position = position
	particles.color = Color(1.0, 0.3, 0.3, 1.0)  # Red
	particles.amount = 20
	particles.lifetime = default_lifetime
	particles.gravity = Vector2(0, 300)
	particles.scale_amount = 4.0
	particles.initial_velocity_min = 30.0
	particles.initial_velocity_max = 80.0
	particles.spread = 90.0  # Downward only
	_particle_container.add_child(particles)
	
	_emit_and_free(particles, 0.3)

func spawn_word_completion_effect(center: Vector2) -> void:
	## Celebration effect for completing a word (GOOGLE, etc.)
	var label = Label.new()
	label.name = "WordComplete"
	label.text = "WORD COMPLETED!"
	label.position = center
	label.add_theme_font_size_override("font_size", 56)
	label.add_theme_color_override("font_color", Color(0.2, 1.0, 0.4, 1.0))  # Green
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 5)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# Celebration animation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(label, "scale", Vector2(1.3, 1.3), 0.15).set_trans(Tween.TRANS_ELASTIC)
	tween.tween_property(label, "modulate:a", 0.0, 1.5).set_delay(0.8)
	
	tween.chain().tween_callback(func():
		if is_instance_valid(label):
			label.queue_free()
	)
	
	_particle_container.add_child(label)
	
	particle_effect_completed.emit("word_completion")

func spawn_zone_activation_effect(zone_name: String, position: Vector2) -> void:
	## Zone-specific activation effect
	var effect_color: Color
	match zone_name:
		"android_acres":
			effect_color = Color(0.2, 0.8, 0.2, 1.0)  # Green
		"google_gallery":
			effect_color = Color(0.2, 0.5, 1.0, 1.0)  # Blue
		"flutter_forest":
			effect_color = Color(0.2, 1.0, 0.8, 1.0)  # Cyan
		"dino_desert":
			effect_color = Color(1.0, 0.5, 0.2, 1.0)  # Orange
		"sparky_scorch":
			effect_color = Color(1.0, 0.2, 0.5, 1.0)  # Pink
		_:
			effect_color = default_particle_color
	
	var particles = _create_cpu_particles(25)
	particles.position = position
	particles.color = effect_color
	particles.amount = 25
	particles.lifetime = default_lifetime * 1.5
	particles.gravity = Vector2(0, -50)
	particles.scale_amount = 6.0
	particles.initial_velocity_min = 80.0
	particles.initial_velocity_max = 150.0
	particles.spread = 360.0
	_particle_container.add_child(particles)
	
	_emit_and_free(particles, 0.3)

# ============================================
# Helper Functions
# ============================================

func _create_cpu_particles(count: int) -> CPUParticles2D:
	var particles = CPUParticles2D.new()
	particles.amount = count
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 0.8
	particles.lifetime = default_lifetime
	
	# Set up gradient
	var gradient = Gradient.new()
	gradient.set_color(0, Color(1, 1, 1, 1))
	gradient.set_color(1, Color(1, 1, 1, 0))
	var gradient_texture = GradientTexture2D.new()
	gradient_texture.gradient = gradient
	particles.color_ramp = gradient_texture
	
	return particles

func _emit_and_free(particles: CPUParticles2D, delay: float) -> void:
	await get_tree().create_timer(delay).timeout
	particles.emitting = true
	await get_tree().create_timer(particles.lifetime + 0.1).timeout
	if is_instance_valid(particles):
		particles.queue_free()

func clear_all_effects() -> void:
	## Clear all particle effects immediately
	if _particle_container:
		for child in _particle_container.get_children():
			if is_instance_valid(child):
				child.queue_free()

# Static access for convenience
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("particle_system")
	return null

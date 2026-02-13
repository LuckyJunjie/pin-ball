extends Node
## v4.0 Background Animation System
## Dynamic backgrounds with animations, weather effects, and transitions

signal transition_started(from_scene: String, to_scene: String)
signal transition_completed(to_scene: String)

@export var default_animation_speed: float = 1.0
@export var weather_enabled: bool = false
@export var particle_density: float = 1.0

var _current_background: String = "default"
var _animation_player: AnimationPlayer = null
var _weather_particles: CPUParticles2D = null
var _transitioning: bool = false

func _ready() -> void:
	add_to_group("background_system")
	_setup_weather()
	_setup_animations()

func _setup_weather() -> void:
	if weather_enabled:
		_create_weather_particles()

func _setup_animations() -> void:
	# Create animation player
	_animation_player = AnimationPlayer.new()
	_animation_player.name = "BackgroundAnimations"
	add_child(_animation_player)
	
	# Define background animations
	_define_animations()

func _define_animations() -> void:
	# Default idle animation
	_add_animation("idle", [
		{"property": "modulate", "to": Color(1, 1, 1, 1), "duration": 2.0}
	])
	
	# Pulse animation for excitement
	_add_animation("pulse", [
		{"property": "scale", "to": Vector2(1.02, 1.02), "duration": 0.5, "ease": "in_out"},
		{"property": "scale", "to": Vector2(1.0, 1.0), "duration": 0.5, "ease": "in_out"}
	])
	
	# Celebrate animation
	_add_animation("celebrate", [
		{"property": "rotation", "to": 0.05, "duration": 0.2},
		{"property": "rotation", "to": -0.05, "duration": 0.2},
		{"property": "rotation", "to": 0.05, "duration": 0.2},
		{"property": "rotation", "to": 0.0, "duration": 0.2}
	])

func _add_animation(name: String, keyframes: Array) -> void:
	var animation = Animation.new()
	animation.length = 0.0
	
	for i in range(keyframes.size()):
		var kf = keyframes[i]
		var track_name = "Background:modulate" if kf.has("property") and "modulate" in kf["property"] else "Background:scale"
		var track = animation.add_track(Animation.TYPE_VALUE)
		animation.track_set_path(track, track_name)
		
		var time = 0.0
		for j in range(i):
			time += kf.get("duration", 1.0)
		
		animation.track_insert_key(track, 0.0, kf.get("from", Color.WHITE))
		animation.track_insert_key(track, time, kf.get("to", Color.WHITE))
	
	_animation_player.add_animation(name, animation)

func transition_to(background_name: String, duration: float = 1.0) -> void:
	if _transitioning:
		return
	
	_transitioning = true
	transition_started.emit(_current_background, background_name)
	
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		get_tree().get_root(),
		"modulate:a",
		0.0,
		duration / 2
	).set_ease(Tween.EASE_IN)
	
	tween.chain().tween_callback(func():
		_current_background = background_name
		_on_background_changed(background_name)
	)
	
	tween.tween_property(
		get_tree().get_root(),
		"modulate:a",
		1.0,
		duration / 2
	).set_ease(Tween.EASE_OUT)
	
	tween.tween_callback(func():
		_transitioning = false
		transition_completed.emit(background_name)
	)

func _on_background_changed(background_name: String) -> void:
	# Trigger background-specific animations
	if _animation_player and _animation_player.has_animation("idle"):
		_animation_player.play("idle")

func play_animation(animation_name: String, blend: float = 0.0) -> void:
	if _animation_player and _animation_player.has_animation(animation_name):
		_animation_player.play(animation_name, blend)

func stop_animation() -> void:
	if _animation_player:
		_animation_player.stop()

func _create_weather_particles() -> void:
	_weather_particles = CPUParticles2D.new()
	_weather_particles.name = "WeatherParticles"
	_weather_particles.amount = 100
	_weather_particles.lifetime = 5.0
	_weather_particles.emitting = true
	_weather_particles.direction = Vector2(0, 1)
	_weather_particles.spread = 15.0
	_weather_particles.gravity = Vector2(0, 50)
	_weather_particles.scale_amount_min = 2.0
	_weather_particles.scale_amount_max = 5.0
	
	# Weather type based on theme
	match _current_background:
		"sparky_scorch":
			_weather_particles.color = Color(1.0, 0.8, 0.2, 0.3)  # Sparkles
		"flutter_forest":
			_weather_particles.color = Color(0.5, 1.0, 0.8, 0.2)  # Leaves/dust
		"dino_desert":
			_weather_particles.color = Color(1.0, 0.7, 0.4, 0.1)  # Sand
		_:
			_weather_particles.color = Color(1.0, 1.0, 1.0, 0.1)  # Generic

func set_weather(weather_type: String) -> void:
	match weather_type:
		"none":
			if _weather_particles:
				_weather_particles.emitting = false
		"rain":
			_weather_particles.emitting = true
			_weather_particles.direction = Vector2(0, 1)
			_weather_particles.gravity = Vector2(0, 200)
		"snow":
			_weather_particles.emitting = true
			_weather_particles.direction = Vector2(0.1, 1)
			_weather_particles.gravity = Vector2(0, 20)
		"sparkles":
			_weather_particles.emitting = true
			_weather_particles.direction = Vector2(0, -0.5)
			_weather_particles.gravity = Vector2(0, 10)

func set_particle_density(density: float) -> void:
	particle_density = clamp(density, 0.1, 2.0)
	if _weather_particles:
		_weather_particles.amount = int(100 * particle_density)

func create_transition_effect(effect_type: String) -> void:
	match effect_type:
		"fade":
			_create_fade_effect()
		"wipe":
			_create_wipe_effect()
		"zoom":
			_create_zoom_effect()
		"slide":
			_create_slide_effect()

func _create_fade_effect() -> void:
	# Full screen fade to black then back
	var fade = ColorRect.new()
	fade.color = Color.BLACK
	fade.anchor_right = 1.0
	fade.anchor_bottom = 1.0
	fade.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	get_tree().get_root().add_child(fade)
	
	var tween = create_tween()
	tween.tween_property(fade, "modulate:a", 1.0, 0.5)
	tween.tween_property(fade, "modulate:a", 0.0, 0.5)
	tween.tween_callback(func(): fade.queue_free())

func _create_wipe_effect() -> void:
	# Wipe effect from left
	pass

func _create_zoom_effect() -> void:
	# Zoom in then out
	pass

func _create_slide_effect() -> void:
	# Slide effect
	pass

func parallax_scroll(speed: Vector2) -> void:
	# Apply parallax scrolling to background
	pass

func set_animation_speed(speed: float) -> void:
	default_animation_speed = clamp(speed, 0.1, 3.0)
	if _animation_player:
		_animation_player.speed_scale = default_animation_speed

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("background_system")
	return null

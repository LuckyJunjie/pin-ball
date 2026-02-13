extends RigidBody2D
class_name BumperV4
## Base class for all bumper types in v4.0 (Android, Dash, Sparky)
## Provides common behavior: lighting, scoring, visual feedback

enum BumperType {
	ANDROID,  # Android Acres bumpers
	DASH,     # Flutter Forest Dash bumpers  
	SPARKY    # Sparky Scorch bumpers
}

# Signals
signal bumper_hit(points: int, bumper_id: String)
signal bumper_lit_changed(is_lit: bool)
signal bumper_bonus_activated(bonus_type: GameManagerV4.Bonus)

# Configuration
@export var bumper_type: BumperType = BumperType.ANDROID
@export var bumper_id: String = "A"
@export var base_points: int = 20000
@export var lit_multiplier: int = 2
@export var lit_color: Color = Color(1.0, 0.9, 0.2, 1.0)  # Yellow for lit
@export var dim_color: Color = Color(0.4, 0.4, 0.4, 1.0)   # Gray for dim

# State
var is_lit: bool = false
var hit_count: int = 0
var can_be_hit: bool = true
var hit_cooldown: float = 0.2  # Seconds between hits

# References
@onready var sprite: Sprite2D = $Sprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var hit_cooldown_timer: Timer = $HitCooldownTimer

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GlobalGameSettings"""
	# Check GlobalGameSettings singleton (autoload)
	if has_node("/root/GlobalGameSettings"):
		var global_settings = get_node("/root/GlobalGameSettings")
		if global_settings.has_method("get") and global_settings.get("debug_mode") != null:
			return bool(global_settings.debug_mode)
	# Fallback to checking game_manager group
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "VisualLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1, 1, 0, 1))  # Yellow
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-30, -30)  # Offset from center
	add_child(label)

func _ready() -> void:
	add_to_group("bumpers")
	add_to_group("bumper_%s" % bumper_id)
	
	# Disable gravity and freeze bumper (should not move)
	gravity_scale = 0.0
	freeze = true
	
	# Set up hit cooldown timer
	if not hit_cooldown_timer:
		hit_cooldown_timer = Timer.new()
		hit_cooldown_timer.name = "HitCooldownTimer"
		hit_cooldown_timer.wait_time = hit_cooldown
		hit_cooldown_timer.one_shot = true
		hit_cooldown_timer.timeout.connect(_on_hit_cooldown_timeout)
		add_child(hit_cooldown_timer)
	
	# Initialize visual state
	_update_visual_state()
	
	# Add debug visual label
	add_visual_label("BUMPER_" + bumper_id)
	
	# Connect to game manager if available
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm and gm.has_signal("game_over"):
		gm.game_over.connect(_on_game_over)

func _on_game_over() -> void:
	# Reset bumper state when game ends
	reset_bumper()

func _on_body_entered(body: Node) -> void:
	if not can_be_hit:
		return
	
	if body.is_in_group("balls"):
		_on_bumper_hit(body)

func _on_bumper_hit(ball: Node) -> void:
	if not can_be_hit:
		return
	
	# Start cooldown
	can_be_hit = false
	hit_cooldown_timer.start(hit_cooldown)
	
	# Increment hit count
	hit_count += 1
	
	# Calculate points (double if lit)
	var points = base_points * (lit_multiplier if is_lit else 1)
	
	# Emit signals
	bumper_hit.emit(points, bumper_id)
	
	# Toggle lit state
	toggle_lit_state()
	
	# Play sound
	_play_hit_sound()
	
	# Trigger screen shake
	_trigger_screen_shake()
	
	# Register combo
	_register_combo()
	
	# Visual feedback
	_show_hit_feedback()
	
	# Apply impulse to ball
	if ball is RigidBody2D:
		_apply_bounce_impulse(ball)

func toggle_lit_state() -> void:
	## Toggle the lit state of the bumper
	is_lit = not is_lit
	bumper_lit_changed.emit(is_lit)
	_update_visual_state()

func set_lit(state: bool) -> void:
	## Set the lit state explicitly
	if is_lit != state:
		is_lit = state
		bumper_lit_changed.emit(is_lit)
		_update_visual_state()

func reset_bumper() -> void:
	## Reset bumper to initial state
	is_lit = false
	hit_count = 0
	can_be_hit = true
	_update_visual_state()
	
	# Stop any timers
	if hit_cooldown_timer and hit_cooldown_timer.time_left > 0:
		hit_cooldown_timer.stop()

func _update_visual_state() -> void:
	## Update visual appearance based on lit state
	if sprite:
		# Simple color change for now
		sprite.modulate = lit_color if is_lit else dim_color
	
	# Could add more visual effects here (particles, animation, etc.)

func _play_hit_sound() -> void:
	var audio = get_tree().get_first_node_in_group("sound_manager")
	if audio and audio.has_method("play_bumper_hit"):
		var zone_type = ""
		match bumper_type:
			BumperType.ANDROID:
				zone_type = "android"
			BumperType.DASH:
				zone_type = "dash"
			BumperType.SPARKY:
				zone_type = "sparky"
		audio.play_bumper_hit(zone_type)
	elif audio and audio.has_method("play_sound"):
		match bumper_type:
			BumperType.ANDROID:
				audio.play_sound("android_bumper_hit")
			BumperType.DASH:
				audio.play_sound("dash_bumper_hit")
			BumperType.SPARKY:
				audio.play_sound("sparky_bumper_hit")
			_:
				audio.play_sound("bumper_hit")

func _trigger_screen_shake() -> void:
	var screen_shake = get_tree().get_first_node_in_group("screen_shake")
	if screen_shake and screen_shake.has_method("shake_light"):
		screen_shake.shake_light()

func _register_combo() -> void:
	var combo = get_tree().get_first_node_in_group("combo_system")
	if combo and combo.has_method("register_hit"):
		var bonus_points = combo.register_hit("bumper_" + bumper_type.keys()[bumper_type], base_points)
		if bonus_points > 0:
			# Add combo bonus to score
			GameManagerV4.add_score(bonus_points)

func _show_hit_feedback() -> void:
	## Show visual feedback for hit
	# Simple scale animation
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.05)
	
	# Spawn particles
	_spawn_particles()
	
	# Could add particles or other effects here

func _spawn_particles() -> void:
	var particles = get_tree().get_first_node_in_group("particle_system")
	if particles and particles.has_method("spawn_hit_effect"):
		var color = Color(1.0, 0.9, 0.2, 1.0)  # Yellow-gold
		if is_lit:
			color = Color(0.2, 1.0, 0.4, 1.0)  # Green when lit
		particles.spawn_hit_effect(global_position, color, 8)

func _apply_bounce_impulse(ball: RigidBody2D) -> void:
	## Apply bounce impulse to ball
	var normal = (ball.global_position - global_position).normalized()
	var impulse_strength = 300.0  # Adjust based on gameplay feel
	ball.apply_impulse(normal * impulse_strength)

func _on_hit_cooldown_timeout() -> void:
	can_be_hit = true

func bonus_flash() -> void:
	## Special visual effect for bonus activation
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.3, 1.3), 0.1)
	
	tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(sprite, "modulate", lit_color if is_lit else dim_color, 0.1)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.1)

func get_bumper_info() -> Dictionary:
	## Return bumper information for debugging/serialization
	return {
		"type": bumper_type,
		"id": bumper_id,
		"is_lit": is_lit,
		"hit_count": hit_count,
		"position": global_position
	}

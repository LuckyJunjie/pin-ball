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
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		# Play different sounds based on bumper type
		match bumper_type:
			BumperType.ANDROID:
				sm.play_sound("android_bumper_hit")
			BumperType.DASH:
				sm.play_sound("dash_bumper_hit")
			BumperType.SPARKY:
				sm.play_sound("sparky_bumper_hit")
			_:
				sm.play_sound("bumper_hit")

func _show_hit_feedback() -> void:
	## Show visual feedback for hit
	# Simple scale animation
	var tween = create_tween()
	tween.tween_property(sprite, "scale", Vector2(1.2, 1.2), 0.05)
	tween.tween_property(sprite, "scale", Vector2(1.0, 1.0), 0.05)
	
	# Could add particles or other effects here

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

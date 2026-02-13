extends Node2D
## v4.0 Character Animatronic System
## Provides animations for character themes (Sparky, Dino, Dash, Android)

signal animation_completed(anim_name: String)
signal frame_changed(frame_index: int)

@export var theme_key: String = "sparky"
@export var default_animation: String = "idle"
@export var animation_speed: float = 4.0  # FPS

var _current_animation: String = ""
var _frame_index: int = 0
var _frame_timer: float = 0.0
var _animation_speed_multiplier: float = 1.0
var _is_playing: bool = false
var _loop: bool = true
var _pending_animations: Array = []

# Animation definitions
var _animations: Dictionary = {}

func _ready() -> void:
	add_to_group("character_animatronic")
	_setup_animations()

func _setup_animations() -> void:
	# Define animations for each theme
	match theme_key:
		"sparky":
			_animations = {
				"idle": {"frames": 4, "speed": 4.0},
				"turbo_charge": {"frames": 8, "speed": 8.0},
				"celebrate": {"frames": 6, "speed": 6.0},
				"hit": {"frames": 3, "speed": 12.0}
			}
		"dino":
			_animations = {
				"idle": {"frames": 4, "speed": 3.0},
				"chomp": {"frames": 6, "speed": 10.0},
				"celebrate": {"frames": 5, "speed": 5.0},
				"sleep": {"frames": 2, "speed": 2.0}
			}
		"dash":
			_animations = {
				"idle": {"frames": 4, "speed": 4.0},
				"nest_complete": {"frames": 8, "speed": 8.0},
				"celebrate": {"frames": 6, "speed": 6.0}
			}
		"android":
			_animations = {
				"idle": {"frames": 4, "speed": 4.0},
				"spaceship_land": {"frames": 10, "speed": 10.0},
				"celebrate": {"frames": 6, "speed": 6.0}
			}

func _process(delta: float) -> void:
	if not _is_playing:
		return
	
	_frame_timer += delta * animation_speed * _animation_speed_multiplier
	
	if _frame_timer >= 1.0:
		_frame_timer -= 1.0
		_frame_index += 1
		
		var anim_info = _animations.get(_current_animation, {"frames": 1})
		var frame_count = anim_info.get("frames", 1)
		
		if _frame_index >= frame_count:
			if _loop:
				_frame_index = 0
				animation_completed.emit(_current_animation)
			else:
				_frame_index = frame_count - 1
				_is_playing = false
				animation_completed.emit(_current_animation)
		
		frame_changed.emit(_frame_index)
		_update_frame_visuals()

func _update_frame_visuals() -> void:
	# Override in subclasses to implement actual sprite animation
	queue_redraw()

func set_theme(new_theme: String) -> void:
	theme_key = new_theme
	_setup_animations()
	play("idle")

func play(anim_name: String, loop_animation: bool = true, speed_multiplier: float = 1.0) -> void:
	if not _animations.has(anim_name):
		if _animations.has("idle"):
			anim_name = "idle"
		else:
			return
	
	_current_animation = anim_name
	_loop = loop_animation
	_animation_speed_multiplier = speed_multiplier
	_frame_index = 0
	_frame_timer = 0.0
	_is_playing = true
	
	var anim_info = _animations[anim_name]
	animation_speed = anim_info.get("speed", 4.0)
	
	_update_frame_visuals()

func play_once(anim_name: String, speed_multiplier: float = 1.0) -> void:
	play(anim_name, false, speed_multiplier)

func queue_animation(anim_name: String) -> void:
	_pending_animations.append(anim_name)

func _on_animation_completed(anim_name: String) -> void:
	animation_completed.emit(anim_name)
	
	if _pending_animations.size() > 0:
		var next_anim = _pending_animations.pop_front()
		play(next_anim)
	else:
		play("idle")

func stop() -> void:
	_is_playing = false

func pause() -> void:
	_is_playing = false

func resume() -> void:
	if _current_animation != "":
		_is_playing = true

func set_animation_speed(speed: float) -> void:
	_animation_speed_multiplier = speed

func is_playing() -> bool:
	return _is_playing

func get_current_animation() -> String:
	return _current_animation

func get_frame_index() -> int:
	return _frame_index

func has_animation(anim_name: String) -> bool:
	return _animations.has(anim_name)

func get_animation_frames(anim_name: String) -> int:
	var anim = _animations.get(anim_name)
	return anim.get("frames", 1) if anim else 0

func get_theme() -> String:
	return theme_key

# Placeholder for actual drawing
func _draw() -> void:
	# Draw debug placeholder
	if _get_debug_mode():
		draw_string(ThemeDB.get_fallback_font(), Vector2(-50, 0), "%s:%s[%d]" % [theme_key, _current_animation, _frame_index], HORIZONTAL_ALIGNMENT_CENTER, 100, 16, Color.WHITE)

func _get_debug_mode() -> bool:
	return false

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("character_animatronic")
	return null

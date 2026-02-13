extends Node
## v4.0 Screen Shake System
## Provides camera shake effects for gameplay feedback

signal shake_completed()

@export var default_shake_intensity: float = 10.0
@export var default_shake_duration: float = 0.2
@export var decay_rate: float = 2.0

var _camera: Camera2D = null
var _current_shake: float = 0.0
var _shake_timer: float = 0.0
var _is_shaking: bool = false
var _original_position: Vector2 = Vector2.ZERO
var _shake_queue: Array = []

func _ready() -> void:
	add_to_group("screen_shake")
	_find_camera()

func _find_camera() -> void:
	# Find camera in various possible locations
	_camera = get_tree().get_first_node_in_group("main_camera")
	if not _camera:
		_camera = get_node_or_null("../Camera2D")
	if not _camera:
		_camera = get_node_or_null("../../Camera2D")
	if not _camera:
		_camera = get_viewport().get_camera_2d()

func _process(delta: float) -> void:
	if _is_shaking and _camera:
		_shake_timer -= delta
		
		if _shake_timer <= 0.0:
			_stop_shake()
		else:
			_apply_shake(delta)

func _apply_shake(_delta: float) -> void:
	if not _camera:
		return
	
	var random_offset = Vector2(
		randf_range(-_current_shake, _current_shake),
		randf_range(-_current_shake, _current_shake)
	)
	_camera.offset = _original_position + random_offset
	
	# Decay shake intensity
	_current_shake = lerp(_current_shake, 0.0, decay_rate * _delta)

func _stop_shake() -> void:
	_is_shaking = false
	_current_shake = 0.0
	
	if _camera:
		_camera.offset = Vector2.ZERO
	
	shake_completed.emit()
	
	# Process any queued shakes
	if _shake_queue.size() > 0:
		var next_shake = _shake_queue.pop_front()
		shake_intensity(next_shake.intensity, next_shake.duration)

func _process_next_shake() -> void:
	## Start the next shake in the queue if any
	if _shake_queue.size() > 0:
		var next_shake = _shake_queue.pop_front()
		shake_intensity(next_shake.intensity, next_shake.duration)

func shake(intensity: float, duration: float) -> void:
	## Queue a shake effect
	_shake_queue.append({
		"intensity": intensity,
		"duration": duration
	})
	
	if not _is_shaking:
		_process_next_shake()

func shake_intensity(intensity: float, duration: float) -> void:
	## Immediate shake effect (replaces current shake)
	if _is_shaking:
		# Add to queue instead
		_shake_queue.append({
			"intensity": intensity,
			"duration": duration
		})
		return
	
	_find_camera()
	if not _camera:
		return
	
	_original_position = _camera.offset
	_current_shake = intensity
	_shake_timer = duration
	_is_shaking = true
	
	if _get_debug_mode():
		print("[ScreenShake] Started shake: intensity=%.1f, duration=%.2f" % [intensity, duration])

func shake_light() -> void:
	## Light shake for small impacts (bumper hits)
	shake_intensity(default_shake_intensity * 0.3, default_shake_duration * 0.5)

func shake_medium() -> void:
	## Medium shake for moderate impacts (flipper hits at speed)
	shake_intensity(default_shake_intensity * 0.6, default_shake_duration * 0.7)

func shake_heavy() -> void:
	## Heavy shake for big impacts (drain, multi-ball)
	shake_intensity(default_shake_intensity, default_shake_duration)

func shake_extreme() -> void:
	## Extreme shake for major events (bonus activation, game over)
	shake_intensity(default_shake_intensity * 2.0, default_shake_duration * 1.5)

func stop_shake() -> void:
	## Immediately stop all shaking
	_is_shaking = false
	_current_shake = 0.0
	_shake_queue.clear()
	
	if _camera:
		_camera.offset = Vector2.ZERO

func _get_debug_mode() -> bool:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		var debug = gm.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

# Static access for convenience
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("screen_shake")
	return null

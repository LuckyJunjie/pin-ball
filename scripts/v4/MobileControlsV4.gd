extends Node
## v4.0 Mobile Touch Controls
## Provides touch input for flippers, launcher, and gestures on mobile devices

signal flipper_touched(side: String, is_pressed: bool)
signal launch_tap()
signal swipe_detected(direction: String, delta: Vector2)

@export var flipper_left_zone: Rect2 = Rect2(0, 300, 200, 300)  # Left side of screen
@export var flipper_right_zone: Rect2 = Rect2(600, 300, 200, 300)  # Right side
@export var launch_zone: Rect2 = Rect2(350, 450, 100, 150)  # Bottom center
@export var swipe_threshold: float = 50.0  # Pixels for swipe detection

var _touch_points: Dictionary = {}  # Track active touch points
var _is_flipper_left_pressed: bool = false
var _is_flipper_right_pressed: bool = false
var _is_launch_pressed: bool = false
var _swipe_start: Vector2 = Vector2.ZERO

func _ready() -> void:
	add_to_group("mobile_controls")
	
	# Configure zones based on screen size
	_configure_zones()

func _get_viewport_size() -> Vector2:
	# Use Viewport API (Godot 4); do not call get_viewport_rect() on self - it does not exist on Node/CanvasLayer
	return get_viewport().get_visible_rect().size

func _configure_zones() -> void:
	var viewport_size := _get_viewport_size()
	
	# Flipper zones take left and right thirds of screen
	flipper_left_zone = Rect2(0, viewport_size.y * 0.4, viewport_size.x * 0.35, viewport_size.y * 0.6)
	flipper_right_zone = Rect2(viewport_size.x * 0.65, viewport_size.y * 0.4, viewport_size.x * 0.35, viewport_size.y * 0.6)
	
	# Launch zone at bottom center
	launch_zone = Rect2(
		viewport_size.x * 0.4, 
		viewport_size.y * 0.7, 
		viewport_size.x * 0.2, 
		viewport_size.y * 0.3
	)

func _input(event: InputEvent) -> void:
	if event is InputEventScreenTouch:
		_handle_touch(event)
	elif event is InputEventScreenDrag:
		_handle_drag(event)

func _handle_touch(event: InputEventScreenTouch) -> void:
	if event.pressed:
		_touch_points[event.index] = event.position
		_process_touch(event.position, true, event.index)
	else:
		_process_touch(_touch_points.get(event.index, event.position), false, event.index)
		_touch_points.erase(event.index)

func _handle_drag(event: InputEventScreenDrag) -> void:
	_touch_points[event.index] = event.position
	
	# Check for swipe
	if event.index in _touch_points:
		var start_pos = _touch_points[event.index]
		var delta = event.position - start_pos
		
		if delta.length() > swipe_threshold:
			var direction = _get_swipe_direction(delta)
			swipe_detected.emit(direction, delta)
			# Remove from tracking after swipe detected
			_touch_points.erase(event.index)

func _process_touch(position: Vector2, pressed: bool, touch_index: int) -> void:
	# Check which zone the touch is in
	if flipper_left_zone.has_point(position):
		if _is_flipper_left_pressed != pressed:
			_is_flipper_left_pressed = pressed
			flipper_touched.emit("left", pressed)
	
	elif flipper_right_zone.has_point(position):
		if _is_flipper_right_pressed != pressed:
			_is_flipper_right_pressed = pressed
			flipper_touched.emit("right", pressed)
	
	elif launch_zone.has_point(position):
		if pressed and not _is_launch_pressed:
			_is_launch_pressed = true
			_launch_tap()
		elif not pressed:
			_is_launch_pressed = false

func _get_swipe_direction(delta: Vector2) -> String:
	var abs_x = abs(delta.x)
	var abs_y = abs(delta.y)
	
	if abs_x > abs_y:
		if delta.x > 0:
			return "right"
		else:
			return "left"
	else:
		if delta.y > 0:
			return "down"
		else:
			return "up"

func _launch_tap() -> void:
	# Trigger launch on tap/press
	launch_tap.emit()
	
	# Trigger game launch
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("launch_ball"):
		gm.launch_ball()

func is_mobile_device() -> bool:
	return OS.get_name() in ["iOS", "Android"]

func _get_debug_mode() -> bool:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		var debug = gm.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

# Debug zone visualization removed: this script runs on a CanvasLayer (not CanvasItem), so _draw/draw_rect/queue_redraw are not available. Use child ColorRects in the scene for zone display.

# ============================================
# Gesture Recognition
# ============================================

func recognize_pinch(center: Vector2, delta: float) -> void:
	## Pinch gesture for zoom (if camera zoom is enabled)
	pass

func recognize_double_tap(position: Vector2) -> void:
	## Double tap for quick launch or special action
	pass

func recognize_long_press(position: Vector2, duration: float) -> void:
	## Long press for special actions (pause, menu, etc.)
	pass

# ============================================
# Haptic Feedback
# ============================================

func trigger_haptic_feedback(type: String = "light") -> void:
	if OS.get_name() == "Android":
		Input.vibrate_handheld(10)  # Light vibration (duration_ms)
	elif OS.get_name() == "iOS":
		# iOS haptics would require native code
		pass

func trigger_impact_feedback(intensity: float = 0.5) -> void:
	## Haptic feedback for game impacts
	var duration = int(intensity * 20)
	if OS.get_name() == "Android":
		Input.vibrate_handheld(duration)

# ============================================
# Static Access
# ============================================

static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("mobile_controls")
	return null

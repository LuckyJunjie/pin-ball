extends Node2D
## v4.0 Ball Trail System
## Creates visual trail effects following the ball

signal trail_visibility_changed(visible: bool)

@export var trail_color: Color = Color(1.0, 1.0, 1.0, 0.6)
@export var trail_width: float = 4.0
@export var trail_length: int = 20  # Number of points in trail
@export var update_frequency: float = 0.016  # Update every 16ms (60fps)
@export var fade_start: float = 0.5  # Start fading at 50% of trail length

var _ball: RigidBody2D = null
var _trail_points: Array[Vector2] = []
var _timer: float = 0.0
var _is_visible: bool = false
var _parent_canvas: CanvasItem = null

func _ready() -> void:
	add_to_group("ball_trail")
	_set_visible(false)

func _process(delta: float) -> void:
	if not _ball or not is_instance_valid(_ball):
		return
	
	_timer += delta
	
	if _timer >= update_frequency:
		_timer = 0.0
		_update_trail()
		_queue_redraw()

func _update_trail() -> void:
	if not _ball:
		return
	
	var current_pos = _ball.global_position
	
	if _trail_points.size() == 0:
		# Initialize trail with current position
		for i in range(trail_length):
			_trail_points.append(current_pos)
	else:
		# Shift points and add current position
		_trail_points.pop_front()
		_trail_points.append(current_pos)

func _draw() -> void:
	if _trail_points.size() < 2:
		return
	
	var points_count = _trail_points.size()
	if points_count < 2:
		return
	
	# Draw trail as a series of line segments with fading opacity
	for i in range(points_count - 1):
		var start_pos = _trail_points[i]
		var end_pos = _trail_points[i + 1]
		
		# Calculate fade factor (0.0 at end, 1.0 at start)
		var fade_factor = 1.0 - (float(i) / float(points_count))
		if fade_factor > fade_start:
			fade_factor = fade_start + (1.0 - fade_start) * fade_factor
		
		# Calculate alpha
		var alpha = int(255 * fade_factor * trail_color.a)
		var color = Color(trail_color.r, trail_color.g, trail_color.b, alpha / 255.0)
		
		# Calculate width (tapering at end)
		var width = trail_width * fade_factor
		
		draw_line(start_pos, end_pos, color, width)

func _set_visible(visible: bool) -> void:
	if _is_visible != visible:
		_is_visible = visible
		visible = visible
		trail_visibility_changed.emit(visible)

func set_ball(ball: RigidBody2D) -> void:
	## Set the ball to follow
	_ball = ball
	_clear_trail()
	
	if ball:
		_set_visible(true)
		if _get_debug_mode():
			print("[BallTrail] Following ball: %s" % ball.name)
	else:
		_set_visible(false)

func _clear_trail() -> void:
	_trail_points.clear()
	for i in range(trail_length):
		_trail_points.append(Vector2.ZERO)
	_queue_redraw()

func clear_trail() -> void:
	## Clear the trail manually
	_clear_trail()

func set_trail_color(color: Color) -> void:
	trail_color = color
	_queue_redraw()

func set_trail_width(width: float) -> void:
	trail_width = width
	_queue_redraw()

func set_trail_length(length: int) -> void:
	trail_length = maxi(2, length)  # Minimum 2 points
	_clear_trail()

func is_visible() -> bool:
	return _is_visible

func _get_debug_mode() -> bool:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		var debug = gm.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

# Static access for convenience
static func get_instance() -> Node2D:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("ball_trail")
	return null

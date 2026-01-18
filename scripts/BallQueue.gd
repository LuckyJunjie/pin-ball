extends Node2D

## Ball Queue script for pinball game
## Manages a queue of standby balls

signal ball_ready(ball: RigidBody2D)
signal queue_empty

@export var ball_scene: PackedScene = null
@export var queue_size: int = 4
@export var infinite_balls: bool = true  # Development mode: infinite balls
@export var queue_spacing: float = 25.0
@export var queue_position: Vector2 = Vector2(720, 100)  # Positioned at top right area
@export var queue_direction: Vector2 = Vector2(0, -1)  # Vertical stack (upward)

var ball_queue: Array[RigidBody2D] = []
var active_ball: RigidBody2D = null

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		# Access debug_mode property directly (it's an @export var in GameManager)
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	if _get_debug_mode():
		print("[BallQueue] _ready() called")
		print("[BallQueue] Global position: ", global_position)
		print("[BallQueue] Position: ", position)
		print("[BallQueue] Visible: ", visible)
		print("[BallQueue] Queue position: ", queue_position)
		print("[BallQueue] Ball scene: ", ball_scene)
		print("[BallQueue] Queue size: ", queue_size)
	
	# Initialize queue with balls
	initialize_queue()
	
	if _get_debug_mode():
		print("[BallQueue] _ready() completed")

func initialize_queue():
	"""Initialize the queue with standby balls"""
	if _get_debug_mode():
		print("[BallQueue] initialize_queue() called")
	if not ball_scene:
		push_error("Ball scene not set in BallQueue!")
		if _get_debug_mode():
			print("[BallQueue] ERROR: Ball scene is null!")
		return
	
	if _get_debug_mode():
		print("[BallQueue] Creating ", queue_size, " balls")
	# Create balls for the queue
	for i in range(queue_size):
		var ball = ball_scene.instantiate()
		add_child(ball)
		
		# Position balls in queue (stacked vertically)
		var queue_offset = queue_direction * i * queue_spacing
		var ball_pos = queue_position + queue_offset
		ball.global_position = ball_pos
		print("[BallQueue] Created ball ", i, " at global position: ", ball.global_position, " (queue_pos: ", queue_position, " + offset: ", queue_offset, ")")
		
		# Disable physics for queued balls (they're just visual)
		ball.gravity_scale = 0.0
		ball.linear_velocity = Vector2.ZERO
		ball.angular_velocity = 0.0
		ball.sleeping = true
		ball.freeze = true
		
		# Make queued balls slightly transparent (but visible)
		ball.modulate = Color(1, 1, 1, 0.8)
		if _get_debug_mode():
			print("[BallQueue] Ball ", i, " - visible: ", ball.visible, ", modulate: ", ball.modulate, ", freeze: ", ball.freeze)
		
		ball_queue.append(ball)
	
	if _get_debug_mode():
		print("[BallQueue] Queue initialized with ", ball_queue.size(), " balls")

func release_next_ball() -> RigidBody2D:
	"""Release the next ball from queue (called by GameManager on Down Arrow)"""
	return get_next_ball()

func get_next_ball() -> RigidBody2D:
	"""Get the next ball from the queue"""
	if _get_debug_mode():
		print("[BallQueue] get_next_ball() called, queue size: ", ball_queue.size())
	if ball_queue.is_empty():
		if _get_debug_mode():
			print("[BallQueue] Queue is empty!")
		queue_empty.emit()
		return null
	
	var ball = ball_queue.pop_front()
	if _get_debug_mode():
		print("[BallQueue] Retrieved ball from queue, remaining: ", ball_queue.size())
	
	# Position ball at maze pipe entrance area FIRST (before enabling physics)
	# Ball should start ABOVE the launcher/maze entry point so it can fall into the maze pipe
	# Maze pipe entry point is at (720, 400), so ball starts higher (y=100-150) to fall through maze
	var maze_entry_pos = Vector2(720, 150)  # Start above maze entry to fall into maze pipe
	
	# Set initial position and reset ball state
	ball.initial_position = maze_entry_pos
	if ball.has_method("reset_ball"):
		ball.reset_ball()
	else:
		# Fallback: manually set position if reset_ball doesn't exist
		ball.global_position = maze_entry_pos
	
	# Re-enable physics for the ball AFTER positioning
	ball.gravity_scale = 1.0
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.sleeping = false
	ball.freeze = false
	ball.modulate = Color(1, 1, 1, 1)  # Full opacity
	
	if _get_debug_mode():
		print("[BallQueue] Ball released at position: ", ball.global_position, ", freeze: ", ball.freeze, ", gravity: ", ball.gravity_scale)
	
	# Update positions of remaining balls in queue
	update_queue_positions()
	
	ball_ready.emit(ball)
	return ball

func return_ball_to_queue(ball: RigidBody2D):
	"""Return a ball to the queue (if it wasn't lost)"""
	if not ball or not is_instance_valid(ball):
		return
	
	# Reset ball state
	ball.gravity_scale = 0.0
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0.0
	ball.sleeping = true
	ball.freeze = true
	ball.modulate = Color(1, 1, 1, 0.8)
	
	# Add to back of queue
	ball_queue.append(ball)
	update_queue_positions()

func update_queue_positions():
	"""Update visual positions of balls in queue"""
	for i in range(ball_queue.size()):
		var queue_offset = queue_direction * i * queue_spacing
		ball_queue[i].global_position = queue_position + queue_offset

func has_balls() -> bool:
	"""Check if queue has any balls"""
	return not ball_queue.is_empty()

func get_queue_count() -> int:
	"""Get number of balls remaining in queue"""
	return ball_queue.size()

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "VisualLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", Color(0, 1, 1, 1))  # Cyan
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-60, -20)  # Offset from center
	add_child(label)

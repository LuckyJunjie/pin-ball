extends Node2D

## Ball Queue script for pinball game
## Manages a queue of standby balls

signal ball_ready(ball: RigidBody2D)
signal queue_empty

@export var ball_scene: PackedScene = null
@export var queue_size: int = 4
@export var infinite_balls: bool = true  # Development mode: infinite balls
@export var queue_spacing: float = 25.0
@export var queue_position: Vector2 = Vector2(400, 100)  # Positioned above launcher
@export var queue_direction: Vector2 = Vector2(0, -1)  # Vertical stack (upward)

var ball_queue: Array[RigidBody2D] = []
var active_ball: RigidBody2D = null

func _ready():
	print("[BallQueue] _ready() called")
	print("[BallQueue] Global position: ", global_position)
	print("[BallQueue] Position: ", position)
	print("[BallQueue] Visible: ", visible)
	print("[BallQueue] Queue position: ", queue_position)
	print("[BallQueue] Ball scene: ", ball_scene)
	print("[BallQueue] Queue size: ", queue_size)
	
	# Initialize queue with balls
	initialize_queue()
	
	print("[BallQueue] _ready() completed")

func initialize_queue():
	"""Initialize the queue with standby balls"""
	print("[BallQueue] initialize_queue() called")
	if not ball_scene:
		push_error("Ball scene not set in BallQueue!")
		print("[BallQueue] ERROR: Ball scene is null!")
		return
	
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
		print("[BallQueue] Ball ", i, " - visible: ", ball.visible, ", modulate: ", ball.modulate, ", freeze: ", ball.freeze)
		
		ball_queue.append(ball)
	
	print("[BallQueue] Queue initialized with ", ball_queue.size(), " balls")
	print("[BallQueue] BallQueue global position: ", global_position)
	print("[BallQueue] All children: ", get_children())
	
	# Check viewport and scene tree info
	var viewport = get_viewport()
	if viewport:
		print("[BallQueue] Viewport size: ", viewport.get_visible_rect().size)
		print("[BallQueue] Viewport visible rect: ", viewport.get_visible_rect())
	
	print("[BallQueue] Is in scene tree: ", is_inside_tree())
	print("[BallQueue] Scene tree path: ", get_path() if is_inside_tree() else "Not in tree")
	
	# Check if queue position is within viewport
	if viewport:
		var visible_rect = viewport.get_visible_rect()
		print("[BallQueue] Queue position (", queue_position, ") is within viewport: ", visible_rect.has_point(queue_position))
		print("[BallQueue] Viewport bounds: ", visible_rect)
	
	# Add visual label
	add_visual_label("BALL QUEUE")

func get_next_ball() -> RigidBody2D:
	"""Get the next ball from the queue"""
	print("[BallQueue] get_next_ball() called, queue size: ", ball_queue.size())
	if ball_queue.is_empty():
		print("[BallQueue] Queue is empty!")
		queue_empty.emit()
		return null
	
	var ball = ball_queue.pop_front()
	print("[BallQueue] Retrieved ball from queue, remaining: ", ball_queue.size())
	
	# Re-enable physics for the ball
	ball.gravity_scale = 1.0
	ball.freeze = false
	ball.modulate = Color(1, 1, 1, 1)  # Full opacity
	
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

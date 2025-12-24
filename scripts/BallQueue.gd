extends Node2D

## Ball Queue script for pinball game
## Manages a queue of standby balls

signal ball_ready(ball: RigidBody2D)
signal queue_empty

@export var ball_scene: PackedScene = null
@export var queue_size: int = 4
@export var queue_spacing: float = 25.0
@export var queue_position: Vector2 = Vector2(750, 300)
@export var queue_direction: Vector2 = Vector2(0, -1)  # Vertical stack (upward)

var ball_queue: Array[RigidBody2D] = []
var active_ball: RigidBody2D = null

func _ready():
	# Initialize queue with balls
	initialize_queue()

func initialize_queue():
	"""Initialize the queue with standby balls"""
	if not ball_scene:
		push_error("Ball scene not set in BallQueue!")
		return
	
	# Create balls for the queue
	for i in range(queue_size):
		var ball = ball_scene.instantiate()
		add_child(ball)
		
		# Position balls in queue (stacked vertically)
		var queue_offset = queue_direction * i * queue_spacing
		ball.global_position = queue_position + queue_offset
		
		# Disable physics for queued balls (they're just visual)
		ball.gravity_scale = 0.0
		ball.linear_velocity = Vector2.ZERO
		ball.angular_velocity = 0.0
		ball.sleeping = true
		ball.freeze = true
		
		# Make queued balls slightly transparent (but visible)
		ball.modulate = Color(1, 1, 1, 0.8)
		
		ball_queue.append(ball)

func get_next_ball() -> RigidBody2D:
	"""Get the next ball from the queue"""
	if ball_queue.is_empty():
		queue_empty.emit()
		return null
	
	var ball = ball_queue.pop_front()
	
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

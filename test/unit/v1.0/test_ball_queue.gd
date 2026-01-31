extends GutTest

## v1.0: Ball Queue System Tests
## Tests ball queue management and ball release

var ball_queue_instance: Node2D
var ball_scene: PackedScene

func before_each():
	# Load ball scene
	ball_scene = load("res://scenes/Ball.tscn")
	assert_not_null(ball_scene, "Ball scene should load")
	
	# Create BallQueue instance
	var script = load("res://scripts/BallQueue.gd")
	ball_queue_instance = Node2D.new()
	ball_queue_instance.set_script(script)
	ball_queue_instance.ball_scene = ball_scene
	ball_queue_instance.queue_size = 4
	add_child_autofree(ball_queue_instance)

func test_ball_queue_initialization():
	"""Test ball queue initializes with correct number of balls"""
	ball_queue_instance.initialize_queue()
	
	assert_eq(ball_queue_instance.get_queue_count(), 4, "Queue should have 4 balls")
	assert_true(ball_queue_instance.has_balls(), "Queue should have balls")

func test_ball_queue_release():
	"""Test releasing ball from queue"""
	ball_queue_instance.initialize_queue()
	var initial_count = ball_queue_instance.get_queue_count()
	
	var ball = ball_queue_instance.release_next_ball()
	
	assert_not_null(ball, "Released ball should not be null")
	assert_eq(ball_queue_instance.get_queue_count(), initial_count - 1, "Queue count should decrease")
	assert_false(ball.freeze, "Released ball should not be frozen")
	assert_eq(ball.gravity_scale, 1.0, "Released ball should have gravity")

func test_ball_queue_empty():
	"""Test queue empty signal"""
	watch_signals(ball_queue_instance)
	
	# Release all balls
	ball_queue_instance.initialize_queue()
	for i in range(4):
		ball_queue_instance.release_next_ball()
	
	# Try to get another ball (should emit signal)
	var ball = ball_queue_instance.get_next_ball()
	
	assert_null(ball, "Should return null when queue is empty")
	assert_signal_emitted(ball_queue_instance, "queue_empty", "Should emit queue_empty signal")

func test_ball_queue_positions():
	"""Test balls are positioned correctly in queue"""
	ball_queue_instance.initialize_queue()
	
	var first_ball = ball_queue_instance.ball_queue[0]
	var expected_pos = ball_queue_instance.queue_position
	
	assert_almost_eq(first_ball.global_position.x, expected_pos.x, 1.0, "First ball X position should match")
	assert_almost_eq(first_ball.global_position.y, expected_pos.y, 1.0, "First ball Y position should match")

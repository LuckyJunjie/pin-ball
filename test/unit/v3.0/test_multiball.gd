extends GutTest

## v3.0: Multiball System Tests
## Tests multiball activation, management, and scoring

var multiball_manager: Node
var ball_queue: Node2D

func before_each():
	# Create BallQueue
	var ball_queue_script = load("res://scripts/BallQueue.gd")
	ball_queue = Node2D.new()
	ball_queue.set_script(ball_queue_script)
	ball_queue.ball_scene = load("res://scenes/Ball.tscn")
	ball_queue.queue_size = 10
	ball_queue.initialize_queue()
	add_child_autofree(ball_queue)
	
	# Create MultiballManager
	var script = load("res://scripts/MultiballManager.gd")
	multiball_manager = Node.new()
	multiball_manager.set_script(script)
	multiball_manager.ball_queue = ball_queue
	multiball_manager.multiball_ball_count = 3
	add_child_autofree(multiball_manager)

func test_multiball_initialization():
	"""Test multiball manager initializes correctly"""
	assert_not_null(multiball_manager, "MultiballManager should exist")
	assert_false(multiball_manager.is_active, "Multiball should start inactive")

func test_multiball_activation():
	"""Test multiball activation"""
	watch_signals(multiball_manager)
	
	await multiball_manager.activate_multiball()
	
	assert_true(multiball_manager.is_active, "Multiball should be active")
	assert_signal_emitted(multiball_manager, "multiball_activated", "Should emit multiball_activated signal")
	assert_gt(multiball_manager.active_balls.size(), 0, "Should have active balls")

func test_multiball_scoring_multiplier():
	"""Test multiball scoring multiplier"""
	multiball_manager.is_active = true
	var multiplier = multiball_manager.get_scoring_multiplier()
	
	assert_eq(multiplier, 1.5, "Should return multiball multiplier when active")
	
	multiball_manager.is_active = false
	multiplier = multiball_manager.get_scoring_multiplier()
	
	assert_eq(multiplier, 1.0, "Should return 1.0 when inactive")

func test_multiball_end():
	"""Test multiball ending"""
	watch_signals(multiball_manager)
	
	multiball_manager.is_active = true
	multiball_manager.active_balls.clear()  # Simulate all balls lost
	multiball_manager._process(0.016)
	
	assert_false(multiball_manager.is_active, "Multiball should end when all balls lost")
	assert_signal_emitted(multiball_manager, "multiball_ended", "Should emit multiball_ended signal")

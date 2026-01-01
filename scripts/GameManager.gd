extends Node2D

## Game Manager for pinball game
## Handles game state, scoring, ball spawning, and integrates launcher/queue systems

signal score_changed(new_score: int)

@export var ball_scene: PackedScene
@export var ball_spawn_position: Vector2 = Vector2(400, 600)
@export var launch_force: Vector2 = Vector2(0, -500)

var current_ball: RigidBody2D = null
var score: int = 0
var is_paused: bool = false
var ball_queue: Node2D = null
var launcher: Node2D = null

func _ready():
	print("[GameManager] _ready() called")
	print("[GameManager] Global position: ", global_position)
	print("[GameManager] Position: ", position)
	
	# Add to group for easy access
	add_to_group("game_manager")
	
	# Find ball queue and launcher in scene
	print("[GameManager] Looking for BallQueue at path: ../BallQueue")
	ball_queue = get_node_or_null("../BallQueue")
	print("[GameManager] Looking for Launcher at path: ../Launcher")
	launcher = get_node_or_null("../Launcher")
	
	if not ball_queue:
		push_warning("BallQueue not found in scene!")
		print("[GameManager] ERROR: BallQueue not found!")
		print("[GameManager] Available children of parent: ", get_parent().get_children() if get_parent() else "No parent")
	else:
		print("[GameManager] BallQueue found!")
		print("[GameManager] BallQueue global position: ", ball_queue.global_position)
		print("[GameManager] BallQueue position: ", ball_queue.position)
		print("[GameManager] BallQueue visible: ", ball_queue.visible)
	
	if not launcher:
		push_warning("Launcher not found in scene!")
		print("[GameManager] ERROR: Launcher not found!")
		print("[GameManager] Available children of parent: ", get_parent().get_children() if get_parent() else "No parent")
	else:
		print("[GameManager] Launcher found!")
		print("[GameManager] Launcher global position: ", launcher.global_position)
		print("[GameManager] Launcher position: ", launcher.position)
		print("[GameManager] Launcher visible: ", launcher.visible)
	
	# Connect ball queue signals
	if ball_queue:
		print("[GameManager] Connecting BallQueue signals")
		ball_queue.ball_ready.connect(_on_ball_ready)
		ball_queue.queue_empty.connect(_on_queue_empty)
		# Set ball scene in queue
		ball_queue.ball_scene = ball_scene
		print("[GameManager] Ball scene set in queue: ", ball_scene)
	
	# Connect launcher signals
	if launcher:
		print("[GameManager] Connecting Launcher signals")
		launcher.ball_launched.connect(_on_ball_launched)
	
	# Connect obstacle hit signals
	connect_obstacle_signals()
	
	# Check viewport info
	var viewport = get_viewport()
	if viewport:
		print("[GameManager] Viewport size: ", viewport.get_visible_rect().size)
		print("[GameManager] Viewport visible rect: ", viewport.get_visible_rect())
		var camera = viewport.get_camera_2d()
		if camera:
			print("[GameManager] Camera found at: ", camera.global_position, ", zoom: ", camera.zoom)
		else:
			print("[GameManager] No Camera2D found in viewport - this may cause visibility issues!")
			# Try to find camera in scene
			var camera_node = get_node_or_null("../Camera2D")
			if camera_node:
				print("[GameManager] Found Camera2D node at: ", camera_node.global_position)
			else:
				print("[GameManager] WARNING: No Camera2D in scene - objects may not be visible!")
	
	# Initialize with first ball
	print("[GameManager] Preparing first ball...")
	prepare_next_ball()
	print("[GameManager] _ready() completed")

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Esc key
		toggle_pause()

func prepare_next_ball():
	"""Prepare the next ball from queue - ball drops from queue position on right side"""
	print("[GameManager] prepare_next_ball() called")
	if not ball_queue:
		print("[GameManager] No ball_queue, using fallback spawn_ball()")
		# Fallback to old system
		spawn_ball()
		return
	
	print("[GameManager] BallQueue has balls: ", ball_queue.has_balls())
	if not ball_queue.has_balls():
		print("[GameManager] Queue has no balls, calling _on_queue_empty()")
		_on_queue_empty()
		return
	
	# Get next ball from queue
	var ball = ball_queue.get_next_ball()
	if ball:
		print("[GameManager] Got ball from queue, positioning at: ", ball_queue.queue_position)
		current_ball = ball
		# Position ball at queue location (right side) - it will fall naturally
		ball.global_position = ball_queue.queue_position
		ball.initial_position = ball_queue.queue_position
		# Reset ball state to ensure clean drop
		ball.reset_ball()
		# Connect ball lost signal
		ball.ball_lost.connect(_on_ball_lost)
		# Pass ball to launcher if launcher exists
		if launcher and launcher.has_method("set_ball"):
			# Wait a moment for ball to settle, then position at launcher
			await get_tree().create_timer(0.5).timeout
			if ball and is_instance_valid(ball):
				print("[GameManager] Positioning ball at launcher")
				# Pass ball to launcher - it will position it correctly
				launcher.set_ball(ball)
	else:
		_on_queue_empty()

func _on_ball_ready(ball: RigidBody2D):
	"""Called when a ball is ready from the queue"""
	current_ball = ball
	# Position ball at queue location - it will fall naturally
	if ball_queue:
		ball.global_position = ball_queue.queue_position
		ball.initial_position = ball_queue.queue_position
		ball.reset_ball()
	ball.ball_lost.connect(_on_ball_lost)
	# Pass ball to launcher if launcher exists
	if launcher and launcher.has_method("set_ball"):
		launcher.set_ball(ball)

func _on_ball_launched(_force: Vector2):
	"""Called when ball is launched from launcher"""
	print("[GameManager] Ball launched, preparing next ball after delay...")
	# Wait a bit then prepare next ball for launcher
	await get_tree().create_timer(2.0).timeout
	# Check if ball is still active, if not prepare next one
	if not current_ball or not is_instance_valid(current_ball):
		print("[GameManager] Current ball is gone, preparing next ball for launcher")
		prepare_next_ball()

func _on_ball_lost():
	"""Handle when ball is lost"""
	print("[GameManager] _on_ball_lost() called")
	if current_ball:
		print("[GameManager] Ball lost at position: ", current_ball.global_position)
		# Disconnect signal
		if current_ball.ball_lost.is_connected(_on_ball_lost):
			current_ball.ball_lost.disconnect(_on_ball_lost)
		
		# Remove ball
		if is_instance_valid(current_ball):
			print("[GameManager] Removing ball from scene")
			current_ball.queue_free()
		current_ball = null
	else:
		print("[GameManager] WARNING: _on_ball_lost() called but current_ball is null")
	
	# Wait a moment then prepare next ball
	print("[GameManager] Waiting 1 second before preparing next ball...")
	await get_tree().create_timer(1.0).timeout
	prepare_next_ball()

func _on_queue_empty():
	"""Handle when ball queue is empty"""
	print("[GameManager] Queue empty - refilling...")
	# Game over or refill queue
	# For development: always refill the queue (infinite balls)
	if ball_queue:
		if ball_queue.infinite_balls:
			print("[GameManager] Infinite balls enabled - refilling queue")
			ball_queue.initialize_queue()
			prepare_next_ball()
		else:
			# Game over logic would go here
			print("[GameManager] Game over - no more balls")

func connect_obstacle_signals():
	"""Connect all obstacle hit signals to scoring"""
	var obstacles = get_tree().get_nodes_in_group("obstacles")
	if obstacles.is_empty():
		# Find obstacles in ObstacleSpawner
		var spawner = get_node_or_null("../Playfield/ObstacleSpawner")
		if spawner:
			# Wait a frame for obstacles to spawn
			await get_tree().process_frame
			obstacles = spawner.get_children()
	
	for obstacle in obstacles:
		if obstacle.has_signal("obstacle_hit"):
			obstacle.obstacle_hit.connect(_on_obstacle_hit)

func _on_obstacle_hit(points: int):
	"""Handle obstacle hit and award points"""
	add_score(points)

func spawn_ball():
	"""Spawn a new ball at the spawn position (fallback method)"""
	if ball_scene:
		var ball_instance = ball_scene.instantiate()
		add_child(ball_instance)
		ball_instance.global_position = ball_spawn_position
		ball_instance.initial_position = ball_spawn_position
		ball_instance.ball_lost.connect(_on_ball_lost)
		current_ball = ball_instance

func launch_ball():
	"""Launch the current ball (fallback method if no launcher)"""
	if current_ball and not launcher:
		current_ball.launch_ball(launch_force)

func add_score(points: int):
	"""Add points to the score"""
	score += points
	score_changed.emit(score)

func reset_score():
	"""Reset the score"""
	score = 0
	score_changed.emit(score)

func toggle_pause():
	"""Toggle game pause state"""
	is_paused = !is_paused
	get_tree().paused = is_paused

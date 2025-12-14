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
	# Add to group for easy access
	add_to_group("game_manager")
	
	# Find ball queue and launcher in scene
	ball_queue = get_node_or_null("../BallQueue")
	launcher = get_node_or_null("../Launcher")
	
	if not ball_queue:
		push_warning("BallQueue not found in scene!")
	if not launcher:
		push_warning("Launcher not found in scene!")
	
	# Connect ball queue signals
	if ball_queue:
		ball_queue.ball_ready.connect(_on_ball_ready)
		ball_queue.queue_empty.connect(_on_queue_empty)
		# Set ball scene in queue
		ball_queue.ball_scene = ball_scene
	
	# Connect launcher signals
	if launcher:
		launcher.ball_launched.connect(_on_ball_launched)
	
	# Connect obstacle hit signals
	connect_obstacle_signals()
	
	# Initialize with first ball
	prepare_next_ball()

func _input(event):
	if event.is_action_pressed("ui_cancel"):  # Esc key
		toggle_pause()

func prepare_next_ball():
	"""Prepare the next ball from queue for launching"""
	if not ball_queue:
		# Fallback to old system
		spawn_ball()
		return
	
	if not ball_queue.has_balls():
		_on_queue_empty()
		return
	
	# Get next ball from queue
	var ball = ball_queue.get_next_ball()
	if ball:
		current_ball = ball
		# Set ball in launcher
		if launcher:
			launcher.set_ball(ball)
			# Connect ball lost signal
			ball.ball_lost.connect(_on_ball_lost)
	else:
		_on_queue_empty()

func _on_ball_ready(ball: RigidBody2D):
	"""Called when a ball is ready from the queue"""
	current_ball = ball
	if launcher:
		launcher.set_ball(ball)
	ball.ball_lost.connect(_on_ball_lost)

func _on_ball_launched(_force: Vector2):
	"""Called when ball is launched from launcher"""
	# Ball is now active, nothing special needed
	pass

func _on_ball_lost():
	"""Handle when ball is lost"""
	if current_ball:
		# Disconnect signal
		if current_ball.ball_lost.is_connected(_on_ball_lost):
			current_ball.ball_lost.disconnect(_on_ball_lost)
		
		# Remove ball
		if is_instance_valid(current_ball):
			current_ball.queue_free()
		current_ball = null
	
	# Wait a moment then prepare next ball
	await get_tree().create_timer(1.0).timeout
	prepare_next_ball()

func _on_queue_empty():
	"""Handle when ball queue is empty"""
	# Game over or refill queue
	# For now, just refill the queue
	if ball_queue:
		ball_queue.initialize_queue()
		prepare_next_ball()

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

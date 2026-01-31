extends Node

## v3.0: Multiball Mode Manager
## Manages multiple active balls simultaneously for high-scoring chaos

signal multiball_activated(ball_count: int)
signal multiball_ended()

@export var multiball_ball_count: int = 3  # Number of balls to release
@export var multiball_duration: float = 45.0  # Duration in seconds (or until all balls lost)
@export var scoring_multiplier: float = 1.5  # Score multiplier during multiball

var is_active: bool = false
var active_balls: Array[RigidBody2D] = []
var duration_timer: float = 0.0
var ball_queue: Node = null
var game_manager: Node = null

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	# Find dependencies
	ball_queue = get_tree().get_first_node_in_group("ball_queue")
	if not ball_queue:
		ball_queue = get_node_or_null("../BallQueue")
	if not ball_queue:
		# Try to find parent's BallQueue
		var parent = get_parent()
		if parent:
			ball_queue = parent.get_node_or_null("BallQueue")
	
	game_manager = get_tree().get_first_node_in_group("game_manager")
	if not game_manager:
		game_manager = get_node_or_null("../GameManager")
	if not game_manager:
		# Try to find parent (should be GameManager)
		var parent = get_parent()
		if parent and parent.has_method("add_score"):
			game_manager = parent
	
	add_to_group("multiball_manager")
	
	# v3.0: Connect to multiball targets
	_connect_multiball_targets()

func _process(delta):
	if is_active:
		duration_timer -= delta
		
		# Check if all balls are lost
		active_balls = active_balls.filter(func(ball): return is_instance_valid(ball) and ball.is_inside_tree())
		
		if active_balls.is_empty():
			end_multiball()
		elif duration_timer <= 0.0:
			end_multiball()

func activate_multiball():
	"""Activate multiball mode"""
	if is_active:
		return  # Already active
	
	is_active = true
	duration_timer = multiball_duration
	active_balls.clear()
	
	if _get_debug_mode():
		print("[MultiballManager] Activating multiball mode - ", multiball_ball_count, " balls")
	
	# Release multiple balls
	for i in range(multiball_ball_count):
		await get_tree().create_timer(0.2 * i).timeout  # Stagger releases
		_release_multiball_ball()
	
	multiball_activated.emit(multiball_ball_count)
	
	# Play multiball sound
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager and sound_manager.has_method("play_sound"):
		sound_manager.play_sound("multiball_activate")

func _release_multiball_ball():
	"""Release a ball for multiball mode"""
	if not ball_queue:
		return
	
	# Get ball from queue
	var ball = ball_queue.release_next_ball()
	if ball:
		ball.freeze = false
		ball.gravity_scale = 1.0
		ball.linear_velocity = Vector2.ZERO
		ball.angular_velocity = 0.0
		ball.sleeping = false
		
		# Add distinct visual (different color/trail)
		_set_multiball_visual(ball, active_balls.size())
		
		# Connect ball lost signal
		if ball.has_signal("ball_lost"):
			ball.ball_lost.connect(_on_multiball_ball_lost.bind(ball))
		
		active_balls.append(ball)
		
		if _get_debug_mode():
			print("[MultiballManager] Released multiball ball ", active_balls.size())

func _set_multiball_visual(ball: RigidBody2D, index: int):
	"""Set distinct visual for multiball ball"""
	# Different colors for each ball
	var colors = [
		Color(1.0, 0.2, 0.2, 1.0),  # Red
		Color(0.2, 1.0, 0.2, 1.0),  # Green
		Color(0.2, 0.2, 1.0, 1.0),  # Blue
		Color(1.0, 1.0, 0.2, 1.0),  # Yellow
	]
	
	var color = colors[index % colors.size()]
	
	# Apply color to ball visual
	var visual = ball.get_node_or_null("Visual")
	if visual:
		visual.modulate = color
	
	# Add trail effect (if trail system exists)
	var trail_manager = get_tree().get_first_node_in_group("trail_manager")
	if trail_manager and trail_manager.has_method("add_trail"):
		trail_manager.add_trail(ball, color)

func _on_multiball_ball_lost(ball: RigidBody2D):
	"""Handle when a multiball ball is lost"""
	if ball in active_balls:
		active_balls.erase(ball)
	
	if _get_debug_mode():
		print("[MultiballManager] Multiball ball lost, remaining: ", active_balls.size())

func end_multiball():
	"""End multiball mode"""
	if not is_active:
		return
	
	is_active = false
	
	if _get_debug_mode():
		print("[MultiballManager] Multiball mode ended")
	
	multiball_ended.emit()
	
	# Play end sound
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager and sound_manager.has_method("play_sound"):
		sound_manager.play_sound("multiball_end")

func is_multiball_active() -> bool:
	"""Check if multiball is currently active"""
	return is_active

func get_scoring_multiplier() -> float:
	"""Get current scoring multiplier"""
	return scoring_multiplier if is_active else 1.0

func _connect_multiball_targets():
	"""v3.0: Connect multiball target signals"""
	var targets = get_tree().get_nodes_in_group("multiball_targets")
	var hit_count = 0
	var required_hits = 3  # Activate multiball after 3 target hits
	
	for target in targets:
		if target and target.has_signal("multiball_target_hit"):
			target.multiball_target_hit.connect(_on_multiball_target_hit)
			if _get_debug_mode():
				print("[MultiballManager] Connected multiball target: ", target)
	
	if _get_debug_mode():
		print("[MultiballManager] Connected ", targets.size(), " multiball target(s)")

func _on_multiball_target_hit():
	"""Called when a multiball target is hit"""
	if _get_debug_mode():
		print("[MultiballManager] Multiball target hit!")
	
	# Check if we should activate multiball
	# For now, activate immediately on any target hit
	# Can be enhanced to require multiple targets
	if not is_active:
		activate_multiball()

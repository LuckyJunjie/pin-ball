extends Node2D

## Game Manager for pinball game
## Handles game state, scoring, ball spawning, and integrates launcher/queue systems

# v3.0: Preload system classes
const MultiballManager = preload("res://scripts/MultiballManager.gd")
const ComboSystem = preload("res://scripts/ComboSystem.gd")
const AnimationManager = preload("res://scripts/AnimationManager.gd")
const ParticleManager = preload("res://scripts/ParticleManager.gd")
const EnhancedParticleManager = preload("res://scripts/EnhancedParticleManager.gd")

signal score_changed(new_score: int)

@export var ball_scene: PackedScene
@export var ball_spawn_position: Vector2 = Vector2(400, 600)
@export var launch_force: Vector2 = Vector2(0, -500)
@export var debug_mode: bool = true  # Enable debug logging and visual labels (default: true)

var current_ball: RigidBody2D = null
var score: int = 0
var is_paused: bool = false
var ball_queue: Node2D = null
var launcher: Node2D = null
var sound_manager: Node = null
var game_version: String = "v1.x"  # v1.x, v2.0, or v3.0
var is_v2_mode: bool = false
var is_v3_mode: bool = false

# v3.0: New systems
var multiball_manager: Node = null
var combo_system: Node = null
var animation_manager: Node = null
var current_multiplier: float = 1.0
var multiplier_timer: float = 0.0
var obstacle_hit_count: int = 0
var skill_shots: Array[Node] = []

func _ready():
	if debug_mode:
		print("[GameManager] _ready() called")
		print("[GameManager] Global position: ", global_position)
		print("[GameManager] Position: ", position)
	
	# Add to group for easy access
	add_to_group("game_manager")
	
	# Check game version from GlobalGameSettings
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		game_version = global_settings.game_version
		is_v2_mode = (game_version == "v2.0" or game_version == "v3.0")
		is_v3_mode = (game_version == "v3.0")
		if debug_mode:
			print("[GameManager] Game version: ", game_version, " (v2.0 mode: ", is_v2_mode, ", v3.0 mode: ", is_v3_mode, ")")
	
	# Find ball queue and launcher in scene
	if debug_mode:
		print("[GameManager] Looking for BallQueue at path: ../BallQueue")
	ball_queue = get_node_or_null("../BallQueue")
	if debug_mode:
		print("[GameManager] Looking for Launcher at path: ../Launcher")
	launcher = get_node_or_null("../Launcher")
	
	if not ball_queue:
		push_warning("BallQueue not found in scene!")
		if debug_mode:
			print("[GameManager] ERROR: BallQueue not found!")
			var parent_info = str(get_parent().get_children()) if get_parent() else "No parent"
			print("[GameManager] Available children of parent: ", parent_info)
	else:
		if debug_mode:
			print("[GameManager] BallQueue found!")
			print("[GameManager] BallQueue global position: ", ball_queue.global_position)
			print("[GameManager] BallQueue position: ", ball_queue.position)
			print("[GameManager] BallQueue visible: ", ball_queue.visible)
	
	if not launcher:
		push_warning("Launcher not found in scene!")
		if debug_mode:
			print("[GameManager] ERROR: Launcher not found!")
			var parent_info = str(get_parent().get_children()) if get_parent() else "No parent"
			print("[GameManager] Available children of parent: ", parent_info)
	else:
		if debug_mode:
			print("[GameManager] Launcher found!")
			print("[GameManager] Launcher global position: ", launcher.global_position)
			print("[GameManager] Launcher position: ", launcher.position)
			print("[GameManager] Launcher visible: ", launcher.visible)
	
	# Connect ball queue signals
	if ball_queue:
		if debug_mode:
			print("[GameManager] Connecting BallQueue signals")
		ball_queue.ball_ready.connect(_on_ball_ready)
		ball_queue.queue_empty.connect(_on_queue_empty)
		# Set ball scene in queue
		ball_queue.ball_scene = ball_scene
		if debug_mode:
			print("[GameManager] Ball scene set in queue: ", ball_scene)
	
	# Connect launcher signals
	if launcher:
		if debug_mode:
			print("[GameManager] Connecting Launcher signals")
		launcher.ball_launched.connect(_on_ball_launched)
	
	# Connect obstacle hit signals
	connect_obstacle_signals()
	
	# Connect hold signals
	connect_hold_signals()
	
	# Find sound manager
	sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if not sound_manager:
		sound_manager = get_node_or_null("../SoundManager")
	if sound_manager and debug_mode:
		print("[GameManager] SoundManager found")
	elif not sound_manager and debug_mode:
		print("[GameManager] SoundManager not found - sounds will be disabled")
	
	# v3.0: Initialize new systems only if v3.0 mode (defer to avoid issues)
	if is_v3_mode:
		call_deferred("_initialize_v3_systems")
	
	# Check viewport info
	if debug_mode:
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
	
	# Initialize with first ball (will be removed, wait for release instead)
	# prepare_next_ball()  # Commented out - wait for ball release
	if debug_mode:
		print("[GameManager] _ready() completed, waiting for ball release")

func _initialize_v3_systems():
	"""v3.0: Initialize new game systems"""
	# Create multiball manager
	multiball_manager = MultiballManager.new()
	multiball_manager.name = "MultiballManager"
	add_child(multiball_manager)
	if multiball_manager.has_signal("multiball_activated"):
		multiball_manager.multiball_activated.connect(_on_multiball_activated)
	if multiball_manager.has_signal("multiball_ended"):
		multiball_manager.multiball_ended.connect(_on_multiball_ended)
	
	# Create combo system
	combo_system = ComboSystem.new()
	combo_system.name = "ComboSystem"
	add_child(combo_system)
	if combo_system.has_signal("combo_increased"):
		combo_system.combo_increased.connect(_on_combo_increased)
	
	# Create animation manager
	animation_manager = AnimationManager.new()
	animation_manager.name = "AnimationManager"
	add_child(animation_manager)
	
	# Create enhanced particle manager (uses EnhancedParticleManager if available)
	var particle_manager = EnhancedParticleManager.new()
	particle_manager.name = "ParticleManager"
	add_child(particle_manager)
	
	# Find and connect skill shots (may not exist yet, will be found when ball launches)
	# Connect skill shot signals when they're found
	_connect_skill_shot_signals()
	
	if debug_mode:
		print("[GameManager] v3.0 systems initialized")

func _connect_skill_shot_signals():
	"""v3.0: Connect skill shot signals to GameManager"""
	# Find all skill shots in the scene
	skill_shots = get_tree().get_nodes_in_group("skill_shots")
	
	for skill_shot in skill_shots:
		if skill_shot and skill_shot.has_signal("skill_shot_hit"):
			if not skill_shot.skill_shot_hit.is_connected(_on_skill_shot_hit):
				skill_shot.skill_shot_hit.connect(_on_skill_shot_hit)
				if debug_mode:
					print("[GameManager] Connected skill shot signal: ", skill_shot)
	
	if debug_mode:
		print("[GameManager] Connected ", skill_shots.size(), " skill shot(s)")

func _input(event):
	# Only process key events (ignore mouse movement, etc.)
	if not event is InputEventKey:
		return
	
	if event.is_action("ui_cancel") and event.pressed:  # Esc key
		toggle_pause()
	
	# Check for Down Arrow key press (ui_down action)
	if event.is_action("ui_down") and event.pressed and not event.is_echo():
		if debug_mode:
			print("[GameManager] Down Arrow pressed - releasing ball from queue")
		release_ball_from_queue()

func release_ball_from_queue():
	"""Handle Down Arrow input to release ball from queue"""
	if debug_mode:
		print("[GameManager] release_ball_from_queue() called")
	if not ball_queue:
		if debug_mode:
			print("[GameManager] No ball_queue available")
		return
	
	if not ball_queue.has_balls():
		if debug_mode:
			print("[GameManager] Queue has no balls")
		return
	
	# Only release if we don't already have an active ball
	# Check if current_ball is valid and still in the scene tree
	if current_ball:
		if is_instance_valid(current_ball) and is_instance_valid(current_ball.get_parent()):
			if debug_mode:
				print("[GameManager] Ball already active at position: ", current_ball.global_position, ", ignoring release request")
			return
		else:
			# Ball reference is invalid, clear it
			if debug_mode:
				print("[GameManager] Clearing invalid current_ball reference")
			current_ball = null
	
	# Release ball from queue
	var ball = ball_queue.release_next_ball()
	if ball:
		if debug_mode:
			print("[GameManager] Ball released from queue at position: ", ball.global_position)
		current_ball = ball
		# Ball position is already set to launcher/pipe entry (720, 400) in BallQueue.get_next_ball()
		# Ensure ball is unfrozen and can fall
		ball.freeze = false
		ball.gravity_scale = 1.0
		ball.linear_velocity = Vector2.ZERO
		ball.angular_velocity = 0.0
		ball.sleeping = false
		ball.ball_lost.connect(_on_ball_lost)
		
		if debug_mode:
			print("[GameManager] Ball unfrozen, will fall through curved pipe")
		
		# Ball will fall through curved pipe: up -> left -> center -> down to flippers

func prepare_next_ball():
	"""Prepare the next ball from queue - ball drops from queue position on right side"""
	if debug_mode:
		print("[GameManager] prepare_next_ball() called")
	if not ball_queue:
		if debug_mode:
			print("[GameManager] No ball_queue, using fallback spawn_ball()")
		# Fallback to old system
		spawn_ball()
		return
	
	if debug_mode:
		print("[GameManager] BallQueue has balls: ", ball_queue.has_balls())
	if not ball_queue.has_balls():
		if debug_mode:
			print("[GameManager] Queue has no balls, calling _on_queue_empty()")
		_on_queue_empty()
		return
	
	# Get next ball from queue
	var ball = ball_queue.get_next_ball()
	if ball:
		if debug_mode:
			print("[GameManager] Got ball from queue, positioning at: ", ball_queue.queue_position)
		current_ball = ball
		# Ball is already positioned by BallQueue at pipe entry (720, 100)
		# Ball will fall through curved pipe: up -> left -> center -> down to flippers
		# No need to position at launcher - ball goes directly through curved pipe
		# Reset ball state to ensure clean drop
		ball.reset_ball()
		# Connect ball lost signal
		ball.ball_lost.connect(_on_ball_lost)
	else:
		_on_queue_empty()

func _on_ball_ready(ball: RigidBody2D):
	"""Called when a ball is ready from the queue"""
	current_ball = ball
	# Ball is already positioned by BallQueue at pipe entry
	# Ball will fall through curved pipe: up -> left -> center -> down to flippers
	# Players can hit or miss the ball as it falls
	ball.reset_ball()
	ball.ball_lost.connect(_on_ball_lost)

func _on_ball_launched(_force: Vector2):
	"""Called when ball is launched from launcher"""
	if debug_mode:
		print("[GameManager] Ball launched")
	play_sound("ball_launch")
	# Ball is now in playfield
	
	# v3.0: Activate skill shots
	if skill_shots.is_empty():
		skill_shots = get_tree().get_nodes_in_group("skill_shots")
		# Connect signals if not already connected
		_connect_skill_shot_signals()
	for skill_shot in skill_shots:
		if skill_shot and skill_shot.has_method("activate"):
			skill_shot.activate()

func _on_ball_lost():
	"""Handle when ball is lost"""
	if debug_mode:
		print("[GameManager] _on_ball_lost() called")
	play_sound("ball_lost")
	if current_ball:
		if debug_mode:
			print("[GameManager] Ball lost at position: ", current_ball.global_position)
		# Disconnect signal
		if current_ball.ball_lost.is_connected(_on_ball_lost):
			current_ball.ball_lost.disconnect(_on_ball_lost)
		
		# Remove ball
		if is_instance_valid(current_ball):
			if debug_mode:
				print("[GameManager] Removing ball from scene")
			current_ball.queue_free()
		current_ball = null
	else:
		if debug_mode:
			print("[GameManager] WARNING: _on_ball_lost() called but current_ball is null")
	
	# Wait a moment then ready for next ball release (no auto-prepare)
	if debug_mode:
		print("[GameManager] Waiting 1 second, then ready for next ball release...")
	await get_tree().create_timer(1.0).timeout
	# Don't auto-prepare - wait for player to press Down Arrow

func _on_queue_empty():
	"""Handle when ball queue is empty"""
	if debug_mode:
		print("[GameManager] Queue empty - refilling...")
	# Game over or refill queue
	# For development: always refill the queue (infinite balls)
	if ball_queue:
		if ball_queue.infinite_balls:
			if debug_mode:
				print("[GameManager] Infinite balls enabled - refilling queue")
			ball_queue.initialize_queue()
			# Don't auto-prepare - wait for player to press Down Arrow
		else:
			# Game over logic would go here
			if debug_mode:
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

func connect_hold_signals():
	"""Connect all hold entry signals to scoring"""
	var holds = get_tree().get_nodes_in_group("holds")
	if holds.is_empty():
		# Find holds in HoldSpawner or Playfield
		var spawner = get_node_or_null("../Playfield/HoldSpawner")
		if spawner:
			await get_tree().process_frame
			holds = spawner.get_children()
		else:
			# Try to find holds directly in Playfield
			var playfield = get_node_or_null("../Playfield")
			if playfield:
				holds = playfield.get_children().filter(func(child): return child.has_signal("hold_entered"))
	
	for hold in holds:
		if hold.has_signal("hold_entered"):
			hold.hold_entered.connect(_on_hold_entered)
			if debug_mode:
				print("[GameManager] Connected hold signal: ", hold)

func _on_obstacle_hit(points: int):
	"""Handle obstacle hit and award points"""
	play_sound("obstacle_hit")
	
	# v3.0: Register combo hit
	if combo_system:
		combo_system.register_hit()
	
	# v3.0: Apply multipliers
	var final_points = points
	if multiball_manager and multiball_manager.is_multiball_active():
		final_points = int(final_points * multiball_manager.get_scoring_multiplier())
	if combo_system:
		final_points = int(final_points * combo_system.get_combo_multiplier())
	if current_multiplier > 1.0:
		final_points = int(final_points * current_multiplier)
	
	add_score(final_points)
	
	# v3.0: Update multiplier system
	obstacle_hit_count += 1
	_update_multiplier()
	
	# v3.0: Animate score popup
	if animation_manager and current_ball:
		animation_manager.animate_score_popup(
			current_ball.global_position + Vector2(0, -30),
			final_points,
			Color.YELLOW if current_multiplier > 1.0 else Color.WHITE
		)
	
	# v2.0: Award coins for obstacle hits (1 coin per 100 points)
	if is_v2_mode:
		var coins_to_award = final_points / 100
		if coins_to_award > 0:
			var currency_mgr = get_node_or_null("/root/CurrencyManager")
			if currency_mgr:
				currency_mgr.add_coins(coins_to_award)
				if debug_mode:
					print("[GameManager] Awarded ", coins_to_award, " coins for obstacle hit")

func _on_hold_entered(points: int):
	"""Handle hold entry and award final scoring - ball round finished"""
	if debug_mode:
		print("[GameManager] Hold entered - ball captured, awarding ", points, " points (final scoring)")
	
	# Calculate and award score first (before ball removal)
	play_sound("hold_entry")
	add_score(points)
	
	# v2.0: Award bonus coins for hold entry (points / 10)
	if is_v2_mode:
		var coins_to_award = points / 10
		if coins_to_award > 0:
			var currency_mgr = get_node_or_null("/root/CurrencyManager")
			if currency_mgr:
				currency_mgr.add_coins(coins_to_award)
				if debug_mode:
					print("[GameManager] Awarded ", coins_to_award, " bonus coins for hold entry")
	
	# Brief delay for visual feedback (ball captured, score displayed)
	if debug_mode:
		print("[GameManager] Ball round finished - waiting 0.5s for visual feedback...")
	await get_tree().create_timer(0.5).timeout
	
	# Remove captured ball and prepare for next release
	if current_ball:
		if current_ball.ball_lost.is_connected(_on_ball_lost):
			current_ball.ball_lost.disconnect(_on_ball_lost)
		if is_instance_valid(current_ball):
			current_ball.queue_free()
		current_ball = null
	
	# Wait a moment then ready for next ball release
	if debug_mode:
		print("[GameManager] Waiting 1 second, then ready for next ball release...")
	await get_tree().create_timer(1.0).timeout
	# Don't auto-prepare - wait for player to press Down Arrow

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
	if debug_mode:
		print("[GameManager] Score changed: ", score, " (+", points, ")")
	score_changed.emit(score)

func play_sound(sound_name: String):
	"""Play a sound effect via SoundManager"""
	if sound_manager and sound_manager.has_method("play_sound"):
		sound_manager.play_sound(sound_name)

func reset_score():
	"""Reset the score"""
	score = 0
	score_changed.emit(score)

func toggle_pause():
	"""Toggle game pause state"""
	is_paused = !is_paused
	get_tree().paused = is_paused

# v3.0: New methods for v3.0 systems

func _on_skill_shot_hit(points: int):
	"""Handle skill shot hit"""
	if debug_mode:
		print("[GameManager] Skill shot hit! ", points, " points")
	
	# Apply multipliers
	var final_points = points
	if multiball_manager and multiball_manager.is_multiball_active():
		final_points = int(final_points * multiball_manager.get_scoring_multiplier())
	if current_multiplier > 1.0:
		final_points = int(final_points * current_multiplier)
	
	add_score(final_points)
	
	# Animate score popup
	if animation_manager and current_ball:
		animation_manager.animate_score_popup(
			current_ball.global_position + Vector2(0, -30),
			final_points,
			Color.CYAN
		)
	
	play_sound("skill_shot")

func _on_multiball_activated(ball_count: int):
	"""Handle multiball activation"""
	if debug_mode:
		print("[GameManager] Multiball activated with ", ball_count, " balls")
	
	# Screen shake effect
	var camera = get_viewport().get_camera_2d()
	if camera and animation_manager:
		animation_manager.screen_shake(camera, 10.0, 0.5)

func _on_multiball_ended():
	"""Handle multiball end"""
	if debug_mode:
		print("[GameManager] Multiball ended")

func _on_combo_increased(combo_count: int, multiplier: float):
	"""Handle combo increase"""
	if debug_mode:
		print("[GameManager] Combo: ", combo_count, " hits, multiplier: ", multiplier, "x")

func _update_multiplier():
	"""Update dynamic multiplier based on obstacle hits"""
	# Increase multiplier every 5 hits
	if obstacle_hit_count % 5 == 0:
		current_multiplier += 0.5
		if current_multiplier > 10.0:
			current_multiplier = 10.0
		
		multiplier_timer = 10.0  # Reset decay timer
		
		if debug_mode:
			print("[GameManager] Multiplier increased to ", current_multiplier, "x")
		
		# Visual feedback
		if animation_manager:
			var ui = get_tree().get_first_node_in_group("ui")
			if ui:
				var multiplier_label = ui.get_node_or_null("MultiplierLabel")
				if multiplier_label:
					animation_manager.animate_component_highlight(multiplier_label, Color.GREEN, 0.3)

func _process(_delta):
	"""v3.0: Process multiplier decay"""
	if current_multiplier > 1.0:
		multiplier_timer -= _delta
		if multiplier_timer <= 0.0:
			current_multiplier = max(1.0, current_multiplier - 0.5)
			multiplier_timer = 10.0
			if debug_mode:
				print("[GameManager] Multiplier decayed to ", current_multiplier, "x")

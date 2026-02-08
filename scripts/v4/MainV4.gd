extends Node2D
## v4.0 Main game scene: wires GameManagerV4 to Balls/Launcher, BackboxManagerV4, camera.

var _camera: Camera2D = null

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	if not gm:
		return
	_camera = get_node_or_null("Camera2D")
	var balls_node = get_node_or_null("Balls")
	var launcher_node = get_node_or_null("Launcher")
	if balls_node:
		gm.balls_container = balls_node
	if launcher_node:
		gm.launcher_node = launcher_node
		gm.launcher_spawn_position = launcher_node.global_position + Vector2(-3, -35)
	var ball_scene = load("res://scenes/Ball.tscn") as PackedScene
	if ball_scene:
		gm.ball_scene = ball_scene
	# Ensure BallPoolV4 is initialized before start_game (scene transition may have skipped init)
	if gm.has_method("_ensure_ball_pool_initialized"):
		gm._ensure_ball_pool_initialized()
	# Bonus ball: Flutter (29.2, -24.5) impulse (-40, 0) via CoordinateConverterV4
	gm.bonus_ball_spawn_position = CoordinateConverterV4.flutter_to_godot(Vector2(29.2, -24.5))
	gm.bonus_ball_impulse = CoordinateConverterV4.flutter_impulse_to_godot(Vector2(-40, 0))
	
	# Zones are already in the scene (Playfield/Zones); no dynamic loading to avoid duplicates
	
	# Set character theme from BackboxManagerV4
	var backbox = get_node_or_null("/root/BackboxManagerV4")
	if backbox:
		var theme_key = backbox.selected_character_key
		if gm.has_method("set_character_theme"):
			gm.set_character_theme(theme_key)
	
	var back_btn = get_node_or_null("UI/BackToMenuButton")
	if back_btn and back_btn is BaseButton:
		back_btn.pressed.connect(_on_back_to_menu)
	if gm.has_signal("game_over"):
		gm.game_over.connect(_on_game_over)
	if gm.has_signal("game_started"):
		gm.game_started.connect(_on_game_started)
	_connect_obstacles()
	_apply_camera_status(gm.status)
	# Release UI focus so Space/Down/S reach the launcher, not buttons
	get_viewport().gui_release_focus()
	# Defer start_game so BallPoolV4 has time to initialize (it uses call_deferred)
	call_deferred("_deferred_start_game")


func _deferred_start_game() -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm and gm.has_method("start_game"):
		gm.start_game()

func _on_game_started() -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm:
		_apply_camera_status(gm.status)


func _on_game_over() -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	var backbox = get_node_or_null("/root/BackboxManagerV4")
	if gm and backbox and backbox.has_method("request_initials"):
		backbox.request_initials(gm.display_score(), backbox.selected_character_key)
	_apply_camera_status(GameManagerV4.Status.GAME_OVER)

func _connect_obstacles() -> void:
	var obstacles = get_tree().get_nodes_in_group("obstacles")
	for obs in obstacles:
		if obs.has_signal("obstacle_hit"):
			obs.obstacle_hit.connect(_on_obstacle_hit)

func _on_obstacle_hit(points: int) -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm and gm.has_method("add_score"):
		gm.add_score(points)
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		sm.play_sound("obstacle_hit")

func _on_back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenuV4.tscn")


## Camera: center on playfield (400,300). Playfield is 800x600, flippers/launcher at y=550.
## Visible height ~650 ensures flippers, launcher, ramp, and zones are all in view.
func _apply_camera_status(status: int) -> void:
	if not _camera:
		return
	var vp := get_viewport().get_visible_rect().size
	var center := Vector2(400, 300)
	# Keep camera centered on playfield so flippers (y=550), launcher, ramp (y=180), zones are visible
	_camera.position = center
	var visible_height: float = 580.0
	var z := vp.y / visible_height
	_camera.zoom = Vector2(z, z)

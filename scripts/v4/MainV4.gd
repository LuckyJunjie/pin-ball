extends Node2D
## v4.0 Main game scene: wires GameManagerV4 to Balls/Launcher, BackboxManagerV4, camera.

var _camera: Camera2D = null
var _multiball_indicators: Array[ColorRect] = []

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
	if gm.has_signal("bonus_activated"):
		gm.bonus_activated.connect(_on_bonus_activated)
	_setup_multiball_indicators()
	_setup_mobile_controls()
	_connect_obstacles()
	_apply_camera_status(gm.status)
	# Release UI focus so Space/Down/S reach the launcher, not buttons
	get_viewport().gui_release_focus()
	# Defer start_game so BallPoolV4 has time to initialize (it uses call_deferred)
	call_deferred("_deferred_start_game")
	# Optional: start in-game tutorial for first-time players (B.4)
	if TutorialSystemV4 and TutorialSystemV4.has_method("has_completed_tutorial") and not TutorialSystemV4.has_completed_tutorial():
		call_deferred("_maybe_start_tutorial")


func _deferred_start_game() -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm and gm.has_method("start_game"):
		gm.start_game()

func _maybe_start_tutorial() -> void:
	if TutorialSystemV4 and TutorialSystemV4.has_method("start_tutorial"):
		TutorialSystemV4.start_tutorial()

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


func _setup_multiball_indicators() -> void:
	# C.3: Four multiball indicator lights (GDD §2.3, §3.1)
	var ui = get_node_or_null("UI")
	if not ui:
		return
	var container = ui.get_node_or_null("MultiballIndicators")
	if not container:
		container = HBoxContainer.new()
		container.name = "MultiballIndicators"
		container.position = Vector2(340, 20)
		container.add_theme_constant_override("separation", 8)
		ui.add_child(container)
	for i in range(4):
		var rect = ColorRect.new()
		rect.custom_minimum_size = Vector2(16, 16)
		rect.color = Color(0.3, 0.3, 0.3, 1)
		rect.name = "Indicator%d" % (i + 1)
		container.add_child(rect)
		_multiball_indicators.append(rect)


func _setup_mobile_controls() -> void:
	# C.6: Mobile controls overlay (GDD §5.2, §6) - left/right flipper, tap to launch
	if not DisplayServer.is_touchscreen_available():
		return
	var scene = load("res://scenes/MobileControlsV4.tscn") as PackedScene
	if not scene:
		return
	var mobile = scene.instantiate()
	add_child(mobile)
	if mobile.has_signal("flipper_touched"):
		mobile.flipper_touched.connect(_on_mobile_flipper_touched)
	if mobile.has_signal("launch_tap"):
		mobile.launch_tap.connect(_on_mobile_launch_tap)


func _on_mobile_flipper_touched(side: String, is_pressed: bool) -> void:
	var action = "flipper_left" if side == "left" else "flipper_right"
	if is_pressed:
		Input.action_press(action)
	else:
		Input.action_release(action)


func _on_mobile_launch_tap() -> void:
	Input.action_press("launch_ball")


func _on_bonus_activated(bonus: int) -> void:
	# Animate multiball indicators when bonus ball is earned (Google Word or Dash Nest)
	if bonus != GameManagerV4.Bonus.GOOGLE_WORD and bonus != GameManagerV4.Bonus.DASH_NEST:
		return
	for rect in _multiball_indicators:
		rect.color = Color(1, 0.9, 0.2, 1)
		var tween = create_tween()
		tween.tween_property(rect, "color", Color(0.4, 0.4, 0.4, 1), 0.8).set_delay(0.2)
		tween.tween_property(rect, "color", Color(1, 0.9, 0.2, 1), 0.3)
		tween.set_loops(3)


## Camera per GDD §7: waiting = top/backbox, playing = playfield, gameOver = top.
func _apply_camera_status(status: int) -> void:
	if not _camera:
		return
	var vp := get_viewport().get_visible_rect().size
	var pos: Vector2
	var visible_height: float
	match status:
		GameManagerV4.Status.WAITING:
			pos = Vector2(400, 100)  # Top of board / backbox area
			visible_height = 175.0
		GameManagerV4.Status.PLAYING:
			pos = Vector2(400, 300)  # Playfield center
			visible_height = 160.0
		GameManagerV4.Status.GAME_OVER:
			pos = Vector2(400, 100)  # Top / backbox
			visible_height = 100.0
		_:
			pos = Vector2(400, 300)
			visible_height = 160.0
	_camera.position = pos
	var z := vp.y / visible_height
	_camera.zoom = Vector2(z, z)

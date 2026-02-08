extends Area2D
## v4.0 Drain: on ball contact return ball to pool (or remove); if no balls left call GameManagerV4.on_round_lost().

func _ready() -> void:
	# Set collision layer to wall layer (4) so balls can detect it
	collision_layer = 4
	body_entered.connect(_on_body_entered)
	# Add visual label if debug mode enabled
	if _get_debug_mode():
		add_visual_label("DRAIN")

func _on_body_entered(body: Node2D) -> void:
	if not (body is RigidBody2D and body.is_in_group("balls")):
		return
	var gm = get_node_or_null("/root/GameManagerV4")
	
	# Return ball to pool if BallPoolV4 is used, else queue_free
	var ball_pool = get_node_or_null("/root/BallPoolV4")
	if ball_pool and ball_pool.has_method("return_ball") and ball_pool.is_initialized():
		ball_pool.return_ball(body)
	else:
		body.queue_free()
	
	# After removing the ball, check if any balls remain
	if gm and gm.has_method("get_ball_count"):
		if gm.get_ball_count() == 0:
			if gm.has_method("on_round_lost"):
				gm.on_round_lost()

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GlobalGameSettings"""
	# Check GlobalGameSettings singleton (autoload)
	if has_node("/root/GlobalGameSettings"):
		var global_settings = get_node("/root/GlobalGameSettings")
		if global_settings.has_method("get") and global_settings.get("debug_mode") != null:
			return bool(global_settings.debug_mode)
	# Fallback to checking game_manager group
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "VisualLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 16)
	label.add_theme_color_override("font_color", Color(1, 0.3, 0.3, 1))  # Red
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-30, -15)  # Offset from center
	add_child(label)

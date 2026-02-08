extends Area2D
## Kicker - 5000 points per Flutter parity.

signal obstacle_hit(points: int)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("obstacles")
	# Add visual label if debug mode enabled
	if _get_debug_mode():
		add_visual_label("KICKER\n5000")

func _on_body_entered(body: Node2D) -> void:
	if not (body is RigidBody2D and body.is_in_group("balls")):
		return
	obstacle_hit.emit(5000)

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
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(0.8, 0.2, 0.8, 1))  # Purple
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-20, -25)  # Offset from center
	add_child(label)

extends Node

## v3.0: Animation Manager
## Handles tween-based animations for UI and game elements

signal animation_completed(animation_name: String)

var active_tweens: Dictionary = {}

func _ready():
	add_to_group("animation_manager")

func animate_score_popup(position: Vector2, points: int, color: Color = Color.WHITE):
	"""Create animated score popup that scales up and fades out"""
	var label = Label.new()
	label.text = "+" + str(points)
	label.add_theme_font_size_override("font_size", 32)
	label.add_theme_color_override("font_color", color)
	label.add_theme_color_override("font_outline_color", Color.BLACK)
	label.add_theme_constant_override("outline_size", 3)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	
	# Add to scene
	var canvas_layer = get_tree().get_first_node_in_group("ui_layer")
	if not canvas_layer:
		canvas_layer = get_tree().get_first_node_in_group("ui")
	if not canvas_layer:
		canvas_layer = get_tree().current_scene.get_node_or_null("UI")
	if canvas_layer:
		canvas_layer.add_child(label)
	else:
		get_tree().current_scene.add_child(label)
	
	label.global_position = position
	
	# Animate: scale up and fade out
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Scale animation
	label.scale = Vector2(0.5, 0.5)
	tween.tween_property(label, "scale", Vector2(1.2, 1.2), 0.2)
	tween.tween_property(label, "scale", Vector2(1.0, 1.0), 0.1).set_delay(0.2)
	
	# Fade and move up
	var start_alpha = 1.0
	var end_alpha = 0.0
	var start_pos = position
	var end_pos = position + Vector2(0, -50)
	
	tween.tween_method(
		func(alpha): label.modulate = Color(color.r, color.g, color.b, alpha),
		start_alpha, end_alpha, 0.5
	)
	tween.tween_property(label, "global_position", end_pos, 0.5)
	
	# Remove after animation
	tween.tween_callback(label.queue_free).set_delay(0.5)

func animate_multiplier_display(control: Control, multiplier: float):
	"""Animate multiplier display with pulsing effect"""
	if not control:
		return
	
	var tween = create_tween()
	tween.set_loops()
	
	# Pulse scale animation
	var base_scale = Vector2(1.0, 1.0)
	var pulse_scale = Vector2(1.1, 1.1)
	
	tween.tween_property(control, "scale", pulse_scale, 0.3)
	tween.tween_property(control, "scale", base_scale, 0.3)

func animate_ui_transition(control: Control, fade_in: bool = true, duration: float = 0.3):
	"""Animate UI element fade in/out"""
	if not control:
		return
	
	var tween = create_tween()
	
	if fade_in:
		control.modulate = Color(1, 1, 1, 0)
		tween.tween_property(control, "modulate", Color(1, 1, 1, 1), duration)
	else:
		tween.tween_property(control, "modulate", Color(1, 1, 1, 0), duration)

func animate_component_highlight(node: Node2D, color: Color = Color.YELLOW, duration: float = 0.2):
	"""Animate component highlight (glow/shake effect)"""
	if not node:
		return
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	# Glow effect (modulate color)
	var original_modulate = node.modulate
	tween.tween_property(node, "modulate", color, duration * 0.5)
	tween.tween_property(node, "modulate", original_modulate, duration * 0.5).set_delay(duration * 0.5)
	
	# Shake effect
	var original_pos = node.position
	var shake_amount = 5.0
	for i in range(3):
		var shake_offset = Vector2(
			randf_range(-shake_amount, shake_amount),
			randf_range(-shake_amount, shake_amount)
		)
		tween.tween_property(node, "position", original_pos + shake_offset, duration / 6.0)
		tween.tween_property(node, "position", original_pos, duration / 6.0)
	
	# Restore position
	tween.tween_property(node, "position", original_pos, 0.1).set_delay(duration)

func screen_shake(camera: Camera2D, intensity: float = 5.0, duration: float = 0.3):
	"""Apply screen shake effect to camera"""
	if not camera:
		return
	
	var original_offset = camera.offset
	var tween = create_tween()
	
	for i in range(int(duration * 10)):
		var shake_offset = Vector2(
			randf_range(-intensity, intensity),
			randf_range(-intensity, intensity)
		)
		tween.tween_property(camera, "offset", original_offset + shake_offset, 0.1)
	
	tween.tween_property(camera, "offset", original_offset, 0.1)

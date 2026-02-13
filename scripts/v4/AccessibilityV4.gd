extends Node
## v4.0 Accessibility System
## Comprehensive accessibility features

signal accessibility_setting_changed(setting_id: String, value: Variant)

@export var large_text_scale: float = 1.0
@export var high_contrast_mode: bool = false
@export var reduce_motion: bool = false
@export var haptic_feedback: bool = true
@export var subtitles_enabled: bool = true
@export var color_blind_mode: int = 0  # 0=none, 1=red-green, 2=blue-yellow

var _accessibility_profiles: Dictionary = {}

func _ready() -> void:
	add_to_group("accessibility_system")
	_load_settings()

func _load_settings() -> void:
	var settings = get_tree().get_first_node_in_group("settings")
	if settings:
		large_text_scale = settings.get_setting("accessibility", "large_text_scale")
		high_contrast_mode = settings.get_setting("accessibility", "high_contrast")
		reduce_motion = settings.get_setting("accessibility", "reduce_motion")
		haptic_feedback = settings.get_setting("accessibility", "haptic_feedback")
		color_blind_mode = settings.get_setting("accessibility", "color_blind_mode")

# ============================================
# Text Size
# ============================================

func set_large_text(enabled: bool) -> void:
	large_text_scale = 1.5 if enabled else 1.0
	_apply_text_scaling()
	accessibility_setting_changed.emit("large_text", enabled)

func set_text_scale(scale: float) -> void:
	large_text_scale = clamp(scale, 1.0, 2.0)
	_apply_text_scaling()
	accessibility_setting_changed.emit("text_scale", large_text_scale)

func _apply_text_scaling() -> void:
	# Apply text scaling to all UI elements
	var ui_elements = get_tree().get_nodes_in_group("ui")
	for ui in ui_elements:
		if ui.has_method("set_text_scale"):
			ui.set_text_scale(large_text_scale)

# ============================================
# Color & Contrast
# ============================================

func set_high_contrast(enabled: bool) -> void:
	high_contrast_mode = enabled
	_apply_color_settings()
	accessibility_setting_changed.emit("high_contrast", enabled)

func set_color_blind_mode(mode: int) -> void:
	color_blind_mode = clamp(mode, 0, 2)
	_apply_color_settings()
	accessibility_setting_changed.emit("color_blind_mode", color_blind_mode)

func _apply_color_settings() -> void:
	# Apply color adjustments based on accessibility settings
	var post_process = get_tree().get_first_node_in_group("post_processing")
	if post_process:
		if high_contrast_mode:
			# Increase contrast
			pass
		if color_blind_mode > 0:
			# Apply color blind corrections
			_apply_color_blind_correction()

func _apply_color_blind_correction() -> void:
	# Red-green (Protanopia/Deuteranopia)
	if color_blind_mode == 1:
		pass  # Apply red-green filter
	# Blue-yellow (Tritanopia)
	elif color_blind_mode == 2:
		pass  # Apply blue-yellow filter

# ============================================
# Motion
# ============================================

func set_reduce_motion(enabled: bool) -> void:
	reduce_motion = enabled
	_apply_motion_settings()
	accessibility_setting_changed.emit("reduce_motion", enabled)

func _apply_motion_settings() -> void:
	# Reduce or disable animations
	var tweens = get_tree().get_nodes_in_group("tweenable")
	for t in tweens:
		if reduce_motion:
			# Slow down or disable animations
			pass

func should_skip_animation(animation_type: String) -> bool:
	if not reduce_motion:
		return false
	
	var skip_types = ["background", "celebration", "transition"]
	return animation_type in skip_types

# ============================================
# Haptics
# ============================================

func set_haptic_feedback(enabled: bool) -> void:
	haptic_feedback = enabled
	accessibility_setting_changed.emit("haptic_feedback", enabled)

func trigger_haptic(type: String) -> void:
	if not haptic_feedback:
		return
	
	match type:
		"light":
			Input.vibrate_handheld(10)
		"medium":
			Input.vibrate_handheld(20)
		"heavy":
			Input.vibrate_handheld(30)

# ============================================
# Subtitles
# ============================================

func set_subtitles(enabled: bool) -> void:
	subtitles_enabled = enabled
	_apply_subtitle_settings()
	accessibility_setting_changed.emit("subtitles", enabled)

func _apply_subtitle_settings() -> void:
	var ui = get_tree().get_first_node_in_group("ui")
	if ui and ui.has_method("set_subtitles_enabled"):
		ui.set_subtitles_enabled(subtitles_enabled)

func show_subtitle(text: String, duration: float = 3.0) -> void:
	if not subtitles_enabled:
		return
	
	var subtitle_display = _get_subtitle_display()
	if subtitle_display:
		subtitle_display.show_text(text)
		await get_tree().create_timer(duration).timeout
		subtitle_display.hide()

func _get_subtitle_display() -> Node:
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		return ui.get_node_or_null("SubtitleDisplay")
	return null

# ============================================
# Simplified Controls
# ============================================

func set_simplified_controls(enabled: bool) -> void:
	# Simplify controls for players with motor difficulties
	var controls = get_tree().get_first_node_in_group("controls")
	if controls and controls.has_method("set_simplified_mode"):
		controls.set_simplified_mode(enabled)
	accessibility_setting_changed.emit("simplified_controls", enabled)

# ============================================
# Color Customization
# ============================================

func set_custom_colors(zone_colors: Dictionary) -> void:
	# Allow players to customize zone colors
	pass

# ============================================
# Profiles
# ============================================

func save_profile(profile_name: String) -> void:
	var profile = {
		"large_text_scale": large_text_scale,
		"high_contrast_mode": high_contrast_mode,
		"reduce_motion": reduce_motion,
		"haptic_feedback": haptic_feedback,
		"color_blind_mode": color_blind_mode
	}
	_accessibility_profiles[profile_name] = profile

func load_profile(profile_name: String) -> bool:
	if not _accessibility_profiles.has(profile_name):
		return False
	
	var profile = _accessibility_profiles[profile_name]
	large_text_scale = profile.get("large_text_scale", 1.0)
	high_contrast_mode = profile.get("high_contrast_mode", false)
	reduce_motion = profile.get("reduce_motion", false)
	haptic_feedback = profile.get("haptic_feedback", true)
	color_blind_mode = profile.get("color_blind_mode", 0)
	
	_apply_all_settings()
	return true

func get_profile_names() -> Array:
	return _accessibility_profiles.keys()

func delete_profile(profile_name: String) -> void:
	if _accessibility_profiles.has(profile_name):
		_accessibility_profiles.erase(profile_name)

func _apply_all_settings() -> void:
	_apply_text_scaling()
	_apply_color_settings()
	_apply_motion_settings()
	_apply_subtitle_settings()

# ============================================
# Presets
# ============================================

func apply_preset(preset_name: String) -> void:
	match preset_name:
		"color_blind_protanopia":
			set_color_blind_mode(1)
			set_large_text(true)
		"color_blind_tritanopia":
			set_color_blind_mode(2)
			set_large_text(true)
		"motor_difficulties":
			set_simplified_controls(true)
			set_reduce_motion(true)
			set_haptic_feedback(true)
		"visual_impairment":
			set_large_text(true)
			set_high_contrast(true)
			set_subtitles(true)

func get_recommended_presets() -> Array:
	return [
		{"name": "Color Blind (Red-Green)", "id": "color_blind_protanopia"},
		{"name": "Color Blind (Blue-Yellow)", "id": "color_blind_tritanopia"},
		{"name": "Motor Difficulties", "id": "motor_difficulties"},
		{"name": "Visual Impairment", "id": "visual_impairment"}
	]

# ============================================
# Query
# ============================================

func get_accessibility_summary() -> Dictionary:
	return {
		"text_scale": large_text_scale,
		"high_contrast": high_contrast_mode,
		"reduce_motion": reduce_motion,
		"haptics": haptic_feedback,
		"subtitles": subtitles_enabled,
		"color_blind_mode": color_blind_mode,
		"profiles": _accessibility_profiles.keys()
	}

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("accessibility_system")
	return null

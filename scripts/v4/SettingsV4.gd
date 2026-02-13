extends Node
## v4.0 Settings System
## Game settings with persistence

signal setting_changed(setting_id: String, value: Variant)
signal settings_reset()

const SETTINGS_FILE = "user://saves/settings.json"

var _settings: Dictionary = {}

func _ready() -> void:
	add_to_group("settings")
	_load_settings()

func _load_settings() -> void:
	if FileAccess.file_exists(SETTINGS_FILE):
		var file = FileAccess.open(SETTINGS_FILE, FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		_settings = json.get_data()
	else:
		_initialize_settings()

func _initialize_settings() -> void:
	_settings = {
		"audio": {
			"master_volume": 1.0,
			"sfx_volume": 0.8,
			"music_volume": 0.6,
			"ui_volume": 0.7,
			"sound_enabled": true
		},
		"video": {
			"fullscreen": false,
			"vsync": true,
			"cr_effect": true,
			"cr_scanlines": 0.3,
			"cr_glow": 0.5,
			"cr_vignette": 0.3,
			"particle_quality": "medium",
			"shadow_quality": "low"
		},
		"gameplay": {
			"difficulty": "normal",
			"flipper_sensitivity": 1.0,
			"launch_power": 0.8,
			"ball_speed": 1.0,
			"auto_launch": false,
			"show_fps": false,
			"show_debug": false
		},
		"accessibility": {
			"large_text": false,
			"high_contrast": false,
			"reduce_motion": false,
			"haptic_feedback": true,
			"subtitles": true
		},
		"controls": {
			"flipper_left": "key_a",
			"flipper_right": "key_d",
			"launch": "key_space",
			"pause": "key_escape",
			"touch_enabled": true
		},
		"version": "1.0.0"
	}

func _save_settings() -> void:
	_settings["version"] = "1.0.0"
	_settings["last_saved"] = Time.get_unix_time_from_system()
	
	var file = FileAccess.open(SETTINGS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(_settings, "\t"))

# ============================================
# Audio Settings
# ============================================

func get_master_volume() -> float:
	return _settings["audio"].get("master_volume", 1.0)

func set_master_volume(value: float) -> void:
	_settings["audio"]["master_volume"] = clamp(value, 0.0, 1.0)
	_apply_audio_settings()
	setting_changed.emit("master_volume", value)
	_save_settings()

func get_sfx_volume() -> float:
	return _settings["audio"].get("sfx_volume", 0.8)

func set_sfx_volume(value: float) -> void:
	_settings["audio"]["sfx_volume"] = clamp(value, 0.0, 1.0)
	_apply_audio_settings()
	setting_changed.emit("sfx_volume", value)
	_save_settings()

func get_music_volume() -> float:
	return _settings["audio"].get("music_volume", 0.6)

func set_music_volume(value: float) -> void:
	_settings["audio"]["music_volume"] = clamp(value, 0.0, 1.0)
	_apply_audio_settings()
	setting_changed.emit("music_volume", value)
	_save_settings()

func is_sound_enabled() -> bool:
	return _settings["audio"].get("sound_enabled", true)

func set_sound_enabled(enabled: bool) -> void:
	_settings["audio"]["sound_enabled"] = enabled
	_apply_audio_settings()
	setting_changed.emit("sound_enabled", enabled)
	_save_settings()

# ============================================
# Video Settings
# ============================================

func is_fullscreen() -> bool:
	return _settings["video"].get("fullscreen", false)

func set_fullscreen(enabled: bool) -> void:
	_settings["video"]["fullscreen"] = enabled
	_apply_video_settings()
	setting_changed.emit("fullscreen", enabled)
	_save_settings()

func is_vsync_enabled() -> bool:
	return _settings["video"].get("vsync", true)

func set_vsync(enabled: bool) -> void:
	_settings["video"]["vsync"] = enabled
	_apply_video_settings()
	setting_changed.emit("vsync", enabled)
	_save_settings()

func is_crt_effect_enabled() -> bool:
	return _settings["video"].get("cr_effect", true)

func set_crt_effect(enabled: bool) -> void:
	_settings["video"]["cr_effect"] = enabled
	_apply_video_settings()
	setting_changed.emit("cr_effect", enabled)
	_save_settings()

func get_scanline_intensity() -> float:
	return _settings["video"].get("cr_scanlines", 0.3)

func set_scanline_intensity(value: float) -> void:
	_settings["video"]["cr_scanlines"] = clamp(value, 0.0, 1.0)
	_apply_video_settings()
	setting_changed.emit("scanline_intensity", value)
	_save_settings()

func get_particle_quality() -> String:
	return _settings["video"].get("particle_quality", "medium")

func set_particle_quality(quality: String) -> void:
	if quality in ["low", "medium", "high"]:
		_settings["video"]["particle_quality"] = quality
		_apply_video_settings()
		setting_changed.emit("particle_quality", quality)
		_save_settings()

# ============================================
# Gameplay Settings
# ============================================

func get_difficulty() -> String:
	return _settings["gameplay"].get("difficulty", "normal")

func set_difficulty(difficulty: String) -> void:
	if difficulty in ["easy", "normal", "hard"]:
		_settings["gameplay"]["difficulty"] = difficulty
		_apply_gameplay_settings()
		setting_changed.emit("difficulty", difficulty)
		_save_settings()

func get_flipper_sensitivity() -> float:
	return _settings["gameplay"].get("flipper_sensitivity", 1.0)

func set_flipper_sensitivity(value: float) -> void:
	_settings["gameplay"]["flipper_sensitivity"] = clamp(value, 0.5, 2.0)
	setting_changed.emit("flipper_sensitivity", value)
	_save_settings()

func get_launch_power() -> float:
	return _settings["gameplay"].get("launch_power", 0.8)

func set_launch_power(value: float) -> void:
	_settings["gameplay"]["launch_power"] = clamp(value, 0.1, 1.0)
	setting_changed.emit("launch_power", value)
	_save_settings()

func is_show_fps() -> bool:
	return _settings["gameplay"].get("show_fps", false)

func set_show_fps(enabled: bool) -> void:
	_settings["gameplay"]["show_fps"] = enabled
	setting_changed.emit("show_fps", enabled)
	_save_settings()

# ============================================
# Accessibility Settings
# ============================================

func is_large_text_enabled() -> bool:
	return _settings["accessibility"].get("large_text", false)

func set_large_text(enabled: bool) -> void:
	_settings["accessibility"]["large_text"] = enabled
	setting_changed.emit("large_text", enabled)
	_save_settings()

func is_high_contrast_enabled() -> bool:
	return _settings["accessibility"].get("high_contrast", false)

func set_high_contrast(enabled: bool) -> void:
	_settings["accessibility"]["high_contrast"] = enabled
	_apply_accessibility_settings()
	setting_changed.emit("high_contrast", enabled)
	_save_settings()

func is_haptic_feedback_enabled() -> bool:
	return _settings["accessibility"].get("haptic_feedback", true)

func set_haptic_feedback(enabled: bool) -> void:
	_settings["accessibility"]["haptic_feedback"] = enabled
	setting_changed.emit("haptic_feedback", enabled)
	_save_settings()

# ============================================
# Control Settings
# ============================================

func is_touch_enabled() -> bool:
	return _settings["controls"].get("touch_enabled", true)

func set_touch_enabled(enabled: bool) -> void:
	_settings["controls"]["touch_enabled"] = enabled
	setting_changed.emit("touch_enabled", enabled)
	_save_settings()

func get_control_mapping(action: String) -> String:
	return _settings["controls"].get(action, "")

func set_control_mapping(action: String, binding: String) -> void:
	_settings["controls"][action] = binding
	setting_changed.emit("control_" + action, binding)
	_save_settings()

# ============================================
# Apply Functions
# ============================================

func _apply_audio_settings() -> void:
	var audio = get_tree().get_first_node_in_group("sound_manager")
	if audio:
		audio.set_master_volume(get_master_volume())
		audio.set_sfx_volume(get_sfx_volume())
		audio.set_music_volume(get_music_volume())

func _apply_video_settings() -> void:
	var crt = get_tree().get_first_node_in_group("post_processing")
	if crt:
		crt.set_enabled(is_crt_effect_enabled())
		crt.set_scanline_intensity(get_scanline_intensity())
	
	var perf = get_tree().get_first_node_in_group("performance_monitor")
	if perf:
		perf.set_quality_preset(get_particle_quality())

func _apply_gameplay_settings() -> void:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("set_difficulty"):
		gm.set_difficulty(get_difficulty())

func _apply_accessibility_settings() -> void:
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.set_large_text(is_large_text_enabled())
		ui.set_high_contrast(is_high_contrast_enabled())

# ============================================
# Query & Reset
# ============================================

func get_setting(category: String, key: String) -> Variant:
	if _settings.has(category):
		return _settings[category].get(key, null)
	return null

func get_all_settings() -> Dictionary:
	return _settings.duplicate()

func reset_settings() -> void:
	_initialize_settings()
	_save_settings()
	_apply_all_settings()
	settings_reset.emit()

func _apply_all_settings() -> void:
	_apply_audio_settings()
	_apply_video_settings()
	_apply_gameplay_settings()
	_apply_accessibility_settings()

func export_settings() -> String:
	return JSON.stringify(_settings, "\t")

func import_settings(json_string: String) -> bool:
	var json = JSON.new()
	if json.parse(json_string) == OK:
		_settings = json.get_data()
		_save_settings()
		_apply_all_settings()
		return true
	return false

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("settings")
	return null

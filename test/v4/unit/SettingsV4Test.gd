extends "res://addons/gut/test.gd"
## Unit tests for SettingsV4.gd

var settings: Node = null

func before_all():
	settings = autoqfree(load("res://scripts/v4/SettingsV4.gd").new())
	add_child(settings)

func test_settings_exists():
	assert_not_null(settings, "SettingsV4 should exist")
	assert_eq(settings.get_script().resource_path, "res://scripts/v4/SettingsV4.gd")

func test_audio_settings():
	watch_signals(settings)
	
	settings.set_master_volume(0.5)
	assert_eq(settings.get_master_volume(), 0.5)
	assert_signal_emitted(settings, "setting_changed")
	
	settings.set_sfx_volume(0.7)
	assert_eq(settings.get_sfx_volume(), 0.7)
	
	settings.set_music_volume(0.6)
	assert_eq(settings.get_music_volume(), 0.6)
	
	settings.set_sound_enabled(false)
	assert_eq(settings.is_sound_enabled(), false)

func test_volume_clamping():
	settings.set_master_volume(2.0)  # Above max
	assert_le(settings.get_master_volume(), 1.0, "Volume should clamp to 1.0")
	
	settings.set_master_volume(-1.0)  # Below min
	assert_ge(settings.get_master_volume(), 0.0, "Volume should clamp to 0.0")

func test_video_settings():
	settings.set_fullscreen(true)
	assert_eq(settings.is_fullscreen(), true)
	
	settings.set_vsync(false)
	assert_eq(settings.is_vsync_enabled(), false)
	
	settings.set_crt_effect(false)
	assert_eq(settings.is_crt_effect_enabled(), false)
	
	settings.set_scanline_intensity(0.5)
	assert_eq(settings.get_scanline_intensity(), 0.5)

func test_gameplay_settings():
	settings.set_difficulty("hard")
	assert_eq(settings.get_difficulty(), "hard")
	
	settings.set_difficulty("invalid")  # Should not change
	assert_eq(settings.get_difficulty(), "hard", "Invalid difficulty should not change")
	
	settings.set_flipper_sensitivity(1.5)
	assert_eq(settings.get_flipper_sensitivity(), 1.5)
	
	settings.set_launch_power(0.9)
	assert_eq(settings.get_launch_power(), 0.9)
	
	settings.set_show_fps(true)
	assert_eq(settings.is_show_fps(), true)

func test_accessibility_settings():
	settings.set_large_text(true)
	assert_eq(settings.is_large_text_enabled(), true)
	
	settings.set_high_contrast(true)
	assert_eq(settings.is_high_contrast_enabled(), true)
	
	settings.set_haptic_feedback(false)
	assert_eq(settings.is_haptic_feedback_enabled(), false)

func test_control_settings():
	settings.set_touch_enabled(false)
	assert_eq(settings.is_touch_enabled(), false)
	
	settings.set_control_mapping("flipper_left", "key_q")
	assert_eq(settings.get_control_mapping("flipper_left"), "key_q")

func test_get_setting():
	var master_vol = settings.get_setting("audio", "master_volume")
	assert_not_null(master_vol, "get_setting should return value")
	
	var invalid = settings.get_setting("invalid", "key")
	assert_null(invalid, "get_setting should return null for invalid category")

func test_get_all_settings():
	var all = settings.get_all_settings()
	assert_true(all.has("audio"), "Should have audio settings")
	assert_true(all.has("video"), "Should have video settings")
	assert_true(all.has("gameplay"), "Should have gameplay settings")

func test_reset_settings():
	settings.set_master_volume(0.3)
	settings.set_fullscreen(true)
	
	watch_signals(settings)
	settings.reset_settings()
	
	assert_signal_emitted(settings, "settings_reset")
	assert_eq(settings.get_master_volume(), 1.0, "Reset should restore defaults")
	assert_eq(settings.is_fullscreen(), false, "Reset should restore defaults")

func test_export_import_settings():
	var exported = settings.export_settings()
	assert_gt(exported.length(), 0, "Export should return JSON string")
	
	settings.set_master_volume(0.4)
	var success = settings.import_settings(exported)
	assert_true(success, "Import should succeed with valid JSON")
	assert_eq(settings.get_master_volume(), 1.0, "Import should restore exported values")

func test_particle_quality():
	settings.set_particle_quality("high")
	assert_eq(settings.get_particle_quality(), "high")
	
	settings.set_particle_quality("invalid")  # Should not change
	assert_eq(settings.get_particle_quality(), "high", "Invalid quality should not change")

func test_setting_changed_signal():
	watch_signals(settings)
	settings.set_master_volume(0.5)
	assert_signal_emitted(settings, "setting_changed")

func after_all():
	# Cleanup test save files
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive("user://saves")
		var save_dir = DirAccess.open("user://saves/")
		if save_dir:
			if save_dir.file_exists("settings.json"):
				save_dir.remove("settings.json")

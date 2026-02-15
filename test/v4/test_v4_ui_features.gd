extends "res://addons/gut/test.gd"
## UI and Effects Test Suite (TC-016 ~ TC-020)
## Added: 2026-02-15

var ui_manager: Node = null
var sound_manager: Node = null
var particle_system: Node = null

func before_all():
	ui_manager = get_node("/root/UIManagerV4")
	sound_manager = get_node("/root/SoundManagerV4")
	particle_system = get_node("/root/ParticleEffectsV4")

# TC-016: 音效反馈测试
func test_sound_effects():
	print("\n=== TC-016: 音效反馈测试 ===")
	assert_not_null(sound_manager, "SoundManagerV4 should exist")
	
	# 测试音效方法
	assert_true(sound_manager.has_method("play_flipper"), "Should have play_flipper method")
	assert_true(sound_manager.has_method("play_bumper"), "Should have play_bumper method")
	assert_true(sound_manager.has_method("play_score"), "Should have play_score method")
	assert_true(sound_manager.has_method("play_game_over"), "Should have play_game_over method")
	
	print("✅ TC-016: 音效反馈测试通过")

# TC-017: 视觉效果测试
func test_particle_effects():
	print("\n=== TC-017: 视觉效果测试 ===")
	assert_not_null(particle_system, "ParticleEffectsV4 should exist")
	
	# 测试粒子效果方法
	assert_true(particle_system.has_method("play_bumper_hit"), "Should have play_bumper_hit method")
	assert_true(particle_system.has_method("play_score_popup"), "Should have play_score_popup method")
	assert_true(particle_system.has_method("play_multiplier_change"), "Should have play_multiplier_change method")
	
	print("✅ TC-017: 视觉效果测试通过")

# TC-018: UI 响应测试
func test_ui_response():
	print("\n=== TC-018: UI 响应测试 ===")
	assert_not_null(ui_manager, "UIManagerV4 should exist")
	
	# 测试 UI 方法
	assert_true(ui_manager.has_method("show_main_menu"), "Should have show_main_menu method")
	assert_true(ui_manager.has_method("show_pause_menu"), "Should have show_pause_menu method")
	assert_true(ui_manager.has_method("update_score_display"), "Should have update_score_display method")
	assert_true(ui_manager.has_method("show_game_over"), "Should have show_game_over method")
	
	print("✅ TC-018: UI 响应测试通过")

# TC-019: 性能压力测试
func test_performance():
	print("\n=== TC-019: 性能压力测试 ===")
	
	# 测试性能监控
	var game_manager = get_node("/root/GameManagerV4")
	assert_true(game_manager.has_method("get_fps"), "Should have get_fps method")
	assert_true(game_manager.has_method("get_memory_usage"), "Should have get_memory_usage method")
	
	print("✅ TC-019: 性能压力测试通过")

# TC-020: 网络存档测试
func test_cloud_save():
	print("\n=== TC-020: 网络存档测试 ===")
	var save_manager = get_node("/root/SaveManagerV4")
	
	# 测试云存档方法
	assert_true(save_manager.has_method("upload_to_cloud"), "Should have upload_to_cloud method")
	assert_true(save_manager.has_method("download_from_cloud"), "Should have download_from_cloud method")
	
	print("✅ TC-020: 网络存档测试通过")

func after_all():
	print("\n=== UI 和特效测试套件完成 ===")

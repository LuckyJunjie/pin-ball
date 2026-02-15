extends "res://addons/gut/test.gd"
## Test suite for new features (TC-011 ~ TC-015)
## Added: 2026-02-15

var game_manager: Node = null
var multiplier_system: Node = null
var save_manager: Node = null
var zone_manager: Node = null

func before_all():
	game_manager = get_node("/root/GameManagerV4")
	multiplier_system = get_node("/root/MultiplierSystemV4")
	save_manager = get_node("/root/SaveManagerV4")
	zone_manager = get_node("/root/ZoneManagerV4")

# TC-011: 连击系统测试
func test_combo_system():
	print("\n=== TC-011: 连击系统测试 ===")
	
	# 测试倍率系统存在
	assert_not_null(multiplier_system, "MultiplierSystemV4 should exist")
	
	# 测试倍率值
	assert_eq(multiplier_system.get("x1"), 1, "Multiplier x1 should be 1")
	assert_eq(multiplier_system.get("x2"), 2, "Multiplier x2 should be 2")
	assert_eq(multiplier_system.get("x3"), 3, "Multiplier x3 should be 3")
	assert_eq(multiplier_system.get("x4"), 4, "Multiplier x4 should be 4")
	assert_eq(multiplier_system.get("x5"), 5, "Multiplier x5 should be 5")
	assert_eq(multiplier_system.get("x6"), 6, "Multiplier x6 should be 6")
	
	print("✅ TC-011: 连击系统测试通过")

# TC-012: 难度选择测试
func test_difficulty_selection():
	print("\n=== TC-012: 难度选择测试 ===")
	
	# 测试难度枚举存在
	assert_true(game_manager.has_method("set_difficulty"), "GameManager should have set_difficulty method")
	
	# 测试难度值
	assert_eq(game_manager.Difficulty.EASY, 0, "EASY should be 0")
	assert_eq(game_manager.Difficulty.NORMAL, 1, "NORMAL should be 1")
	assert_eq(game_manager.Difficulty.HARD, 2, "HARD should be 2")
	
	print("✅ TC-012: 难度选择测试通过")

# TC-013: 得分系统测试
func test_scoring_system():
	print("\n=== TC-013: 得分系统测试 ===")
	
	# 测试得分值定义
	assert_eq(game_manager.Score.BUMPER, 20, "Bumper score should be 20")
	assert_eq(game_manager.Score.PEG, 5, "Peg score should be 5")
	assert_eq(game_manager.Score.WALL, 15, "Wall score should be 15")
	
	# 测试得分方法
	game_manager.round_score = 0
	game_manager.add_score(game_manager.Score.BUMPER)
	assert_eq(game_manager.round_score, 20, "add_score with BUMPER should add 20")
	
	game_manager.add_score(game_manager.Score.PEG)
	assert_eq(game_manager.round_score, 25, "add_score with PEG should add 5")
	
	game_manager.add_score(game_manager.Score.WALL)
	assert_eq(game_manager.round_score, 40, "add_score with WALL should add 15")
	
	print("✅ TC-013: 得分系统测试通过")

# TC-014: 存档功能测试
func test_save_system():
	print("\n=== TC-014: 存档功能测试 ===")
	
	# 测试 SaveManager 存在
	assert_not_null(save_manager, "SaveManagerV4 should exist")
	
	# 测试存档方法
	assert_true(save_manager.has_method("save_game"), "SaveManager should have save_game method")
	assert_true(save_manager.has_method("load_game"), "SaveManager should have load_game method")
	
	# 测试自动存档启用
	assert_eq(save_manager.get("is_save_system_enabled"), true, "Save system should be enabled")
	
	print("✅ TC-014: 存档功能测试通过")

# TC-015: 区域系统测试
func test_zone_system():
	print("\n=== TC-015: 区域系统测试 ===")
	
	# 测试区域脚本存在
	var zone_scripts = [
		"res://scripts/v4/zones/AndroidAcresV4.gd",
		"res://scripts/v4/zones/GoogleGalleryV4.gd",
		"res://scripts/v4/zones/SparkyScorchV4.gd",
		"res://scripts/v4/zones/DinoDesertV4.gd",
		"res://scripts/v4/zones/FlutterForestV4.gd"
	]
	
	for script_path in zone_scripts:
		var script = load(script_path)
		assert_not_null(script, "Zone script should exist: " + script_path)
	
	# 测试区域数量
	assert_eq(zone_scripts.size(), 5, "Should have 5 zone scripts")
	
	print("✅ TC-015: 区域系统测试通过")

func after_all():
	print("\n=== 所有新功能测试完成 ===")

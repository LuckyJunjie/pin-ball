extends "res://addons/gut/test.gd"
## Unit tests for AchievementSystemV4.gd

var achievement_system: Node = null

func before_all():
	achievement_system = autoqfree(load("res://scripts/v4/AchievementSystemV4.gd").new())
	add_child(achievement_system)

func test_achievement_system_exists():
	assert_not_null(achievement_system, "AchievementSystemV4 should exist")
	assert_eq(achievement_system.get_script().resource_path, "res://scripts/v4/AchievementSystemV4.gd")

func test_achievement_categories():
	assert_eq(achievement_system.AchievementCategory.GENERAL, 0)
	assert_eq(achievement_system.AchievementCategory.SCORING, 1)
	assert_eq(achievement_system.AchievementCategory.ZONES, 2)
	assert_eq(achievement_system.AchievementCategory.COMBOS, 3)
	assert_eq(achievement_system.AchievementCategory.BONUSES, 4)

func test_achievements_defined():
	assert_gt(achievement_system.ACHIEVEMENTS.size(), 0, "Achievements should be defined")
	assert_true(achievement_system.ACHIEVEMENTS.has("first_game"), "first_game achievement should exist")
	assert_true(achievement_system.ACHIEVEMENTS.has("first_million"), "first_million achievement should exist")

func test_initial_state():
	assert_eq(achievement_system._unlocked_achievements.size(), 0, 
		"Initially no achievements should be unlocked")
	assert_eq(achievement_system.get_unlocked_count(), 0)

func test_on_game_started():
	achievement_system.on_game_started()
	var stats = achievement_system.get_statistics()
	assert_eq(stats["games_played"], 1, "games_played should increment")

func test_first_game_achievement():
	watch_signals(achievement_system)
	achievement_system.on_game_started()
	achievement_system._check_achievements()
	
	assert_true(achievement_system.is_unlocked("first_game"), 
		"first_game achievement should unlock after first game")
	assert_signal_emitted(achievement_system, "achievement_unlocked")

func test_scoring_achievements():
	achievement_system.on_game_started()
	achievement_system.on_game_ended(1000000)
	
	assert_true(achievement_system.is_unlocked("first_million"),
		"first_million should unlock with score >= 1,000,000")
	
	achievement_system.on_game_started()
	achievement_system.on_game_ended(5000000)
	
	assert_true(achievement_system.is_unlocked("five_million"),
		"five_million should unlock with score >= 5,000,000")

func test_multiplier_achievements():
	achievement_system.on_multiplier_changed(2)
	assert_true(achievement_system.is_unlocked("multiplier_2x"),
		"multiplier_2x should unlock at 2x")
	
	achievement_system.on_multiplier_changed(6)
	assert_true(achievement_system.is_unlocked("multiplier_6x"),
		"multiplier_6x should unlock at 6x")

func test_bonus_achievements():
	achievement_system.on_bonus_earned("GOOGLE_WORD")
	achievement_system.on_bonus_earned("DASH_NEST")
	achievement_system.on_bonus_earned("DINO_CHOMP")
	achievement_system.on_bonus_earned("SPARKY_TURBO_CHARGE")
	achievement_system.on_bonus_earned("ANDROID_SPACESHIP")
	
	achievement_system.on_game_ended(100000)
	
	assert_true(achievement_system.is_unlocked("all_bonuses"),
		"all_bonuses should unlock when all 5 bonus types earned")

func test_zone_achievements():
	for i in range(3):
		achievement_system.on_bonus_earned("ANDROID_SPACESHIP")
	
	achievement_system.on_game_ended(100000)
	
	assert_true(achievement_system.is_unlocked("android_master"),
		"android_master should unlock after 3 Android Acres bonuses")

func test_combo_achievements():
	achievement_system.on_combo_achieved(5)
	achievement_system.on_game_ended(100000)
	
	assert_true(achievement_system.is_unlocked("combo_5"),
		"combo_5 should unlock at combo 5")
	
	achievement_system.on_combo_achieved(20)
	achievement_system.on_game_ended(100000)
	
	assert_true(achievement_system.is_unlocked("combo_20"),
		"combo_20 should unlock at combo 20")

func test_bonus_ball_achievements():
	achievement_system.on_bonus_ball_earned()
	achievement_system.on_game_ended(100000)
	
	assert_true(achievement_system.is_unlocked("first_bonus"),
		"first_bonus should unlock after earning bonus ball")

func test_get_achievement_info():
	var info = achievement_system.get_achievement_info("first_game")
	assert_eq(info["name"], "First Game")
	assert_eq(info["description"], "Play your first game")
	assert_eq(info["points"], 10)

func test_get_all_achievements():
	var all = achievement_system.get_all_achievements()
	assert_gt(all.size(), 0, "Should return all achievements")
	assert_true(all[0].has("id"), "Each achievement should have id")
	assert_true(all[0].has("name"), "Each achievement should have name")
	assert_true(all[0].has("unlocked"), "Each achievement should have unlocked status")

func test_get_progress_percentage():
	achievement_system.on_game_started()
	achievement_system.on_game_ended(100000)
	
	var percentage = achievement_system.get_progress_percentage()
	assert_gt(percentage, 0.0, "Progress should be > 0 after unlocking achievements")
	assert_le(percentage, 100.0, "Progress should be <= 100")

func test_get_total_points():
	achievement_system.on_game_started()
	achievement_system.on_game_ended(100000)
	
	var points = achievement_system.get_total_points()
	assert_gt(points, 0, "Should have points from unlocked achievements")

func test_reset_progress():
	achievement_system.on_game_started()
	achievement_system.on_game_ended(100000)
	
	var unlocked_before = achievement_system.get_unlocked_count()
	assert_gt(unlocked_before, 0, "Should have unlocked achievements")
	
	achievement_system.reset_progress()
	assert_eq(achievement_system.get_unlocked_count(), 0, 
		"Reset should clear all achievements")

func test_zone_collector_achievement():
	# Activate bonuses in all 5 zones
	achievement_system.on_bonus_earned("ANDROID_SPACESHIP")
	achievement_system.on_bonus_earned("GOOGLE_WORD")
	achievement_system.on_bonus_earned("DASH_NEST")
	achievement_system.on_bonus_earned("DINO_CHOMP")
	achievement_system.on_bonus_earned("SPARKY_TURBO_CHARGE")
	
	achievement_system.on_game_ended(100000)
	
	assert_true(achievement_system.is_unlocked("zone_collector"),
		"zone_collector should unlock when all zones activated")

func after_all():
	# Cleanup test save files
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive("user://saves")
		var save_dir = DirAccess.open("user://saves/")
		if save_dir:
			if save_dir.file_exists("achievements.json"):
				save_dir.remove("achievements.json")

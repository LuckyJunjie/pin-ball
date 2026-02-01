extends "res://addons/gut/test.gd"
## Test suite for v4.0 implementation

var game_manager: Node = null
var backbox_manager: Node = null


func before_all():
	# Load autoloads if they exist
	game_manager = autoqfree(load("res://scripts/v4/GameManagerV4.gd").new())
	backbox_manager = autoqfree(load("res://scripts/v4/BackboxManagerV4.gd").new())


func test_game_manager_v4_exists():
	assert_not_null(game_manager, "GameManagerV4 should exist")
	assert_eq(game_manager.get_script().resource_path, "res://scripts/v4/GameManagerV4.gd")


func test_game_manager_signals():
	# Check that GameManagerV4 has required signals
	assert_has_signal(game_manager, "scored")
	assert_has_signal(game_manager, "round_lost")
	assert_has_signal(game_manager, "bonus_activated")
	assert_has_signal(game_manager, "multiplier_increased")
	assert_has_signal(game_manager, "game_over")
	assert_has_signal(game_manager, "game_started")


func test_game_manager_enums():
	# Check that GameManagerV4 has required enums
	assert_eq(game_manager.Status.WAITING, 0)
	assert_eq(game_manager.Status.PLAYING, 1)
	assert_eq(game_manager.Status.GAME_OVER, 2)
	
	# Check bonus enum values
	assert_eq(game_manager.Bonus.GOOGLE_WORD, 0)
	assert_eq(game_manager.Bonus.DASH_NEST, 1)
	assert_eq(game_manager.Bonus.SPARKY_TURBO_CHARGE, 2)
	assert_eq(game_manager.Bonus.DINO_CHOMP, 3)
	assert_eq(game_manager.Bonus.ANDROID_SPACESHIP, 4)


func test_game_manager_methods():
	# Test basic methods
	game_manager.round_score = 1000
	game_manager.total_score = 5000
	game_manager.multiplier = 2
	
	assert_eq(game_manager.display_score(), 6000, "display_score should return round_score + total_score")
	
	# Test add_score
	game_manager.status = game_manager.Status.PLAYING
	game_manager.add_score(500)
	assert_eq(game_manager.round_score, 1500, "add_score should increase round_score")
	
	# Test increase_multiplier
	game_manager.increase_multiplier()
	assert_eq(game_manager.multiplier, 3, "increase_multiplier should increase multiplier")


func test_backbox_manager_v4_exists():
	assert_not_null(backbox_manager, "BackboxManagerV4 should exist")
	assert_eq(backbox_manager.get_script().resource_path, "res://scripts/v4/BackboxManagerV4.gd")


func test_backbox_manager_states():
	# Check that BackboxManagerV4 has required states
	assert_eq(backbox_manager.State.LEADERBOARD_SUCCESS, 0)
	assert_eq(backbox_manager.State.LEADERBOARD_FAILURE, 1)
	assert_eq(backbox_manager.State.LOADING, 2)
	assert_eq(backbox_manager.State.INITIALS_FORM, 3)
	assert_eq(backbox_manager.State.INITIALS_SUCCESS, 4)
	assert_eq(backbox_manager.State.INITIALS_FAILURE, 5)
	assert_eq(backbox_manager.State.SHARE, 6)


func test_backbox_manager_methods():
	# Test request_initials
	backbox_manager.request_initials(1000000, "sparky")
	assert_eq(backbox_manager.initials_score, 1000000)
	assert_eq(backbox_manager.initials_character_key, "sparky")
	assert_eq(backbox_manager.current_state, backbox_manager.State.INITIALS_FORM)
	
	# Test submit_initials
	backbox_manager.submit_initials("ABC")
	# Should transition to LOADING then INITIALS_SUCCESS
	assert_eq(backbox_manager.current_state, backbox_manager.State.INITIALS_SUCCESS)
	
	# Test leaderboard entries
	var entries = backbox_manager.get_leaderboard_entries()
	assert_true(entries.size() > 0, "Leaderboard should have entries")


func test_zone_scripts_exist():
	# Check that all zone scripts exist
	var zone_scripts = [
		"res://scripts/v4/zones/AndroidAcresV4.gd",
		"res://scripts/v4/zones/DinoDesertV4.gd",
		"res://scripts/v4/zones/GoogleGalleryV4.gd",
		"res://scripts/v4/zones/FlutterForestV4.gd",
		"res://scripts/v4/zones/SparkyScorchV4.gd"
	]
	
	for script_path in zone_scripts:
		var script = load(script_path)
		assert_not_null(script, "Zone script should exist: %s" % script_path)
		var instance = autoqfree(script.new())
		assert_true(instance is Node2D, "Zone should extend Node2D: %s" % script_path)


func test_asset_loader_exists():
	var asset_loader = autoqfree(load("res://scripts/v4/AssetLoaderV4.gd").new())
	assert_not_null(asset_loader, "AssetLoaderV4 should exist")
	
	# Test theme loading
	var assets = asset_loader.load_theme_assets("sparky")
	assert_true(assets is Dictionary, "load_theme_assets should return Dictionary")


func test_bonus_visual_manager_exists():
	var bonus_manager = autoqfree(load("res://scripts/v4/BonusVisualManagerV4.gd").new())
	assert_not_null(bonus_manager, "BonusVisualManagerV4 should exist")
	assert_true(bonus_manager is Node2D, "BonusVisualManagerV4 should extend Node2D")


func test_main_v4_script_exists():
	var main_v4_script = load("res://scripts/v4/MainV4.gd")
	assert_not_null(main_v4_script, "MainV4.gd should exist")
	
	var instance = autoqfree(main_v4_script.new())
	assert_true(instance is Node2D, "MainV4 should extend Node2D")


func after_all():
	# Cleanup
	pass
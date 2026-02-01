extends "res://addons/gut/test.gd"
## Test suite for v4.0 implementation

var game_manager: Node = null
var backbox_manager: Node = null
var ball_pool: Node = null


func before_all():
	# Load autoloads if they exist
	game_manager = autoqfree(load("res://scripts/v4/GameManagerV4.gd").new())
	backbox_manager = autoqfree(load("res://scripts/v4/BackboxManagerV4.gd").new())
	ball_pool = autoqfree(load("res://scripts/v4/BallPoolV4.gd").new())


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


func test_ball_pool_v4_exists():
	assert_not_null(ball_pool, "BallPoolV4 should exist")
	assert_eq(ball_pool.get_script().resource_path, "res://scripts/v4/BallPoolV4.gd")


func test_ball_pool_v4_singleton():
	# Test singleton pattern
	var instance1 = BallPoolV4.get_instance()
	var instance2 = BallPoolV4.get_instance()
	assert_eq(instance1, instance2, "BallPoolV4 should follow singleton pattern")


func test_ball_pool_v4_initialization():
	# Test initialization
	var test_ball_scene = load("res://scenes/Ball.tscn")
	var test_container = Node2D.new()
	add_child(test_container)
	
	ball_pool.initialize(test_ball_scene, test_container, 3)
	assert_true(ball_pool.is_initialized(), "BallPoolV4 should be initialized after calling initialize()")
	assert_eq(ball_pool.get_total_pool_size(), 3, "BallPoolV4 should have correct pool size after initialization")
	
	test_container.queue_free()


func test_ball_pool_v4_get_and_return_ball():
	# Test ball retrieval and return
	var test_ball_scene = load("res://scenes/Ball.tscn")
	var test_container = Node2D.new()
	add_child(test_container)
	
	ball_pool.initialize(test_ball_scene, test_container, 2)
	
	# Get a ball
	var ball1 = ball_pool.get_ball()
	assert_not_null(ball1, "BallPoolV4.get_ball() should return a ball")
	assert_eq(ball_pool.get_active_ball_count(), 1, "Should have 1 active ball after get_ball()")
	assert_eq(ball_pool.get_available_ball_count(), 1, "Should have 1 available ball after get_ball()")
	
	# Get another ball
	var ball2 = ball_pool.get_ball()
	assert_not_null(ball2, "BallPoolV4.get_ball() should return second ball")
	assert_eq(ball_pool.get_active_ball_count(), 2, "Should have 2 active balls after second get_ball()")
	assert_eq(ball_pool.get_available_ball_count(), 0, "Should have 0 available balls after second get_ball()")
	
	# Return a ball
	ball_pool.return_ball(ball1)
	assert_eq(ball_pool.get_active_ball_count(), 1, "Should have 1 active ball after returning ball1")
	assert_eq(ball_pool.get_available_ball_count(), 1, "Should have 1 available ball after returning ball1")
	
	# Return second ball
	ball_pool.return_ball(ball2)
	assert_eq(ball_pool.get_active_ball_count(), 0, "Should have 0 active balls after returning ball2")
	assert_eq(ball_pool.get_available_ball_count(), 2, "Should have 2 available balls after returning ball2")
	
	test_container.queue_free()


func test_ball_pool_v4_performance_metrics():
	# Test performance metrics
	var test_ball_scene = load("res://scenes/Ball.tscn")
	var test_container = Node2D.new()
	add_child(test_container)
	
	ball_pool.initialize(test_ball_scene, test_container, 2)
	
	# Get and return balls to generate metrics
	var ball1 = ball_pool.get_ball()
	var ball2 = ball_pool.get_ball()
	ball_pool.return_ball(ball1)
	
	var metrics = ball_pool.get_performance_metrics()
	assert_true(metrics.has("balls_activated"), "Metrics should have balls_activated")
	assert_true(metrics.has("balls_deactivated"), "Metrics should have balls_deactivated")
	assert_true(metrics.has("instantiation_time_saved_ms"), "Metrics should have instantiation_time_saved_ms")
	
	assert_eq(metrics["balls_activated"], 2, "Should have activated 2 balls")
	assert_eq(metrics["balls_deactivated"], 1, "Should have deactivated 1 ball")
	
	test_container.queue_free()


func test_game_manager_save_load_system():
	# Test save/load system
	game_manager.is_save_system_enabled = true
	
	# Set up some game state
	game_manager.status = game_manager.Status.PLAYING
	game_manager.round_score = 1500
	game_manager.total_score = 7500
	game_manager.multiplier = 3
	game_manager.rounds = 2
	game_manager.bonus_history = [game_manager.Bonus.GOOGLE_WORD, game_manager.Bonus.DASH_NEST]
	game_manager.zone_ramp_hits = {
		"android_acres": 3,
		"dino_desert": 2,
		"google_gallery": 1,
		"flutter_forest": 0,
		"sparky_scorch": 4
	}
	game_manager.selected_character_theme = "android"
	
	# Test get_game_state
	var state = game_manager.get_game_state()
	assert_eq(state.version, 1, "Save version should be 1")
	assert_eq(state.round_score, 1500, "State should contain round_score")
	assert_eq(state.total_score, 7500, "State should contain total_score")
	assert_eq(state.multiplier, 3, "State should contain multiplier")
	assert_eq(state.rounds, 2, "State should contain rounds")
	assert_eq(state.bonus_history.size(), 2, "State should contain bonus_history")
	assert_eq(state.selected_character_theme, "android", "State should contain selected_character_theme")
	assert_true(state.has("timestamp"), "State should have timestamp")
	
	# Test validate_game_state
	assert_true(game_manager.validate_game_state(state), "Valid state should pass validation")
	
	# Test with invalid state
	var invalid_state = state.duplicate()
	invalid_state.version = 999
	assert_false(game_manager.validate_game_state(invalid_state), "Invalid version should fail validation")
	
	invalid_state = state.duplicate()
	invalid_state.round_score = -100
	assert_false(game_manager.validate_game_state(invalid_state), "Negative score should fail validation")
	
	invalid_state = state.duplicate()
	invalid_state.selected_character_theme = "invalid_theme"
	assert_false(game_manager.validate_game_state(invalid_state), "Invalid theme should fail validation")

func test_game_manager_save_and_load():
	# Test actual save/load operations
	game_manager.is_save_system_enabled = true
	
	# Set up game state
	game_manager.status = game_manager.Status.PLAYING
	game_manager.round_score = 2500
	game_manager.total_score = 10000
	game_manager.multiplier = 2
	game_manager.rounds = 1
	game_manager.bonus_history = [game_manager.Bonus.ANDROID_SPACESHIP]
	game_manager.selected_character_theme = "sparky"
	
	# Save game state
	var save_result = game_manager.save_game_state()
	assert_true(save_result, "save_game_state should return true on success")
	
	# Modify game state to verify load works
	game_manager.round_score = 0
	game_manager.total_score = 0
	game_manager.multiplier = 1
	game_manager.rounds = 3
	game_manager.bonus_history = []
	game_manager.selected_character_theme = "dino"
	
	# Load game state
	var load_result = game_manager.load_game_state()
	assert_true(load_result, "load_game_state should return true on success")
	
	# Verify state was restored
	assert_eq(game_manager.round_score, 2500, "round_score should be restored after load")
	assert_eq(game_manager.total_score, 10000, "total_score should be restored after load")
	assert_eq(game_manager.multiplier, 2, "multiplier should be restored after load")
	assert_eq(game_manager.rounds, 1, "rounds should be restored after load")
	assert_eq(game_manager.bonus_history.size(), 1, "bonus_history should be restored after load")
	assert_eq(game_manager.bonus_history[0], game_manager.Bonus.ANDROID_SPACESHIP, "bonus_history content should be restored")
	assert_eq(game_manager.selected_character_theme, "sparky", "selected_character_theme should be restored after load")

func test_game_manager_auto_save_functionality():
	# Test auto-save triggers
	game_manager.is_save_system_enabled = true
	game_manager.status = game_manager.Status.PLAYING
	
	# Reset auto-save timer
	game_manager.auto_save_timer = 0.0
	game_manager.last_saved_score = 0
	
	# Test that add_score triggers force_save for significant scores
	game_manager.add_score(150)  # Above MIN_SCORE_CHANGE_FOR_AUTO_SAVE (100)
	# Note: We can't easily test if force_save was called without mocking,
	# but we can verify the score was added
	assert_eq(game_manager.round_score, 150, "add_score should increase round_score")
	
	# Test on_round_lost triggers force_save
	game_manager.on_round_lost()
	# Verify round was processed
	assert_eq(game_manager.round_score, 0, "on_round_lost should reset round_score")
	
	# Test add_bonus triggers force_save
	game_manager.add_bonus(game_manager.Bonus.GOOGLE_WORD)
	assert_eq(game_manager.bonus_history.size(), 1, "add_bonus should add to bonus_history")
	
	# Test increase_multiplier triggers force_save
	game_manager.increase_multiplier()
	assert_eq(game_manager.multiplier, 2, "increase_multiplier should increase multiplier")

func test_game_manager_backup_system():
	# Test backup system
	game_manager.is_save_system_enabled = true
	
	# Set up game state
	game_manager.status = game_manager.Status.PLAYING
	game_manager.round_score = 5000
	game_manager.total_score = 20000
	
	# Save to create backup
	game_manager.save_game_state()
	
	# Test has_save_data
	assert_true(game_manager.has_save_data(), "has_save_data should return true after save")
	
	# Test delete_save
	var delete_result = game_manager.delete_save()
	assert_true(delete_result, "delete_save should return true on success")
	
	# After delete, has_save_data should return false (or true if backup exists)
	# Note: delete_save only deletes primary save, backup may still exist

func test_game_manager_force_save():
	# Test force_save method
	game_manager.is_save_system_enabled = true
	game_manager.status = game_manager.Status.PLAYING
	
	# Set up some state
	game_manager.round_score = 3000
	game_manager.total_score = 15000
	
	# Call force_save
	game_manager.force_save()
	
	# Verify auto_save_timer was reset
	assert_eq(game_manager.auto_save_timer, 0.0, "force_save should reset auto_save_timer")

func after_all():
	# Cleanup - delete any test save files
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive("user://saves")
		var save_dir = DirAccess.open("user://saves/")
		if save_dir:
			if save_dir.file_exists("v4.0_save.json"):
				save_dir.remove("v4.0_save.json")
			if save_dir.file_exists("v4.0_save_backup.json"):
				save_dir.remove("v4.0_save_backup.json")
	pass
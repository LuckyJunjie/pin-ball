extends "res://addons/gut/test.gd"
## Unit tests for GameManagerV4.gd

var game_manager: Node = null


func before_all():
	game_manager = get_node("/root/GameManagerV4")
	if game_manager and game_manager.get("is_save_system_enabled") != null:
		game_manager.is_save_system_enabled = false


func test_game_manager_exists():
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
	assert_has_signal(game_manager, "zone_ramp_hit")
	assert_has_signal(game_manager, "character_theme_changed")


func test_game_manager_enums():
	# Check that GameManagerV4 has required enums
	assert_eq(game_manager.Status.WAITING, 0)
	assert_eq(game_manager.Status.PLAYING, 1)
	assert_eq(game_manager.Status.GAME_OVER, 2)
	
	# Check bonus enum values (must match Flutter)
	assert_eq(game_manager.Bonus.GOOGLE_WORD, 0)
	assert_eq(game_manager.Bonus.DASH_NEST, 1)
	assert_eq(game_manager.Bonus.SPARKY_TURBO_CHARGE, 2)
	assert_eq(game_manager.Bonus.DINO_CHOMP, 3)
	assert_eq(game_manager.Bonus.ANDROID_SPACESHIP, 4)


func test_game_manager_constants():
	# Check important constants
	assert_eq(game_manager.MAX_SCORE, 9999999999)
	assert_eq(game_manager.INITIAL_ROUNDS, 3)
	assert_eq(game_manager.MAX_MULTIPLIER, 6)
	assert_eq(game_manager.RAMP_HITS_PER_MULTIPLIER, 5)


func test_scoring_calculation_matches_flutter():
	## Test that scoring calculation matches Flutter implementation
	# Flutter: displayScore = roundScore + totalScore (no multiplier in display)
	# Flutter: When round lost: totalScore = totalScore + (roundScore * multiplier)
	
	game_manager.status = game_manager.Status.PLAYING
	game_manager.round_score = 1000
	game_manager.total_score = 5000
	game_manager.multiplier = 2
	
	# Test display_score (should NOT apply multiplier)
	assert_eq(game_manager.display_score(), 6000, 
		"display_score should return round_score + total_score without multiplier")
	
	# Test add_score
	game_manager.add_score(500)
	assert_eq(game_manager.round_score, 1500, "add_score should increase round_score")
	
	# Test on_round_lost with multiplier
	game_manager.on_round_lost()
	# Expected: total_score = 5000 + (1500 * 2) = 8000
	assert_eq(game_manager.total_score, 8000, 
		"on_round_lost should apply multiplier to round_score before adding to total_score")
	assert_eq(game_manager.round_score, 0, "on_round_lost should reset round_score to 0")
	assert_eq(game_manager.multiplier, 1, "on_round_lost should reset multiplier to 1")


func test_multiplier_increase():
	game_manager.status = game_manager.Status.PLAYING
	game_manager.multiplier = 1
	
	# Test normal multiplier increase
	game_manager.increase_multiplier()
	assert_eq(game_manager.multiplier, 2, "increase_multiplier should increase multiplier")
	
	# Test max multiplier
	game_manager.multiplier = game_manager.MAX_MULTIPLIER
	game_manager.increase_multiplier()
	assert_eq(game_manager.multiplier, game_manager.MAX_MULTIPLIER,
		"increase_multiplier should not exceed MAX_MULTIPLIER")
	
	# Test multiplier not increased when not playing
	game_manager.status = game_manager.Status.WAITING
	game_manager.multiplier = 1
	game_manager.increase_multiplier()
	assert_eq(game_manager.multiplier, 1,
		"increase_multiplier should not work when status is not PLAYING")


func test_bonus_system():
	game_manager.bonus_history.clear()
	
	# Test adding bonus
	game_manager.add_bonus(game_manager.Bonus.ANDROID_SPACESHIP)
	assert_eq(game_manager.bonus_history.size(), 1)
	assert_eq(game_manager.bonus_history[0], game_manager.Bonus.ANDROID_SPACESHIP)
	
	# Test bonus history accumulation
	game_manager.add_bonus(game_manager.Bonus.GOOGLE_WORD)
	assert_eq(game_manager.bonus_history.size(), 2)
	assert_eq(game_manager.bonus_history[1], game_manager.Bonus.GOOGLE_WORD)


func test_zone_ramp_hit_tracking():
	game_manager.status = game_manager.Status.PLAYING
	game_manager.reset_zone_tracking()
	
	# Test registering ramp hits
	game_manager.register_zone_ramp_hit("android_acres")
	game_manager.register_zone_ramp_hit("android_acres")
	game_manager.register_zone_ramp_hit("dino_desert")
	
	assert_eq(game_manager.zone_ramp_hits["android_acres"], 2)
	assert_eq(game_manager.zone_ramp_hits["dino_desert"], 1)
	
	# Test multiplier increase after 5 hits (across all zones)
	game_manager.multiplier = 1
	for i in range(3):  # Already have 3 hits, need 2 more for total of 5
		game_manager.register_zone_ramp_hit("android_acres")
	
	assert_eq(game_manager.multiplier, 2,
		"Multiplier should increase after 5 total ramp hits")


func test_character_theme_system():
	# Test setting character theme
	game_manager.set_character_theme("sparky")
	assert_eq(game_manager.selected_character_theme, "sparky")
	
	game_manager.set_character_theme("android")
	assert_eq(game_manager.selected_character_theme, "android")
	
	# Test invalid theme (should not change)
	game_manager.set_character_theme("invalid")
	assert_eq(game_manager.selected_character_theme, "android",
		"Invalid theme should not change current theme")


func test_game_flow():
	# Test start_game
	game_manager.start_game()
	assert_eq(game_manager.status, game_manager.Status.PLAYING)
	assert_eq(game_manager.round_score, 0)
	assert_eq(game_manager.total_score, 0)
	assert_eq(game_manager.multiplier, 1)
	assert_eq(game_manager.rounds, game_manager.INITIAL_ROUNDS)
	assert_eq(game_manager.bonus_history.size(), 0)
	
	# Test round progression
	game_manager.rounds = 3
	game_manager.on_round_lost()
	assert_eq(game_manager.rounds, 2)
	
	# Test game over when rounds reach 0
	game_manager.rounds = 1
	game_manager.on_round_lost()
	assert_eq(game_manager.status, game_manager.Status.GAME_OVER)


func test_max_score_limit():
	game_manager.status = game_manager.Status.PLAYING
	game_manager.total_score = game_manager.MAX_SCORE - 1000
	game_manager.round_score = 2000
	game_manager.multiplier = 1
	
	# Test that score doesn't exceed MAX_SCORE
	game_manager.on_round_lost()
	assert_eq(game_manager.total_score, game_manager.MAX_SCORE,
		"Score should not exceed MAX_SCORE")
	
	# Test display_score also respects MAX_SCORE
	game_manager.total_score = game_manager.MAX_SCORE
	game_manager.round_score = 1000000
	assert_eq(game_manager.display_score(), game_manager.MAX_SCORE,
		"display_score should not exceed MAX_SCORE")


func after_all():
	# Cleanup
	pass
extends "res://addons/gut/test.gd"
## Integration tests for v4.0 game flow and component interactions

var game_manager: Node = null
var test_bumper: Node = null
var test_zone: Node = null


class TestBumper extends Node:
	# Simple test bumper that implements BumperV4 interface
	signal bumper_hit(points: int, bumper_id: String)
	signal bumper_lit_changed(is_lit: bool)
	
	var bumper_id: String = "TEST"
	var is_lit: bool = false
	var base_points: int = 20000
	
	func simulate_hit() -> void:
		var points = base_points * (2 if is_lit else 1)
		bumper_hit.emit(points, bumper_id)
		toggle_lit_state()
	
	func toggle_lit_state() -> void:
		is_lit = not is_lit
		bumper_lit_changed.emit(is_lit)
	
	func set_lit(state: bool) -> void:
		if is_lit != state:
			is_lit = state
			bumper_lit_changed.emit(is_lit)
	
	func reset_bumper() -> void:
		is_lit = false


class TestZone extends Node:
	# Simple test zone that implements AndroidAcresV4 interface
	signal ramp_hit(points: int)
	signal bumper_hit(points: int, bumper_id: String)
	
	var bumpers_lit: Dictionary = {"A": false, "B": false, "COW": false}
	var ramp_hit_count: int = 0
	
	func _on_bumper_hit(points: int, bumper_id: String) -> void:
		bumper_hit.emit(points, bumper_id)
		# Update bumper lit state (simplified)
		if bumper_id in bumpers_lit:
			bumpers_lit[bumper_id] = not bumpers_lit[bumper_id]
	
	func _on_ramp_hit() -> void:
		ramp_hit_count += 1
		ramp_hit.emit(5000)
	
	func _are_all_bumpers_lit() -> bool:
		for lit in bumpers_lit.values():
			if not lit:
				return false
		return true


func before_all():
	game_manager = autoqfree(load("res://scripts/v4/GameManagerV4.gd").new())
	test_bumper = autoqfree(TestBumper.new())
	test_zone = autoqfree(TestZone.new())
	
	# Set game manager to playing state
	game_manager.status = game_manager.Status.PLAYING


func test_integration_scoring_flow():
	## Test complete scoring flow from bumper hit to score update
	
	# Track score changes
	var initial_score = game_manager.display_score()
	var score_changed = false
	
	# Connect to scored signal
	game_manager.scored.connect(func(points: int):
		score_changed = true
	)
	
	# Simulate bumper hit
	test_bumper.simulate_hit()
	
	# Manually trigger zone handling (simulating connection)
	test_zone._on_bumper_hit(20000, "A")
	
	# Zone should emit bumper_hit signal
	# In real integration, GameManager would be connected to this signal
	# For test, we directly call add_score
	game_manager.add_score(20000)
	
	assert_true(score_changed, "Score should change after bumper hit")
	assert_gt(game_manager.display_score(), initial_score,
		"Display score should increase after bumper hit")


func test_multiplier_integration():
	## Test multiplier integration with ramp hits
	
	game_manager.multiplier = 1
	game_manager.reset_zone_tracking()
	
	# Simulate 5 ramp hits (should increase multiplier)
	for i in range(5):
		game_manager.register_zone_ramp_hit("android_acres")
	
	assert_eq(game_manager.multiplier, 2,
		"Multiplier should increase to 2 after 5 ramp hits")
	
	# Test that multiplier applies to round score
	game_manager.round_score = 10000
	game_manager.on_round_lost()
	
	# With multiplier 2, 10000 round score should become 20000 added to total
	# total_score was 0, so should become 20000
	assert_eq(game_manager.total_score, 20000,
		"Multiplier should apply to round score when round is lost")


func test_bonus_system_integration():
	## Test bonus system integration
	
	game_manager.bonus_history.clear()
	
	# Test Android Spaceship bonus
	game_manager.add_bonus(game_manager.Bonus.ANDROID_SPACESHIP)
	
	assert_eq(game_manager.bonus_history.size(), 1)
	assert_eq(game_manager.bonus_history[0], game_manager.Bonus.ANDROID_SPACESHIP)
	
	# Test that bonus adds score
	var initial_score = game_manager.display_score()
	# Note: Android Spaceship bonus adds 200000 points in GameManagerV4.add_bonus
	# We need to check if this happens
	game_manager.add_bonus(game_manager.Bonus.ANDROID_SPACESHIP)
	# Score should increase by 200000 for second bonus
	assert_gt(game_manager.display_score(), initial_score,
		"Android Spaceship bonus should add score")


func test_zone_bumper_integration():
	## Test zone and bumper integration
	
	# Create a test scenario where all bumpers get lit
	test_zone.bumpers_lit["A"] = true
	test_zone.bumpers_lit["B"] = true
	test_zone.bumpers_lit["COW"] = true
	
	assert_true(test_zone._are_all_bumpers_lit(),
		"Zone should detect all bumpers lit")
	
	# In real game, this would trigger bonus activation
	# For test, verify the detection works


func test_game_flow_integration():
	## Test complete game flow integration
	
	# Start game
	game_manager.start_game()
	
	assert_eq(game_manager.status, game_manager.Status.PLAYING)
	assert_eq(game_manager.rounds, game_manager.INITIAL_ROUNDS)
	assert_eq(game_manager.multiplier, 1)
	assert_eq(game_manager.round_score, 0)
	assert_eq(game_manager.total_score, 0)
	
	# Play a round (simulate scoring)
	game_manager.add_score(5000)  # Ramp hit
	game_manager.add_score(20000) # Bumper hit
	
	assert_eq(game_manager.round_score, 25000)
	
	# Lose round
	game_manager.on_round_lost()
	
	assert_eq(game_manager.rounds, game_manager.INITIAL_ROUNDS - 1)
	assert_eq(game_manager.round_score, 0)
	assert_eq(game_manager.multiplier, 1)
	# total_score should be 25000 (no multiplier in this test)
	
	# Play until game over
	game_manager.rounds = 1
	game_manager.on_round_lost()
	
	assert_eq(game_manager.status, game_manager.Status.GAME_OVER)
	assert_eq(game_manager.rounds, 0)


func test_character_theme_integration():
	## Test character theme integration
	
	var theme_changed = false
	var new_theme = ""
	
	game_manager.character_theme_changed.connect(func(theme_key: String):
		theme_changed = true
		new_theme = theme_key
	)
	
	# Change theme
	game_manager.set_character_theme("sparky")
	
	assert_true(theme_changed, "Character theme change should emit signal")
	assert_eq(new_theme, "sparky")
	assert_eq(game_manager.selected_character_theme, "sparky")
	
	# Change to another theme
	game_manager.set_character_theme("android")
	
	assert_eq(game_manager.selected_character_theme, "android")


func test_performance_integration():
	## Test performance-related integration
	
	# Test that game manager can handle many rapid score additions
	game_manager.status = game_manager.Status.PLAYING
	var initial_score = game_manager.display_score()
	
	# Add many scores rapidly (simulating fast gameplay)
	for i in range(100):
		game_manager.add_score(1000)
	
	var final_score = game_manager.display_score()
	var expected_score = initial_score + (100 * 1000)
	
	# Account for MAX_SCORE limit
	expected_score = min(expected_score, game_manager.MAX_SCORE)
	
	assert_eq(final_score, expected_score,
		"Game manager should handle rapid score additions correctly")
	
	# Test that score doesn't exceed MAX_SCORE
	game_manager.total_score = game_manager.MAX_SCORE - 5000
	game_manager.round_score = 10000
	game_manager.multiplier = 2
	
	game_manager.on_round_lost()
	
	assert_eq(game_manager.total_score, game_manager.MAX_SCORE,
		"Score should not exceed MAX_SCORE even with multiplier")


func test_error_handling_integration():
	## Test error handling and edge cases
	
	# Test adding score when not playing
	game_manager.status = game_manager.Status.WAITING
	var score_before = game_manager.display_score()
	
	game_manager.add_score(10000)
	
	assert_eq(game_manager.display_score(), score_before,
		"Should not add score when game status is not PLAYING")
	
	# Test multiplier increase when not playing
	game_manager.multiplier = 1
	game_manager.increase_multiplier()
	
	assert_eq(game_manager.multiplier, 1,
		"Should not increase multiplier when game status is not PLAYING")
	
	# Reset to playing for other tests
	game_manager.status = game_manager.Status.PLAYING


func after_all():
	# Cleanup
	pass
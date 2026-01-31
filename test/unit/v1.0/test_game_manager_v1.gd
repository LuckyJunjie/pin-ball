extends GutTest

## v1.0: Game Manager Core Tests
## Tests game state, scoring, and basic game flow

var game_manager: Node2D

func before_each():
	# Create GameManager instance
	var script = load("res://scripts/GameManager.gd")
	game_manager = Node2D.new()
	game_manager.set_script(script)
	add_child_autofree(game_manager)
	
	# Set game version to v1.x
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		global_settings.set_game_version("v1.x")

func test_game_manager_initialization():
	"""Test GameManager initializes correctly"""
	assert_not_null(game_manager, "GameManager should exist")
	assert_eq(game_manager.score, 0, "Initial score should be 0")
	assert_false(game_manager.is_paused, "Game should not be paused initially")

func test_score_system():
	"""Test scoring system"""
	watch_signals(game_manager)
	
	game_manager.add_score(100)
	
	assert_eq(game_manager.score, 100, "Score should increase")
	assert_signal_emitted(game_manager, "score_changed", "Should emit score_changed signal")
	
	game_manager.add_score(50)
	assert_eq(game_manager.score, 150, "Score should accumulate")

func test_reset_score():
	"""Test score reset"""
	game_manager.add_score(200)
	game_manager.reset_score()
	
	assert_eq(game_manager.score, 0, "Score should reset to 0")

func test_pause_toggle():
	"""Test pause functionality"""
	assert_false(game_manager.is_paused, "Game should start unpaused")
	
	game_manager.toggle_pause()
	assert_true(game_manager.is_paused, "Game should be paused after toggle")
	
	game_manager.toggle_pause()
	assert_false(game_manager.is_paused, "Game should be unpaused after second toggle")

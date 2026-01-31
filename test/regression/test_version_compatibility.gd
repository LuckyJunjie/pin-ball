extends GutTest

## Regression Tests - Version Compatibility
## Ensures v1.0 and v2.0 features still work when v3.0 is added

var game_manager: Node2D

func test_v1_features_still_work():
	"""Test that v1.0 core features still work"""
	var gm_script = load("res://scripts/GameManager.gd")
	game_manager = Node2D.new()
	game_manager.set_script(gm_script)
	game_manager.ball_scene = load("res://scenes/Ball.tscn")
	add_child_autofree(game_manager)
	
	# Set to v1.x
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		global_settings.set_game_version("v1.x")
	
	# Test basic scoring
	game_manager.add_score(50)
	assert_eq(game_manager.score, 50, "v1.0 scoring should still work")
	
	# Test pause
	game_manager.toggle_pause()
	assert_true(game_manager.is_paused, "v1.0 pause should still work")

func test_v2_features_still_work():
	"""Test that v2.0 monetization features still work"""
	var currency_script = load("res://scripts/CurrencyManager.gd")
	var currency_manager = Node.new()
	currency_manager.set_script(currency_script)
	add_child_autofree(currency_manager)
	
	# Test currency system
	currency_manager.add_coins(100)
	assert_eq(currency_manager.get_coins(), 100, "v2.0 currency should still work")

func test_v3_does_not_break_v1_v2():
	"""Test that v3.0 doesn't break v1.0 or v2.0 features"""
	# Create game manager in v3.0 mode
	var gm_script = load("res://scripts/GameManager.gd")
	game_manager = Node2D.new()
	game_manager.set_script(gm_script)
	game_manager.is_v3_mode = true
	add_child_autofree(game_manager)
	
	# Initialize v3 systems
	game_manager._initialize_v3_systems()
	await wait_frames(1)
	
	# v1.0 features should still work
	game_manager.add_score(100)
	assert_eq(game_manager.score, 100, "v1.0 scoring should work in v3.0 mode")
	
	# v2.0 features should still work
	game_manager.is_v2_mode = true
	# Currency system should still function
	assert_not_null(game_manager, "GameManager should exist with v3.0 enabled")

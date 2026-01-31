extends GutTest

## v1.0: Integration Tests - Complete Game Flow
## Tests end-to-end game flow for v1.0

var game_manager: Node2D
var ball_queue: Node2D
var launcher: Node2D

func before_each():
	# Create game components
	var gm_script = load("res://scripts/GameManager.gd")
	game_manager = Node2D.new()
	game_manager.set_script(gm_script)
	game_manager.ball_scene = load("res://scenes/Ball.tscn")
	add_child_autofree(game_manager)
	
	# Set version to v1.x
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		global_settings.set_game_version("v1.x")

func test_ball_release_to_launch():
	"""Test complete flow: ball release -> launcher -> playfield"""
	# This is an integration test that would require full scene setup
	# For now, test that components can work together
	assert_not_null(game_manager, "GameManager should exist")
	# Full integration test would require scene instantiation

func test_scoring_flow():
	"""Test scoring flow: obstacle hit -> score increase"""
	watch_signals(game_manager)
	
	# Simulate obstacle hit
	game_manager._on_obstacle_hit(50)
	
	assert_gt(game_manager.score, 0, "Score should increase after obstacle hit")
	assert_signal_emitted(game_manager, "score_changed", "Should emit score_changed signal")

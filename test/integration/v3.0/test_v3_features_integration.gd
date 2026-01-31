extends GutTest

## v3.0: Integration Tests - v3.0 Features Integration
## Tests that all v3.0 systems work together

var game_manager: Node2D

func before_each():
	# Create GameManager with v3.0 mode
	var gm_script = load("res://scripts/GameManager.gd")
	game_manager = Node2D.new()
	game_manager.set_script(gm_script)
	game_manager.is_v3_mode = true
	add_child_autofree(game_manager)
	
	# Set version to v3.0
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		global_settings.set_game_version("v3.0")

func test_v3_systems_initialization():
	"""Test all v3.0 systems initialize correctly"""
	# Initialize v3 systems
	game_manager._initialize_v3_systems()
	
	# Wait a frame for initialization
	await wait_frames(1)
	
	assert_not_null(game_manager.multiball_manager, "MultiballManager should be created")
	assert_not_null(game_manager.combo_system, "ComboSystem should be created")
	assert_not_null(game_manager.animation_manager, "AnimationManager should be created")

func test_scoring_with_multipliers():
	"""Test scoring with v3.0 multipliers"""
	game_manager._initialize_v3_systems()
	await wait_frames(1)
	
	# Set up multipliers
	game_manager.current_multiplier = 2.0
	if game_manager.combo_system:
		game_manager.combo_system.register_hit()
		game_manager.combo_system.register_hit()
	
	# Simulate obstacle hit
	var initial_score = game_manager.score
	game_manager._on_obstacle_hit(100)
	
	# Score should be multiplied
	assert_gt(game_manager.score, initial_score + 100, "Score should be multiplied")

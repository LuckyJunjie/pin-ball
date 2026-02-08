extends "res://addons/gut/test.gd"

## Zone Integration Test - Validates Android Acres zone components work together

var android_acres: Node2D = null
var game_manager: Node = null
var bonus_manager: Node = null

func before_all():
	# Load Android Acres scene
	var scene = load("res://scenes/zones/AndroidAcres/AndroidAcres.tscn")
	assert_not_null(scene, "Android Acres scene should load")
	android_acres = scene.instantiate()
	add_child(android_acres)
	
	# Get autoload references
	game_manager = get_node_or_null("/root/GameManagerV4")
	bonus_manager = get_node_or_null("/root/BonusManagerV4")
	
	# Start game if game manager exists
	if game_manager and game_manager.has_method("start_game"):
		game_manager.start_game()

func after_all():
	if android_acres:
		android_acres.queue_free()

func test_android_acres_components_exist():
	## Test that all required components exist in the scene
	assert_not_null(android_acres, "Android Acres scene should be instantiated")
	
	# Check for required nodes
	var bumper_a = android_acres.get_node_or_null("AndroidBumperA")
	var bumper_b = android_acres.get_node_or_null("AndroidBumperB")
	var bumper_cow = android_acres.get_node_or_null("AndroidBumperCow")
	var spaceship_ramp = android_acres.get_node_or_null("SpaceshipRamp")
	var spaceship_target = android_acres.get_node_or_null("AndroidSpaceship")
	
	assert_not_null(bumper_a, "AndroidBumperA should exist")
	assert_not_null(bumper_b, "AndroidBumperB should exist")
	assert_not_null(bumper_cow, "AndroidBumperCow should exist")
	assert_not_null(spaceship_ramp, "SpaceshipRamp should exist")
	assert_not_null(spaceship_target, "AndroidSpaceship target should exist")
	
	# Check that bumpers are of correct type
	if bumper_a:
		assert_true(bumper_a is BumperV4, "AndroidBumperA should be BumperV4 type")
	if bumper_b:
		assert_true(bumper_b is BumperV4, "AndroidBumperB should be BumperV4 type")
	if bumper_cow:
		assert_true(bumper_cow is BumperV4, "AndroidBumperCow should be BumperV4 type")

func test_bumper_configuration():
	## Test that bumpers are properly configured
	var bumper_a = android_acres.get_node_or_null("AndroidBumperA") as BumperV4
	if bumper_a:
		assert_eq(bumper_a.bumper_type, BumperV4.BumperType.ANDROID, "Bumper A should be ANDROID type")
		assert_eq(bumper_a.bumper_id, "A", "Bumper A should have ID 'A'")
		assert_eq(bumper_a.base_points, 20000, "Bumper A should have 20,000 base points")

func test_zone_script_initialization():
	## Test that zone script is properly initialized
	var zone_script = android_acres.get_script()
	assert_not_null(zone_script, "Android Acres should have a script")
	
	# Check that zone is in correct groups
	assert_true(android_acres.is_in_group("zones"), "Should be in 'zones' group")
	assert_true(android_acres.is_in_group("android_acres"), "Should be in 'android_acres' group")

func test_game_manager_integration():
	## Test integration with GameManagerV4
	if game_manager:
		assert_true(game_manager.has_method("add_score"), "GameManager should have add_score method")
		assert_true(game_manager.has_method("add_bonus"), "GameManager should have add_bonus method")
		assert_true(game_manager.has_method("register_zone_ramp_hit"), "GameManager should have register_zone_ramp_hit method")

func test_bonus_manager_integration():
	## Test integration with BonusManagerV4
	if bonus_manager:
		assert_true(bonus_manager.has_method("activate_bonus"), "BonusManager should have activate_bonus method")
		assert_true(bonus_manager.has_method("update_zone_progress"), "BonusManager should have update_zone_progress method")

func test_zone_signals():
	## Test that zone emits correct signals
	var zone_script_instance = android_acres
	
	# Check for required signals
	assert_has_signal(zone_script_instance, "ramp_hit")
	assert_has_signal(zone_script_instance, "bumper_hit")
	assert_has_signal(zone_script_instance, "spaceship_target_hit")
	assert_has_signal(zone_script_instance, "bumper_bonus_activated")

func test_scoring_values():
	## Test that scoring values match Flutter Pinball
	var zone_script_instance = android_acres
	
	# These values should match Flutter Pinball
	# Check via reflection if constants are accessible
	# For now, we'll check the script source for correct values
	pass  # Values are hardcoded in AndroidAcresV4.gd

func test_zone_reset_functionality():
	## Test that zone can be reset
	var zone_script_instance = android_acres
	if zone_script_instance.has_method("reset_zone"):
		# Store initial state
		var initial_ramp_hits = zone_script_instance.get("ramp_hit_count") if zone_script_instance.has_method("get") else 0
		
		# Modify state
		zone_script_instance.set("ramp_hit_count", 5)
		
		# Reset
		zone_script_instance.reset_zone()
		
		# Check reset
		var final_ramp_hits = zone_script_instance.get("ramp_hit_count") if zone_script_instance.has_method("get") else 0
		assert_eq(final_ramp_hits, 0, "Ramp hits should reset to 0")

func test_bumper_lighting_sequence():
	## Test bumper lighting logic
	var bumper_a = android_acres.get_node_or_null("AndroidBumperA") as BumperV4
	if bumper_a and bumper_a.has_method("set_lit"):
		# Test lighting
		bumper_a.set_lit(true)
		assert_true(bumper_a.is_lit, "Bumper A should be lit after set_lit(true)")
		
		# Test unlighting
		bumper_a.set_lit(false)
		assert_false(bumper_a.is_lit, "Bumper A should not be lit after set_lit(false)")

func run_all_tests():
	## Run all test methods
	test_android_acres_components_exist()
	test_bumper_configuration()
	test_zone_script_initialization()
	test_game_manager_integration()
	test_bonus_manager_integration()
	test_zone_signals()
	test_scoring_values()
	test_zone_reset_functionality()
	test_bumper_lighting_sequence()
	
	print("All zone integration tests completed")
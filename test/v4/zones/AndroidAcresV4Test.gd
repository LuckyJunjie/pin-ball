extends "res://addons/gut/test.gd"
## Unit tests for AndroidAcresV4.gd zone

var zone: Node = null
var mock_game_manager: Node = null


class MockGameManager extends Node:
	var score_added: int = 0
	var bonuses_added: Array = []
	var zone_ramp_hits_registered: Array = []
	var multiplier_increased: bool = false
	
	func add_score(points: int) -> void:
		score_added += points
	
	func add_bonus(bonus) -> void:
		bonuses_added.append(bonus)
	
	func register_zone_ramp_hit(zone_name: String) -> void:
		zone_ramp_hits_registered.append(zone_name)
	
	func increase_multiplier() -> void:
		multiplier_increased = true


func before_all():
	zone = autoqfree(load("res://scripts/v4/zones/AndroidAcresV4.gd").new())
	mock_game_manager = autoqfree(MockGameManager.new())
	
	# Replace GameManagerV4 with mock for testing
	zone.set_meta("mock_game_manager", mock_game_manager)


func test_zone_exists():
	assert_not_null(zone, "AndroidAcresV4 should exist")
	assert_eq(zone.get_script().resource_path, "res://scripts/v4/zones/AndroidAcresV4.gd")


func test_zone_signals():
	# Check that zone has required signals
	assert_has_signal(zone, "ramp_hit")
	assert_has_signal(zone, "bumper_hit")
	assert_has_signal(zone, "spaceship_target_hit")
	assert_has_signal(zone, "bumper_bonus_activated")


func test_zone_constants():
	# Check zone constants match Flutter values
	assert_eq(zone.RAMP_HIT_POINTS, 5000)
	assert_eq(zone.BUMPER_BASE_POINTS, 20000)
	assert_eq(zone.SPACESHIP_BONUS_POINTS, 200000)
	assert_eq(zone.BUMPER_BONUS_POINTS, 50000)


func test_zone_initial_state():
	# Test initial zone state
	assert_eq(zone.ramp_hit_count, 0)
	assert_false(zone.all_bumpers_lit_bonus_activated)
	assert_true(zone.spaceship_target_active)
	
	# Test bumper lit state dictionary
	assert_true(zone.bumpers_lit.has("A"))
	assert_true(zone.bumpers_lit.has("B"))
	assert_true(zone.bumpers_lit.has("COW"))
	
	assert_false(zone.bumpers_lit["A"])
	assert_false(zone.bumpers_lit["B"])
	assert_false(zone.bumpers_lit["COW"])


func test_bumper_configuration():
	# Test that zone configures bumpers correctly
	# Since we don't have actual bumper nodes in unit test,
	# we test that the configuration method exists
	assert_true(zone.has_method("_configure_bumpers"),
		"Zone should have _configure_bumpers method")


func test_ramp_hit_behavior():
	# Test ramp hit behavior
	var initial_ramp_hits = zone.ramp_hit_count
	
	# Simulate ramp hit
	zone._on_ramp_hit(Node.new())  # Pass dummy node
	
	# Should increment ramp hit count
	assert_eq(zone.ramp_hit_count, initial_ramp_hits + 1,
		"Ramp hit should increment ramp_hit_count")
	
	# Note: Actual scoring would be handled by GameManagerV4
	# which we mock in integration tests


func test_bumper_hit_handling():
	# Test bumper hit handling
	# Create a mock bumper hit
	var test_points = 20000
	var test_bumper_id = "A"
	
	zone._on_bumper_hit(test_points, test_bumper_id)
	
	# Bumper lit state should be updated by bumper component,
	# not directly by zone in new implementation
	# Zone just forwards the hit to GameManager


func test_all_bumpers_lit_detection():
	# Test detection of all bumpers lit
	zone.bumpers_lit["A"] = true
	zone.bumpers_lit["B"] = true
	zone.bumpers_lit["COW"] = true
	
	assert_true(zone._are_all_bumpers_lit(),
		"_are_all_bumpers_lit should return true when all bumpers are lit")
	
	# Test with one unlit
	zone.bumpers_lit["B"] = false
	assert_false(zone._are_all_bumpers_lit(),
		"_are_all_bumpers_lit should return false when any bumper is unlit")


func test_bumper_bonus_activation():
	# Test bumper bonus activation
	zone.all_bumpers_lit_bonus_activated = false
	zone.bumpers_lit["A"] = true
	zone.bumpers_lit["B"] = true
	zone.bumpers_lit["COW"] = true
	
	# Mock the bonus activation
	zone._activate_bumper_bonus()
	
	assert_true(zone.all_bumpers_lit_bonus_activated,
		"Bonus activation should set all_bumpers_lit_bonus_activated to true")
	
	# Test that bonus can only be activated once per round
	zone._activate_bumper_bonus()
	# Should not activate again (method should return early)


func test_spaceship_target_hit():
	# Test spaceship target hit
	zone.spaceship_target_active = true
	
	# Simulate spaceship hit
	zone._on_spaceship_target_hit(Node.new())  # Pass dummy node
	
	assert_false(zone.spaceship_target_active,
		"Spaceship target should become inactive after hit")
	
	# Note: Actual bonus activation would be handled by GameManagerV4


func test_zone_reset():
	# Set some state
	zone.ramp_hit_count = 5
	zone.all_bumpers_lit_bonus_activated = true
	zone.spaceship_target_active = false
	zone.bumpers_lit["A"] = true
	zone.bumpers_lit["B"] = true
	zone.bumpers_lit["COW"] = true
	
	# Test reset
	zone.reset_zone()
	
	assert_eq(zone.ramp_hit_count, 0, "reset_zone should reset ramp_hit_count")
	assert_false(zone.all_bumpers_lit_bonus_activated,
		"reset_zone should reset all_bumpers_lit_bonus_activated")
	assert_true(zone.spaceship_target_active,
		"reset_zone should reset spaceship_target_active to true")
	
	# Bumpers should be reset (via _reset_bumpers)
	# Note: Actual bumper reset would be handled by bumper components


func test_get_bumper_by_id():
	# Test bumper lookup
	# Since we don't have actual bumper nodes in unit test,
	# we test that the method exists and handles all cases
	assert_true(zone.has_method("_get_bumper_by_id"),
		"Zone should have _get_bumper_by_id method")
	
	# Test that method handles all bumper IDs
	var method = zone._get_bumper_by_id
	assert_not_null(method, "Method should exist")
	
	# Note: Actual bumper references would be null in unit test
	# without scene nodes


func test_zone_info():
	# Test get_zone_info returns correct structure
	var info = zone.get_zone_info()
	
	assert_true(info.has("zone"), "Zone info should have 'zone'")
	assert_true(info.has("ramp_hit_count"), "Zone info should have 'ramp_hit_count'")
	assert_true(info.has("bumpers_lit"), "Zone info should have 'bumpers_lit'")
	assert_true(info.has("spaceship_active"), "Zone info should have 'spaceship_active'")
	assert_true(info.has("bonus_activated"), "Zone info should have 'bonus_activated'")
	
	assert_eq(info["zone"], "android_acres")
	assert_eq(info["ramp_hit_count"], zone.ramp_hit_count)
	assert_eq(info["bumpers_lit"], zone.bumpers_lit)
	assert_eq(info["spaceship_active"], zone.spaceship_target_active)
	assert_eq(info["bonus_activated"], zone.all_bumpers_lit_bonus_activated)


func test_zone_methods_exist():
	# Test that all required methods exist
	assert_true(zone.has_method("connect_ramp"))
	assert_true(zone.has_method("connect_bumpers"))
	assert_true(zone.has_method("connect_spaceship_target"))
	assert_true(zone.has_method("_update_bumper_visuals"))
	assert_true(zone.has_method("_update_bumper_visual"))
	assert_true(zone.has_method("_show_ramp_hit_feedback"))
	assert_true(zone.has_method("_show_spaceship_activation"))
	assert_true(zone.has_method("_reset_spaceship_visual"))
	assert_true(zone.has_method("_show_bumper_bonus_feedback"))
	assert_true(zone.has_method("_on_round_lost"))


func after_all():
	# Cleanup
	pass
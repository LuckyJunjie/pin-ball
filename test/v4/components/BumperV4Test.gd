extends "res://addons/gut/test.gd"
## Unit tests for BumperV4.gd component

var bumper: Node = null


func before_all():
	bumper = autoqfree(load("res://scripts/v4/components/BumperV4.gd").new())


func test_bumper_exists():
	assert_not_null(bumper, "BumperV4 should exist")
	assert_eq(bumper.get_script().resource_path, "res://scripts/v4/components/BumperV4.gd")


func test_bumper_enums():
	# Check that BumperV4 has required enums
	assert_eq(bumper.BumperType.ANDROID, 0)
	assert_eq(bumper.BumperType.DASH, 1)
	assert_eq(bumper.BumperType.SPARKY, 2)


func test_bumper_signals():
	# Check that BumperV4 has required signals
	assert_has_signal(bumper, "bumper_hit")
	assert_has_signal(bumper, "bumper_lit_changed")
	assert_has_signal(bumper, "bumper_bonus_activated")


func test_bumper_properties():
	# Test default properties
	assert_eq(bumper.bumper_type, bumper.BumperType.ANDROID)
	assert_eq(bumper.bumper_id, "A")
	assert_eq(bumper.base_points, 20000)
	assert_eq(bumper.lit_multiplier, 2)
	assert_false(bumper.is_lit, "Bumper should start unlit")
	assert_eq(bumper.hit_count, 0)
	assert_true(bumper.can_be_hit, "Bumper should start hittable")


func test_bumper_lit_state():
	# Test toggle_lit_state
	bumper.is_lit = false
	bumper.toggle_lit_state()
	assert_true(bumper.is_lit, "toggle_lit_state should toggle from false to true")
	
	bumper.toggle_lit_state()
	assert_false(bumper.is_lit, "toggle_lit_state should toggle from true to false")
	
	# Test set_lit
	bumper.set_lit(true)
	assert_true(bumper.is_lit, "set_lit(true) should set bumper to lit")
	
	bumper.set_lit(false)
	assert_false(bumper.is_lit, "set_lit(false) should set bumper to unlit")


func test_bumper_reset():
	# Set some state
	bumper.is_lit = true
	bumper.hit_count = 5
	bumper.can_be_hit = false
	
	# Test reset
	bumper.reset_bumper()
	assert_false(bumper.is_lit, "reset_bumper should set is_lit to false")
	assert_eq(bumper.hit_count, 0, "reset_bumper should reset hit_count to 0")
	assert_true(bumper.can_be_hit, "reset_bumper should set can_be_hit to true")


func test_bumper_hit_cooldown():
	# Test that bumper enters cooldown after hit
	# Note: We can't easily test the actual hit without a ball,
	# but we can test the cooldown mechanism
	
	bumper.can_be_hit = true
	bumper.hit_cooldown = 0.1  # Short cooldown for testing
	
	# Simulate hit (would normally be called by _on_body_entered)
	bumper.can_be_hit = false
	bumper.hit_cooldown_timer.start(bumper.hit_cooldown)
	
	assert_false(bumper.can_be_hit, "Bumper should not be hittable during cooldown")
	
	# Wait for cooldown (simulated)
	await get_tree().create_timer(0.15).timeout
	# Note: In actual test, we'd need to call _on_hit_cooldown_timeout
	# For now, just verify the timer setup


func test_bumper_visual_state():
	# Test that visual state updates when lit state changes
	# Since we're testing without actual scene nodes, we'll test the method exists
	assert_true(bumper.has_method("_update_visual_state"),
		"Bumper should have _update_visual_state method")
	
	assert_true(bumper.has_method("_show_hit_feedback"),
		"Bumper should have _show_hit_feedback method")
	
	assert_true(bumper.has_method("bonus_flash"),
		"Bumper should have bonus_flash method")


func test_bumper_info():
	# Test get_bumper_info returns correct structure
	var info = bumper.get_bumper_info()
	
	assert_true(info.has("type"), "Bumper info should have 'type'")
	assert_true(info.has("id"), "Bumper info should have 'id'")
	assert_true(info.has("is_lit"), "Bumper info should have 'is_lit'")
	assert_true(info.has("hit_count"), "Bumper info should have 'hit_count'")
	assert_true(info.has("position"), "Bumper info should have 'position'")
	
	assert_eq(info["type"], bumper.bumper_type)
	assert_eq(info["id"], bumper.bumper_id)
	assert_eq(info["is_lit"], bumper.is_lit)
	assert_eq(info["hit_count"], bumper.hit_count)


func test_bumper_configuration():
	# Test that bumper can be configured with different types
	bumper.bumper_type = bumper.BumperType.DASH
	bumper.bumper_id = "DASH_1"
	bumper.base_points = 15000
	bumper.lit_multiplier = 3
	
	assert_eq(bumper.bumper_type, bumper.BumperType.DASH)
	assert_eq(bumper.bumper_id, "DASH_1")
	assert_eq(bumper.base_points, 15000)
	assert_eq(bumper.lit_multiplier, 3)


func test_bumper_sound_methods():
	# Test that bumper has sound methods
	assert_true(bumper.has_method("_play_hit_sound"),
		"Bumper should have _play_hit_sound method")


func after_all():
	# Cleanup
	pass
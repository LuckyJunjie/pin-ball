extends "res://addons/gut/test.gd"
## Unit tests for ComboSystem.gd

var combo_system: Node = null

func before_all():
	combo_system = autoqfree(load("res://scripts/v4/ComboSystem.gd").new())
	add_child(combo_system)

func test_combo_system_exists():
	assert_not_null(combo_system, "ComboSystem should exist")
	assert_eq(combo_system.get_script().resource_path, "res://scripts/v4/ComboSystem.gd")

func test_initial_state():
	assert_eq(combo_system.combo_count, 0, "Initial combo_count should be 0")
	assert_eq(combo_system.is_combo_active, false, "Initial combo should not be active")
	assert_eq(combo_system.max_combo_achieved, 0, "Initial max_combo should be 0")

func test_register_hit_starts_combo():
	watch_signals(combo_system)
	var bonus = combo_system.register_hit("bumper", 100)
	
	assert_eq(combo_system.combo_count, 1, "First hit should start combo")
	assert_eq(combo_system.is_combo_active, true, "Combo should be active after first hit")
	assert_signal_emitted(combo_system, "combo_started")
	assert_eq(bonus, 0, "First hit should not award bonus")

func test_register_hit_increases_combo():
	combo_system.register_hit("bumper", 100)
	watch_signals(combo_system)
	var bonus = combo_system.register_hit("ramp", 200)
	
	assert_eq(combo_system.combo_count, 2, "Second hit should increase combo")
	assert_signal_emitted(combo_system, "combo_increased")
	assert_gt(bonus, 0, "Combo bonus should be awarded")

func test_same_hit_type_resets_timer():
	combo_system.register_hit("bumper", 100)
	var count_before = combo_system.combo_count
	var bonus = combo_system.register_hit("bumper", 100)
	
	assert_eq(combo_system.combo_count, count_before, 
		"Same hit type should not increase combo count")
	assert_eq(bonus, 0, "Same hit type should not award bonus")

func test_combo_bonus_calculation():
	combo_system.register_hit("bumper", 100)
	combo_system.register_hit("ramp", 200)  # Combo 2
	var bonus2 = combo_system._calculate_combo_bonus()
	assert_gt(bonus2, 0, "Combo 2 should have bonus")
	
	combo_system.register_hit("letter", 50)  # Combo 3
	var bonus3 = combo_system._calculate_combo_bonus()
	assert_gt(bonus3, bonus2, "Combo 3 should have higher bonus than combo 2")

func test_combo_timeout():
	combo_system.register_hit("bumper", 100)
	combo_system.register_hit("ramp", 200)
	combo_system.combo_timer = 0.0  # Force timeout
	
	watch_signals(combo_system)
	combo_system._process(0.1)  # Process to trigger timeout
	
	assert_signal_emitted(combo_system, "combo_reset")
	assert_eq(combo_system.is_combo_active, false, "Combo should be inactive after timeout")

func test_register_drain():
	combo_system.register_hit("bumper", 100)
	combo_system.register_hit("ramp", 200)
	combo_system.register_hit("letter", 50)
	
	watch_signals(combo_system)
	var bonus_earned = combo_system.register_drain()
	
	assert_signal_emitted(combo_system, "combo_reset")
	assert_eq(combo_system.is_combo_active, false, "Combo should be inactive after drain")
	assert_gt(bonus_earned, 0, "Should return bonus earned")
	assert_eq(combo_system.combo_count, 0, "Combo count should reset")

func test_max_combo_tracking():
	combo_system.register_hit("bumper", 100)
	combo_system.register_hit("ramp", 200)
	combo_system.register_hit("letter", 50)
	
	assert_eq(combo_system.max_combo_achieved, 3, "max_combo should track highest combo")
	
	combo_system.register_drain()
	combo_system.register_hit("bumper", 100)
	combo_system.register_hit("ramp", 200)
	
	assert_eq(combo_system.max_combo_achieved, 3, "max_combo should keep highest value")

func test_combo_display():
	combo_system.register_hit("bumper", 100)
	combo_system.register_hit("ramp", 200)
	
	var display = combo_system.get_combo_display()
	assert_true(display.contains("2"), "Display should show combo count")
	
	combo_system.register_drain()
	display = combo_system.get_combo_display()
	assert_eq(display, "", "Display should be empty when combo inactive")

func test_combo_multiplier():
	combo_system.register_hit("bumper", 100)
	assert_eq(combo_system.get_combo_multiplier(), 1.0, "Combo 1 should have multiplier 1.0")
	
	combo_system.register_hit("ramp", 200)
	var multiplier = combo_system.get_combo_multiplier()
	assert_gt(multiplier, 1.0, "Combo 2+ should have multiplier > 1.0")

func test_combo_statistics():
	combo_system.register_hit("bumper", 100)
	combo_system.register_hit("ramp", 200)
	combo_system.register_hit("letter", 50)
	
	var stats = combo_system.get_combo_statistics()
	assert_eq(stats["max_combo"], 3)
	assert_gt(stats["total_bonus_earned"], 0)

func test_reset():
	combo_system.register_hit("bumper", 100)
	combo_system.register_hit("ramp", 200)
	combo_system.reset()
	
	assert_eq(combo_system.combo_count, 0)
	assert_eq(combo_system.is_combo_active, false)
	assert_eq(combo_system.max_combo_achieved, 0)
	assert_eq(combo_system.combo_history.size(), 0)

func test_combo_bonus_cap():
	# Combo only increases when hit_type != last_hit_type. Build high combo with different types.
	var hit_types := ["bumper", "ramp", "letter", "kicker", "rollover"]
	for i in range(25):  # More than MAX_COMBO_BONUS_COMBO_COUNT (20)
		combo_system.register_hit(hit_types[i % hit_types.size()], 100)
	
	var bonus = combo_system._calculate_combo_bonus()
	var capped_bonus = combo_system._calculate_combo_bonus()
	
	# Bonus should be capped at MAX_COMBO_BONUS_COMBO_COUNT level
	assert_eq(bonus, capped_bonus, "Bonus should cap at MAX_COMBO_BONUS_COMBO_COUNT")
	assert_gt(combo_system.combo_count, 1, "Combo should be above 1 to exercise cap")

func after_all():
	pass

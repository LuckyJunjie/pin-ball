extends "res://addons/gut/test.gd"
## Unit tests for DifficultySystem.gd

var difficulty_system: Node = null

func before_all():
	difficulty_system = autoqfree(load("res://scripts/v4/DifficultySystem.gd").new())
	add_child(difficulty_system)

func test_difficulty_system_exists():
	assert_not_null(difficulty_system, "DifficultySystem should exist")
	assert_eq(difficulty_system.get_script().resource_path, "res://scripts/v4/DifficultySystem.gd")

func test_difficulty_enums():
	assert_eq(difficulty_system.Difficulty.EASY, 0)
	assert_eq(difficulty_system.Difficulty.NORMAL, 1)
	assert_eq(difficulty_system.Difficulty.HARD, 2)

func test_difficulty_names():
	assert_eq(difficulty_system.DIFFICULTY_NAMES[difficulty_system.Difficulty.EASY], "Easy")
	assert_eq(difficulty_system.DIFFICULTY_NAMES[difficulty_system.Difficulty.NORMAL], "Normal")
	assert_eq(difficulty_system.DIFFICULTY_NAMES[difficulty_system.Difficulty.HARD], "Hard")

func test_default_difficulty():
	assert_eq(difficulty_system.current_difficulty, difficulty_system.Difficulty.NORMAL, 
		"Default difficulty should be NORMAL")

func test_set_difficulty():
	difficulty_system.set_difficulty(difficulty_system.Difficulty.EASY)
	assert_eq(difficulty_system.current_difficulty, difficulty_system.Difficulty.EASY,
		"set_difficulty should change current difficulty")
	
	difficulty_system.set_difficulty(difficulty_system.Difficulty.HARD)
	assert_eq(difficulty_system.current_difficulty, difficulty_system.Difficulty.HARD)

func test_get_difficulty():
	difficulty_system.set_difficulty(difficulty_system.Difficulty.EASY)
	assert_eq(difficulty_system.get_difficulty(), difficulty_system.Difficulty.EASY)

func test_get_difficulty_name():
	difficulty_system.set_difficulty(difficulty_system.Difficulty.EASY)
	assert_eq(difficulty_system.get_difficulty_name(), "Easy")
	
	difficulty_system.set_difficulty(difficulty_system.Difficulty.HARD)
	assert_eq(difficulty_system.get_difficulty_name(), "Hard")

func test_difficulty_configs():
	# Test EASY config
	difficulty_system.set_difficulty(difficulty_system.Difficulty.EASY)
	var config = difficulty_system.difficulty_config
	assert_eq(config["flipper_strength"], 1500.0)
	assert_eq(config["gravity_scale"], 0.8)
	assert_eq(config["bumper_force"], 250.0)
	assert_eq(config["multiplier_decay_enabled"], false)
	
	# Test NORMAL config
	difficulty_system.set_difficulty(difficulty_system.Difficulty.NORMAL)
	config = difficulty_system.difficulty_config
	assert_eq(config["flipper_strength"], 2200.0)
	assert_eq(config["gravity_scale"], 1.0)
	assert_eq(config["multiplier_decay_enabled"], true)
	
	# Test HARD config
	difficulty_system.set_difficulty(difficulty_system.Difficulty.HARD)
	config = difficulty_system.difficulty_config
	assert_eq(config["flipper_strength"], 2800.0)
	assert_eq(config["gravity_scale"], 1.2)
	assert_eq(config["bumper_force"], 350.0)

func test_get_flipper_strength():
	difficulty_system.set_difficulty(difficulty_system.Difficulty.EASY)
	assert_eq(difficulty_system.get_flipper_strength(), 1500.0)
	
	difficulty_system.set_difficulty(difficulty_system.Difficulty.HARD)
	assert_eq(difficulty_system.get_flipper_strength(), 2800.0)

func test_get_gravity_scale():
	difficulty_system.set_difficulty(difficulty_system.Difficulty.EASY)
	assert_eq(difficulty_system.get_gravity_scale(), 0.8)
	
	difficulty_system.set_difficulty(difficulty_system.Difficulty.HARD)
	assert_eq(difficulty_system.get_gravity_scale(), 1.2)

func test_get_bumper_force():
	difficulty_system.set_difficulty(difficulty_system.Difficulty.EASY)
	assert_eq(difficulty_system.get_bumper_force(), 250.0)
	
	difficulty_system.set_difficulty(difficulty_system.Difficulty.HARD)
	assert_eq(difficulty_system.get_bumper_force(), 350.0)

func test_multiplier_decay_settings():
	difficulty_system.set_difficulty(difficulty_system.Difficulty.EASY)
	assert_eq(difficulty_system.is_multiplier_decay_enabled(), false)
	assert_eq(difficulty_system.get_multiplier_decay_time(), 20.0)
	assert_eq(difficulty_system.get_multiplier_decay_amount(), 0.25)
	
	difficulty_system.set_difficulty(difficulty_system.Difficulty.NORMAL)
	assert_eq(difficulty_system.is_multiplier_decay_enabled(), true)
	assert_eq(difficulty_system.get_multiplier_decay_time(), 15.0)
	assert_eq(difficulty_system.get_multiplier_decay_amount(), 0.5)

func test_extra_ball_chance():
	difficulty_system.set_difficulty(difficulty_system.Difficulty.EASY)
	assert_eq(difficulty_system.get_extra_ball_chance(), 0.15)
	
	difficulty_system.set_difficulty(difficulty_system.Difficulty.HARD)
	assert_eq(difficulty_system.get_extra_ball_chance(), 0.05)

func test_difficulty_changed_signal():
	watch_signals(difficulty_system)
	difficulty_system.set_difficulty(difficulty_system.Difficulty.HARD)
	assert_signal_emitted(difficulty_system, "difficulty_changed")

func test_reset():
	difficulty_system.set_difficulty(difficulty_system.Difficulty.HARD)
	difficulty_system.reset()
	assert_eq(difficulty_system.current_difficulty, difficulty_system.Difficulty.NORMAL,
		"reset should set difficulty back to NORMAL")

func after_all():
	pass

extends "res://addons/gut/test.gd"
## Unit tests for TutorialSystemV4.gd

var tutorial_system: Node = null

func before_all():
	tutorial_system = autoqfree(load("res://scripts/v4/TutorialSystemV4.gd").new())
	add_child(tutorial_system)

func test_tutorial_system_exists():
	assert_not_null(tutorial_system, "TutorialSystemV4 should exist")
	assert_eq(tutorial_system.get_script().resource_path, "res://scripts/v4/TutorialSystemV4.gd")

func test_tutorial_steps_setup():
	assert_gt(tutorial_system._steps.size(), 0, "Tutorial steps should be defined")
	assert_eq(tutorial_system._steps[0]["id"], "welcome", "First step should be welcome")

func test_initial_state():
	assert_eq(tutorial_system._state, tutorial_system.TutorialState.NOT_STARTED,
		"Initial state should be NOT_STARTED")
	assert_eq(tutorial_system._current_step, 0, "Initial step should be 0")
	assert_eq(tutorial_system.is_tutorial_active(), false, "Tutorial should not be active initially")

func test_start_tutorial():
	watch_signals(tutorial_system)
	tutorial_system.start_tutorial()
	
	assert_eq(tutorial_system._state, tutorial_system.TutorialState.IN_PROGRESS,
		"State should be IN_PROGRESS after start")
	assert_eq(tutorial_system.is_tutorial_active(), true, "Tutorial should be active")
	assert_signal_emitted(tutorial_system, "tutorial_step_completed")

func test_skip_tutorial():
	tutorial_system.start_tutorial()
	watch_signals(tutorial_system)
	tutorial_system.skip_tutorial()
	
	assert_eq(tutorial_system._state, tutorial_system.TutorialState.SKIPPED,
		"State should be SKIPPED after skip")
	assert_eq(tutorial_system.is_tutorial_active(), false, "Tutorial should not be active")
	assert_signal_emitted(tutorial_system, "tutorial_skipped")

func test_complete_tutorial():
	tutorial_system.start_tutorial()
	watch_signals(tutorial_system)
	tutorial_system.complete_tutorial()
	
	assert_eq(tutorial_system._state, tutorial_system.TutorialState.COMPLETED,
		"State should be COMPLETED")
	assert_eq(tutorial_system.is_tutorial_active(), false, "Tutorial should not be active")
	assert_signal_emitted(tutorial_system, "tutorial_completed")

func test_get_current_step():
	tutorial_system.start_tutorial()
	var step = tutorial_system.get_current_step()
	
	assert_false(step.is_empty(), "Should return current step")
	assert_eq(step["id"], "welcome", "Should return correct step")

func test_get_progress():
	tutorial_system.start_tutorial()
	var progress = tutorial_system.get_progress()
	
	assert_ge(progress, 0.0, "Progress should be >= 0")
	assert_le(progress, 1.0, "Progress should be <= 1")

func test_jump_to_step():
	tutorial_system.start_tutorial()
	tutorial_system.jump_to_step("scoring")
	
	var step = tutorial_system.get_current_step()
	assert_eq(step["id"], "scoring", "Should jump to specified step")

func test_has_completed_tutorial():
	var completed = tutorial_system.has_completed_tutorial()
	# Initially should be false (unless file exists)
	assert_typeof(completed, TYPE_BOOL, "Should return boolean")

func test_show_prompt():
	# Should not crash
	tutorial_system.show_prompt("flipper_hint", 1.0)
	pass_test("show_prompt should not crash")

func test_tutorial_step_structure():
	tutorial_system.start_tutorial()
	var step = tutorial_system.get_current_step()
	
	assert_true(step.has("id"), "Step should have id")
	assert_true(step.has("title"), "Step should have title")
	assert_true(step.has("message"), "Step should have message")
	assert_true(step.has("action"), "Step should have action")

func test_cannot_start_twice():
	tutorial_system.start_tutorial()
	var step_before = tutorial_system._current_step
	tutorial_system.start_tutorial()  # Try to start again
	var step_after = tutorial_system._current_step
	
	assert_eq(step_before, step_after, "Should not restart if already in progress")

func after_all():
	# Cleanup test save files
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive("user://saves")
		var save_dir = DirAccess.open("user://saves/")
		if save_dir:
			if save_dir.file_exists("tutorial_completed.txt"):
				save_dir.remove("tutorial_completed.txt")

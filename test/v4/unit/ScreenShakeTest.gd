extends "res://addons/gut/test.gd"
## Unit tests for ScreenShake.gd

var screen_shake: Node = null
var test_camera: Camera2D = null

func before_all():
	screen_shake = autoqfree(load("res://scripts/v4/ScreenShake.gd").new())
	add_child(screen_shake)
	
	# Create a test camera
	test_camera = Camera2D.new()
	test_camera.name = "TestCamera"
	add_child(test_camera)
	test_camera.add_to_group("main_camera")

func test_screen_shake_exists():
	assert_not_null(screen_shake, "ScreenShake should exist")
	assert_eq(screen_shake.get_script().resource_path, "res://scripts/v4/ScreenShake.gd")

func test_shake_intensity():
	screen_shake.shake_intensity(10.0, 0.2)
	assert_eq(screen_shake._current_shake, 10.0, "Shake intensity should be set")
	assert_eq(screen_shake._shake_timer, 0.2, "Shake timer should be set")
	assert_eq(screen_shake._is_shaking, true, "Shake should be active")

func test_shake_light():
	screen_shake.shake_light()
	assert_gt(screen_shake._current_shake, 0.0, "Light shake should have intensity")
	assert_lt(screen_shake._current_shake, screen_shake.default_shake_intensity,
		"Light shake should be less than default")

func test_shake_medium():
	screen_shake.shake_medium()
	assert_gt(screen_shake._current_shake, 0.0, "Medium shake should have intensity")
	assert_lt(screen_shake._current_shake, screen_shake.default_shake_intensity,
		"Medium shake should be less than default")

func test_shake_heavy():
	screen_shake.shake_heavy()
	assert_eq(screen_shake._current_shake, screen_shake.default_shake_intensity,
		"Heavy shake should equal default intensity")

func test_shake_extreme():
	screen_shake.shake_extreme()
	assert_gt(screen_shake._current_shake, screen_shake.default_shake_intensity,
		"Extreme shake should be greater than default")

func test_shake_queue():
	screen_shake.shake_intensity(5.0, 0.1)
	screen_shake.shake(10.0, 0.2)  # Should queue
	
	assert_eq(screen_shake._shake_queue.size(), 1, "Shake should be queued")
	assert_eq(screen_shake._shake_queue[0]["intensity"], 10.0)
	assert_eq(screen_shake._shake_queue[0]["duration"], 0.2)

func test_shake_decay():
	screen_shake.shake_intensity(10.0, 1.0)
	var initial_shake = screen_shake._current_shake
	
	screen_shake._process(0.1)
	var after_decay = screen_shake._current_shake
	
	assert_lt(after_decay, initial_shake, "Shake should decay over time")

func test_shake_timeout():
	screen_shake.shake_intensity(10.0, 0.1)
	watch_signals(screen_shake)
	
	screen_shake._process(0.15)  # Process past timeout
	
	assert_signal_emitted(screen_shake, "shake_completed")
	assert_eq(screen_shake._is_shaking, false, "Shake should stop after timeout")

func test_stop_shake():
	screen_shake.shake_intensity(10.0, 1.0)
	screen_shake.shake(5.0, 0.5)  # Add to queue
	
	screen_shake.stop_shake()
	
	assert_eq(screen_shake._is_shaking, false, "Shake should stop")
	assert_eq(screen_shake._current_shake, 0.0, "Shake intensity should be 0")
	assert_eq(screen_shake._shake_queue.size(), 0, "Queue should be cleared")

func test_queued_shake_processing():
	screen_shake.shake_intensity(5.0, 0.05)
	screen_shake.shake(10.0, 0.1)
	
	# Process until first shake completes
	screen_shake._process(0.06)
	
	# Second shake should start
	assert_eq(screen_shake._current_shake, 10.0, "Queued shake should start")
	assert_eq(screen_shake._shake_queue.size(), 0, "Queue should be empty")

func test_camera_finding():
	# Test that camera is found
	screen_shake._find_camera()
	assert_not_null(screen_shake._camera, "Camera should be found")

func after_all():
	if test_camera:
		test_camera.queue_free()

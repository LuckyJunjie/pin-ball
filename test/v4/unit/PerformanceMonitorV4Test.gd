extends "res://addons/gut/test.gd"
## Unit tests for PerformanceMonitorV4.gd

var performance_monitor: Node = null

func before_all():
	performance_monitor = autoqfree(load("res://scripts/v4/PerformanceMonitorV4.gd").new())
	add_child(performance_monitor)

func test_performance_monitor_exists():
	assert_not_null(performance_monitor, "PerformanceMonitorV4 should exist")
	assert_eq(performance_monitor.get_script().resource_path, "res://scripts/v4/PerformanceMonitorV4.gd")

func test_initial_state():
	assert_eq(performance_monitor.target_fps, 60, "Default target FPS should be 60")
	assert_eq(performance_monitor.warning_threshold, 30, "Default warning threshold should be 30")
	assert_eq(performance_monitor.auto_optimize, true, "Auto optimize should be enabled by default")

func test_fps_measurement():
	watch_signals(performance_monitor)
	performance_monitor._measure_performance()
	
	assert_signal_emitted(performance_monitor, "fps_updated")
	assert_gt(performance_monitor._fps_history.size(), 0, "FPS history should be populated")

func test_get_average_fps():
	performance_monitor._fps_history = [60.0, 55.0, 50.0]
	var avg = performance_monitor.get_average_fps()
	assert_eq(avg, 55.0, "Should calculate average FPS correctly")

func test_get_min_fps():
	performance_monitor._fps_history = [60.0, 30.0, 50.0]
	var min_fps = performance_monitor.get_min_fps()
	assert_eq(min_fps, 30.0, "Should return minimum FPS")

func test_get_max_fps():
	performance_monitor._fps_history = [60.0, 70.0, 50.0]
	var max_fps = performance_monitor.get_max_fps()
	assert_eq(max_fps, 70.0, "Should return maximum FPS")

func test_is_performing_well():
	performance_monitor._fps_history = [60.0, 55.0, 50.0]
	assert_true(performance_monitor.is_performing_well(), "Should be performing well above threshold")
	
	performance_monitor._fps_history = [20.0, 25.0, 30.0]
	assert_false(performance_monitor.is_performing_well(), "Should not be performing well below threshold")

func test_performance_warning():
	watch_signals(performance_monitor)
	performance_monitor._last_fps = 15.0  # Below critical threshold
	performance_monitor._measure_performance()
	
	assert_signal_emitted(performance_monitor, "performance_warning")

func test_fps_history_limit():
	for i in range(100):
		performance_monitor._fps_history.append(60.0)
	
	assert_le(performance_monitor._fps_history.size(), performance_monitor._history_size,
		"FPS history should not exceed history_size")

func after_all():
	pass

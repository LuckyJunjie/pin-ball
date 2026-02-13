extends "res://addons/gut/test.gd"
## Unit tests for BallTrailV4.gd

var ball_trail: Node2D = null
var test_ball: RigidBody2D = null

func before_all():
	ball_trail = autoqfree(load("res://scripts/v4/BallTrailV4.gd").new())
	add_child(ball_trail)
	
	test_ball = RigidBody2D.new()
	test_ball.name = "TestBall"
	test_ball.position = Vector2(100, 100)
	add_child(test_ball)

func test_ball_trail_exists():
	assert_not_null(ball_trail, "BallTrailV4 should exist")
	assert_eq(ball_trail.get_script().resource_path, "res://scripts/v4/BallTrailV4.gd")

func test_initial_state():
	assert_eq(ball_trail.is_visible(), false, "Trail should not be visible initially")
	assert_eq(ball_trail._trail_points.size(), 0, "Trail points should be empty initially")

func test_set_ball():
	watch_signals(ball_trail)
	ball_trail.set_ball(test_ball)
	
	assert_eq(ball_trail._ball, test_ball, "Ball should be set")
	assert_eq(ball_trail.is_visible(), true, "Trail should be visible when ball is set")
	assert_signal_emitted(ball_trail, "trail_visibility_changed")

func test_set_ball_null():
	ball_trail.set_ball(test_ball)
	ball_trail.set_ball(null)
	
	assert_eq(ball_trail._ball, null, "Ball should be cleared")
	assert_eq(ball_trail.is_visible(), false, "Trail should not be visible when ball is null")

func test_trail_update():
	ball_trail.set_ball(test_ball)
	ball_trail._update_trail()
	
	assert_gt(ball_trail._trail_points.size(), 0, "Trail points should be added")

func test_trail_length():
	ball_trail.set_trail_length(10)
	assert_eq(ball_trail.trail_length, 10, "Trail length should be set")
	
	ball_trail.set_ball(test_ball)
	ball_trail._update_trail()
	
	# Trail should initialize with specified length
	assert_le(ball_trail._trail_points.size(), ball_trail.trail_length,
		"Trail points should not exceed trail_length")

func test_trail_color():
	var new_color = Color(1.0, 0.0, 0.0, 1.0)
	ball_trail.set_trail_color(new_color)
	assert_eq(ball_trail.trail_color, new_color, "Trail color should be set")

func test_trail_width():
	ball_trail.set_trail_width(8.0)
	assert_eq(ball_trail.trail_width, 8.0, "Trail width should be set")

func test_clear_trail():
	ball_trail.set_ball(test_ball)
	ball_trail._update_trail()
	
	ball_trail.clear_trail()
	
	# Trail should be cleared (points reset to zero)
	assert_eq(ball_trail._trail_points.size(), ball_trail.trail_length,
		"Trail should be cleared")

func test_minimum_trail_length():
	ball_trail.set_trail_length(1)  # Try to set below minimum
	assert_ge(ball_trail.trail_length, 2, "Trail length should be at least 2")

func test_trail_visibility_changed_signal():
	watch_signals(ball_trail)
	ball_trail.set_ball(test_ball)
	assert_signal_emitted(ball_trail, "trail_visibility_changed")

func after_all():
	if test_ball:
		test_ball.queue_free()

extends GutTest

## Regression Tests - Physics System
## Ensures physics changes don't break existing behavior

func test_ball_physics_properties():
	"""Test ball physics properties are correct"""
	var ball_scene = load("res://scenes/Ball.tscn")
	var ball = ball_scene.instantiate()
	add_child_autofree(ball)
	
	# Check physics properties
	assert_eq(ball.gravity_scale, 1.0, "Ball gravity should be 1.0")
	assert_gt(ball.mass, 0.0, "Ball should have mass")
	
	var material = ball.physics_material_override
	assert_not_null(material, "Ball should have physics material")
	assert_gt(material.bounce, 0.0, "Ball should have bounce")

func test_flipper_physics_properties():
	"""Test flipper physics properties are correct"""
	var flipper_scene = load("res://scenes/Flipper.tscn")
	var flipper = flipper_scene.instantiate()
	add_child_autofree(flipper)
	
	# Check physics properties
	assert_eq(flipper.gravity_scale, 0.0, "Flipper should have no gravity")
	assert_eq(flipper.freeze, true, "Flipper should be frozen")
	assert_eq(flipper.collision_layer, 2, "Flipper should be on layer 2")

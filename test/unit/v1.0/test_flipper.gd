extends GutTest

## v1.0: Flipper System Tests
## Tests flipper controls, rotation, and physics

var flipper_scene: PackedScene
var flipper_instance: RigidBody2D

func before_each():
	# Load flipper scene
	flipper_scene = load("res://scenes/Flipper.tscn")
	assert_not_null(flipper_scene, "Flipper scene should load")
	
	# Create flipper instance
	flipper_instance = flipper_scene.instantiate()
	add_child_autofree(flipper_instance)
	assert_not_null(flipper_instance, "Flipper instance should be created")

func test_flipper_initialization():
	"""Test flipper initializes correctly"""
	assert_not_null(flipper_instance, "Flipper should exist")
	assert_eq(flipper_instance.collision_layer, 2, "Flipper should be on collision layer 2")
	assert_eq(flipper_instance.gravity_scale, 0.0, "Flipper should have no gravity")
	assert_eq(flipper_instance.freeze, true, "Flipper should be frozen (kinematic)")

func test_flipper_side_configuration():
	"""Test left and right flipper configuration"""
	# Test left flipper
	flipper_instance.flipper_side = "left"
	flipper_instance._ready()
	assert_gt(flipper_instance.rest_angle, 0, "Left flipper rest angle should be positive")
	assert_lt(flipper_instance.pressed_angle, 0, "Left flipper pressed angle should be negative")
	
	# Test right flipper
	flipper_instance.flipper_side = "right"
	flipper_instance._ready()
	assert_lt(flipper_instance.rest_angle, 0, "Right flipper rest angle should be negative")
	assert_gt(flipper_instance.pressed_angle, 0, "Right flipper pressed angle should be positive")

func test_flipper_rotation_to_rest():
	"""Test flipper rotates to rest position"""
	flipper_instance.rotation_degrees = 45.0
	flipper_instance.target_angle = flipper_instance.rest_angle
	flipper_instance.is_pressed = false
	
	# Simulate physics process
	for i in range(10):
		flipper_instance._physics_process(0.016)
	
	# Should be close to rest angle
	assert_almost_eq(flipper_instance.rotation_degrees, flipper_instance.rest_angle, 5.0, 
		"Flipper should rotate toward rest angle")

func test_flipper_physics_material():
	"""Test flipper physics material"""
	var material = flipper_instance.physics_material_override
	assert_not_null(material, "Flipper should have physics material")
	assert_gt(material.bounce, 0.0, "Flipper should have bounce > 0")

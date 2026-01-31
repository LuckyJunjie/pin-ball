extends GutTest

## v3.0: Skill Shot System Tests
## Tests skill shot activation, detection, and scoring

var skill_shot: Area2D

func before_each():
	# Create SkillShot instance
	var script = load("res://scripts/SkillShot.gd")
	skill_shot = Area2D.new()
	skill_shot.set_script(script)
	skill_shot.skill_shot_points = 200
	skill_shot.time_window = 2.5
	add_child_autofree(skill_shot)

func test_skill_shot_initialization():
	"""Test skill shot initializes correctly"""
	assert_not_null(skill_shot, "SkillShot should exist")
	assert_false(skill_shot.is_active, "Skill shot should start inactive")
	assert_eq(skill_shot.skill_shot_points, 200, "Should have correct point value")

func test_skill_shot_activation():
	"""Test skill shot activation"""
	watch_signals(skill_shot)
	
	skill_shot.activate()
	
	assert_true(skill_shot.is_active, "Skill shot should be active")
	assert_eq(skill_shot.activation_timer, 2.5, "Activation timer should be set")

func test_skill_shot_deactivation():
	"""Test skill shot deactivation after time window"""
	skill_shot.activate()
	skill_shot.activation_timer = 0.0
	skill_shot._process(0.016)
	
	assert_false(skill_shot.is_active, "Skill shot should deactivate after timer expires")

func test_skill_shot_hit():
	"""Test skill shot hit detection and scoring"""
	watch_signals(skill_shot)
	
	skill_shot.activate()
	skill_shot.has_been_hit = false
	
	# Create a mock ball
	var ball = RigidBody2D.new()
	ball.collision_layer = 1
	add_child_autofree(ball)
	
	# Simulate body entering
	skill_shot._on_body_entered(ball)
	
	assert_true(skill_shot.has_been_hit, "Skill shot should be marked as hit")
	assert_signal_emitted(skill_shot, "skill_shot_hit", "Should emit skill_shot_hit signal")
	assert_false(skill_shot.is_active, "Skill shot should deactivate after hit")

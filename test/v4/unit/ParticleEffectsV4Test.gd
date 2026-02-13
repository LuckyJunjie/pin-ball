extends "res://addons/gut/test.gd"
## Unit tests for ParticleEffectsV4.gd

var particle_effects: Node2D = null

func before_all():
	particle_effects = autoqfree(load("res://scripts/v4/ParticleEffectsV4.gd").new())
	add_child(particle_effects)

func test_particle_effects_exists():
	assert_not_null(particle_effects, "ParticleEffectsV4 should exist")
	assert_eq(particle_effects.get_script().resource_path, "res://scripts/v4/ParticleEffectsV4.gd")

func test_spawn_hit_effect():
	# Should not crash
	particle_effects.spawn_hit_effect(Vector2(100, 100))
	pass_test("spawn_hit_effect should not crash")

func test_spawn_score_popup():
	particle_effects.spawn_score_popup(Vector2(100, 100), 1000)
	pass_test("spawn_score_popup should not crash")

func test_spawn_bonus_effect():
	particle_effects.spawn_bonus_effect(Vector2(100, 100))
	pass_test("spawn_bonus_effect should not crash")

func test_spawn_letter_effect():
	particle_effects.spawn_letter_effect(Vector2(100, 100), "G")
	pass_test("spawn_letter_effect should not crash")

func test_spawn_multiplier_effect():
	watch_signals(particle_effects)
	particle_effects.spawn_multiplier_effect(2)
	assert_signal_emitted(particle_effects, "particle_effect_completed")

func test_spawn_zone_activation_effect():
	particle_effects.spawn_zone_activation_effect("sparky_scorch", Vector2(100, 100))
	pass_test("spawn_zone_activation_effect should not crash")

func test_clear_all_effects():
	particle_effects.spawn_hit_effect(Vector2(100, 100))
	particle_effects.clear_all_effects()
	pass_test("clear_all_effects should not crash")

func after_all():
	pass

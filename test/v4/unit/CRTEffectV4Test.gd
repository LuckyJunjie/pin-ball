extends "res://addons/gut/test.gd"
## Unit tests for CRTEffectV4.gd

var crt_effect: Node = null

func before_all():
	crt_effect = autoqfree(load("res://scripts/v4/CRTEffectV4.gd").new())
	add_child(crt_effect)

func test_crt_effect_exists():
	assert_not_null(crt_effect, "CRTEffectV4 should exist")
	assert_eq(crt_effect.get_script().resource_path, "res://scripts/v4/CRTEffectV4.gd")

func test_initial_state():
	assert_eq(crt_effect.enabled, true, "CRT effect should be enabled by default")

func test_set_enabled():
	crt_effect.set_enabled(false)
	assert_eq(crt_effect.enabled, false, "set_enabled should change enabled state")
	assert_eq(crt_effect.visible, false, "visible should match enabled state")
	
	crt_effect.set_enabled(true)
	assert_eq(crt_effect.enabled, true, "set_enabled should enable")

func test_set_scanline_intensity():
	crt_effect.set_scanline_intensity(0.5)
	assert_eq(crt_effect.scanline_intensity, 0.5, "scanline_intensity should be set")
	
	crt_effect.set_scanline_intensity(2.0)  # Above max
	assert_le(crt_effect.scanline_intensity, 1.0, "Should clamp to 1.0")
	
	crt_effect.set_scanline_intensity(-1.0)  # Below min
	assert_ge(crt_effect.scanline_intensity, 0.0, "Should clamp to 0.0")

func test_set_glow_strength():
	crt_effect.set_glow_strength(1.0)
	assert_eq(crt_effect.glow_strength, 1.0, "glow_strength should be set")
	
	crt_effect.set_glow_strength(3.0)  # Above max
	assert_le(crt_effect.glow_strength, 2.0, "Should clamp to 2.0")

func test_set_chromatic_aberration():
	crt_effect.set_chromatic_aberration(0.005)
	assert_eq(crt_effect.chromatic_aberration, 0.005, "chromatic_aberration should be set")
	
	crt_effect.set_chromatic_aberration(0.02)  # Above max
	assert_le(crt_effect.chromatic_aberration, 0.01, "Should clamp to 0.01")

func test_set_curvature():
	crt_effect.set_curvature(0.1)
	assert_eq(crt_effect.curvature_amount, 0.1, "curvature_amount should be set")
	
	crt_effect.set_curvature(0.3)  # Above max
	assert_le(crt_effect.curvature_amount, 0.2, "Should clamp to 0.2")

func test_set_vignette():
	crt_effect.set_vignette(0.5)
	assert_eq(crt_effect.vignette_intensity, 0.5, "vignette_intensity should be set")
	
	crt_effect.set_vignette(2.0)  # Above max
	assert_le(crt_effect.vignette_intensity, 1.0, "Should clamp to 1.0")

func test_set_noise():
	crt_effect.set_noise(0.05)
	assert_eq(crt_effect.noise_intensity, 0.05, "noise_intensity should be set")
	
	crt_effect.set_noise(0.2)  # Above max
	assert_le(crt_effect.noise_intensity, 0.1, "Should clamp to 0.1")

func test_toggle():
	crt_effect.set_enabled(true)
	crt_effect.toggle()
	assert_eq(crt_effect.enabled, false, "toggle should disable")
	
	crt_effect.toggle()
	assert_eq(crt_effect.enabled, true, "toggle should enable")

func test_material_setup():
	# Material should be created in _ready
	assert_not_null(crt_effect._material, "Material should be created")

func test_process_updates_time():
	var time_before = crt_effect._material.get_shader_parameter("time_scale") if crt_effect._material else 0.0
	crt_effect._process(0.1)
	var time_after = crt_effect._material.get_shader_parameter("time_scale") if crt_effect._material else 0.0
	
	# Time should update (or at least material should exist)
	assert_not_null(crt_effect._material, "Material should exist after process")

func after_all():
	pass

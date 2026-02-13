extends Node
## v4.0 Dynamic Lighting System
## Advanced lighting with shadows, glow, and dynamic color changes

signal lighting_changed(zone_name: String, intensity: float)

@export var ambient_light_color: Color = Color(0.2, 0.2, 0.3)
@export var ambient_light_energy: float = 0.5
@export var shadow_quality: int = 2  # 0=off, 1=medium, 2=high

var _light_nodes: Dictionary = {}
var _zone_lighting: Dictionary = {}
var _global_light_energy: float = 1.0

func _ready() -> void:
	add_to_group("lighting_system")
	_setup_lighting()

func _setup_lighting() -> void:
	# Initialize zone lighting states
	_zone_lighting = {
		"android_acres": {"color": Color(0.2, 0.8, 0.2), "energy": 1.0},
		"google_gallery": {"color": Color(0.2, 0.5, 1.0), "energy": 1.0},
		"flutter_forest": {"color": Color(0.2, 1.0, 0.8), "energy": 1.0},
		"dino_desert": {"color": Color(1.0, 0.5, 0.2), "energy": 1.0},
		"sparky_scorch": {"color": Color(1.0, 0.2, 0.5), "energy": 1.0},
		"default": {"color": Color(1.0, 1.0, 1.0), "energy": 1.0}
	}

func set_zone_light(zone_name: String, color: Color, energy: float) -> void:
	if _zone_lighting.has(zone_name):
		_zone_lighting[zone_name]["color"] = color
		_zone_lighting[zone_name]["energy"] = energy
		lighting_changed.emit(zone_name, energy)
		_apply_zone_lighting(zone_name)

func set_global_light_energy(energy: float) -> void:
	_global_light_energy = clamp(energy, 0.0, 2.0)
	_apply_all_lighting()

func pulse_light(zone_name: String, duration: float = 0.5, intensity: float = 1.5) -> void:
	if not _zone_lighting.has(zone_name):
		return
	
	var original_energy = _zone_lighting[zone_name]["energy"]
	_zone_lighting[zone_name]["energy"] = intensity
	
	var tween = create_tween()
	tween.tween_method(
		func(val): _zone_lighting[zone_name]["energy"] = val,
		original_energy,
		intensity,
		duration / 2
	)
	tween.tween_method(
		func(val): _zone_lighting[zone_name]["energy"] = val,
		intensity,
		original_energy,
		duration / 2
	)
	tween.tween_callback(func(): _apply_zone_lighting(zone_name))

func flash_light(color: Color, duration: float = 0.1) -> void:
	var tween = create_tween()
	_apply_all_lighting_color(color)
	tween.tween_callback(func(): _apply_all_lighting())
	tween.tween_interval(duration)
	tween.tween_callback(func(): _apply_all_lighting())

func set_light_color_for_time(zone_name: String, color: Color, duration: float) -> void:
	if not _zone_lighting.has(zone_name):
		return
	
	var original_color = _zone_lighting[zone_name]["color"]
	_zone_lighting[zone_name]["color"] = color
	_apply_zone_lighting(zone_name)
	
	await get_tree().create_timer(duration).timeout
	_zone_lighting[zone_name]["color"] = original_color
	_apply_zone_lighting(zone_name)

func _apply_zone_lighting(zone_name: String) -> void:
	# In a real implementation, would adjust actual light nodes
	print("Lighting: Zone %s color=%s energy=%.2f" % [
		zone_name,
		_zone_lighting[zone_name]["color"],
		_zone_lighting[zone_name]["energy"]
	])

func _apply_all_lighting() -> void:
	for zone in _zone_lighting:
		_apply_zone_lighting(zone)

func _apply_all_lighting_color(color: Color) -> void:
	for zone in _zone_lighting:
		_zone_lighting[zone]["color"] = color

func get_zone_light_info(zone_name: String) -> Dictionary:
	if _zone_lighting.has(zone_name):
		return _zone_lighting[zone_name].duplicate()
	return {}

func set_shadows(enabled: bool) -> void:
	shadow_quality = 2 if enabled else 0

func set_glow_enabled(enabled: bool) -> void:
	# Toggle global glow effect
	var crt = get_tree().get_first_node_in_group("post_processing")
	if crt and crt.has_method("set_glow_strength"):
		if enabled:
			crt.set_glow_strength(0.5)
		else:
			crt.set_glow_strength(0.0)

func create_light_glow(light_type: String, color: Color) -> void:
	# Create temporary glow effect
	pass

func animate_light_to(zone_name: String, target_color: Color, duration: float) -> void:
	if not _zone_lighting.has(zone_name):
		return
	
	var start_color = _zone_lighting[zone_name]["color"]
	var tween = create_tween()
	tween.tween_method(
		func(val): _zone_lighting[zone_name]["color"] = val,
		start_color,
		target_color,
		duration
	)
	tween.tween_callback(func(): _apply_zone_lighting(zone_name))

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("lighting_system")
	return null

extends Node
## v4.0 Special Ball System
## Different ball types with unique abilities and visual effects

signal ball_type_changed(ball_type: String)

enum BallType { NORMAL, FIREBALL, GHOSTBALL, MULTIBALL, MEGABALL }

var _ball_types: Dictionary = {
	BallType.NORMAL: {
		"name": "Normal",
		"description": "Standard pinball",
		"color": Color.WHITE,
		"physics": {"gravity": 1.0, "bounce": 0.85, "mass": 0.4},
		"special_ability": "",
		"duration": 0,
		"probability": 0.7
	},
	BallType.FIREBALL: {
		"name": "Fireball",
		"description": "Burns through bumpers for 2x points!",
		"color": Color(1.0, 0.3, 0.0),
		"physics": {"gravity": 1.0, "bounce": 0.95, "mass": 0.3},
		"special_ability": "double_points",
		"duration": 15.0,
		"probability": 0.1
	},
	BallType.GHOSTBALL: {
		"name": "Ghost Ball",
		"description": "Passes through flippers once",
		"color": Color(0.5, 0.8, 1.0, 0.6),
		"physics": {"gravity": 0.8, "bounce": 0.5, "mass": 0.2},
		"special_ability": "phase_through",
		"duration": 5.0,
		"probability": 0.1
	},
	BallType.MULTIBALL: {
		"name": "Multiball",
		"description": "Spawns 2 extra balls!",
		"color": Color(1.0, 0.8, 0.0),
		"physics": {"gravity": 1.0, "bounce": 0.9, "mass": 0.4},
		"special_ability": "spawn_balls",
		"duration": 0,
		"spawn_count": 2,
		"probability": 0.05
	},
	BallType.MEGABALL: {
		"name": "Mega Ball",
		"description": "Larger ball, 3x points!",
		"color": Color(0.8, 0.2, 1.0),
		"physics": {"gravity": 1.2, "bounce": 0.8, "mass": 0.6},
		"special_ability": "triple_points",
		"duration": 20.0,
		"probability": 0.05
	}
}

var _current_ball_type: BallType = BallType.NORMAL
var _active_ball_types: Array = []
var _ball_pool: Node2D = null

func _ready() -> void:
	add_to_group("special_ball_system")

func spawn_special_ball(type: BallType, position: Vector2 = Vector2(400, 500)) -> Node2D:
	if not _ball_types.has(type):
		return null
	
	var ball_data = _ball_types[type]
	var ball = _create_ball_with_type(type)
	
	if ball:
		ball.global_position = position
		_apply_ball_properties(ball, type)
		_active_ball_types.append(type)
		ball_type_changed.emit(_get_ball_type_name(type))
	
	return ball

func _create_ball_with_type(type: BallType) -> Node2D:
	# Create a special ball instance
	var ball = Node2D.new()
	ball.name = "SpecialBall_%s" % type
	ball.add_to_group("balls")
	ball.add_to_group("special_balls")
	return ball

func _apply_ball_properties(ball: Node2D, type: BallType) -> void:
	var data = _ball_types[type]
	
	# Apply visual
	if ball.has_method("set_color"):
		ball.set_color(data["color"])
	
	# Apply physics
	if ball.has_method("set_physics"):
		ball.set_physics(data["physics"])
	
	# Apply special ability
	match data.get("special_ability"):
		"double_points":
			_apply_double_points(ball)
		"triple_points":
			_apply_triple_points(ball)
		"phase_through":
			_apply_phase_through(ball)
		"spawn_balls":
			_apply_spawn_balls(ball, data.get("spawn_count", 2))

func _apply_double_points(ball: Node) -> void:
	ball.set_meta("score_multiplier", 2.0)

func _apply_triple_points(ball: Node) -> void:
	ball.set_meta("score_multiplier", 3.0)

func _apply_phase_through(ball: Node) -> void:
	ball.set_meta("can_phase", true)
	ball.set_collision_mask_value(2, false)  # Disable flipper collision

func _apply_spawn_balls(ball: Node, count: int) -> void:
	ball.set_meta("spawn_on_hit", true)
	ball.set_meta("spawn_count", count)

func get_ball_type() -> BallType:
	return _current_ball_type

func get_ball_info(type: BallType) -> Dictionary:
	if _ball_types.has(type):
		return _ball_types[type].duplicate()
	return {}

func get_random_ball_type() -> BallType:
	var rand = randf()
	var cumulative = 0.0
	
	for type in _ball_types:
		cumulative += _ball_types[type].get("probability", 0.0)
		if rand <= cumulative:
			return type
	
	return BallType.NORMAL

func roll_for_special_ball() -> BallType:
	if randf() < 0.2:  # 20% chance for special ball
		return get_random_ball_type()
	return BallType.NORMAL

func is_special_ball(ball: Node) -> bool:
	return ball.is_in_group("special_balls")

func get_special_ability(ball: Node) -> String:
	if ball.has_meta("special_ability"):
		return ball.get_meta("special_ability")
	return ""

func get_score_multiplier(ball: Node) -> float:
	if ball.has_meta("score_multiplier"):
		return ball.get_meta("score_multiplier")
	return 1.0

func on_ball_hit_bumper(ball: Node, bumper_type: String) -> void:
	var multiplier = get_score_multiplier(ball)
	if multiplier > 1.0:
		_show_multiplier_effect(ball.global_position, multiplier)

func on_ball_hit_flipper(ball: Node) -> void:
	if ball.has_meta("can_phase") and ball.get_meta("can_phase"):
		# Use up phase ability
		ball.set_meta("can_phase", false)
		ball.set_collision_mask_value(2, true)  # Re-enable flipper collision
		_apply_ghosting_effect(ball)

func _apply_ghosting_effect(ball: Node) -> void:
	# Visual feedback for ghosting
	ball.modulate.a = 1.0  # Restore opacity

func _show_multiplier_effect(position: Vector2, multiplier: float) -> void:
	var particles = get_tree().get_first_node_in_group("particle_system")
	if particles and particles.has_method("spawn_hit_effect"):
		particles.spawn_hit_effect(position, Color.GOLD, 15)

func activate_multiball(ball: Node) -> void:
	if not ball.has_meta("spawn_on_hit"):
		return
	
	var spawn_count = ball.get_meta("spawn_count", 2)
	ball.set_meta("spawn_on_hit", false)
	
	for i in range(spawn_count):
		var offset = Vector2(randf_range(-30, 30), randf_range(-30, 30))
		spawn_special_ball(BallType.NORMAL, ball.global_position + offset)

func reset_ball(ball: Node) -> void:
	ball.remove_from_group("special_balls")
	ball.modulate.a = 1.0
	if ball.has_meta("score_multiplier"):
		ball.set_meta("score_multiplier", 1.0)
	if ball.has_meta("can_phase"):
		ball.set_meta("can_phase", false)

func _get_ball_type_name(type: BallType) -> String:
	if _ball_types.has(type):
		return _ball_types[type]["name"]
	return "Normal"

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("special_ball_system")
	return null

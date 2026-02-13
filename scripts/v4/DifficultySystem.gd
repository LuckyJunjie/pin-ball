extends Node
## v4.0 Difficulty System
## Provides configurable difficulty levels for gameplay customization

signal difficulty_changed(new_difficulty: Difficulty)

enum Difficulty { EASY, NORMAL, HARD }

const DIFFICULTY_NAMES = {
	Difficulty.EASY: "Easy",
	Difficulty.NORMAL: "Normal",
	Difficulty.HARD: "Hard"
}

# Difficulty configurations
const CONFIGS = {
	Difficulty.EASY: {
		"flipper_strength": 1500.0,
		"gravity_scale": 0.8,
		"bumper_force": 250.0,
		"multiplier_decay_enabled": false,
		"multiplier_decay_time": 20.0,
		"multiplier_decay_amount": 0.25,
		"ball_drain_speed": 0.8,
		"skill_shot_bonus": 1.5,
		"extra_ball_chance": 0.15
	},
	Difficulty.NORMAL: {
		"flipper_strength": 2200.0,
		"gravity_scale": 1.0,
		"bumper_force": 300.0,
		"multiplier_decay_enabled": true,
		"multiplier_decay_time": 15.0,
		"multiplier_decay_amount": 0.5,
		"ball_drain_speed": 1.0,
		"skill_shot_bonus": 1.0,
		"extra_ball_chance": 0.10
	},
	Difficulty.HARD: {
		"flipper_strength": 2800.0,
		"gravity_scale": 1.2,
		"bumper_force": 350.0,
		"multiplier_decay_enabled": false,
		"multiplier_decay_time": 10.0,
		"multiplier_decay_amount": 0.75,
		"ball_drain_speed": 1.3,
		"skill_shot_bonus": 0.75,
		"extra_ball_chance": 0.05
	}
}

var current_difficulty: Difficulty = Difficulty.NORMAL
var difficulty_config: Dictionary = {}

func _ready() -> void:
	add_to_group("difficulty_system")
	_apply_difficulty(current_difficulty)

func _get_debug_mode() -> bool:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		var debug = gm.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func set_difficulty(difficulty: Difficulty) -> void:
	if difficulty != current_difficulty:
		current_difficulty = difficulty
		_apply_difficulty(difficulty)
		difficulty_changed.emit(difficulty)
		if _get_debug_mode():
			print("[DifficultySystem] Changed to %s" % DIFFICULTY_NAMES[difficulty])

func get_difficulty() -> Difficulty:
	return current_difficulty

func get_difficulty_name() -> String:
	return DIFFICULTY_NAMES[current_difficulty]

func _apply_difficulty(difficulty: Difficulty) -> void:
	difficulty_config = CONFIGS[difficulty].duplicate()
	
	# Apply settings to existing nodes
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		# Notify game manager of difficulty change
		if game_manager.has_method("on_difficulty_changed"):
			game_manager.on_difficulty_changed(difficulty)
	
	# Apply flipper settings
	var flippers = get_tree().get_nodes_in_group("flippers")
	for flipper in flippers:
		if flipper.has_method("set_strength"):
			flipper.set_strength(difficulty_config["flipper_strength"])
	
	# Apply ball settings
	var balls = get_tree().get_nodes_in_group("balls")
	for ball in balls:
		if ball.has_method("set_gravity_scale"):
			ball.set_gravity_scale(difficulty_config["gravity_scale"])

func get_flipper_strength() -> float:
	return difficulty_config.get("flipper_strength", 2200.0)

func get_gravity_scale() -> float:
	return difficulty_config.get("gravity_scale", 1.0)

func get_bumper_force() -> float:
	return difficulty_config.get("bumper_force", 300.0)

func is_multiplier_decay_enabled() -> bool:
	return difficulty_config.get("multiplier_decay_enabled", true)

func get_multiplier_decay_time() -> float:
	return difficulty_config.get("multiplier_decay_time", 15.0)

func get_multiplier_decay_amount() -> float:
	return difficulty_config.get("multiplier_decay_amount", 0.5)

func get_ball_drain_speed() -> float:
	return difficulty_config.get("ball_drain_speed", 1.0)

func get_skill_shot_bonus() -> float:
	return difficulty_config.get("skill_shot_bonus", 1.0)

func get_extra_ball_chance() -> float:
	return difficulty_config.get("extra_ball_chance", 0.10)

func reset() -> void:
	# Reset to default difficulty
	set_difficulty(Difficulty.NORMAL)

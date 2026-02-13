extends Node
## v4.0 Challenge Mode System
## Special game modes with unique rules and objectives

signal mode_started(mode_id: String)
signal mode_completed(mode_id: String, success: bool, score: int)
signal mode_progress_changed(progress: float)

enum ChallengeMode { NONE, TIME_ATTACK, SURVIVAL, PRECISION, MADNESS }

var _current_mode: ChallengeMode = ChallengeMode.NONE
var _mode_progress: float = 0.0
var _mode_start_time: float = 0.0
var _mode_objectives: Dictionary = {}
var _mode_stats: Dictionary = {}

# Challenge mode definitions
const MODE_DEFINITIONS = {
	ChallengeMode.TIME_ATTACK: {
		"name": "Time Attack",
		"description": "Score as high as possible in 2 minutes!",
		"rules": "2-minute timer, sudden death",
		"duration": 120.0,
		"difficulty": 2,
		"objectives": ["score", "time"]
	},
	ChallengeMode.SURVIVAL: {
		"name": "Survival",
		"description": "Keep the ball alive as long as possible!",
		"rules": "No extra balls, score per hit",
		"duration": 0,
		"difficulty": 3,
		"objectives": ["time_alive", "balls_lost"]
	},
	ChallengeMode.PRECISION: {
		"name": "Precision",
		"description": "Hit specific targets for bonus points!",
		"rules": "Follow the highlighted targets",
		"duration": 180.0,
		"difficulty": 3,
		"objectives": ["targets_hit", "accuracy"]
	},
	ChallengeMode.MADNESS: {
		"name": "Madness",
		"description": "Everything is放大2x, chaos mode!",
		"rules": "2x ball size, 2x gravity, 3x points",
		"duration": 90.0,
		"difficulty": 5,
		"objectives": ["score", "bonuses"]
	}
}

func _ready() -> void:
	add_to_group("challenge_mode")

func start_mode(mode: ChallengeMode, difficulty: int = 1) -> bool:
	if mode == ChallengeMode.NONE:
		return false
	
	if not MODE_DEFINITIONS.has(mode):
		return false
	
	_current_mode = mode
	_mode_start_time = Time.get_ticks_msec()
	_mode_progress = 0.0
	_mode_objectives = MODE_DEFINITIONS[mode].duplicate()
	_mode_objectives["difficulty"] = difficulty
	
	_apply_mode_settings(mode, difficulty)
	mode_started.emit(_get_mode_name(mode))
	
	return true

func _apply_mode_settings(mode: ChallengeMode, difficulty: int) -> void:
	match mode:
		ChallengeMode.TIME_ATTACK:
			_apply_time_attack_settings(difficulty)
		ChallengeMode.SURVIVAL:
			_apply_survival_settings(difficulty)
		ChallengeMode.PRECISION:
			_apply_precision_settings(difficulty)
		ChallengeMode.MADNESS:
			_apply_madness_settings(difficulty)

func _apply_time_attack_settings(difficulty: int) -> void:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		# 2 minute timer
		pass

func _apply_survival_settings(difficulty: int) -> void:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		# No extra balls
		pass

func _apply_precision_settings(difficulty: int) -> void:
	# Show target indicators
	var ui = get_tree().get_first_node_in_group("ui")
	if ui:
		ui.show_precision_targets(true)

func _apply_madness_settings(difficulty: int) -> void:
	var ball = get_tree().get_first_node_in_group("ball")
	if ball:
		# 2x ball size
		pass

func end_mode(final_score: int) -> bool:
	if _current_mode == ChallengeMode.NONE:
		return false
	
	var mode_name = _get_mode_name(_current_mode)
	var success = _check_mode_success()
	
	mode_completed.emit(mode_name, success, final_score)
	_restore_normal_settings()
	
	_current_mode = ChallengeMode.NONE
	return success

func _check_mode_success() -> bool:
	match _current_mode:
		ChallengeMode.TIME_ATTACK:
			return _mode_progress >= 0.8  # 80% time survived
		ChallengeMode.SURVIVAL:
			return _mode_progress >= 0.5  # 50% time survived
		ChallengeMode.PRECISION:
			return _mode_progress >= 0.7  # 70% targets hit
		ChallengeMode.MADNESS:
			return _mode_progress >= 0.6  # 60% complete
	return false

func _restore_normal_settings() -> void:
	# Restore normal game settings
	var ball = get_tree().get_first_node_in_group("ball")
	if ball:
		# Normal size
		pass

func get_current_mode() -> ChallengeMode:
	return _current_mode

func _get_mode_name(mode: ChallengeMode) -> String:
	if MODE_DEFINITIONS.has(mode):
		return MODE_DEFINITIONS[mode]["name"]
	return ""

func get_mode_description(mode: ChallengeMode) -> String:
	if MODE_DEFINITIONS.has(mode):
		return MODE_DEFINITIONS[mode]["description"]
	return ""

func get_mode_rules(mode: ChallengeMode) -> String:
	if MODE_DEFINITIONS.has(mode):
		return MODE_DEFINITIONS[mode]["rules"]
	return ""

func get_mode_time_remaining() -> float:
	if _current_mode == ChallengeMode.NONE:
		return 0.0
	
	var mode = MODE_DEFINITIONS[_current_mode]
	var duration = mode.get("duration", 0)
	if duration == 0:
		return 999.0  # No time limit
	
	var elapsed = (Time.get_ticks_msec() - _mode_start_time) / 1000.0
	return max(0.0, duration - elapsed)

func get_mode_progress() -> float:
	return _mode_progress

func update_progress(progress: float) -> void:
	_mode_progress = clamp(progress, 0.0, 1.0)
	mode_progress_changed.emit(_mode_progress)

func is_mode_active() -> bool:
	return _current_mode != ChallengeMode.NONE

func get_available_modes() -> Array:
	var modes = []
	for mode in MODE_DEFINITIONS:
		var info = MODE_DEFINITIONS[mode]
		modes.append({
			"id": mode,
			"name": info["name"],
			"description": info["description"],
			"difficulty": info["difficulty"]
		})
	return modes

func get_high_score(mode: ChallengeMode) -> int:
	var key = "challenge_%d_high_score" % mode
	var settings = get_tree().get_first_node_in_group("settings")
	if settings:
		return settings.get_setting("gameplay", key)
	return 0

func save_high_score(mode: ChallengeMode, score: int) -> void:
	var key = "challenge_%d_high_score" % mode
	var settings = get_tree().get_first_node_in_group("settings")
	if settings:
		var current = get_high_score(mode)
		if score > current:
			settings.set_setting("gameplay", key, score)

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("challenge_mode")
	return null

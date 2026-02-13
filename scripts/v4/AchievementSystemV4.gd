extends Node
## v4.0 Achievement System
## Tracks player milestones and achievements

signal achievement_unlocked(achievement_id: String, achievement_name: String)
signal achievement_progress_updated(achievement_id: String, progress: float)

enum AchievementCategory { GENERAL, SCORING, ZONES, COMBOS, BONUSES }

const ACHIEVEMENTS = {
	# General Achievements
	"first_game": {
		"name": "First Game",
		"description": "Play your first game",
		"category": AchievementCategory.GENERAL,
		"condition": "games_played >= 1",
		"points": 10
	},
	"five_games": {
		"name": "Getting Serious",
		"description": "Play 5 games",
		"category": AchievementCategory.GENERAL,
		"condition": "games_played >= 5",
		"points": 25
	},
	"twenty_five_games": {
		"name": "Pinball Wizard",
		"description": "Play 25 games",
		"category": AchievementCategory.GENERAL,
		"condition": "games_played >= 25",
		"points": 50
	},
	
	# Scoring Achievements
	"first_million": {
		"name": "Millionaire",
		"description": "Score over 1,000,000 in a single game",
		"category": AchievementCategory.SCORING,
		"condition": "max_single_game_score >= 1000000",
		"points": 50
	},
	"five_million": {
		"name": "High Roller",
		"description": "Score over 5,000,000 in a single game",
		"category": AchievementCategory.SCORING,
		"condition": "max_single_game_score >= 5000000",
		"points": 100
	},
	"ten_million": {
		"name": "Legend",
		"description": "Score over 10,000,000 in a single game",
		"category": AchievementCategory.SCORING,
		"condition": "max_single_game_score >= 10000000",
		"points": 200
	},
	
	# Multiplier Achievements
	"multiplier_2x": {
		"name": "Heating Up",
		"description": "Reach 2x multiplier",
		"category": AchievementCategory.SCORING,
		"condition": "max_multiplier_reached >= 2",
		"points": 15
	},
	"multiplier_4x": {
		"name": "On Fire",
		"description": "Reach 4x multiplier",
		"category": AchievementCategory.SCORING,
		"condition": "max_multiplier_reached >= 4",
		"points": 30
	},
	"multiplier_6x": {
		"name": "Maximum Power",
		"description": "Reach maximum 6x multiplier",
		"category": AchievementCategory.SCORING,
		"condition": "max_multiplier_reached >= 6",
		"points": 75
	},
	
	# Zone Achievements
	"android_master": {
		"name": "Android Ace",
		"description": "Complete Android Acres bonus 3 times in one game",
		"category": AchievementCategory.ZONES,
		"condition": "android_acres_bonuses >= 3",
		"points": 40
	},
	"google_word": {
		"name": "Spellbound",
		"description": "Complete the GOOGLE word 5 times",
		"category": AchievementCategory.ZONES,
		"condition": "google_words_completed >= 5",
		"points": 50
	},
	"dash_nest": {
		"name": "Dash Champion",
		"description": "Complete Dash Nest 5 times",
		"category": AchievementCategory.ZONES,
		"condition": "dash_nests_completed >= 5",
		"points": 40
	},
	"dino_chomp": {
		"name": "Dino Tamer",
		"description": "Feed Dino 5 times",
		"category": AchievementCategory.ZONES,
		"condition": "dino_chomps >= 5",
		"points": 40
	},
	"sparky_turbo": {
		"name": "Turbo Master",
		"description": "Activate Turbo Charge 5 times",
		"category": AchievementCategory.ZONES,
		"condition": "sparky_turbos >= 5",
		"points": 40
	},
	"zone_collector": {
		"name": "World Tour",
		"description": "Activate bonuses in all 5 zones in a single game",
		"category": AchievementCategory.ZONES,
		"condition": "all_zones_bonus",
		"points": 100
	},
	
	# Combo Achievements
	"combo_5": {
		"name": "Hot Streak",
		"description": "Reach a 5x combo",
		"category": AchievementCategory.COMBOS,
		"condition": "max_combo >= 5",
		"points": 25
	},
	"combo_10": {
		"name": "Unstoppable",
		"description": "Reach a 10x combo",
		"category": AchievementCategory.COMBOS,
		"condition": "max_combo >= 10",
		"points": 50
	},
	"combo_20": {
		"name": "God Mode",
		"description": "Reach maximum 20x combo",
		"category": AchievementCategory.COMBOS,
		"condition": "max_combo >= 20",
		"points": 100
	},
	
	# Bonus Achievements
	"first_bonus": {
		"name": "Bonus Hunter",
		"description": "Earn your first bonus ball",
		"category": AchievementCategory.BONUSES,
		"condition": "total_bonus_balls >= 1",
		"points": 20
	},
	"five_bonus": {
		"name": "Bonus Master",
		"description": "Earn 5 bonus balls in one game",
		"category": AchievementCategory.BONUSES,
		"condition": "max_bonus_balls_single_game >= 5",
		"points": 75
	},
	"all_bonuses": {
		"name": "Jackpot",
		"description": "Earn all 5 bonus types in a single game",
		"category": AchievementCategory.BONUSES,
		"condition": "all_bonus_types_earned",
		"points": 150
	}
}

var _unlocked_achievements: Array[String] = []
var _stats: Dictionary = {
	"games_played": 0,
	"max_single_game_score": 0,
	"max_multiplier_reached": 0,
	"android_acres_bonuses": 0,
	"google_words_completed": 0,
	"dash_nests_completed": 0,
	"dino_chomps": 0,
	"sparky_turbos": 0,
	"all_zones_bonus": false,
	"max_combo": 0,
	"total_bonus_balls": 0,
	"max_bonus_balls_single_game": 0,
	"all_bonus_types_earned": false,
	"bonus_types_earned_this_game": []
}

var _current_game_stats: Dictionary = {}
var _current_game_bonus_types: Array[String] = []

func _ready() -> void:
	add_to_group("achievement_system")
	_load_progress()
	_reset_current_game_stats()

func _reset_current_game_stats() -> void:
	_current_game_stats = {
		"android_acres_bonuses": 0,
		"google_words_completed": 0,
		"dash_nests_completed": 0,
		"dino_chomps": 0,
		"sparky_turbos": 0,
		"bonus_balls": 0,
		"bonus_types_earned": []
	}
	_current_game_bonus_types.clear()

func _load_progress() -> void:
	var save_path = "user://saves/achievements.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json_string = file.get_as_text()
		var json = JSON.new()
		json.parse(json_string)
		var data = json.get_data()
		
		if data.has("unlocked"):
			_unlocked_achievements = data["unlocked"]
		if data.has("stats"):
			_stats = data["stats"]

func _save_progress() -> void:
	var save_path = "user://saves/achievements.json"
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			dir.make_dir("saves")
	
	var data = {
		"unlocked": _unlocked_achievements,
		"stats": _stats,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func _check_achievements() -> void:
	for ach_id in ACHIEVEMENTS:
		if ach_id in _unlocked_achievements:
			continue
		
		var ach = ACHIEVEMENTS[ach_id]
		if _evaluate_condition(ach["condition"]):
			_unlock_achievement(ach_id, ach)

func _evaluate_condition(condition: String) -> bool:
	# Parse and evaluate condition string
	# Format: "stat_name >= value"
	var parts = condition.split(" >= ")
	if parts.size() != 2:
		return false
	
	var stat_name = parts[0]
	var required_value = int(parts[1])
	
	var current_value = _stats.get(stat_name, 0)
	return current_value >= required_value

func _unlock_achievement(ach_id: String, ach: Dictionary) -> void:
	_unlocked_achievements.append(ach_id)
	_achievement_unlocked.emit(ach_id, ach["name"])
	
	# Update stats with bonus points
	if _stats.has("total_points"):
		_stats["total_points"] += ach["points"]
	else:
		_stats["total_points"] = ach["points"]
	
	_save_progress()

# ============================================
# Public API
# ============================================

func on_game_started() -> void:
	_stats["games_played"] += 1
	_reset_current_game_stats()

func on_game_ended(final_score: int) -> void:
	# Update max score
	if final_score > _stats["max_single_game_score"]:
		_stats["max_single_game_score"] = final_score
	
	# Check for achievements
	_check_achievements()
	_save_progress()

func on_multiplier_changed(new_multiplier: int) -> void:
	if new_multiplier > _stats["max_multiplier_reached"]:
		_stats["max_multiplier_reached"] = new_multiplier

func on_bonus_earned(bonus_type: String) -> void:
	if bonus_type == "GOOGLE_WORD":
		_current_game_stats["google_words_completed"] += 1
		_stats["google_words_completed"] += 1
	elif bonus_type == "DASH_NEST":
		_current_game_stats["dash_nests_completed"] += 1
		_stats["dash_nests_completed"] += 1
	elif bonus_type == "DINO_CHOMP":
		_current_game_stats["dino_chomps"] += 1
		_stats["dino_chomps"] += 1
	elif bonus_type == "SPARKY_TURBO_CHARGE":
		_current_game_stats["sparky_turbos"] += 1
		_stats["sparky_turbos"] += 1
	elif bonus_type == "ANDROID_SPACESHIP":
		_current_game_stats["android_acres_bonuses"] += 1
		_stats["android_acres_bonuses"] += 1
	
	# Track bonus types earned this game
	if not bonus_type in _current_game_bonus_types:
		_current_game_bonus_types.append(bonus_type)
		_current_game_stats["bonus_types_earned"].append(bonus_type)
		if _current_game_stats["bonus_types_earned"].size() >= 5:
			_stats["all_bonus_types_earned"] = true
	
	# Check all zones bonus
	var zone_bonuses = [
		_current_game_stats["android_acres_bonuses"],
		_current_game_stats["google_words_completed"],
		_current_game_stats["dash_nests_completed"],
		_current_game_stats["dino_chomps"],
		_current_game_stats["sparky_turbos"]
	]
	var zones_with_bonus = 0
	for count in zone_bonuses:
		if count > 0:
			zones_with_bonus += 1
	if zones_with_bonus >= 5:
		_stats["all_zones_bonus"] = true

func on_bonus_ball_earned() -> void:
	_current_game_stats["bonus_balls"] += 1
	_stats["total_bonus_balls"] += 1
	if _current_game_stats["bonus_balls"] > _stats["max_bonus_balls_single_game"]:
		_stats["max_bonus_balls_single_game"] = _current_game_stats["bonus_balls"]

func on_combo_achieved(combo_count: int) -> void:
	if combo_count > _stats["max_combo"]:
		_stats["max_combo"] = combo_count

# ============================================
# Query Methods
# ============================================

func is_unlocked(ach_id: String) -> bool:
	return ach_id in _unlocked_achievements

func get_unlocked_count() -> int:
	return _unlocked_achievements.size()

func get_total_count() -> int:
	return ACHIEVEMENTS.size()

func get_progress_percentage() -> float:
	return float(_unlocked_achievements.size()) / float(ACHIEVEMENTS.size()) * 100.0

func get_achievement_info(ach_id: String) -> Dictionary:
	if ACHIEVEMENTS.has(ach_id):
		var info = ACHIEVEMENTS[ach_id].duplicate()
		info["unlocked"] = is_unlocked(ach_id)
		return info
	return {}

func get_all_achievements() -> Array:
	var result = []
	for ach_id in ACHIEVEMENTS:
		result.append({
			"id": ach_id,
			"name": ACHIEVEMENTS[ach_id]["name"],
			"description": ACHIEVEMENTS[ach_id]["description"],
			"category": AchievementCategory.keys()[ACHIEVEMENTS[ach_id]["category"]],
			"unlocked": is_unlocked(ach_id),
			"points": ACHIEVEMENTS[ach_id]["points"]
		})
	return result

func get_statistics() -> Dictionary:
	return _stats.duplicate()

func get_total_points() -> int:
	return _stats.get("total_points", 0)

func reset_progress() -> void:
	_unlocked_achievements.clear()
	_stats = {
		"games_played": 0,
		"max_single_game_score": 0,
		"max_multiplier_reached": 0,
		"android_acres_bonuses": 0,
		"google_words_completed": 0,
		"dash_nests_completed": 0,
		"dino_chomps": 0,
		"sparky_turbos": 0,
		"all_zones_bonus": false,
		"max_combo": 0,
		"total_bonus_balls": 0,
		"max_bonus_balls_single_game": 0,
		"all_bonus_types_earned": false,
		"bonus_types_earned_this_game": []
	}
	_save_progress()

# ============================================
# Static Access
# ============================================

static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("achievement_system")
	return null

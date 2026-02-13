extends Node
## v4.0 Statistics Tracker
## Comprehensive game statistics and player metrics

const STATS_FILE = "user://saves/statistics.json"

var _stats: Dictionary = {}
var _session_stats: Dictionary = {}

func _ready() -> void:
	add_to_group("statistics")
	_load_stats()

func _load_stats() -> void:
	if FileAccess.file_exists(STATS_FILE):
		var file = FileAccess.open(STATS_FILE, FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		_stats = json.get_data()
	else:
		_initialize_stats()

func _initialize_stats() -> void:
	_stats = {
		"lifetime": {
			"games_played": 0,
			"total_score": 0,
			"total_time_played": 0,
			"total_balls_lost": 0,
			"total_bonus_balls": 0,
			"high_score": 0,
			"favorite_character": "sparky",
			"first_played": Time.get_unix_time_from_system(),
			"last_played": Time.get_unix_time_from_system()
		},
		"scoring": {
			"total_hits": 0,
			"total_bumper_hits": 0,
			"total_ramp_hits": 0,
			"total_letter_hits": 0,
			"total_word_completions": 0,
			"highest_multiplier_reached": 0,
			"highest_combo": 0
		},
		"zones": {
			"android_acres_bonuses": 0,
			"google_words_completed": 0,
			"dash_nests_completed": 0,
			"dino_chomps": 0,
			"sparky_turbos": 0,
			"favorite_zone": "android_acres"
		},
		"session": {
			"current_session_start": 0,
			"session_score": 0,
			"session_balls_lost": 0,
			"session_bonus_balls": 0
		},
		"achievements": {
			"unlocked_count": 0,
			"total_points": 0
		}
	}

func _save_stats() -> void:
	var file = FileAccess.open(STATS_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(_stats, "\t"))

func _update_session_stats() -> void:
	_stats["session"]["session_score"] = _session_stats.get("score", 0)
	_stats["session"]["session_balls_lost"] = _session_stats.get("balls_lost", 0)
	_stats["session"]["session_bonus_balls"] = _session_stats.get("bonus_balls", 0)

# ============================================
# Lifetime Stats
# ============================================

func on_game_started() -> void:
	_stats["lifetime"]["games_played"] += 1
	_stats["lifetime"]["last_played"] = Time.get_unix_time_from_system()
	_stats["session"]["current_session_start"] = Time.get_unix_time_from_system()
	
	_session_stats = {
		"score": 0,
		"balls_lost": 0,
		"bonus_balls": 0,
		"hits": 0,
		"bumper_hits": 0,
		"ramp_hits": 0,
		"combo": 0,
		"max_combo": 0
	}

func on_game_ended(final_score: int) -> void:
	_stats["lifetime"]["total_score"] += final_score
	if final_score > _stats["lifetime"]["high_score"]:
		_stats["lifetime"]["high_score"] = final_score
	
	_stats["lifetime"]["total_balls_lost"] += _session_stats.get("balls_lost", 0)
	_stats["lifetime"]["total_bonus_balls"] += _session_stats.get("bonus_balls", 0)
	
	var session_time = Time.get_unix_time_from_system() - _stats["session"]["current_session_start"]
	_stats["lifetime"]["total_time_played"] += session_time
	
	_update_session_stats()
	_save_stats()

func on_ball_lost() -> void:
	_session_stats["balls_lost"] += 1

func on_bonus_ball_earned() -> void:
	_session_stats["bonus_balls"] += 1

# ============================================
# Scoring Stats
# ============================================

func on_hit(points: int) -> void:
	_session_stats["hits"] += 1
	_stats["scoring"]["total_hits"] += 1

func on_bumper_hit() -> void:
	_session_stats["bumper_hits"] += 1
	_stats["scoring"]["total_bumper_hits"] += 1

func on_ramp_hit() -> void:
	_session_stats["ramp_hits"] += 1
	_stats["scoring"]["total_ramp_hits"] += 1

func on_letter_hit() -> void:
	_stats["scoring"]["total_letter_hits"] += 1

func on_word_completed() -> void:
	_stats["scoring"]["total_word_completions"] += 1

func on_multiplier_changed(new_multiplier: int) -> void:
	if new_multiplier > _stats["scoring"]["highest_multiplier_reached"]:
		_stats["scoring"]["highest_multiplier_reached"] = new_multiplier

func on_combo_changed(combo_count: int) -> void:
	_session_stats["combo"] = combo_count
	if combo_count > _session_stats["max_combo"]:
		_session_stats["max_combo"] = combo_count
	
	if combo_count > _stats["scoring"]["highest_combo"]:
		_stats["scoring"]["highest_combo"] = combo_count

# ============================================
# Zone Stats
# ============================================

func on_android_bonus() -> void:
	_stats["zones"]["android_acres_bonuses"] += 1

func on_google_word() -> void:
	_stats["zones"]["google_words_completed"] += 1

func on_dash_nest() -> void:
	_stats["zones"]["dash_nests_completed"] += 1

func on_dino_chomp() -> void:
	_stats["zones"]["dino_chomps"] += 1

func on_sparky_turbo() -> void:
	_stats["zones"]["sparky_turbos"] += 1

func _update_favorite_zone() -> void:
	var zones = {
		"android_acres": _stats["zones"]["android_acres_bonuses"],
		"google_gallery": _stats["zones"]["google_words_completed"],
		"flutter_forest": _stats["zones"]["dash_nests_completed"],
		"dino_desert": _stats["zones"]["dino_chomps"],
		"sparky_scorch": _stats["zones"]["sparky_turbos"]
	}
	
	var max_zone = "android_acres"
	var max_count = 0
	
	for zone in zones:
		if zones[zone] > max_count:
			max_count = zones[zone]
			max_zone = zone
	
	_stats["zones"]["favorite_zone"] = max_zone

# ============================================
# Achievement Stats
# ============================================

func on_achievement_unlocked() -> void:
	_stats["achievements"]["unlocked_count"] += 1

func on_achievement_points_earned(points: int) -> void:
	_stats["achievements"]["total_points"] += points

# ============================================
# Query Methods
# ============================================

func get_lifetime_stat(key: String) -> Variant:
	return _stats["lifetime"].get(key, 0)

func get_scoring_stat(key: String) -> Variant:
	return _stats["scoring"].get(key, 0)

func get_zone_stat(key: String) -> Variant:
	return _stats["zones"].get(key, 0)

func get_session_stat(key: String) -> Variant:
	return _session_stats.get(key, 0)

func get_high_score() -> int:
	return _stats["lifetime"].get("high_score", 0)

func get_games_played() -> int:
	return _stats["lifetime"].get("games_played", 0)

func get_total_score() -> int:
	return _stats["lifetime"].get("total_score", 0)

func get_total_time_played() -> int:
	return _stats["lifetime"].get("total_time_played", 0)

func get_highest_multiplier() -> int:
	return _stats["scoring"].get("highest_multiplier_reached", 0)

func get_highest_combo() -> int:
	return _stats["scoring"].get("highest_combo", 0)

func get_favorite_zone() -> String:
	_update_favorite_zone()
	return _stats["zones"].get("favorite_zone", "android_acres")

# ============================================
# Statistics Display
# ============================================

func get_statistics_summary() -> Dictionary:
	_update_favorite_zone()
	return {
		"lifetime": _stats["lifetime"],
		"scoring": _stats["scoring"],
		"zones": _stats["zones"],
		"achievements": _stats["achievements"]
	}

func get_friendly_summary() -> String:
	var summary = "=== Statistics ===\n"
	summary += "Games Played: %d\n" % get_games_played()
	summary += "High Score: %d\n" % get_high_score()
	summary += "Total Score: %d\n" % get_total_score()
	summary += "Time Played: %s\n" % _format_time(get_total_time_played())
	summary += "Highest Multiplier: %dx\n" % get_highest_multiplier()
	summary += "Highest Combo: %dx\n" % get_highest_combo()
	summary += "Favorite Zone: %s\n" % get_favorite_zone()
	return summary

func _format_time(seconds: int) -> String:
	var hours = seconds / 3600
	var minutes = (seconds % 3600) / 60
	var secs = seconds % 60
	return "%02d:%02d:%02d" % [hours, minutes, secs]

# ============================================
# Milestones
# ============================================

func get_milestones() -> Array:
	var milestones = []
	var total_score = get_total_score()
	var games = get_games_played()
	var high_score = get_high_score()
	var multiplier = get_highest_multiplier()
	
	milestones.append({"name": "Novice", "achieved": games >= 1, "description": "Play your first game"})
	milestones.append({"name": "Regular", "achieved": games >= 10, "description": "Play 10 games"})
	milestones.append({"name": "Pro", "achieved": games >= 50, "description": "Play 50 games"})
	milestones.append({"name": "Master", "achieved": games >= 100, "description": "Play 100 games"})
	
	milestones.append({"name": "High Scorer", "achieved": high_score >= 100000, "description": "Score 100,000 in one game"})
	milestones.append({"name": "Super Scorer", "achieved": high_score >= 1000000, "description": "Score 1,000,000 in one game"})
	milestones.append({"name": "Legend", "achieved": high_score >= 5000000, "description": "Score 5,000,000 in one game"})
	
	milestones.append({"name": "Multiplier King", "achieved": multiplier >= 6, "description": "Reach 6x multiplier"})
	
	return milestones

func reset_stats() -> void:
	_initialize_stats()
	_save_stats()

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("statistics")
	return null

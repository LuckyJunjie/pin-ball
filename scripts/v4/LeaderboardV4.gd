extends Node
## v4.0 Leaderboard System
## Persistent leaderboard with local storage and optional cloud sync

signal leaderboard_updated()
signal score_submitted(score_id: String)
signal sync_completed(success: bool)

const LEADERBOARD_FILE = "user://saves/leaderboard.json"
const MAX_ENTRIES = 100
const LOCAL_CACHE_SIZE = 50

var _entries: Array = []
var _is_loading: bool = false
var _is_syncing: bool = false
var _last_sync_time: int = 0
var _sync_interval: int = 3600  # 1 hour in seconds

# Character-specific leaderboards
var _character_leaderboards: Dictionary = {
	"sparky": [],
	"dino": [],
	"dash": [],
	"android": []
}

func _ready() -> void:
	add_to_group("leaderboard")
	_load_local()

func _load_local() -> void:
	if not FileAccess.file_exists(LEADERBOARD_FILE):
		_entries = _get_default_entries()
		_save_local()
		return
	
	var file = FileAccess.open(LEADERBOARD_FILE, FileAccess.READ)
	if file == null:
		_entries = _get_default_entries()
		return
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		_entries = _get_default_entries()
		return
	
	var data = json.get_data()
	if data.has("entries"):
		_entries = data["entries"]
	
	if data.has("character_leaderboards"):
		_character_leaderboards = data["character_leaderboards"]
	
	if data.has("last_sync"):
		_last_sync_time = data["last_sync"]

func _save_local() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			dir.make_dir("saves")
	
	var data = {
		"entries": _entries,
		"character_leaderboards": _character_leaderboards,
		"last_sync": _last_sync_time,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(LEADERBOARD_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))
	file.close()

func _get_default_entries() -> Array:
	return [
		{"initials": "AAA", "score": 1000000, "character": "sparky", "timestamp": Time.get_unix_time_from_system()},
		{"initials": "BBB", "score": 800000, "character": "dino", "timestamp": Time.get_unix_time_from_system()},
		{"initials": "CCC", "score": 600000, "character": "dash", "timestamp": Time.get_unix_time_from_system()}
	]

func _sort_entries(entries: Array) -> Array:
	var sorted = entries.duplicate()
	sorted.sort_custom(func(a, b): return a["score"] > b["score"])
	return sorted

# ============================================
# Public API
# ============================================

func submit_score(initials: String, score: int, character: String = "sparky") -> String:
	var entry = {
		"id": str(Time.get_ticks_msec()) + "_" + initials,
		"initials": initials.to_upper().substr(0, 3),
		"score": score,
		"character": character,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	_entries.append(entry)
	_entries = _sort_entries(_entries)
	_entries = _entries.slice(0, MAX_ENTRIES)
	
	if _character_leaderboards.has(character):
		_character_leaderboards[character].append(entry)
		_character_leaderboards[character] = _sort_entries(_character_leaderboards[character])
		_character_leaderboards[character] = _character_leaderboards[character].slice(0, LOCAL_CACHE_SIZE)
	
	_save_local()
	leaderboard_updated.emit()
	score_submitted.emit(entry["id"])
	
	return entry["id"]

func get_leaderboard(count: int = 10, character: String = "") -> Array:
	var entries = []
	
	if character == "" or character == "all":
		entries = _entries.slice(0, count)
	elif _character_leaderboards.has(character):
		entries = _character_leaderboards[character].slice(0, count)
	
	return entries

func get_rank(initials: String, score: int, character: String = "") -> int:
	var target_score = score
	
	for i in range(_entries.size()):
		if _entries[i]["initials"] == initials and _entries[i]["score"] == target_score:
			return i + 1
	
	return -1

func is_high_score(score: int) -> bool:
	if _entries.size() < MAX_ENTRIES:
		return true
	return score > _entries[_entries.size() - 1]["score"]

func get_total_entries() -> int:
	return _entries.size()

func get_highest_score() -> int:
	if _entries.size() == 0:
		return 0
	return _entries[0]["score"]

func get_average_score() -> int:
	if _entries.size() == 0:
		return 0
	
	var total = 0
	for entry in _entries:
		total += entry["score"]
	
	return int(total / _entries.size())

func get_character_high_score(character: String) -> int:
	if not _character_leaderboards.has(character):
		return 0
	
	if _character_leaderboards[character].size() == 0:
		return 0
	
	return _character_leaderboards[character][0]["score"]

func clear_leaderboard() -> void:
	_entries.clear()
	for key in _character_leaderboards:
		_character_leaderboards[key].clear()
	_save_local()
	leaderboard_updated.emit()

func remove_entry(entry_id: String) -> void:
	var new_entries = []
	for entry in _entries:
		if entry["id"] != entry_id:
			new_entries.append(entry)
	
	_entries = new_entries
	
	for character in _character_leaderboards:
		var char_entries = []
		for entry in _character_leaderboards[character]:
			if entry["id"] != entry_id:
				char_entries.append(entry)
		_character_leaderboards[character] = char_entries
	
	_save_local()
	leaderboard_updated.emit()

func get_entry_by_id(entry_id: String) -> Dictionary:
	for entry in _entries:
		if entry["id"] == entry_id:
			return entry
	return {}

func export_leaderboard() -> String:
	var data = {
		"entries": _entries,
		"character_leaderboards": _character_leaderboards,
		"export_timestamp": Time.get_unix_time_from_system()
	}
	return JSON.stringify(data, "\t")

func import_leaderboard(json_string: String, merge: bool = true) -> bool:
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		return false
	
	var data = json.get_data()
	if not data.has("entries"):
		return false
	
	if merge:
		# Merge entries, avoiding duplicates
		var existing_ids = []
		for entry in _entries:
			existing_ids.append(entry["id"])
		
		for entry in data["entries"]:
			if not entry["id"] in existing_ids:
				_entries.append(entry)
		
		for character in data.get("character_leaderboards", {}):
			if _character_leaderboards.has(character):
				var existing_char_ids = []
				for entry in _character_leaderboards[character]:
					existing_char_ids.append(entry["id"])
				
				for entry in data["character_leaderboards"][character]:
					if not entry["id"] in existing_char_ids:
						_character_leaderboards[character].append(entry)
		
		_entries = _sort_entries(_entries)
		_entries = _entries.slice(0, MAX_ENTRIES)
		
		for character in _character_leaderboards:
			_character_leaderboards[character] = _sort_entries(_character_leaderboards[character])
	else:
		_entries = data["entries"]
		if data.has("character_leaderboards"):
			_character_leaderboards = data["character_leaderboards"]
	
	_save_local()
	leaderboard_updated.emit()
	return true

# ============================================
# Statistics
# ============================================

func get_statistics() -> Dictionary:
	var stats = {
		"total_entries": _entries.size(),
		"highest_score": get_highest_score(),
		"average_score": get_average_score(),
		"character_counts": {}
	}
	
	for character in _character_leaderboards:
		stats["character_counts"][character] = _character_leaderboards[character].size()
	
	return stats

func get_recent_entries(count: int = 5) -> Array:
	var recent = []
	var sorted_by_time = _entries.duplicate()
	sorted_by_time.sort_custom(func(a, b): return a["timestamp"] > b["timestamp"])
	return sorted_by_time.slice(0, count)

func get_top_character() -> String:
	var max_score = 0
	var top_char = "sparky"
	
	for character in _character_leaderboards:
		var char_high = get_character_high_score(character)
		if char_high > max_score:
			max_score = char_high
			top_char = character
	
	return top_char

# ============================================
# Static Access
# ============================================

static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("leaderboard")
	return null

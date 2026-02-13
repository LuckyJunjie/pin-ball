extends Node
## v4.0 Replay System
## Record and replay game sessions

signal replay_saved(replay_id: String)
signal replay_loaded(replay_id: String)
signal replay_progress(percent: float)

const REPLAY_DIR = "user://replays/"
const MAX_REPLAYS = 10

var _is_recording: bool = false
var _is_replaying: bool = false
var _recording_start_time: float = 0.0
var _frame_count: int = 0
var _replay_data: Dictionary = {}
var _current_replay_id: String = ""
var _replay_frame: int = 0

func _ready() -> void:
	add_to_group("replay_system")
	_ensure_replay_directory()

func _ensure_replay_directory() -> void:
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("replays"):
			dir.make_dir("replays")

func start_recording(final_score: int = 0, character: String = "sparky") -> void:
	if _is_recording or _is_replaying:
		return
	
	_is_recording = true
	_frame_count = 0
	_recording_start_time = Time.get_ticks_msec()
	
	_current_replay_id = str(_recording_start_time)
	
	_replay_data = {
		"id": _current_replay_id,
		"timestamp": Time.get_unix_time_from_system(),
		"start_time": _recording_start_time,
		"final_score": final_score,
		"character": character,
		"frames": [],
		"metadata": {
			"game_version": "1.0.0",
			"platform": OS.get_name()
		}
	}

func stop_recording() -> String:
	if not _is_recording:
		return ""
	
	_is_recording = false
	_save_replay()
	
	var replay_id = _current_replay_id
	_current_replay_id = ""
	
	replay_saved.emit(replay_id)
	return replay_id

func record_frame(input_data: Dictionary) -> void:
	if not _is_recording:
		return
	
	_replay_data["frames"].append({
		"frame": _frame_count,
		"time": Time.get_ticks_msec() - _recording_start_time,
		"input": input_data
	})
	
	_frame_count += 1

func _save_replay() -> void:
	var filepath = REPLAY_DIR + _current_replay_id + ".replay"
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_string(JSON.stringify(_replay_data, "\t"))
	
	# Limit stored replays
	_prune_old_replays()

func _prune_old_replays() -> void:
	var dir = DirAccess.open(REPLAY_DIR)
	if dir:
		var replays = []
		var files = dir.get_files()
		for f in files:
			if f.ends_with(".replay"):
				var path = REPLAY_DIR + f
				var time = dir.get_modified_time(path)
				replays.append({"file": f, "time": time})
		
		# Sort by time (oldest first)
		replays.sort_custom(func(a, b): return a["time"] < b["time"])
		
		# Keep only MAX_REPLAYS
		while replays.size() > MAX_REPLAYS:
			var oldest = replays.pop_front()
			dir.remove(oldest["file"])

func load_replay(replay_id: String) -> bool:
	var filepath = REPLAY_DIR + replay_id + ".replay"
	
	if not FileAccess.file_exists(filepath):
		return false
	
	var file = FileAccess.open(filepath, FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	
	var data = json.get_data()
	if data.has("frames"):
		_replay_data = data
		_replay_frame = 0
		replay_loaded.emit(replay_id)
		return true
	
	return false

func start_replay() -> bool:
	if _replay_data.is_empty() or not _replay_data.has("frames"):
		return false
	
	_is_replaying = true
	_replay_frame = 0
	return true

func stop_replay() -> void:
	_is_replaying = false
	_replay_frame = 0

func get_next_frame() -> Dictionary:
	if not _is_replaying:
		return {}
	
	if _replay_frame >= _replay_data["frames"].size():
		return {"type": "end"}
	
	var frame = _replay_data["frames"][_replay_frame]
	_replay_frame += 1
	
	# Report progress
	var progress = float(_replay_frame) / float(_replay_data["frames"].size())
	replay_progress.emit(progress * 100)
	
	return {
		"type": "input",
		"time": frame.get("time", 0),
		"input": frame.get("input", {})
	}

func is_recording() -> bool:
	return _is_recording

func is_replaying() -> bool:
	return _is_replaying

func get_replay_info(replay_id: String) -> Dictionary:
	var filepath = REPLAY_DIR + replay_id + ".replay"
	
	if not FileAccess.file_exists(filepath):
		return {}
	
	var file = FileAccess.open(filepath, FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	var data = json.get_data()
	
	return {
		"id": data.get("id", ""),
		"timestamp": data.get("timestamp", 0),
		"final_score": data.get("final_score", 0),
		"character": data.get("character", ""),
		"frame_count": data.get("frames", []).size(),
		"duration": _calculate_duration(data)
	}

func _calculate_duration(data: Dictionary) -> float:
	var frames = data.get("frames", [])
	if frames.is_empty():
		return 0.0
	return frames[-1].get("time", 0) / 1000.0

func get_all_replays() -> Array:
	var replays = []
	var dir = DirAccess.open(REPLAY_DIR)
	
	if dir:
		var files = dir.get_files()
		for f in files:
			if f.ends_with(".replay"):
				var replay_id = f.replace(".replay", "")
				var info = get_replay_info(replay_id)
				if not info.is_empty():
					replays.append(info)
	
	# Sort by timestamp (newest first)
	replays.sort_custom(func(a, b): return a["timestamp"] > b["timestamp"])
	return replays

func delete_replay(replay_id: String) -> bool:
	var filepath = REPLAY_DIR + replay_id + ".replay"
	
	if FileAccess.file_exists(filepath):
		var dir = DirAccess.open(REPLAY_DIR)
		if dir:
			return dir.remove(replay_id + ".replay") == OK
	
	return false

func export_replay(replay_id: String) -> String:
	var filepath = REPLAY_DIR + replay_id + ".replay"
	
	if FileAccess.file_exists(filepath):
		var file = FileAccess.open(filepath, FileAccess.READ)
		return file.get_as_text()
	
	return ""

func import_replay(json_string: String) -> bool:
	var json = JSON.new()
	if json.parse(json_string) != OK:
		return false
	
	var data = json.get_data()
	if not data.has("id") or not data.has("frames"):
		return false
	
	var replay_id = data["id"]
	var filepath = REPLAY_DIR + replay_id + ".replay"
	
	var file = FileAccess.open(filepath, FileAccess.WRITE)
	file.store_string(json_string)
	return true

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("replay_system")
	return null

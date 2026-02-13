extends Node
## v4.0 Daily Challenge System
## Rotating daily challenges with rewards

signal challenge_unlocked(challenge_id: String)
signal challenge_completed(challenge_id: String, reward: int)
signal daily_refreshed()

const CHALLENGE_FILE = "user://saves/daily_challenges.json"

var _challenges: Array = []
var _today_challenges: Array = []
var _last_refresh: int = 0
var _completed_today: Array = []

# Challenge definitions
const CHALLENGE_TEMPLATES = [
	{
		"id": "high_score",
		"name": "High Scorer",
		"description": "Score over 500,000 points",
		"type": "score",
		"target": 500000,
		"difficulty": 1,
		"reward": 100
	},
	{
		"id": "multiplier_master",
		"name": "Multiplier Master",
		"description": "Reach 6x multiplier",
		"type": "multiplier",
		"target": 6,
		"difficulty": 2,
		"reward": 150
	},
	{
		"id": "bonus_hunter",
		"name": "Bonus Hunter",
		"description": "Earn 3 bonus balls",
		"type": "bonus",
		"target": 3,
		"difficulty": 2,
		"reward": 200
	},
	{
		"id": "zone_king",
		"name": "Zone King",
		"description": "Complete bonuses in all 5 zones",
		"type": "zones",
		"target": 5,
		"difficulty": 3,
		"reward": 300
	},
	{
		"id": "combo_king",
		"name": "Combo King",
		"description": "Reach a 10x combo",
		"type": "combo",
		"target": 10,
		"difficulty": 2,
		"reward": 175
	},
	{
		"id": "bumpers",
		"name": "Bumper Master",
		"description": "Hit 50 bumpers",
		"type": "bumpers",
		"target": 50,
		"difficulty": 1,
		"reward": 100
	},
	{
		"id": "survivor",
		"name": "Survivor",
		"description": "Play 3 full games",
		"type": "games",
		"target": 3,
		"difficulty": 1,
		"reward": 150
	},
	{
		"id": "speed_demon",
		"name": "Speed Demon",
		"description": "Score 100,000 points in under 2 minutes",
		"type": "speed_score",
		"target": 100000,
		"difficulty": 3,
		"reward": 250
	},
	{
		"id": "perfectionist",
		"name": "Perfectionist",
		"description": "Complete a game without losing a ball",
		"type": "no_drain",
		"target": 1,
		"difficulty": 4,
		"reward": 500
	},
	{
		"id": "collector",
		"name": "Collector",
		"description": "Hit all 6 GOOGLE letters",
		"type": "letters",
		"target": 6,
		"difficulty": 2,
		"reward": 175
	}
]

func _ready() -> void:
	add_to_group("daily_challenge")
	_load_data()
	_check_refresh()

func _load_data() -> void:
	if FileAccess.file_exists(CHALLENGE_FILE):
		var file = FileAccess.open(CHALLENGE_FILE, FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		var data = json.get_data()
		
		_challenges = data.get("challenges", [])
		_last_refresh = data.get("last_refresh", 0)
		_completed_today = data.get("completed_today", [])

func _save_data() -> void:
	var data = {
		"challenges": _challenges,
		"last_refresh": _last_refresh,
		"completed_today": _completed_today,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			dir.make_dir("saves")
	
	var file = FileAccess.open(CHALLENGE_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

func _check_refresh() -> void:
	var now = Time.get_unix_time_from_system()
	var today_start = Time.get_unix_time_from_system()
	
	# Get today's start (midnight)
	var time_dict = Time.get_datetime_dict_from_unix_time(now)
	today_start = Time.get_unix_time_from_datetime({
		"year": time_dict.year,
		"month": time_dict.month,
		"day": time_dict.day,
		"hour": 0,
		"minute": 0,
		"second": 0,
		"weekday": 0
	})
	
	if _last_refresh < today_start:
		_refresh_challenges()

func _refresh_challenges() -> void:
	_today_challenges.clear()
	_completed_today.clear()
	
	# Select 3 random challenges
	var available = CHALLENGE_TEMPLATES.duplicate()
	available.shuffle()
	
	for i in range(min(3, available.size())):
		var challenge = available[i].duplicate()
		challenge["progress"] = 0
		challenge["completed"] = false
		challenge["date"] = Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_system())
		_today_challenges.append(challenge)
	
	_last_refresh = Time.get_unix_time_from_system()
	_save_data()
	daily_refreshed.emit()

func start_tracking() -> void:
	_check_refresh()

func update_progress(challenge_type: String, value: int) -> void:
	for challenge in _today_challenges:
		if challenge.get("type") == challenge_type and not challenge.get("completed", false):
			challenge["progress"] = challenge.get("progress", 0) + value
			
			var target = challenge.get("target", 1)
			if challenge["progress"] >= target:
				_complete_challenge(challenge)
			
			_save_data()
			break

func _complete_challenge(challenge: Dictionary) -> void:
	challenge["completed"] = true
	_completed_today.append(challenge["id"])
	
	var reward = challenge.get("reward", 100)
	challenge_completed.emit(challenge["id"], reward)
	
	# Award currency
	var currency = get_tree().get_first_node_in_group("currency_manager")
	if currency and currency.has_method("add_coins"):
		currency.add_coins(reward)

func get_today_challenges() -> Array:
	return _today_challenges

func get_challenge_progress(challenge_id: String) -> Dictionary:
	for challenge in _today_challenges:
		if challenge.get("id") == challenge_id:
			return {
				"name": challenge.get("name", ""),
				"description": challenge.get("description", ""),
				"progress": challenge.get("progress", 0),
				"target": challenge.get("target", 1),
				"completed": challenge.get("completed", false),
				"reward": challenge.get("reward", 100)
			}
	return {}

func is_completed(challenge_id: String) -> bool:
	return challenge_id in _completed_today

func get_completed_count() -> int:
	return _completed_today.size()

func get_total_rewards_today() -> int:
	var total = 0
	for challenge_id in _completed_today:
		for template in CHALLENGE_TEMPLATES:
			if template["id"] == challenge_id:
				total += template.get("reward", 100)
				break
	return total

func get_streak() -> int:
	# Calculate consecutive days with at least 1 challenge completed
	var streak = 0
	var check_date = Time.get_unix_time_from_system()
	
	while true:
		var time_dict = Time.get_datetime_dict_from_unix_time(check_date)
		var day_start = Time.get_unix_time_from_datetime({
			"year": time_dict.year,
			"month": time_dict.month,
			"day": time_dict.day,
			"hour": 0,
			"minute": 0,
			"second": 0,
			"weekday": 0
		})
		
		# Check if any challenge was completed on this day
		var completed = false
		for challenge in _challenges:
			if challenge.get("date"):
				var challenge_time = Time.get_unix_time_from_datetime(challenge["date"])
				if challenge_time >= day_start and challenge_time < day_start + 86400:
					if challenge.get("completed", false):
						completed = true
						break
		
		if completed:
			streak += 1
			check_date -= 86400  # Previous day
		else:
			break
	
	return streak

func get_statistics() -> Dictionary:
	return {
		"challenges_completed": _completed_today.size(),
		"rewards_earned": get_total_rewards_today(),
		"streak": get_streak(),
		"total_challenges": _challenges.size()
	}

func reset_data() -> void:
	_challenges.clear()
	_today_challenges.clear()
	_completed_today.clear()
	_last_refresh = 0
	_save_data()

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("daily_challenge")
	return null

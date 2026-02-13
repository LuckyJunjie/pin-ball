extends Node
## v4.0 Easter Egg & Secret System
## Hidden features, easter eggs, and secret achievements

signal easter_egg_found(egg_id: String)
signal secret_unlocked(secret_id: String)

var _secrets_found: Array = []
var _easter_eggs_found: Array = []
var _combo_count: int = 0
var _consecutive_days: int = 0
var _total_score_session: int = 0
var _bumper_hit_count: int = 0
var _flipper_hits: Dictionary = {"left": 0, "right": 0}

# Secret definitions
const SECRETS = {
	"lucky_ball": {
		"name": "Lucky Ball",
		"description": "Your first bonus ball!",
		"condition": lambda: _has_bonus_ball(),
		"reward": "成就解锁：幸运球"
	},
	"combo_master": {
		"name": "Combo Master",
		"description": "Achieve a 50x combo",
		"condition": lambda: _combo_count >= 50,
		"reward": "成就解锁：连击大师"
	},
	"flipper_god": {
		"name": "Flipper God",
		"description": "Hit flipper 1000 times in one session",
		"condition": lambda: _flipper_hits["left"] + _flipper_hits["right"] >= 1000,
		"reward": "成就解锁：挡板之神"
	},
	"bumper_king": {
		"name": "Bumper King",
		"description": "Hit 1000 bumpers total",
		"condition": lambda: _bumper_hit_count >= 1000,
		"reward": "成就解锁：弹射器之王"
	},
	"perfectionist": {
		"name": "Perfectionist",
		"description": "Score over 1 million without losing a ball",
		"condition": lambda: _can_unlock_perfectionist(),
		"reward": "成就解锁：完美主义者"
	},
	"night_owl": {
		"name": "Night Owl",
		"description": "Play after midnight",
		"condition": lambda: _is_midnight(),
		"reward": "成就解锁：夜猫子"
	},
	"speedy": {
		"name": "Speedy",
		"description": "Score 50,000 points in under 1 minute",
		"condition": lambda: _can_unlock_speedy(),
		"reward": "成就解锁：闪电侠"
	},
	"collector": {
		"name": "Collector",
		"description": "Unlock all character themes",
		"condition": lambda: _has_all_themes(),
		"reward": "成就解锁：收藏家"
	}
}

# Easter eggs
const EASTER_EGGS = {
	"invincible": {
		"name": "???",
		"trigger": "hit_flipper_10_times_fast",
		"action": "_trigger_invincible"
	},
	"party_mode": {
		"name": "🎉",
		"trigger": "combo_20",
		"action": "_trigger_party_mode"
	},
	"rainbow": {
		"name": "🌈",
		"trigger": "hit_all_zones_fast",
		"action": "_trigger_rainbow"
	},
	"tiny_ball": {
		"name": "⚪",
		"trigger": "special_sequence",
		"action": "_trigger_tiny_ball"
	},
	"ghost_mode": {
		"name": "👻",
		"trigger": "lose_3_balls_fast",
		"action": "_trigger_ghost_mode"
	}
}

func _ready() -> void:
	add_to_group("easter_eggs")
	_load_data()

func _load_data() -> void:
	var file_path = "user://saves/secrets.json"
	if FileAccess.file_exists(file_path):
		var file = FileAccess.open(file_path, FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		var data = json.get_data()
		_secrets_found = data.get("secrets", [])
		_easter_eggs_found = data.get("easter_eggs", [])

func _save_data() -> void:
	var file_path = "user://saves/secrets.json"
	var data = {
		"secrets": _secrets_found,
		"easter_eggs": _easter_eggs_found,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var file = FileAccess.open(file_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

# ============================================
# Trigger Monitoring
# ============================================

func on_flipper_hit(side: String) -> void:
	_flipper_hits[side] += 1
	_check_easter_egg("flipper_hit")
	_check_secrets()

func on_combo_changed(combo: int) -> void:
	_combo_count = combo
	_check_easter_egg("combo")
	_check_secrets()

func on_bumper_hit() -> void:
	_bumper_hit_count += 1
	_check_secrets()

func on_score(points: int) -> void:
	_total_score_session += points
	_check_easter_egg("score")

func on_ball_lost() -> void:
	_check_easter_egg("ball_lost")

func on_zone_hit(zone: String) -> void:
	_check_easter_egg("zone_hit")

func _check_secrets() -> void:
	for secret_id in SECRETS:
		if not secret_id in _secrets_found:
			var secret = SECRETS[secret_id]
			if secret["condition"].call():
				_unlock_secret(secret_id)

func _check_easter_egg(trigger_type: String) -> void:
	for egg_id in EASTER_EGGS:
		if not egg_id in _easter_eggs_found:
			var egg = EASTER_EGGS[egg_id]
			if egg["trigger"] == trigger_type:
				if _verify_trigger(egg["trigger"]):
					_trigger_easter_egg(egg_id, egg)

func _verify_trigger(trigger: String) -> bool:
	match trigger:
		"hit_flipper_10_times_fast":
			return _flipper_hits["left"] + _flipper_hits["right"] >= 10
		"combo_20":
			return _combo_count >= 20
		"hit_all_zones_fast":
			return _has_hit_all_zones_recently()
		"special_sequence":
			return _check_special_sequence()
		"lose_3_balls_fast":
			return _has_lost_3_balls_recently()
	return false

# ============================================
# Easter Egg Effects
# ============================================

func _trigger_easter_egg(egg_id: String, egg: Dictionary) -> void:
	_easter_eggs_found.append(egg_id)
	_save_data()
	easter_egg_found.emit(egg_id)
	
	# Apply effect
	if has_method(egg["action"]):
		call(egg["action"])

func _trigger_invincible() -> void:
	# Make ball invincible for 10 seconds
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("set_ball_invincible"):
		gm.set_ball_invincible(true)
		await get_tree().create_timer(10.0).timeout
		if gm and gm.has_method("set_ball_invincible"):
			gm.set_ball_invincible(false)

func _trigger_party_mode() -> void:
	# Enable party mode - extra points!
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("set_party_mode"):
		gm.set_party_mode(true)
		await get_tree().create_timer(15.0).timeout
		if gm and gm.has_method("set_party_mode"):
			gm.set_party_mode(false)

func _trigger_rainbow() -> void:
	# Rainbow colors for 10 seconds
	var crt = get_tree().get_first_node_in_group("post_processing")
	if crt and crt.has_method("set_rainbow_mode"):
		crt.set_rainbow_mode(true)
		await get_tree().create_timer(10.0).timeout
		if crt and crt.has_method("set_rainbow_mode"):
			crt.set_rainbow_mode(false)

func _trigger_tiny_ball() -> void:
	# Shrink ball
	var balls = get_tree().get_nodes_in_group("balls")
	for ball in balls:
		if ball.has_method("set_scale"):
			ball.set_scale(ball.get_scale() * 0.5)
			await get_tree().create_timer(10.0).timeout
			if ball and ball.has_method("set_scale"):
				ball.set_scale(ball.get_scale() * 2.0)

func _trigger_ghost_mode() -> void:
	# Ghost ball - pass through flippers
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("set_ghost_mode"):
		gm.set_ghost_mode(true)
		await get_tree().create_timer(5.0).timeout
		if gm and gm.has_method("set_ghost_mode"):
			gm.set_ghost_mode(false)

# ============================================
# Secret Unlocks
# ============================================

func _unlock_secret(secret_id: String) -> void:
	if secret_id in _secrets_found:
		return
	
	_secrets_found.append(secret_id)
	_save_data()
	
	var secret = SECRETS[secret_id]
	secret_unlocked.emit(secret_id, secret["name"])
	
	# Show notification
	_show_notification("🔓 SECRET UNLOCKED!\n%s" % secret["name"])

func _show_notification(text: String) -> void:
	var label = Label.new()
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 24)
	label.add_theme_color_override("font_color", Color(1, 0.8, 0))
	
	var tween = create_tween()
	tween.tween_property(label, "position:y", 100, 2.0).set_trans(Tween.TRANS_SINE)
	tween.tween_property(label, "modulate:a", 0, 1.0).set_delay(1.0)
	tween.tween_callback(func():
		label.queue_free()
	)
	
	var main = get_tree().get_root().get_child(0)
	if main:
		main.add_child(label)

# ============================================
# Helper Functions
# ============================================

func _has_bonus_ball() -> bool:
	return _easter_eggs_found.size() > 0

func _can_unlock_perfectionist() -> bool:
	return false  # Implement with game state

func _can_unlock_speedy() -> bool:
	return false  # Implement with timer

func _is_midnight() -> bool:
	var now = Time.get_datetime_dict_from_unix_time(Time.get_unix_time_from_system())
	return now.hour >= 0 and now.hour < 5

func _has_all_themes() -> bool:
	var themes = get_tree().get_nodes_in_group("theme_manager")
	return themes.size() > 0

var _recent_zone_hits: Array = []
var _recent_ball_losts: Array = []

func _has_hit_all_zones_recently() -> bool:
	return false  # Implement tracking

func _has_lost_3_balls_recently() -> bool:
	return false  # Implement tracking

func _check_special_sequence() -> bool:
	return false  # Implement sequence detection

# ============================================
# Query Methods
# ============================================

func get_found_secrets() -> Array:
	return _secrets_found

func get_found_easter_eggs() -> Array:
	return _easter_eggs_found

func is_secret_found(secret_id: String) -> bool:
	return secret_id in _secrets_found

func is_easter_egg_found(egg_id: String) -> bool:
	return egg_id in _easter_eggs_found

func get_secret_info(secret_id: String) -> Dictionary:
	if SECRETS.has(secret_id):
		var secret = SECRETS[secret_id]
		return {
			"name": secret["name"],
			"description": secret["description"],
			"found": secret_id in _secrets_found
		}
	return {}

func get_all_secrets() -> Array:
	var result = []
	for secret_id in SECRETS:
		result.append(get_secret_info(secret_id))
	return result

func get_progress() -> Dictionary:
	return {
		"secrets_found": _secrets_found.size(),
		"total_secrets": SECRETS.size(),
		"easter_eggs_found": _easter_eggs_found.size(),
		"total_easter_eggs": EASTER_EGGS.size()
	}

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("easter_eggs")
	return null

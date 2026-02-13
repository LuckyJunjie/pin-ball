extends Node
## v4.0 Ad Monetization System
## Ad integration for rewards: watch ads to get items

signal ad_started(ad_type: String)
signal ad_completed(ad_type: String, reward: Variant)
signal ad_skipped(ad_type: String)
signal ad_failed(ad_type: String, error: String)
signal reward_granted(reward_id: String, reward_data: Dictionary)

@export var enabled: bool = true
@export var ad_provider: String = "admob"  # admob, unity, custom
@export var reward_cooldown: float = 30.0  # Seconds between rewarded ads

var _last_ad_time: float = 0.0
var _ad_available: bool = false
var _ad_in_progress: bool = false
var _pending_reward: Dictionary = {}
var _daily_ad_count: int = 0
var _daily_ad_limit: int = 10
var _coins_from_ads: int = 0

# Ad placement definitions
const AD_PLACEMENTS = {
	"extra_life": {
		"name": "Extra Life",
		"description": "Watch an ad to get an extra ball!",
		"reward_type": "extra_ball",
		"reward_value": 1,
		"icon": "❤️",
		"priority": 1
	},
	"double_score": {
		"name": "2x Score Boost",
		"description": "Watch an ad to double your score for 30 seconds!",
		"reward_type": "double_score",
		"reward_value": 2.0,
		"duration": 30.0,
		"icon": "💯",
		"priority": 2
	},
	"coin_bonus": {
		"name": "Coin Bonus",
		"description": "Watch an ad to get 100 bonus coins!",
		"reward_type": "coins",
		"reward_value": 100,
		"icon": "🪙",
		"priority": 3
	},
	"free_skin": {
		"name": "Free Skin",
		"description": "Watch an ad to unlock a random skin for 24 hours!",
		"reward_type": "temp_skin",
		"reward_value": 1,
		"duration": 86400,
		"icon": "🎨",
		"priority": 4
	},
	"continue_game": {
		"name": "Continue",
		"description": "Watch an ad to continue your game!",
		"reward_type": "continue",
		"reward_value": 1,
		"icon": "▶️",
		"priority": 0
	}
}

func _ready() -> void:
	add_to_group("ad_system")
	_load_ad_stats()

func _load_ad_stats() -> void:
	var save_path = "user://saves/ad_stats.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		var data = json.get_data()
		_daily_ad_count = data.get("daily_ad_count", 0)
		_coins_from_ads = data.get("coins_from_ads", 0)

func _save_ad_stats() -> void:
	var save_path = "user://saves/ad_stats.json"
	var data = {
		"daily_ad_count": _daily_ad_count,
		"coins_from_ads": _coins_from_ads,
		"timestamp": Time.get_unix_time_from_system()
	}
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

# ============================================
# Ad Availability
# ============================================

func is_ad_available(ad_type: String = "") -> bool:
	if not enabled:
		return false
	
	if _ad_in_progress:
		return false
	
	# Check cooldown
	var now = Time.get_ticks_msec() / 1000.0
	if now - _last_ad_time < reward_cooldown:
		return false
	
	# Check daily limit
	if _daily_ad_count >= _daily_ad_limit:
		return false
	
	return true

func get_available_rewards() -> Array:
	var available = []
	for ad_id in AD_PLACEMENTS:
		if is_ad_available(ad_id):
			var placement = AD_PLACEMENTS[ad_id]
			placement["id"] = ad_id
			available.append(placement)
	
	# Sort by priority
	available.sort_custom(func(a, b): return a["priority"] < b["priority"])
	return available

func get_reward_info(ad_type: String) -> Dictionary:
	if AD_PLACEMENTS.has(ad_type):
		return AD_PLACEMENTS[ad_type].duplicate()
	return {}

# ============================================
# Show Ad
# ============================================

func show_rewarded_ad(ad_type: String, callback: Callable = func(success):) -> bool:
	if not is_ad_available(ad_type):
		print("Ad not available: %s" % ad_type)
		return false
	
	if not AD_PLACEMENTS.has(ad_type):
		print("Unknown ad type: %s" % ad_type)
		return false
	
	_ad_in_progress = true
	_pending_reward = {
		"type": ad_type,
		"reward_type": AD_PLACEMENTS[ad_type]["reward_type"],
		"reward_value": AD_PLACEMENTS[ad_type]["reward_value"]
	}
	
	# Handle reward-specific data
	if AD_PLACEMENTS[ad_type].has("duration"):
		_pending_reward["duration"] = AD_PLACEMENTS[ad_type]["duration"]
	
	ad_started.emit(ad_type)
	
	# Simulate ad playback (in real implementation, would call SDK)
	_simulate_ad_playback(ad_type, callback)
	
	return true

func _simulate_ad_playback(ad_type: String, callback: Callable) -> void:
	# In real implementation, would show actual ad from SDK
	print("Showing ad: %s" % ad_type)
	
	# Create ad UI
	_create_ad_overlay(ad_type)
	
	# Simulate ad completion after 15-30 seconds
	var ad_duration = randf_range(15.0, 30.0)
	await get_tree().create_timer(ad_duration).timeout
	
	_on_ad_completed(ad_type, true, callback)

func _create_ad_overlay(ad_type: String) -> void:
	# In real implementation, would show actual ad view
	var overlay = Panel.new()
	overlay.name = "AdOverlay"
	overlay.anchor_right = 1.0
	overlay.anchor_bottom = 1.0
	overlay.modulate.a = 0.8
	overlay.z_index = 10000
	
	var label = Label.new()
	label.text = "📺 Watching Ad: %s\n\nReward: %s\n\nLoading in %d seconds..." % [
		AD_PLACEMENTS[ad_type]["name"],
		AD_PLACEMENTS[ad_type]["description"],
		30
	]
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	overlay.add_child(label)
	
	var close_btn = Button.new()
	close_btn.text = "Skip Ad ✖"
	close_btn.pressed.connect(func(): _on_ad_skipped(ad_type, callback))
	overlay.add_child(close_btn)
	
	get_tree().get_root().add_child(overlay)
	
	# Countdown
	var count = 30
	for i in range(30):
		await get_tree().create_timer(1.0).timeout
		count -= 1
		label.text = "📺 Watching Ad: %s\n\nReward: %s\n\nLoading in %d seconds..." % [
			AD_PLACEMENTS[ad_type]["name"],
			AD_PLACEMENTS[ad_type]["description"],
			count
		]

func _remove_ad_overlay() -> void:
	var overlay = get_tree().get_root().get_node_or_null("AdOverlay")
	if overlay:
		overlay.queue_free()

# ============================================
# Ad Callbacks
# ============================================

func _on_ad_completed(ad_type: String, success: bool, callback: Callable) -> void:
	_remove_ad_overlay()
	_ad_in_progress = false
	
	if success:
		_last_ad_time = Time.get_ticks_msec() / 1000.0
		_daily_ad_count += 1
		
		# Grant reward
		_grant_reward(ad_type)
		
		ad_completed.emit(ad_type, _pending_reward)
		callback.call(true, _pending_reward)
	else:
		ad_failed.emit(ad_type, "Unknown error")
		callback.call(false, {})

func _on_ad_skipped(ad_type: String, callback: Callable) -> void:
	_remove_ad_overlay()
	_ad_in_progress = false
	ad_skipped.emit(ad_type)
	callback.call(false, {})

func _grant_reward(ad_type: String) -> void:
	var reward = _pending_reward
	
	match reward["reward_type"]:
		"extra_ball":
			_grant_extra_ball(reward["reward_value"])
		"double_score":
			_grant_double_score(reward["reward_value"], reward.get("duration", 30.0))
		"coins":
			_grant_coins(reward["reward_value"])
		"temp_skin":
			_grant_temp_skin(reward.get("duration", 86400))
		"continue":
			_grant_continue()
	
	reward_granted.emit(ad_type, reward)
	_save_ad_stats()

func _grant_extra_ball(count: int) -> void:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("add_bonus_ball"):
		for i in range(count):
			gm.add_bonus_ball()

func _grant_double_score(multiplier: float, duration: float) -> void:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("activate_double_score"):
		gm.activate_double_score(multiplier, duration)

func _grant_coins(amount: int) -> void:
	var currency = get_tree().get_first_node_in_group("currency_manager")
	if currency and currency.has_method("add_coins"):
		currency.add_coins(amount)
		_coins_from_ads += amount

func _grant_temp_skin(duration: int) -> void:
	# Grant random temp skin
	var skins = ["golden", "rainbow", "neon", "cyber"]
	var skin = skins[randi() % skins.size()]
	
	# In real implementation, would unlock skin
	print("Granted temp skin: %s for %d seconds" % [skin, duration])

func _grant_continue() -> void:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("continue_game"):
		gm.continue_game()

# ============================================
# Banner Ads (Non-Rewarded)
# ============================================

func show_banner_ad() -> void:
	if not enabled:
		return
	
	# In real implementation, would show banner from SDK
	pass

func hide_banner_ad() -> void:
	# Hide banner ad
	pass

func show_interstitial_ad() -> void:
	# Show interstitial (full-screen) ad
	# Typically shown between game sessions
	pass

# ============================================
# Statistics
# ============================================

func get_ad_statistics() -> Dictionary:
	return {
		"ads_watched_today": _daily_ad_count,
		"daily_limit": _daily_ad_limit,
		"coins_from_ads": _coins_from_ads,
		"revenue_estimate": _estimate_revenue()
	}

func _estimate_revenue() -> float:
	# Rough estimate: $2-5 CPM for rewarded ads
	var ecpm = randf_range(2.0, 5.0)
	return _daily_ad_count * ecpm / 1000.0

func reset_daily_count() -> void:
	var now = Time.get_unix_time_from_system()
	var today_start = now - (now % 86400)
	
	# Check if we need to reset
	var save_path = "user://saves/ad_stats.json"
	if FileAccess.file_exists(save_path):
		var file = FileAccess.open(save_path, FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		var data = json.get_data()
		var last_ad = data.get("timestamp", 0)
		
		if last_ad < today_start:
			_daily_ad_count = 0
			_save_ad_stats()

# ============================================
# Configuration
# ============================================

func set_enabled(enabled_state: bool) -> void:
	enabled = enabled_state

func set_reward_cooldown(seconds: float) -> void:
	reward_cooldown = clamp(seconds, 10.0, 300.0)

func set_daily_limit(limit: int) -> void:
	_daily_ad_limit = clamp(limit, 1, 50)

# ============================================
# Shop Integration
# ============================================

func get_shop_rewards() -> Array:
	# Rewards available in shop for ad watching
	return [
		{
			"id": "ad_extra_life",
			"name": "❤️ Extra Life",
			"description": "Watch an ad for 1 extra ball!",
			"cost": 0,
			"ad_type": "extra_life",
			"icon": "❤️"
		},
		{
			"id": "ad_coins",
			"id": "🪙 Free Coins",
			"description": "Watch an ad for 100 coins!",
			"cost": 0,
			"ad_type": "coin_bonus",
			"icon": "🪙"
		}
	]

func purchase_with_ad(item_id: String) -> bool:
	var shop_rewards = get_shop_rewards()
	for reward in shop_rewards:
		if reward["id"] == item_id:
			return show_rewarded_ad(reward["ad_type"], func(success, data): pass)
	return false

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("ad_system")
	return null

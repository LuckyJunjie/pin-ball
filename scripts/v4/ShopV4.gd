extends Node
## v4.0 Shop System
## In-game shop for purchasing power-ups and cosmetics

signal purchase_completed(item_id: String, success: bool)
signal currency_updated(new_amount: int)
signal item_equipped(item_id: String)

const SHOP_FILE = "user://saves/shop.json"

var _currency: int = 0
var _items: Array = []
var _equipped_items: Dictionary = {}
var _purchase_history: Array = []

# Shop items definition
const SHOP_ITEMS = [
	{
		"id": "double_points_1min",
		"name": "2x Points (1 min)",
		"description": "Double all points for 1 minute!",
		"type": "powerup",
		"cost": 100,
		"duration": 60.0,
		"icon": "⭐"
	},
	{
		"id": "extra_ball",
		"name": "Extra Ball",
		"description": "Add an extra ball to your next game!",
		"type": "consumable",
		"cost": 200,
		"icon": "🔮"
	},
	{
		"id": "safe_landing",
		"name": "Safe Landing",
		"description": "Your next ball won't drain from the flippers!",
		"type": "consumable",
		"cost": 150,
		"icon": "🛡️"
	},
	{
		"id": "theme_sparky",
		"name": "Sparky Theme",
		"description": "Unlock the Sparky character theme",
": "theme		"type",
		"cost": 500,
		"icon": "⚡"
	},
	{
		"id": "theme_dino",
		"name": "Dino Theme",
		"description": "Unlock the Dino character theme",
		"type": "theme",
		"cost": 500,
		"icon": "🦖"
	},
	{
		"id": "theme_dash",
		"name": "Dash Theme",
		"description": "Unlock the Dash character theme",
		"type": "theme",
		"cost": 500,
		"icon": "🦋"
	},
	{
		"id": "gold_ball",
		"name": "Gold Ball Skin",
		"description": "Make your ball golden!",
		"type": "cosmetic",
		"cost": 300,
		"icon": "🥇"
	},
	{
		"id": "rainbow_ball",
		"name": "Rainbow Ball Skin",
		"description": "Colorful ball effect!",
		"type": "cosmetic",
		"cost": 500,
		"icon": "🌈"
	},
	{
		"id": "title_pro",
		"name": "Pro Title",
		"description": "Display 'Pro' under your name",
		"type": "title",
		"cost": 1000,
		"icon": "🏆"
	},
	{
		"id": "title_master",
		"name": "Master Title",
		"description": "Display 'Master' under your name",
		"type": "title",
		"cost": 2000,
		"icon": "👑"
	}
]

func _ready() -> void:
	add_to_group("shop_system")
	_load_shop_data()

func _load_shop_data() -> void:
	if FileAccess.file_exists(SHOP_FILE):
		var file = FileAccess.open(SHOP_FILE, FileAccess.READ)
		var json = JSON.new()
		json.parse(file.get_as_text())
		var data = json.get_data()
		
		_currency = data.get("currency", 0)
		_items = data.get("items", [])
		_equipped_items = data.get("equipped_items", {})
		_purchase_history = data.get("purchase_history", [])

func _save_shop_data() -> void:
	var data = {
		"currency": _currency,
		"items": _items,
		"equipped_items": _equipped_items,
		"purchase_history": _purchase_history,
		"timestamp": Time.get_unix_time_from_system()
	}
	
	var dir = DirAccess.open("user://")
	if dir:
		if not dir.dir_exists("saves"):
			dir.make_dir("saves")
	
	var file = FileAccess.open(SHOP_FILE, FileAccess.WRITE)
	file.store_string(JSON.stringify(data, "\t"))

# ============================================
# Currency
# ============================================

func get_currency() -> int:
	return _currency

func add_currency(amount: int) -> void:
	_currency += amount
	currency_updated.emit(_currency)
	_save_shop_data()

func spend_currency(amount: int) -> bool:
	if _currency >= amount:
		_currency -= amount
		currency_updated.emit(_currency)
		_save_shop_data()
		return true
	return false

# ============================================
# Shop Items
# ============================================

func get_all_items() -> Array:
	return SHOP_ITEMS

func get_item(item_id: String) -> Dictionary:
	for item in SHOP_ITEMS:
		if item["id"] == item_id:
			var owned = _is_item_owned(item_id)
			var equipped = _is_item_equipped(item_id)
			var result = item.duplicate()
			result["owned"] = owned
			result["equipped"] = equipped
			return result
	return {}

func get_items_by_type(item_type: String) -> Array:
	var result = []
	for item in SHOP_ITEMS:
		if item["type"] == item_type:
			var owned = _is_item_owned(item["id"])
			var equipped = _is_item_equipped(item["id"])
			var copy = item.duplicate()
			copy["owned"] = owned
			copy["equipped"] = equipped
			result.append(copy)
	return result

func purchase_item(item_id: String) -> bool:
	var item = get_item(item_id)
	if item.is_empty():
		purchase_completed.emit(item_id, false)
		return false
	
	if _is_item_owned(item_id):
		purchase_completed.emit(item_id, false)
		return false
	
	if not spend_currency(item["cost"]):
		purchase_completed.emit(item_id, false)
		return false
	
	_items.append(item_id)
	_purchase_history.append({
		"item_id": item_id,
		"timestamp": Time.get_unix_time_from_system(),
		"cost": item["cost"]
	})
	
	_save_shop_data()
	purchase_completed.emit(item_id, true)
	return true

func _is_item_owned(item_id: String) -> bool:
	return item_id in _items

func equip_item(item_id: String) -> bool:
	if not _is_item_owned(item_id):
		return false
	
	var item = get_item(item_id)
	if item.is_empty() or item["type"] not in ["theme", "cosmetic", "title"]:
		return False
	
	_equipped_items[item["type"]] = item_id
	_save_shop_data()
	item_equipped.emit(item_id)
	return true

func unequip_item(item_type: String) -> void:
	if _equipped_items.has(item_type):
		_equipped_items.erase(item_type)
		_save_shop_data()

func _is_item_equipped(item_id: String) -> bool:
	for item_type in _equipped_items:
		if _equipped_items[item_type] == item_id:
			return true
	return false

func get_equipped_item(item_type: String) -> String:
	return _equipped_items.get(item_type, "")

# ============================================
# Power-up Effects
# ============================================

func activate_powerup(item_id: String, target: Node) -> bool:
	match item_id:
		"double_points_1min":
			return _activate_double_points(target)
		"extra_ball":
			return _activate_extra_ball(target)
		"safe_landing":
			return _activate_safe_landing(target)
	return false

func _activate_double_points(target: Node) -> bool:
	if target.has_method("set_score_multiplier"):
		target.set_score_multiplier(2.0)
		# Timer to remove effect
		await get_tree().create_timer(60.0).timeout
		if target and target.has_method("set_score_multiplier"):
			target.set_score_multiplier(1.0)
		return true
	return false

func _activate_extra_ball(target: Node) -> bool:
	# Add to bonus balls in next game
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm and gm.has_method("add_bonus_ball"):
		gm.add_bonus_ball()
		return true
	return false

func _activate_safe_landing(target: Node) -> bool:
	if target.has_method("enable_safe_landing"):
		target.enable_safe_landing()
		return True
	return false

# ============================================
# Daily Deals
# ============================================

func get_daily_deals() -> Array:
	# 3 random items on sale
	var available = SHOP_ITEMS.duplicate()
	available.shuffle()
	
	var deals = []
	for i in range(min(3, available.size())):
		var item = available[i]
		var discount = 0.2 if i == 0 else (0.15 if i == 1 else 0.1)
		var deal = item.duplicate()
		deal["original_cost"] = item["cost"]
		deal["cost"] = int(item["cost"] * (1.0 - discount))
		deal["discount"] = int(discount * 100)
		deals.append(deal)
	
	return deals

# ============================================
# Statistics
# ============================================

func get_statistics() -> Dictionary:
	var stats = {
		"currency": _currency,
		"items_owned": _items.size(),
		"total_spent": _get_total_spent(),
		"purchases_today": _get_purchases_today(),
		"equipped_themes": _equipped_items.get("theme", ""),
		"equipped_cosmetic": _equipped_items.get("cosmetic", "")
	}
	return stats

func _get_total_spent() -> int:
	var total = 0
	for purchase in _purchase_history:
		total += purchase.get("cost", 0)
	return total

func _get_purchases_today() -> int:
	var today = Time.get_unix_time_from_system()
	var start_of_day = today - (today % 86400)
	
	var count = 0
	for purchase in _purchase_history:
		if purchase.get("timestamp", 0) >= start_of_day:
			count += 1
	return count

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("shop_system")
	return null

extends Node

## Save manager singleton (Autoload)
## Handles all data persistence for the game

var save_file_path: String = "user://pinball_save.json"
var save_data: Dictionary = {}

func _ready():
	# Load all data on startup
	load_all_data()

func save_all_data():
	"""Save all player data to file"""
	save_data["version"] = "2.0"
	
	# Save currency
	var currency_mgr = get_node_or_null("/root/CurrencyManager")
	if currency_mgr:
		save_data["currency"] = {
			"coins": currency_mgr.get_coins(),
			"gems": currency_mgr.get_gems()
		}
	
	# Save equipped items
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		save_data["equipped_items"] = global_settings.equipped_items
	
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
		print("[SaveManager] Saved all data to: ", save_file_path)
		return true
	else:
		push_error("[SaveManager] Failed to save file: ", save_file_path)
		return false

func load_all_data() -> Dictionary:
	"""Load all player data from file"""
	if not FileAccess.file_exists(save_file_path):
		print("[SaveManager] Save file not found, starting fresh")
		save_data = {
			"version": "2.0",
			"currency": {"coins": 0, "gems": 0},
			"owned_items": [],
			"equipped_items": {
				"ball": "ball_standard",
				"flipper": "flipper_standard"
			}
		}
		return save_data
	
	var file = FileAccess.open(save_file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			save_data = json.data
			print("[SaveManager] Loaded data from: ", save_file_path)
		else:
			push_error("[SaveManager] Failed to parse JSON: ", json.get_error_message())
			save_data = {}
	else:
		push_error("[SaveManager] Failed to open save file: ", save_file_path)
		save_data = {}
	
	return save_data

func save_currency(coins: int, gems: int):
	"""Save currency data"""
	if not save_data.has("currency"):
		save_data["currency"] = {}
	save_data["currency"]["coins"] = coins
	save_data["currency"]["gems"] = gems
	_save_to_file()

func load_currency() -> Dictionary:
	"""Load currency data"""
	if save_data.has("currency"):
		return save_data["currency"]
	return {"coins": 0, "gems": 0}

func save_owned_items(items: Array):
	"""Save owned items list"""
	save_data["owned_items"] = items
	_save_to_file()

func load_owned_items() -> Array:
	"""Load owned items list"""
	if save_data.has("owned_items"):
		return save_data["owned_items"]
	# Default items owned by all players
	return ["ball_standard", "flipper_standard"]

func save_equipped_items(items: Dictionary):
	"""Save equipped items"""
	save_data["equipped_items"] = items
	_save_to_file()

func load_equipped_items() -> Dictionary:
	"""Load equipped items"""
	if save_data.has("equipped_items"):
		return save_data["equipped_items"]
	# Default equipped items
	return {
		"ball": "ball_standard",
		"flipper": "flipper_standard"
	}

func _save_to_file():
	"""Internal method to save data to file"""
	# Use call_deferred to avoid saving during initialization
	call_deferred("_do_save_to_file")

func _do_save_to_file():
	"""Actually perform the file save"""
	var file = FileAccess.open(save_file_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()
	else:
		push_error("[SaveManager] Failed to save to file: ", save_file_path)

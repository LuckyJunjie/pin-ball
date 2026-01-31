extends Node

## Global game settings and configuration singleton (Autoload)
## Manages game version, equipped items, and global settings

var game_version: String = "v1.x"  # "v1.x", "v2.0", or "v3.0"
var equipped_items: Dictionary = {
	"ball": "ball_standard",
	"flipper": "flipper_standard"
}

var debug_mode: bool = false
var sound_enabled: bool = true
var music_enabled: bool = true
var volume: float = 1.0

func _ready():
	# Load equipped items from SaveManager if available
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		var loaded_equipped = save_mgr.load_equipped_items()
		if not loaded_equipped.is_empty():
			equipped_items = loaded_equipped
		print("[GlobalGameSettings] Loaded equipped items: ", equipped_items)

func set_game_version(version: String):
	"""Set the game version (v1.x, v2.0, or v3.0)"""
	game_version = version
	print("[GlobalGameSettings] Game version set to: ", game_version)

func get_equipped_item(category: String) -> String:
	"""Get the equipped item ID for a category"""
	return equipped_items.get(category, "")

func set_equipped_item(category: String, item_id: String):
	"""Set the equipped item for a category"""
	equipped_items[category] = item_id
	print("[GlobalGameSettings] Equipped ", category, ": ", item_id)
	
	# Save to SaveManager if available
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.save_equipped_items(equipped_items)

func get_equipped_ball() -> String:
	"""Get equipped ball ID"""
	return get_equipped_item("ball")

func get_equipped_flipper() -> String:
	"""Get equipped flipper ID"""
	return get_equipped_item("flipper")

func load_equipped_items():
	"""Load equipped items from SaveManager"""
	if SaveManager:
		equipped_items = SaveManager.load_equipped_items()

func save_equipped_items():
	"""Save equipped items to SaveManager"""
	if SaveManager:
		SaveManager.save_equipped_items(equipped_items)

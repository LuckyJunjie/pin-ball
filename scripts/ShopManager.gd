extends Node

## Shop manager script
## Handles shop UI, item database, and purchase flow

signal item_purchased(item_id: String, success: bool)
signal item_equipped(item_type: String, item_id: String)
signal currency_updated(coins: int, gems: int)

var item_database: Dictionary = {}
var current_category: String = "balls"
var owned_items: Array = []
var equipped_items: Dictionary = {}

@onready var tab_container: TabContainer = $CanvasLayer/VBoxContainer/TabContainer

func _ready():
	print("[ShopManager] Shop manager ready")
	load_item_database()
	load_player_data()
	_update_category_display()
	
	# Connect tab container signals
	if tab_container:
		tab_container.tab_changed.connect(_on_tab_changed)
	
	# Update currency display
	_update_currency_display()
	
	# Connect to currency changed signal
	var currency_mgr = get_node_or_null("/root/CurrencyManager")
	if currency_mgr:
		currency_mgr.currency_changed.connect(_on_currency_changed)

func load_item_database():
	"""Load item database from JSON file"""
	var file_path = "res://config/items_database.json"
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		file.close()
		
		var json = JSON.new()
		var parse_result = json.parse(json_string)
		if parse_result == OK:
			item_database = json.data.get("items", {})
			print("[ShopManager] Loaded ", item_database.size(), " items from database")
		else:
			push_error("[ShopManager] Failed to parse JSON: ", json.get_error_message())
	else:
		push_error("[ShopManager] Failed to open item database: ", file_path)

func load_player_data():
	"""Load owned items and equipped items from SaveManager"""
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		owned_items = save_mgr.load_owned_items()
		
		var global_settings = get_node_or_null("/root/GlobalGameSettings")
		if global_settings:
			equipped_items = global_settings.equipped_items
		
		print("[ShopManager] Loaded ", owned_items.size(), " owned items")

func get_items_by_category(category: String) -> Array:
	"""Get all items for a specific category"""
	var category_items = []
	for item_id in item_database:
		var item = item_database[item_id]
		if item.get("category") == category:
			category_items.append(item)
	return category_items

func purchase_item(item_id: String) -> bool:
	"""Attempt to purchase an item, return true if successful"""
	if not item_database.has(item_id):
		push_error("[ShopManager] Item not found: ", item_id)
		return false
	
	if is_item_owned(item_id):
		print("[ShopManager] Item already owned: ", item_id)
		return false
	
	var item = item_database[item_id]
	var price = item.get("price", {})
	var currency_type = price.get("currency", "coins")
	var amount = price.get("amount", 0)
	
	# Check if can afford
	if not can_afford_item(item_id):
		print("[ShopManager] Cannot afford item: ", item_id)
		return false
	
	# Spend currency
	var currency_mgr = get_node_or_null("/root/CurrencyManager")
	if currency_mgr:
		var success = false
		if currency_type == "coins":
			success = currency_mgr.spend_coins(amount)
		elif currency_type == "gems":
			success = currency_mgr.spend_gems(amount)
		
		if success:
			# Add to owned items
			owned_items.append(item_id)
			
			# Save to SaveManager
			var save_mgr = get_node_or_null("/root/SaveManager")
			if save_mgr:
				save_mgr.save_owned_items(owned_items)
			
			print("[ShopManager] Purchased item: ", item_id)
			item_purchased.emit(item_id, true)
			_update_category_display()
			return true
	
	return false

func can_afford_item(item_id: String) -> bool:
	"""Check if player can afford an item"""
	if not item_database.has(item_id):
		return false
	
	var item = item_database[item_id]
	var price = item.get("price", {})
	var currency_type = price.get("currency", "coins")
	var amount = price.get("amount", 0)
	
	var currency_mgr = get_node_or_null("/root/CurrencyManager")
	if currency_mgr:
		if currency_type == "coins":
			return currency_mgr.can_afford_coins(amount)
		elif currency_type == "gems":
			return currency_mgr.can_afford_gems(amount)
	
	return false

func equip_item(item_id: String) -> bool:
	"""Equip an item"""
	if not is_item_owned(item_id):
		print("[ShopManager] Cannot equip item not owned: ", item_id)
		return false
	
	if not item_database.has(item_id):
		return false
	
	var item = item_database[item_id]
	var category = item.get("category", "")
	
	if category.is_empty():
		return false
	
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		global_settings.set_equipped_item(category, item_id)
		equipped_items[category] = item_id
		item_equipped.emit(category, item_id)
		_update_category_display()
		return true
	
	return false

func is_item_owned(item_id: String) -> bool:
	"""Check if item is owned"""
	return item_id in owned_items

func is_item_equipped(item_id: String) -> bool:
	"""Check if item is currently equipped"""
	if not item_database.has(item_id):
		return false
	
	var item = item_database[item_id]
	var category = item.get("category", "")
	if category.is_empty():
		return false
	
	return equipped_items.get(category, "") == item_id

func get_item_data(item_id: String) -> Dictionary:
	"""Get item data by ID"""
	return item_database.get(item_id, {})

func _on_tab_changed(tab: int):
	"""Handle tab change in TabContainer"""
	var category_map = {
		0: "ball",  # Balls tab -> ball category
		1: "flipper",  # Flippers tab -> flipper category
		2: "ramp",  # Ramps tab -> ramp category
		3: "cosmetic",  # Cosmetics tab -> cosmetic category
		4: "special"  # Specials tab -> special category
	}
	if tab in category_map:
		current_category = category_map[tab]
		_update_category_display()

func _update_category_display():
	"""Update item grid display for current category"""
	if not tab_container:
		return
	
	# Get current tab's item grid
	var current_tab = tab_container.get_current_tab_control()
	if not current_tab:
		return
	
	var scroll_container = current_tab.get_node_or_null("ScrollContainer")
	if not scroll_container:
		return
	
	var item_grid = scroll_container.get_node_or_null("ItemGrid")
	if not item_grid:
		return
	
	# Clear existing items
	for child in item_grid.get_children():
		child.queue_free()
	
	# Get items for current category
	var items = get_items_by_category(current_category)
	
	for item in items:
		_create_item_card(item, item_grid)

func _create_item_card(item: Dictionary, item_grid: GridContainer):
	"""Create an item card UI element"""
	var item_id = item.get("id", "")
	var item_name = item.get("name", "Unknown")
	var price = item.get("price", {})
	var price_currency = price.get("currency", "coins")
	var price_amount = price.get("amount", 0)
	
	# Create container for item card
	var card = VBoxContainer.new()
	card.custom_minimum_size = Vector2(180, 220)
	
	# Item name label
	var name_label = Label.new()
	name_label.text = item_name
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	name_label.add_theme_font_size_override("font_size", 16)
	card.add_child(name_label)
	
	# Price label
	var price_label = Label.new()
	if price_amount == 0:
		price_label.text = "FREE"
	else:
		var currency_symbol = "🪙" if price_currency == "coins" else "💎"
		price_label.text = currency_symbol + " " + str(price_amount)
	price_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	price_label.add_theme_font_size_override("font_size", 14)
	card.add_child(price_label)
	
	# Action button
	var action_button = Button.new()
	var is_owned = is_item_owned(item_id)
	var is_equipped = is_item_equipped(item_id)
	
	if is_equipped:
		action_button.text = "EQUIPPED"
		action_button.disabled = true
	elif is_owned:
		action_button.text = "EQUIP"
		action_button.pressed.connect(_on_equip_pressed.bind(item_id))
	else:
		action_button.text = "BUY"
		if can_afford_item(item_id):
			action_button.pressed.connect(_on_buy_pressed.bind(item_id))
		else:
			action_button.disabled = true
	
	card.add_child(action_button)
	
	# Add card to grid
	item_grid.add_child(card)

func _on_buy_pressed(item_id: String):
	"""Handle buy button press"""
	purchase_item(item_id)

func _on_equip_pressed(item_id: String):
	"""Handle equip button press"""
	equip_item(item_id)

func _update_currency_display():
	"""Update currency display in header"""
	var currency_mgr = get_node_or_null("/root/CurrencyManager")
	if currency_mgr:
		var header = $CanvasLayer/VBoxContainer/HeaderContainer
		if header:
			var coin_label = header.get_node_or_null("CurrencyDisplay/CoinLabel")
			var gem_label = header.get_node_or_null("CurrencyDisplay/GemLabel")
			
			if coin_label:
				coin_label.text = "Coins: " + str(currency_mgr.get_coins())
			if gem_label:
				gem_label.text = "Gems: " + str(currency_mgr.get_gems())

func _on_currency_changed(_coins: int, _gems: int):
	"""Handle currency changed signal"""
	_update_currency_display()
	_update_category_display()  # Refresh buttons (enable/disable based on affordability)

func _on_back_pressed():
	"""Handle back button press - return to main menu"""
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

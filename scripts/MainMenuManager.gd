extends Node

## Main menu manager script
## Handles main menu UI interactions and navigation

var play_v1_button: Button = null
var play_v2_button: Button = null
var shop_button: Button = null
var settings_button: Button = null
var currency_display: HBoxContainer = null

func _ready():
	print("[MainMenuManager] Main menu ready")
	
	# Find buttons - MainMenuManager and CanvasLayer are siblings under MainMenu
	var main_menu = get_parent()
	if not main_menu:
		print("[MainMenuManager] ERROR: No parent found!")
		return
	
	print("[MainMenuManager] Parent found: ", main_menu.name)
	
	# Find buttons using parent (MainMenu) as base
	play_v1_button = main_menu.get_node_or_null("CanvasLayer/VBoxContainer/ButtonContainer/PlayV1Button")
	play_v2_button = main_menu.get_node_or_null("CanvasLayer/VBoxContainer/ButtonContainer/PlayV2Button")
	shop_button = main_menu.get_node_or_null("CanvasLayer/VBoxContainer/ButtonContainer/ShopButton")
	settings_button = main_menu.get_node_or_null("CanvasLayer/VBoxContainer/ButtonContainer/SettingsButton")
	currency_display = main_menu.get_node_or_null("CanvasLayer/VBoxContainer/HeaderContainer/CurrencyDisplay")
	
	# Debug: Check if buttons are found
	if play_v1_button:
		print("[MainMenuManager] PlayV1Button found")
	else:
		print("[MainMenuManager] ERROR: PlayV1Button NOT found!")
	if play_v2_button:
		print("[MainMenuManager] PlayV2Button found")
	else:
		print("[MainMenuManager] ERROR: PlayV2Button NOT found!")
	
	# Connect button signals
	if play_v1_button:
		play_v1_button.pressed.connect(_on_play_v1_pressed)
		print("[MainMenuManager] Connected PlayV1Button signal")
	if play_v2_button:
		play_v2_button.pressed.connect(_on_play_v2_pressed)
		print("[MainMenuManager] Connected PlayV2Button signal")
	if shop_button:
		shop_button.pressed.connect(_on_shop_pressed)
		print("[MainMenuManager] Connected ShopButton signal")
	if settings_button:
		settings_button.pressed.connect(_on_settings_pressed)
		print("[MainMenuManager] Connected SettingsButton signal")
	
	# Update currency display if CurrencyManager is available
	_update_currency_display()
	
	# Connect to currency changed signal
	var currency_mgr = get_node_or_null("/root/CurrencyManager")
	if currency_mgr:
		currency_mgr.currency_changed.connect(_on_currency_changed)

func _on_play_v1_pressed():
	"""Start game in v1.x mode"""
	print("[MainMenuManager] Starting game in v1.x mode")
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		global_settings.set_game_version("v1.x")
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_play_v2_pressed():
	"""Start game in v2.0 mode"""
	print("[MainMenuManager] Starting game in v2.0 mode")
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		global_settings.set_game_version("v2.0")
	
	# Initialize default items for v2.0 if first time
	_initialize_v2_defaults()
	
	get_tree().change_scene_to_file("res://scenes/Main.tscn")

func _on_shop_pressed():
	"""Open shop scene"""
	print("[MainMenuManager] Opening shop")
	get_tree().change_scene_to_file("res://scenes/ShopScene.tscn")

func _on_settings_pressed():
	"""Open settings (placeholder)"""
	print("[MainMenuManager] Settings pressed (not yet implemented)")

func _initialize_v2_defaults():
	"""Initialize default owned items for v2.0 if needed"""
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		var owned_items = save_mgr.load_owned_items()
		if owned_items.is_empty():
			# Add default items
			var default_items = ["ball_standard", "flipper_standard"]
			save_mgr.save_owned_items(default_items)
			print("[MainMenuManager] Initialized default items for v2.0")

func _update_currency_display():
	"""Update currency display in header"""
	var currency_mgr = get_node_or_null("/root/CurrencyManager")
	if currency_mgr and currency_display:
		var coin_label = currency_display.get_node_or_null("CoinLabel")
		var gem_label = currency_display.get_node_or_null("GemLabel")
		
		if coin_label:
			coin_label.text = "Coins: " + str(currency_mgr.get_coins())
		if gem_label:
			gem_label.text = "Gems: " + str(currency_mgr.get_gems())

func _on_currency_changed(_coins: int, _gems: int):
	"""Handle currency changed signal"""
	_update_currency_display()

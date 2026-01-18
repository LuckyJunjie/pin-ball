extends CanvasLayer

## UI script for score display and game information

@onready var score_label: Label = $ScoreLabel
@onready var currency_display: HBoxContainer = $CurrencyDisplay
@onready var coin_label: Label = $CurrencyDisplay/CoinLabel
@onready var gem_label: Label = $CurrencyDisplay/GemLabel
@onready var back_to_menu_button: Button = $BackToMenuButton

var is_v2_mode: bool = false

func _ready():
	# Find GameManager and connect score signal
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if not game_manager:
		# Try to find it in the scene tree
		game_manager = get_node("../GameManager")
	
	if game_manager:
		game_manager.score_changed.connect(_on_score_changed)
	
	# Check if v2.0 mode
	var global_settings = get_node_or_null("/root/GlobalGameSettings")
	if global_settings:
		is_v2_mode = (global_settings.game_version == "v2.0")
	
	# Show/hide currency display based on version
	if currency_display:
		currency_display.visible = is_v2_mode
	
	if is_v2_mode:
		# Connect to currency changed signal
		var currency_mgr = get_node_or_null("/root/CurrencyManager")
		if currency_mgr:
			currency_mgr.currency_changed.connect(_on_currency_changed)
			_update_currency_display()
	
	# Connect back to menu button
	if back_to_menu_button:
		back_to_menu_button.pressed.connect(_on_back_to_menu_pressed)

func _on_score_changed(new_score: int):
	"""Update score label when score changes"""
	if score_label:
		score_label.text = "Score: " + str(new_score)

func set_score_text(score: int):
	"""Set score text (for direct connection)"""
	_on_score_changed(score)

func update_currency_display(coins: int, gems: int):
	"""Update currency display (v2.0)"""
	if not is_v2_mode:
		return
	
	if coin_label:
		coin_label.text = "Coins: " + str(coins)
	if gem_label:
		gem_label.text = "Gems: " + str(gems)

func _update_currency_display():
	"""Internal method to update currency display"""
	if not is_v2_mode:
		return
	
	var currency_mgr = get_node_or_null("/root/CurrencyManager")
	if currency_mgr:
		update_currency_display(currency_mgr.get_coins(), currency_mgr.get_gems())

func _on_currency_changed(coins: int, gems: int):
	"""Handle currency changed signal"""
	update_currency_display(coins, gems)

func _on_back_to_menu_pressed():
	"""Handle back to menu button press"""
	print("[UI] Returning to main menu")
	get_tree().change_scene_to_file("res://scenes/MainMenu.tscn")

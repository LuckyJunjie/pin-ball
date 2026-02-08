extends CanvasLayer

## UI script for score display and game information

@onready var score_label: Label = $ScoreLabel
@onready var currency_display: HBoxContainer = $CurrencyDisplay
@onready var coin_label: Label = $CurrencyDisplay/CoinLabel
@onready var gem_label: Label = $CurrencyDisplay/GemLabel
@onready var back_to_menu_button: Button = $BackToMenuButton

# v3.0: New UI elements
var multiplier_label: Label = null
var combo_label: Label = null
var animation_manager: Node = null

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
	
	# v3.0: Initialize new UI elements
	_initialize_v3_ui()

func _on_score_changed(new_score: int):
	"""Update score label when score changes"""
	if score_label:
		score_label.text = "Score: " + str(new_score)
		
		# v3.0: Animate score update
		if animation_manager:
			animation_manager.animate_component_highlight(score_label, Color.YELLOW, 0.2)

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

# v3.0: New UI methods

func _initialize_v3_ui():
	"""Initialize v3.0 UI elements"""
	# Find animation manager
	animation_manager = get_tree().get_first_node_in_group("animation_manager")
	if not animation_manager:
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			animation_manager = game_manager.get_node_or_null("AnimationManager")
	
	# Create multiplier label
	multiplier_label = Label.new()
	multiplier_label.name = "MultiplierLabel"
	multiplier_label.text = "1.0x"
	multiplier_label.add_theme_font_size_override("font_size", 24)
	multiplier_label.add_theme_color_override("font_color", Color.GREEN)
	multiplier_label.add_theme_color_override("font_outline_color", Color.BLACK)
	multiplier_label.add_theme_constant_override("outline_size", 2)
	multiplier_label.position = Vector2(20, 100)  # Below score
	multiplier_label.visible = false  # Hidden until multiplier > 1.0
	add_child(multiplier_label)
	
	# Create combo label
	combo_label = Label.new()
	combo_label.name = "ComboLabel"
	combo_label.text = "Combo: 0"
	combo_label.add_theme_font_size_override("font_size", 20)
	combo_label.add_theme_color_override("font_color", Color.CYAN)
	combo_label.add_theme_color_override("font_outline_color", Color.BLACK)
	combo_label.add_theme_constant_override("outline_size", 2)
	combo_label.position = Vector2(20, 140)  # Below multiplier
	combo_label.visible = false  # Hidden until combo active
	add_child(combo_label)
	
	# Connect to game systems
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		# Connect to combo system
		var combo_system = game_manager.get_node_or_null("ComboSystem")
		if combo_system:
			if combo_system.has_signal("combo_increased"):
				combo_system.combo_increased.connect(_on_combo_increased)
			if combo_system.has_signal("combo_ended"):
				combo_system.combo_ended.connect(_on_combo_ended)
	
	# Start update loop (use call_deferred to avoid await in _ready)
	call_deferred("_start_ui_update_loop")

func _start_ui_update_loop():
	"""Start the UI update loop"""
	_update_ui_loop()

func _update_ui_loop():
	"""Update UI elements continuously"""
	# Update multiplier display
	if multiplier_label:
		var game_manager = get_tree().get_first_node_in_group("game_manager")
		if game_manager:
			var multiplier = game_manager.get("current_multiplier")
			if multiplier and multiplier > 1.0:
				multiplier_label.text = str(multiplier) + "x"
				multiplier_label.visible = true
			else:
				multiplier_label.visible = false
	
	# Schedule next update
	await get_tree().create_timer(0.1).timeout
	_update_ui_loop()

func _on_combo_increased(combo_count: int, multiplier: float):
	"""Update combo display"""
	if combo_label:
		combo_label.text = "Combo: " + str(combo_count) + " (" + str(multiplier) + "x)"
		combo_label.visible = true
		
		# Animate combo display
		if animation_manager:
			animation_manager.animate_component_highlight(combo_label, Color.CYAN, 0.2)

func _on_combo_ended():
	"""Hide combo display"""
	if combo_label:
		combo_label.visible = false

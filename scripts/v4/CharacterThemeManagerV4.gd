extends Node
## v4.0 Character Theme Manager - Manages character theme switching and visual updates
## Use as autoload "CharacterThemeManagerV4"

# Theme definitions
enum ThemeKey { SPARKY, DINO, DASH, ANDROID }

# Theme configuration
const THEME_CONFIG: Dictionary = {
	"sparky": {
		"name": "Sparky",
		"color": Color(1.0, 0.5, 0.0),  # Orange
		"zone": "sparky_scorch",
		"bonus": GameManagerV4.Bonus.SPARKY_TURBO_CHARGE,
		"asset_path": "res://assets/sprites/v4.0/android/"  # Placeholder
	},
	"dino": {
		"name": "Chrome Dino",
		"color": Color(0.0, 0.8, 0.0),  # Green
		"zone": "dino_desert",
		"bonus": GameManagerV4.Bonus.DINO_CHOMP,
		"asset_path": "res://assets/sprites/v3.0/"
	},
	"dash": {
		"name": "Dash",
		"color": Color(0.0, 0.5, 1.0),  # Blue
		"zone": "flutter_forest",
		"bonus": GameManagerV4.Bonus.DASH_NEST,
		"asset_path": "res://assets/sprites/v3.0/"
	},
	"android": {
		"name": "Android",
		"color": Color(0.6, 0.8, 0.2),  # Android green
		"zone": "android_acres",
		"bonus": GameManagerV4.Bonus.ANDROID_SPACESHIP,
		"asset_path": "res://assets/sprites/v4.0/android/"
	}
}

# Signals
signal theme_changed(old_theme: String, new_theme: String)
signal theme_assets_loaded(theme_key: String, assets: Dictionary)
signal theme_activation_started(theme_key: String)
signal theme_activation_completed(theme_key: String)

# Current state
var current_theme: String = "sparky"
var theme_assets: Dictionary = {}
var is_theme_loading: bool = false
var theme_queue: Array[String] = []

# References
@onready var asset_loader = get_node_or_null("/root/AssetLoaderV4")
@onready var game_manager = get_node_or_null("/root/GameManagerV4")


func _ready() -> void:
	add_to_group("character_theme_manager_v4")
	
	# Load initial theme
	call_deferred("load_theme", current_theme)
	
	# Connect to game manager for theme changes
	if game_manager and game_manager.has_signal("character_theme_changed"):
		game_manager.character_theme_changed.connect(_on_game_manager_theme_changed)


func load_theme(theme_key: String) -> void:
	## Load and activate a character theme
	if theme_key not in THEME_CONFIG:
		push_warning("CharacterThemeManagerV4: Invalid theme key '%s'" % theme_key)
		return
	
	if is_theme_loading:
		# Queue the theme change
		if theme_key not in theme_queue:
			theme_queue.append(theme_key)
		return
	
	is_theme_loading = true
	theme_activation_started.emit(theme_key)
	
	# Load theme assets
	_load_theme_assets(theme_key)
	
	# Update current theme
	var old_theme = current_theme
	current_theme = theme_key
	
	# Update game manager
	if game_manager:
		game_manager.set_character_theme(theme_key)
	
	# Emit signals
	theme_changed.emit(old_theme, theme_key)
	theme_activation_completed.emit(theme_key)
	
	# Process next theme in queue
	is_theme_loading = false
	if theme_queue.size() > 0:
		var next_theme = theme_queue.pop_front()
		load_theme(next_theme)


func _load_theme_assets(theme_key: String) -> void:
	## Load assets for the given theme
	if asset_loader and asset_loader.has_method("load_theme_assets"):
		theme_assets = asset_loader.load_theme_assets(theme_key)
		theme_assets_loaded.emit(theme_key, theme_assets)
	else:
		# Fallback: create empty assets dictionary
		theme_assets = {
			"ball": null,
			"icon": null,
			"leaderboard_icon": null,
			"background": null,
			"animation": null
		}
		theme_assets_loaded.emit(theme_key, theme_assets)


func get_current_theme_config() -> Dictionary:
	## Get configuration for current theme
	return THEME_CONFIG.get(current_theme, {})


func get_theme_config(theme_key: String) -> Dictionary:
	## Get configuration for specific theme
	return THEME_CONFIG.get(theme_key, {})


func get_theme_color(theme_key: String = "") -> Color:
	## Get theme color for UI elements
	var config = get_theme_config(theme_key if theme_key else current_theme)
	return config.get("color", Color.WHITE)


func get_theme_zone(theme_key: String = "") -> String:
	## Get associated zone for theme
	var config = get_theme_config(theme_key if theme_key else current_theme)
	return config.get("zone", "")


func get_theme_bonus(theme_key: String = "") -> GameManagerV4.Bonus:
	## Get associated bonus for theme
	var config = get_theme_config(theme_key if theme_key else current_theme)
	return config.get("bonus", GameManagerV4.Bonus.SPARKY_TURBO_CHARGE)


func get_theme_assets() -> Dictionary:
	## Get loaded assets for current theme
	return theme_assets.duplicate()


func get_theme_asset(asset_key: String) -> Texture2D:
	## Get specific asset for current theme
	return theme_assets.get(asset_key, null)


func set_theme_by_bonus(bonus: GameManagerV4.Bonus) -> void:
	## Set theme based on activated bonus
	var target_theme = ""
	
	match bonus:
		GameManagerV4.Bonus.SPARKY_TURBO_CHARGE:
			target_theme = "sparky"
		GameManagerV4.Bonus.DINO_CHOMP:
			target_theme = "dino"
		GameManagerV4.Bonus.DASH_NEST:
			target_theme = "dash"
		GameManagerV4.Bonus.ANDROID_SPACESHIP:
			target_theme = "android"
		GameManagerV4.Bonus.GOOGLE_WORD:
			# Google Word bonus doesn't change theme
			return
	
	if target_theme and target_theme != current_theme:
		load_theme(target_theme)


func _on_game_manager_theme_changed(theme_key: String) -> void:
	## Handle theme change from game manager
	if theme_key != current_theme:
		load_theme(theme_key)


func reset() -> void:
	## Reset to default theme
	theme_queue.clear()
	load_theme("sparky")


func get_debug_info() -> Dictionary:
	## Return debug information
	return {
		"current_theme": current_theme,
		"theme_config": get_current_theme_config(),
		"theme_assets_loaded": theme_assets.keys(),
		"is_loading": is_theme_loading,
		"queue_size": theme_queue.size()
	}
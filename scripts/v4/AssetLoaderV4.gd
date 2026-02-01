extends Node
## v4.0 Asset loader service for theme-based asset loading.
## Use as autoload "AssetLoaderV4".

# Theme asset paths
const THEME_PATHS: Dictionary = {
	"sparky": "res://assets/sprites/v4.0/android/",  # Note: using android assets as placeholder
	"dino": "res://assets/sprites/v4.0/android/",
	"dash": "res://assets/sprites/v4.0/android/",
	"android": "res://assets/sprites/v4.0/android/"
}

# Zone asset paths
const ZONE_PATHS: Dictionary = {
	"android_acres": "res://assets/sprites/v4.0/android/",
	"dino_desert": "res://assets/sprites/v3.0/",
	"google_gallery": "res://assets/sprites/v3.0/",
	"flutter_forest": "res://assets/sprites/v3.0/",
	"sparky_scorch": "res://assets/sprites/v3.0/"
}

# Cache loaded assets
var theme_cache: Dictionary = {}
var zone_cache: Dictionary = {}


func _ready() -> void:
	add_to_group("asset_loader_v4")
	
	# Preload default theme
	load_theme_assets("sparky")


func load_theme_assets(theme_key: String) -> Dictionary:
	## Load all assets for a given theme
	if theme_key in theme_cache:
		return theme_cache[theme_key].duplicate()
	
	var assets = {}
	var base_path = THEME_PATHS.get(theme_key, THEME_PATHS["sparky"])
	
	# Try to load theme assets
	assets.ball = _load_texture("%sball.png" % base_path)
	assets.icon = _load_texture("%sicon.png" % base_path)
	assets.leaderboard_icon = _load_texture("%sleaderboard_icon.png" % base_path)
	assets.background = _load_texture("%sbackground.jpg" % base_path)
	assets.animation = _load_texture("%sanimation.png" % base_path)
	
	# Store in cache
	theme_cache[theme_key] = assets.duplicate()
	
	return assets


func load_zone_assets(zone_key: String) -> Dictionary:
	## Load zone-specific sprites
	if zone_key in zone_cache:
		return zone_cache[zone_key].duplicate()
	
	var assets = {}
	var base_path = ZONE_PATHS.get(zone_key, ZONE_PATHS["android_acres"])
	
	# Zone-specific assets would be loaded here
	# For now, return empty dictionary
	
	zone_cache[zone_key] = assets.duplicate()
	return assets


func get_ball_texture(theme_key: String) -> Texture2D:
	## Get ball texture for current theme
	var assets = load_theme_assets(theme_key)
	return assets.get("ball", null)


func get_background_texture(theme_key: String) -> Texture2D:
	## Get background texture for current theme
	var assets = load_theme_assets(theme_key)
	return assets.get("background", null)


func _load_texture(path: String) -> Texture2D:
	## Helper to load texture with error handling
	if FileAccess.file_exists(path):
		return load(path)
	else:
		push_warning("AssetLoaderV4: Texture not found: %s" % path)
		return null


func clear_cache() -> void:
	## Clear asset cache (e.g., when changing themes)
	theme_cache.clear()
	zone_cache.clear()


func get_current_theme_assets() -> Dictionary:
	## Get assets for currently selected theme
	var backbox = get_node_or_null("/root/BackboxManagerV4")
	if backbox and backbox.has_method("get_selected_character_key"):
		var theme_key = backbox.selected_character_key
		return load_theme_assets(theme_key)
	
	# Default to sparky
	return load_theme_assets("sparky")
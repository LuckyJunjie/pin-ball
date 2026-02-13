extends Node
## v4.0 Localization System
## Multi-language support

signal language_changed(new_language: String)

var _current_language: String = "en"
var _translations: Dictionary = {}
var _fallback_language: String = "en"

const TRANSLATIONS_DIR = "res://translations/"
const SETTINGS_KEY = "localization/language"

func _ready() -> void:
	add_to_group("localization")
	_load_language()
	_load_translations()

func _load_language() -> void:
	var settings = get_tree().get_first_node_in_group("settings")
	if settings:
		var lang = settings.get_setting("gameplay", "language")
		if lang:
			_current_language = lang
	else:
		# Try to detect from system
		_current_language = _detect_system_language()

func _detect_system_language() -> String:
	var locale = OS.get_locale()
	if locale.begins_with("zh"):
		return "zh"
	elif locale.begins_with("ja"):
		return "ja"
	elif locale.begins_with("ko"):
		return "ko"
	elif locale.begins_with("es"):
		return "es"
	elif locale.begins_with("de"):
		return "de"
	elif locale.begins_with("fr"):
		return "fr"
	return "en"

func _load_translations() -> void:
	# Load English (fallback)
	_translations["en"] = _load_translation_file("en.json")
	
	# Load current language
	if _current_language != "en":
		_translations[_current_language] = _load_translation_file(_current_language + ".json")

func _load_translation_file(filename: String) -> Dictionary:
	var path = TRANSLATIONS_DIR + filename
	
	if not FileAccess.file_exists(path):
		return {}
	
	var file = FileAccess.open(path, FileAccess.READ)
	var json = JSON.new()
	json.parse(file.get_as_text())
	return json.get_data()

func set_language(lang_code: String) -> void:
	if lang_code == _current_language:
		return
	
	_current_language = lang_code
	
	# Save preference
	var settings = get_tree().get_first_node_in_group("settings")
	if settings:
		settings.set_setting("gameplay", "language", lang_code)
	
	# Reload translations
	_load_translations()
	
	# Notify systems
	language_changed.emit(lang_code)

func get_language() -> String:
	return _current_language

func tr(key: String, context: String = "") -> String:
	# Try current language
	if _translations.has(_current_language):
		var lang_dict = _translations[_current_language]
		if lang_dict.has(key):
			return lang_dict[key]
	
	# Try fallback
	if _translations.has(_fallback_language):
		var fallback_dict = _translations[_fallback_language]
		if fallback_dict.has(key):
			return fallback_dict[key]
	
	# Return key if no translation found
	return key

func tr_with_count(key: String, count: int) -> String:
	var singular = tr(key)
	var plural = tr(key + "_plural")
	
	if count == 1:
		return singular
	else:
		return plural.format({"count": count})

func get_available_languages() -> Array:
	return [
		{"code": "en", "name": "English", "native_name": "English"},
		{"code": "zh", "name": "Chinese", "native_name": "中文"},
		{"code": "ja", "name": "Japanese", "native_name": "日本語"},
		{"code": "ko", "name": "Korean", "native_name": "한국어"},
		{"code": "es", "name": "Spanish", "native_name": "Español"},
		{"code": "de", "name": "German", "native_name": "Deutsch"},
		{"code": "fr", "name": "French", "native_name": "Français"}
	]

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("localization")
	return null

# Example translation file format (translations/en.json):
"""
{
    "game_title": "Pinball",
    "start_game": "Start Game",
    "settings": "Settings",
    "leaderboard": "Leaderboard",
    "achievements": "Achievements",
    "back": "Back",
    "score": "Score",
    "high_score": "High Score",
    "new_game": "New Game",
    "continue": "Continue",
    "game_over": "Game Over",
    "pause": "Pause",
    "bonus": "Bonus",
    "multiplier": "Multiplier",
    "combo": "Combo",
    "flipper": "Flipper",
    "launch": "Launch",
    "ready": "Ready?",
    "game_complete": "Game Complete!"
}
"""

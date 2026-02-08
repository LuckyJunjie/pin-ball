extends Node
## v4.0 Bonus Manager - Tracks and manages bonus activation across all zones
## Use as autoload "BonusManagerV4"

# Bonus definitions matching GameManagerV4.Bonus enum
enum Bonus { GOOGLE_WORD, DASH_NEST, SPARKY_TURBO_CHARGE, DINO_CHOMP, ANDROID_SPACESHIP }

# Bonus configuration
const BONUS_CONFIG: Dictionary = {
	Bonus.GOOGLE_WORD: {
		"name": "Google Word",
		"points": 100000,
		"zone": "google_gallery",
		"description": "Complete the GOOGLE word by hitting all 6 letters",
		"activation_condition": "all_letters_completed",
		"visual_effect": "word_completion"
	},
	Bonus.DASH_NEST: {
		"name": "Dash Nest",
		"points": 75000,
		"zone": "flutter_forest",
		"description": "Light all Dash bumpers and hit the nest",
		"activation_condition": "dash_nest_completed",
		"visual_effect": "dash_activation"
	},
	Bonus.SPARKY_TURBO_CHARGE: {
		"name": "Sparky Turbo Charge",
		"points": 100000,
		"zone": "sparky_scorch",
		"description": "Activate all Sparky bumpers and hit the computer target",
		"activation_condition": "sparky_completed",
		"visual_effect": "sparky_activation"
	},
	Bonus.DINO_CHOMP: {
		"name": "Dino Chomp",
		"points": 150000,
		"zone": "dino_desert",
		"description": "Activate the Chrome Dino by hitting the chomp target",
		"activation_condition": "dino_chomp_activated",
		"visual_effect": "dino_chomp"
	},
	Bonus.ANDROID_SPACESHIP: {
		"name": "Android Spaceship",
		"points": 200000,
		"zone": "android_acres",
		"description": "Hit the Android Spaceship target",
		"activation_condition": "spaceship_hit",
		"visual_effect": "spaceship_activation"
	}
}

# Bonus state tracking
var active_bonuses: Array[Bonus] = []
var bonus_history: Array[Dictionary] = []  # {bonus: Bonus, timestamp: float, points: int}
var zone_progress: Dictionary = {}  # Tracks progress toward each bonus

# Signals
signal bonus_activated(bonus: Bonus, points: int)
signal bonus_progress_updated(zone: String, progress: Dictionary)
signal all_bonuses_completed()  # When all 5 bonuses are activated in a game

# References
@onready var game_manager = get_node_or_null("/root/GameManagerV4")
@onready var theme_manager = get_node_or_null("/root/CharacterThemeManagerV4")


func _ready() -> void:
	add_to_group("bonus_manager_v4")
	
	# Initialize zone progress tracking
	_init_zone_progress()
	
	# Connect to game manager for bonus activation
	if game_manager and game_manager.has_signal("bonus_activated"):
		game_manager.bonus_activated.connect(_on_game_manager_bonus_activated)


func _init_zone_progress() -> void:
	## Initialize progress tracking for all zones
	zone_progress = {
		"google_gallery": {
			"letters_completed": 0,
			"total_letters": 6,
			"word_completed": false
		},
		"flutter_forest": {
			"dash_bumpers_lit": 0,
			"total_dash_bumpers": 3,
			"dash_nest_activated": false
		},
		"sparky_scorch": {
			"sparky_bumpers_lit": 0,
			"total_sparky_bumpers": 3,
			"computer_target_activated": false
		},
		"dino_desert": {
			"dino_chomp_activated": false,
			"slingshot_hits": 0
		},
		"android_acres": {
			"spaceship_hit": false,
			"bumpers_lit": 0,
			"total_bumpers": 3
		}
	}


func activate_bonus(bonus: Bonus, source_zone: String = "") -> void:
	## Activate a bonus and handle all related logic
	if bonus in active_bonuses:
		return  # Already active
	
	# Get bonus configuration
	var config = BONUS_CONFIG.get(bonus, {})
	if config.is_empty():
		push_warning("BonusManagerV4: Invalid bonus %s" % bonus)
		return
	
	# Add to active bonuses
	active_bonuses.append(bonus)
	
	# Record in history
	var bonus_record = {
		"bonus": bonus,
		"timestamp": Time.get_unix_time_from_system(),
		"points": config.get("points", 0),
		"zone": source_zone if source_zone else config.get("zone", "")
	}
	bonus_history.append(bonus_record)
	
	# Add score through game manager
	if game_manager:
		game_manager.add_bonus(bonus)
	
	# Update theme if theme manager exists
	if theme_manager and theme_manager.has_method("set_theme_by_bonus"):
		theme_manager.set_theme_by_bonus(bonus)
	
	# Emit signals
	bonus_activated.emit(bonus, config.get("points", 0))
	
	# Check if all bonuses are completed
	if active_bonuses.size() >= 5:  # All 5 bonuses activated
		all_bonuses_completed.emit()
	
	# Log activation
	print("BonusManagerV4: Activated %s (+%d points)" % [config.get("name", "Unknown"), config.get("points", 0)])


func update_zone_progress(zone: String, progress_key: String, value) -> void:
	## Update progress for a specific zone
	if not zone_progress.has(zone):
		push_warning("BonusManagerV4: Unknown zone '%s'" % zone)
		return
	
	var zone_data = zone_progress[zone]
	zone_data[progress_key] = value
	
	# Check for bonus completion based on zone progress
	_check_zone_bonus_completion(zone, zone_data)
	
	# Emit progress update
	bonus_progress_updated.emit(zone, zone_data.duplicate())


func _check_zone_bonus_completion(zone: String, zone_data: Dictionary) -> void:
	## Check if zone progress warrants a bonus activation
	match zone:
		"google_gallery":
			if zone_data.get("letters_completed", 0) >= zone_data.get("total_letters", 6) and not zone_data.get("word_completed", false):
				zone_data["word_completed"] = true
				activate_bonus(Bonus.GOOGLE_WORD, zone)
		
		"flutter_forest":
			if zone_data.get("dash_bumpers_lit", 0) >= zone_data.get("total_dash_bumpers", 3) and not zone_data.get("dash_nest_activated", false):
				# Dash nest needs to be hit separately, but we'll activate when bumpers are lit
				# Actual activation happens when nest is hit
				pass
		
		"sparky_scorch":
			if zone_data.get("sparky_bumpers_lit", 0) >= zone_data.get("total_sparky_bumpers", 3) and not zone_data.get("computer_target_activated", false):
				# Computer target needs to be hit separately
				pass
		
		"dino_desert":
			if zone_data.get("dino_chomp_activated", false):
				activate_bonus(Bonus.DINO_CHOMP, zone)
		
		"android_acres":
			if zone_data.get("spaceship_hit", false):
				activate_bonus(Bonus.ANDROID_SPACESHIP, zone)


func get_zone_progress(zone: String) -> Dictionary:
	## Get current progress for a zone
	return zone_progress.get(zone, {}).duplicate()


func get_active_bonuses() -> Array[Bonus]:
	## Get list of currently active bonuses
	return active_bonuses.duplicate()


func get_bonus_history() -> Array[Dictionary]:
	## Get complete bonus history
	return bonus_history.duplicate()


func is_bonus_active(bonus: Bonus) -> bool:
	## Check if a specific bonus is currently active
	return bonus in active_bonuses


func get_bonus_config(bonus: Bonus) -> Dictionary:
	## Get configuration for a specific bonus
	return BONUS_CONFIG.get(bonus, {}).duplicate()


func reset() -> void:
	## Reset bonus state for new game
	active_bonuses.clear()
	bonus_history.clear()
	_init_zone_progress()
	
	print("BonusManagerV4: Reset for new game")


func _on_game_manager_bonus_activated(bonus: GameManagerV4.Bonus) -> void:
	## Handle bonus activation from game manager
	# Convert GameManagerV4.Bonus to our Bonus enum
	var bonus_enum = Bonus.get(bonus)
	if bonus_enum != null:
		activate_bonus(bonus_enum)


func get_debug_info() -> Dictionary:
	## Return debug information
	return {
		"active_bonuses": active_bonuses.size(),
		"bonus_history": bonus_history.size(),
		"zone_progress": zone_progress.duplicate(),
		"all_bonuses_completed": active_bonuses.size() >= 5
	}
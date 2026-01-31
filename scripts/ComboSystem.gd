extends Node

## v3.0: Combo System
## Chain hits for bonus scoring

signal combo_started()
signal combo_increased(combo_count: int, multiplier: float)
signal combo_ended()

@export var combo_window: float = 3.0  # Time window between hits (seconds)
@export var combo_multiplier_per_hit: float = 0.1  # +0.1x per hit
@export var max_combo: int = 20  # Maximum combo hits
@export var max_combo_multiplier: float = 2.0  # Maximum combo multiplier (2x)

var current_combo: int = 0
var combo_timer: float = 0.0
var is_combo_active: bool = false

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	add_to_group("combo_system")

func _process(delta):
	if is_combo_active:
		combo_timer -= delta
		
		# End combo if timer expires
		if combo_timer <= 0.0:
			end_combo()

func register_hit():
	"""Register a hit for combo system"""
	if not is_combo_active:
		# Start new combo
		start_combo()
	
	# Reset timer
	combo_timer = combo_window
	
	# Increase combo count
	current_combo += 1
	
	# Cap at max combo
	if current_combo > max_combo:
		current_combo = max_combo
	
	# Calculate multiplier
	var multiplier = 1.0 + (current_combo * combo_multiplier_per_hit)
	if multiplier > (1.0 + max_combo_multiplier):
		multiplier = 1.0 + max_combo_multiplier
	
	if _get_debug_mode():
		print("[ComboSystem] Combo: ", current_combo, " hits, multiplier: ", multiplier, "x")
	
	combo_increased.emit(current_combo, multiplier)
	
	# Play combo sound with rising pitch
	_play_combo_sound()

func start_combo():
	"""Start a new combo"""
	is_combo_active = true
	current_combo = 0
	combo_timer = combo_window
	
	if _get_debug_mode():
		print("[ComboSystem] Combo started")
	
	combo_started.emit()

func end_combo():
	"""End current combo"""
	if not is_combo_active:
		return
	
	is_combo_active = false
	
	if _get_debug_mode():
		print("[ComboSystem] Combo ended at ", current_combo, " hits")
	
	combo_ended.emit()
	
	current_combo = 0
	combo_timer = 0.0

func get_combo_multiplier() -> float:
	"""Get current combo multiplier"""
	if not is_combo_active:
		return 1.0
	
	var multiplier = 1.0 + (current_combo * combo_multiplier_per_hit)
	if multiplier > (1.0 + max_combo_multiplier):
		multiplier = 1.0 + max_combo_multiplier
	
	return multiplier

func get_combo_count() -> int:
	"""Get current combo count"""
	return current_combo if is_combo_active else 0

func _play_combo_sound():
	"""Play combo sound with rising pitch"""
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager and sound_manager.has_method("play_sound_with_pitch"):
		# Pitch increases with combo (1.0 base, up to 2.0)
		var pitch = 1.0 + (current_combo * 0.05)
		if pitch > 2.0:
			pitch = 2.0
		sound_manager.play_sound_with_pitch("combo_hit", pitch)
	elif sound_manager and sound_manager.has_method("play_sound"):
		sound_manager.play_sound("combo_hit")

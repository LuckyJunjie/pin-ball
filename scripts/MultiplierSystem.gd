extends Node

## v3.0: Dynamic Multiplier System
## Progressive score multipliers that increase with gameplay

signal multiplier_changed(new_multiplier: float)

@export var base_multiplier: float = 1.0
@export var increase_per_hits: int = 5  # Increase every N hits
@export var multiplier_increment: float = 0.5  # +0.5x per increase
@export var max_multiplier: float = 10.0  # Maximum multiplier
@export var decay_time: float = 10.0  # Seconds before decay
@export var decay_amount: float = 0.5  # Multiplier decrease on decay

var current_multiplier: float = 1.0
var hit_count: int = 0
var decay_timer: float = 0.0

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	current_multiplier = base_multiplier
	add_to_group("multiplier_system")

func _process(delta):
	if current_multiplier > base_multiplier:
		decay_timer -= delta
		if decay_timer <= 0.0:
			decay_multiplier()

func register_hit():
	"""Register a hit and potentially increase multiplier"""
	hit_count += 1
	decay_timer = decay_time  # Reset decay timer
	
	# Check if we should increase multiplier
	if hit_count % increase_per_hits == 0:
		increase_multiplier()

func increase_multiplier():
	"""Increase multiplier"""
	current_multiplier += multiplier_increment
	if current_multiplier > max_multiplier:
		current_multiplier = max_multiplier
	
	decay_timer = decay_time  # Reset decay timer
	
	if _get_debug_mode():
		print("[MultiplierSystem] Multiplier increased to ", current_multiplier, "x")
	
	multiplier_changed.emit(current_multiplier)

func decay_multiplier():
	"""Decay multiplier if no hits for decay_time"""
	current_multiplier = max(base_multiplier, current_multiplier - decay_amount)
	decay_timer = decay_time
	
	if _get_debug_mode():
		print("[MultiplierSystem] Multiplier decayed to ", current_multiplier, "x")
	
	multiplier_changed.emit(current_multiplier)

func get_multiplier() -> float:
	"""Get current multiplier"""
	return current_multiplier

func reset():
	"""Reset multiplier to base"""
	current_multiplier = base_multiplier
	hit_count = 0
	decay_timer = 0.0
	multiplier_changed.emit(current_multiplier)

extends Node
## v4.0 Combo System
## Tracks consecutive hits without drain for score multipliers

signal combo_started(combo_count: int)
signal combo_increased(combo_count: int)
signal combo_reset(reason: String, final_combo: int)
signal combo_bonus_awarded(combo_count: int, bonus_points: int)

const COMBO_TIMEOUT: float = 3.0  # Seconds before combo resets
const COMBO_BONUS_BASE: int = 1000  # Base bonus per combo level
const COMBO_BONUS_MULTIPLIER: float = 0.5  # 50% increase per combo level
const MAX_COMBO_BONUS_COMBO_COUNT: int = 20  # Cap bonus at this combo level

var combo_count: int = 0
var combo_timer: float = 0.0
var is_combo_active: bool = false
var last_hit_type: String = ""
var total_combo_bonus_earned: int = 0

# Combo statistics
var max_combo_achieved: int = 0
var combo_history: Array = []  # Array of {combo: int, timestamp: float}

func _ready() -> void:
	add_to_group("combo_system")
	_reset_combo("game_start")

func _process(delta: float) -> void:
	if is_combo_active:
		combo_timer -= delta
		
		if combo_timer <= 0.0:
			_reset_combo("timeout")

func _get_debug_mode() -> bool:
	var gm = get_tree().get_first_node_in_group("game_manager")
	if gm:
		var debug = gm.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func register_hit(hit_type: String, base_points: int) -> int:
	## Register a hit and return any combo bonus points awarded
	if hit_type == last_hit_type:
		# Same hit type - no combo increase, just reset timer
		combo_timer = COMBO_TIMEOUT
		return 0
	
	last_hit_type = hit_type
	
	if not is_combo_active:
		# Start new combo
		combo_count = 1
		is_combo_active = true
		combo_started.emit(combo_count)
		
		if _get_debug_mode():
			print("[ComboSystem] Combo started: %d" % combo_count)
	else:
		# Increase existing combo
		combo_count += 1
		
		if combo_count > max_combo_achieved:
			max_combo_achieved = combo_count
		
		combo_increased.emit(combo_count)
		
		if _get_debug_mode():
			print("[ComboSystem] Combo increased to: %d" % combo_count)
	
	combo_timer = COMBO_TIMEOUT
	
	# Calculate and award combo bonus
	var bonus_points = _calculate_combo_bonus()
	if bonus_points > 0:
		total_combo_bonus_earned += bonus_points
		combo_bonus_awarded.emit(combo_count, bonus_points)
		
		# Log combo
		combo_history.append({
			"combo": combo_count,
			"bonus": bonus_points,
			"timestamp": Time.get_unix_time_from_system()
		})
		
		if _get_debug_mode():
			print("[ComboSystem] Combo bonus: %d points for combo %d" % [bonus_points, combo_count])
	
	return bonus_points

func _calculate_combo_bonus() -> int:
	## Calculate bonus points based on combo count
	if combo_count < 2:
		return 0
	
	# Cap bonus calculation at MAX_COMBO_BONUS_COMBO_COUNT
	var effective_combo = mini(combo_count, MAX_COMBO_BONUS_COMBO_COUNT)
	
	# Bonus = Base * (1 + (Combo-1) * Multiplier)
	var bonus = int(COMBO_BONUS_BASE * (1.0 + (effective_combo - 1) * COMBO_BONUS_MULTIPLIER))
	
	return bonus

func register_drain() -> int:
	## Register ball drain - resets combo and returns final combo info
	var final_combo = combo_count
	var bonus_earned = total_combo_bonus_earned
	
	if is_combo_active:
		_reset_combo("drain", final_combo)
	
	return bonus_earned

func _reset_combo(reason: String, final_combo: int = 0) -> void:
	if is_combo_active:
		combo_reset.emit(reason, combo_count)
		
		if _get_debug_mode():
			print("[ComboSystem] Combo reset: %s (final: %d)" % [reason, combo_count])
	
	combo_count = 0
	is_combo_active = false
	combo_timer = 0.0
	last_hit_type = ""
	total_combo_bonus_earned = 0

func add_combo_score_to_game() -> int:
	## Add accumulated combo bonus to game score
	if total_combo_bonus_earned > 0:
		var gm = get_tree().get_first_node_in_group("game_manager")
		if gm and gm.has_method("add_score"):
			gm.add_score(total_combo_bonus_earned)
		
		var earned = total_combo_bonus_earned
		total_combo_bonus_earned = 0
		return earned
	return 0

func get_combo_display() -> String:
	## Get formatted combo string for UI
	if is_combo_active:
		return "Combo x%d" % combo_count
	return ""

func get_combo_multiplier() -> float:
	## Get current combo multiplier (for display purposes)
	if combo_count <= 1:
		return 1.0
	
	var effective_combo = mini(combo_count, MAX_COMBO_BONUS_COMBO_COUNT)
	return 1.0 + (effective_combo - 1) * COMBO_BONUS_MULTIPLIER

func get_max_combo() -> int:
	return max_combo_achieved

func get_combo_statistics() -> Dictionary:
	return {
		"max_combo": max_combo_achieved,
		"total_combos": combo_history.size(),
		"total_bonus_earned": _get_total_bonus_earned()
	}

func _get_total_bonus_earned() -> int:
	var total := 0
	for entry in combo_history:
		total += entry.get("bonus", 0)
	return total

func reset() -> void:
	## Reset all combo state
	_reset_combo("reset")
	max_combo_achieved = 0
	combo_history.clear()

# Static access for convenience
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("combo_system")
	return null

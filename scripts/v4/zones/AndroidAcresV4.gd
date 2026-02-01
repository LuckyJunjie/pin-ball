extends Node2D
## Android Acres zone v4.0 - Spaceship ramp, Android bumpers, Spaceship target
## Implements Flutter Pinball Android Acres behavior with ramp multiplier tracking

# Zone-specific signals
signal ramp_hit(points: int)
signal bumper_hit(points: int, bumper_id: String)
signal spaceship_target_hit(points: int)
signal bumper_bonus_activated(bonus_type: GameManagerV4.Bonus)

# Zone state
var ramp_hit_count: int = 0
var bumpers_lit: Dictionary = {
	"A": false,
	"B": false,
	"COW": false
}
var spaceship_target_active: bool = true
var all_bumpers_lit_bonus_activated: bool = false

# Configuration
const RAMP_HIT_POINTS: int = 5000
const BUMPER_BASE_POINTS: int = 20000
const SPACESHIP_BONUS_POINTS: int = 200000
const BUMPER_BONUS_POINTS: int = 50000

# References
@onready var spaceship_ramp: Area2D = $SpaceshipRamp
@onready var bumper_a: BumperV4 = $AndroidBumperA
@onready var bumper_b: BumperV4 = $AndroidBumperB
@onready var bumper_cow: BumperV4 = $AndroidBumperCow
@onready var spaceship_target: Area2D = $AndroidSpaceship


func _ready() -> void:
	add_to_group("zones")
	add_to_group("android_acres")
	
	# Configure bumpers
	_configure_bumpers()
	
	# Connect signals
	connect_ramp()
	connect_bumpers()
	connect_spaceship_target()
	
	# Initialize visual state
	_update_bumper_visuals()
	
	# Connect to game manager for round reset
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm and gm.has_signal("round_lost"):
		gm.round_lost.connect(_on_round_lost)


func _configure_bumpers() -> void:
	## Configure bumper properties
	if bumper_a:
		bumper_a.bumper_type = BumperV4.BumperType.ANDROID
		bumper_a.bumper_id = "A"
		bumper_a.base_points = BUMPER_BASE_POINTS
	
	if bumper_b:
		bumper_b.bumper_type = BumperV4.BumperType.ANDROID
		bumper_b.bumper_id = "B"
		bumper_b.base_points = BUMPER_BASE_POINTS
	
	if bumper_cow:
		bumper_cow.bumper_type = BumperV4.BumperType.ANDROID
		bumper_cow.bumper_id = "COW"
		bumper_cow.base_points = BUMPER_BASE_POINTS


func connect_ramp() -> void:
	if spaceship_ramp and spaceship_ramp.has_signal("body_entered"):
		spaceship_ramp.connect("body_entered", _on_ramp_hit)


func connect_bumpers() -> void:
	# Connect each bumper's hit signal
	for bumper in [bumper_a, bumper_b, bumper_cow]:
		if bumper and bumper.has_signal("bumper_hit"):
			bumper.connect("bumper_hit", _on_bumper_hit)
		if bumper and bumper.has_signal("bumper_lit_changed"):
			bumper.connect("bumper_lit_changed", _on_bumper_lit_changed.bind(bumper.bumper_id))


func connect_spaceship_target() -> void:
	if spaceship_target and spaceship_target.has_signal("body_entered"):
		spaceship_target.connect("body_entered", _on_spaceship_target_hit)


func _on_ramp_hit(body: Node) -> void:
	if body.is_in_group("balls"):
		ramp_hit_count += 1
		
		# Score points for ramp hit (5,000 points per Flutter)
		GameManagerV4.add_score(RAMP_HIT_POINTS)
		ramp_hit.emit(RAMP_HIT_POINTS)
		
		# Register ramp hit for multiplier tracking
		GameManagerV4.register_zone_ramp_hit("android_acres")
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("ramp_hit")
		
		# Visual feedback
		_show_ramp_hit_feedback()


func _on_bumper_hit(points: int, bumper_id: String) -> void:
	## Handle bumper hit from BumperV4 component
	# Update local bumper lit state
	if bumper_id in bumpers_lit:
		# Get the actual bumper to check its lit state
		var bumper = _get_bumper_by_id(bumper_id)
		if bumper:
			bumpers_lit[bumper_id] = bumper.is_lit
		
		# Score points (already calculated by BumperV4 with lit multiplier)
		GameManagerV4.add_score(points)
		bumper_hit.emit(points, bumper_id)
		
		# Check for all bumpers lit bonus (but only activate once per round)
		if _are_all_bumpers_lit() and not all_bumpers_lit_bonus_activated:
			_activate_bumper_bonus()


func _on_bumper_lit_changed(is_lit: bool, bumper_id: String) -> void:
	## Handle bumper lit state change
	if bumper_id in bumpers_lit:
		bumpers_lit[bumper_id] = is_lit
		_update_bumper_visual(bumper_id)


func _on_spaceship_target_hit(body: Node) -> void:
	if body.is_in_group("balls") and spaceship_target_active:
		spaceship_target_active = false
		
		# Large score bonus (200,000 points per Flutter)
		GameManagerV4.add_score(SPACESHIP_BONUS_POINTS)
		spaceship_target_hit.emit(SPACESHIP_BONUS_POINTS)
		
		# Activate Android Spaceship bonus
		GameManagerV4.add_bonus(GameManagerV4.Bonus.ANDROID_SPACESHIP)
		
		# Visual feedback
		_show_spaceship_activation()
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("bonus_activation")
		
		# Reactivate after delay (10 seconds per Flutter)
		await get_tree().create_timer(10.0).timeout
		spaceship_target_active = true
		_reset_spaceship_visual()


func _get_bumper_by_id(bumper_id: String) -> BumperV4:
	## Get bumper reference by ID
	match bumper_id:
		"A": return bumper_a
		"B": return bumper_b
		"COW": return bumper_cow
	return null


func _are_all_bumpers_lit() -> bool:
	for lit in bumpers_lit.values():
		if not lit:
			return false
	return true


func _activate_bumper_bonus() -> void:
	## Activate bonus for lighting all bumpers (once per round)
	if all_bumpers_lit_bonus_activated:
		return
	
	all_bumpers_lit_bonus_activated = true
	
	# Bonus points for lighting all bumpers
	GameManagerV4.add_score(BUMPER_BONUS_POINTS)
	bumper_bonus_activated.emit(GameManagerV4.Bonus.ANDROID_SPACESHIP)
	
	# Visual feedback
	_show_bumper_bonus_feedback()
	
	# Play bonus sound
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		sm.play_sound("bonus_activation")
	
	# Reset bumpers after delay (3 seconds)
	await get_tree().create_timer(3.0).timeout
	_reset_bumpers()


func _reset_bumpers() -> void:
	## Reset all bumpers to unlit state
	for bumper in [bumper_a, bumper_b, bumper_cow]:
		if bumper:
			bumper.set_lit(false)
			bumper.reset_bumper()
	
	# Reset local state
	for bumper_id in bumpers_lit:
		bumpers_lit[bumper_id] = false


func _update_bumper_visuals() -> void:
	for bumper_id in bumpers_lit:
		_update_bumper_visual(bumper_id)


func _update_bumper_visual(bumper_id: String) -> void:
	var bumper = _get_bumper_by_id(bumper_id)
	if bumper:
		bumper.set_lit(bumpers_lit[bumper_id])


func _show_ramp_hit_feedback() -> void:
	# Simple visual feedback for ramp hit
	if spaceship_ramp and spaceship_ramp.has_method("flash"):
		spaceship_ramp.flash()
	
	# Could add particles or animation here


func _show_spaceship_activation() -> void:
	# Visual feedback for spaceship activation
	if spaceship_target and spaceship_target.has_method("activate"):
		spaceship_target.activate()
	
	# Could add particles, animation, or sound here


func _reset_spaceship_visual() -> void:
	if spaceship_target and spaceship_target.has_method("deactivate"):
		spaceship_target.deactivate()


func _show_bumper_bonus_feedback() -> void:
	# Visual feedback for bumper bonus
	for bumper in [bumper_a, bumper_b, bumper_cow]:
		if bumper and bumper.has_method("bonus_flash"):
			bumper.bonus_flash()
	
	# Could add particles or screen shake here


func _on_round_lost() -> void:
	## Reset zone when round is lost
	reset_zone()


func reset_zone() -> void:
	## Reset zone state for new round/game
	ramp_hit_count = 0
	all_bumpers_lit_bonus_activated = false
	spaceship_target_active = true
	
	# Reset bumpers
	_reset_bumpers()
	
	# Reset spaceship visual
	_reset_spaceship_visual()
	
	# Reset any other zone-specific state
	print("Android Acres zone reset for new round")


func get_zone_info() -> Dictionary:
	## Return zone information for debugging
	return {
		"zone": "android_acres",
		"ramp_hit_count": ramp_hit_count,
		"bumpers_lit": bumpers_lit,
		"spaceship_active": spaceship_target_active,
		"bonus_activated": all_bumpers_lit_bonus_activated
	}
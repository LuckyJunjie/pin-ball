extends Node2D
## Android Acres zone v4.0 - Spaceship ramp, Android bumpers, Spaceship target

# Zone-specific signals
signal ramp_hit(points: int)
signal bumper_hit(points: int, bumper_id: String)
signal spaceship_target_hit(points: int)

# Zone state
var ramp_hit_count: int = 0
var bumpers_lit: Dictionary = {
	"A": false,
	"B": false,
	"COW": false
}
var spaceship_target_active: bool = true

# References
@onready var spaceship_ramp: Area2D = $SpaceshipRamp
@onready var bumper_a: RigidBody2D = $AndroidBumperA
@onready var bumper_b: RigidBody2D = $AndroidBumperB
@onready var bumper_cow: RigidBody2D = $AndroidBumperCow
@onready var spaceship_target: Area2D = $AndroidSpaceship


func _ready() -> void:
	add_to_group("zones")
	add_to_group("android_acres")
	
	# Connect signals
	connect_ramp()
	connect_bumpers()
	connect_spaceship_target()
	
	# Initialize visual state
	_update_bumper_visuals()


func connect_ramp() -> void:
	if spaceship_ramp and spaceship_ramp.has_signal("body_entered"):
		spaceship_ramp.connect("body_entered", _on_ramp_hit)


func connect_bumpers() -> void:
	# Connect each bumper's hit signal
	for bumper in [bumper_a, bumper_b, bumper_cow]:
		if bumper and bumper.has_signal("bumper_hit"):
			bumper.connect("bumper_hit", _on_bumper_hit.bind(bumper.name))


func connect_spaceship_target() -> void:
	if spaceship_target and spaceship_target.has_signal("body_entered"):
		spaceship_target.connect("body_entered", _on_spaceship_target_hit)


func _on_ramp_hit(body: Node) -> void:
	if body.is_in_group("balls"):
		ramp_hit_count += 1
		
		# Score points for ramp hit
		var points = 5000
		GameManagerV4.add_score(points)
		ramp_hit.emit(points)
		
		# Register ramp hit for multiplier tracking
		GameManagerV4.register_zone_ramp_hit("android_acres")
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("ramp_hit")
		
		# Visual feedback
		_show_ramp_hit_feedback()


func _on_bumper_hit(points: int, bumper_id: String) -> void:
	if bumper_id in bumpers_lit:
		# Toggle bumper lit state
		bumpers_lit[bumper_id] = not bumpers_lit[bumper_id]
		
		# Score points (more if lit)
		var actual_points = points * 2 if bumpers_lit[bumper_id] else points
		GameManagerV4.add_score(actual_points)
		bumper_hit.emit(actual_points, bumper_id)
		
		# Update visual
		_update_bumper_visual(bumper_id)
		
		# Check for all bumpers lit bonus
		if _are_all_bumpers_lit():
			_activate_bumper_bonus()
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("bumper_hit")


func _on_spaceship_target_hit(body: Node) -> void:
	if body.is_in_group("balls") and spaceship_target_active:
		spaceship_target_active = false
		
		# Large score bonus
		var points = 200000
		GameManagerV4.add_score(points)
		spaceship_target_hit.emit(points)
		
		# Activate Android Spaceship bonus
		GameManagerV4.add_bonus(GameManagerV4.Bonus.ANDROID_SPACESHIP)
		
		# Visual feedback
		_show_spaceship_activation()
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("bonus_activation")
		
		# Reactivate after delay
		await get_tree().create_timer(10.0).timeout
		spaceship_target_active = true
		_reset_spaceship_visual()


func _are_all_bumpers_lit() -> bool:
	for lit in bumpers_lit.values():
		if not lit:
			return false
	return true


func _activate_bumper_bonus() -> void:
	# Bonus for lighting all bumpers
	var points = 50000
	GameManagerV4.add_score(points)
	
	# Visual feedback
	_show_bumper_bonus_feedback()
	
	# Reset bumpers after bonus
	await get_tree().create_timer(3.0).timeout
	for bumper_id in bumpers_lit:
		bumpers_lit[bumper_id] = false
	_update_bumper_visuals()


func _update_bumper_visuals() -> void:
	for bumper_id in bumpers_lit:
		_update_bumper_visual(bumper_id)


func _update_bumper_visual(bumper_id: String) -> void:
	var bumper_node = null
	match bumper_id:
		"A": bumper_node = bumper_a
		"B": bumper_node = bumper_b
		"COW": bumper_node = bumper_cow
	
	if bumper_node and bumper_node.has_method("set_lit"):
		bumper_node.set_lit(bumpers_lit[bumper_id])


func _show_ramp_hit_feedback() -> void:
	# Simple visual feedback for ramp hit
	if spaceship_ramp and spaceship_ramp.has_method("flash"):
		spaceship_ramp.flash()


func _show_spaceship_activation() -> void:
	# Visual feedback for spaceship activation
	if spaceship_target and spaceship_target.has_method("activate"):
		spaceship_target.activate()


func _reset_spaceship_visual() -> void:
	if spaceship_target and spaceship_target.has_method("deactivate"):
		spaceship_target.deactivate()


func _show_bumper_bonus_feedback() -> void:
	# Visual feedback for bumper bonus
	for bumper in [bumper_a, bumper_b, bumper_cow]:
		if bumper and bumper.has_method("bonus_flash"):
			bumper.bonus_flash()


func reset_zone() -> void:
	## Reset zone state for new round/game
	ramp_hit_count = 0
	for bumper_id in bumpers_lit:
		bumpers_lit[bumper_id] = false
	spaceship_target_active = true
	
	_update_bumper_visuals()
	_reset_spaceship_visual()
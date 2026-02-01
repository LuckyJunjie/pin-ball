extends Node2D
## Sparky Scorch zone v4.0 - Sparky bumpers, computer target, Sparky animatronic

# Zone-specific signals
signal sparky_bumper_hit(points: int, bumper_id: String)
signal computer_target_hit(points: int)
signal turbo_charge_activated()

# Zone state
var sparky_bumpers_lit: Dictionary = {
	"1": false,
	"2": false,
	"3": false
}
var computer_target_active: bool = true
var turbo_charge_progress: int = 0
const TURBO_CHARGE_REQUIRED: int = 5  # Need 5 bumper hits to activate turbo charge

# References
@onready var sparky_bumper_1: RigidBody2D = $SparkyBumper1
@onready var sparky_bumper_2: RigidBody2D = $SparkyBumper2
@onready var sparky_bumper_3: RigidBody2D = $SparkyBumper3
@onready var computer_target: Area2D = $SparkyComputer
@onready var sparky_animatronic: Node2D = $SparkyAnimatronic


func _ready() -> void:
	add_to_group("zones")
	add_to_group("sparky_scorch")
	
	# Connect signals
	connect_sparky_bumpers()
	connect_computer_target()
	
	# Initialize visual state
	_update_bumper_visuals()
	_update_sparky_animatronic()


func connect_sparky_bumpers() -> void:
	# Connect each bumper's hit signal
	var bumpers = {
		"1": sparky_bumper_1,
		"2": sparky_bumper_2,
		"3": sparky_bumper_3
	}
	
	for bumper_id in bumpers:
		var bumper = bumpers[bumper_id]
		if bumper and bumper.has_signal("bumper_hit"):
			bumper.connect("bumper_hit", _on_sparky_bumper_hit.bind(bumper_id))


func connect_computer_target() -> void:
	if computer_target and computer_target.has_signal("body_entered"):
		computer_target.connect("body_entered", _on_computer_target_hit)


func _on_sparky_bumper_hit(points: int, bumper_id: String) -> void:
	if bumper_id in sparky_bumpers_lit:
		# Toggle bumper lit state
		sparky_bumpers_lit[bumper_id] = not sparky_bumpers_lit[bumper_id]
		turbo_charge_progress += 1
		
		# Score points (more if lit)
		var actual_points = points * 2 if sparky_bumpers_lit[bumper_id] else points
		GameManagerV4.add_score(actual_points)
		sparky_bumper_hit.emit(actual_points, bumper_id)
		
		# Update visual
		_update_bumper_visual(bumper_id)
		
		# Check for turbo charge activation
		if turbo_charge_progress >= TURBO_CHARGE_REQUIRED:
			_activate_turbo_charge()
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("bumper_hit")


func _on_computer_target_hit(body: Node) -> void:
	if body.is_in_group("balls") and computer_target_active:
		computer_target_active = false
		
		# Large score bonus
		var points = 200000
		GameManagerV4.add_score(points)
		computer_target_hit.emit(points)
		
		# Register as ramp hit for multiplier
		GameManagerV4.register_zone_ramp_hit("sparky_scorch")
		
		# Visual feedback
		_show_computer_activation()
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("computer_hit")
		
		# Reactivate after delay
		await get_tree().create_timer(10.0).timeout
		computer_target_active = true
		_reset_computer_visual()


func _activate_turbo_charge() -> void:
	# Turbo charge activated - activate Sparky Turbo Charge bonus
	GameManagerV4.add_bonus(GameManagerV4.Bonus.SPARKY_TURBO_CHARGE)
	turbo_charge_activated.emit()
	
	# Large score bonus
	var points = 100000
	GameManagerV4.add_score(points)
	
	# Visual feedback
	_show_turbo_charge_activation()
	
	# Play sound
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		sm.play_sound("turbo_charge")
	
	# Reset turbo charge progress after delay
	await get_tree().create_timer(5.0).timeout
	_reset_turbo_charge()


func _show_computer_activation() -> void:
	# Visual feedback for computer target hit
	if computer_target and computer_target.has_method("activate"):
		computer_target.activate()


func _reset_computer_visual() -> void:
	if computer_target and computer_target.has_method("deactivate"):
		computer_target.deactivate()


func _show_turbo_charge_activation() -> void:
	# Visual feedback for turbo charge activation
	if sparky_animatronic and sparky_animatronic.has_method("turbo_charge"):
		sparky_animatronic.turbo_charge()
	
	# Flash all bumpers
	for bumper in [sparky_bumper_1, sparky_bumper_2, sparky_bumper_3]:
		if bumper and bumper.has_method("bonus_flash"):
			bumper.bonus_flash()


func _reset_turbo_charge() -> void:
	# Reset turbo charge progress
	turbo_charge_progress = 0
	
	# Update animatronic
	_update_sparky_animatronic()


func _update_bumper_visuals() -> void:
	for bumper_id in sparky_bumpers_lit:
		_update_bumper_visual(bumper_id)


func _update_bumper_visual(bumper_id: String) -> void:
	var bumper_node = null
	match bumper_id:
		"1": bumper_node = sparky_bumper_1
		"2": bumper_node = sparky_bumper_2
		"3": bumper_node = sparky_bumper_3
	
	if bumper_node and bumper_node.has_method("set_lit"):
		bumper_node.set_lit(sparky_bumpers_lit[bumper_id])


func _update_sparky_animatronic() -> void:
	if sparky_animatronic and sparky_animatronic.has_method("set_charge_level"):
		var charge_level = min(turbo_charge_progress, TURBO_CHARGE_REQUIRED)
		sparky_animatronic.set_charge_level(charge_level)


func reset_zone() -> void:
	## Reset zone state for new round/game
	for bumper_id in sparky_bumpers_lit:
		sparky_bumpers_lit[bumper_id] = false
	computer_target_active = true
	turbo_charge_progress = 0
	
	_update_bumper_visuals()
	_reset_computer_visual()
	_update_sparky_animatronic()
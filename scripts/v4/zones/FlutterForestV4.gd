extends Node2D
## Flutter Forest zone v4.0 - Signpost target, Dash bumpers, Dash animatronic

# Zone-specific signals
signal signpost_hit(points: int)
signal dash_bumper_hit(points: int, bumper_id: String)
signal dash_nest_completed()

# Zone state
var signpost_active: bool = true
var dash_bumpers_lit: Dictionary = {
	"main": false,
	"A": false,
	"B": false
}
var dash_nest_progress: int = 0
const DASH_NEST_REQUIRED: int = 3  # Need to hit all 3 bumpers to complete nest

# References
@onready var signpost: Area2D = $Signpost
@onready var dash_bumper_main: RigidBody2D = $DashBumperMain
@onready var dash_bumper_a: RigidBody2D = $DashBumperA
@onready var dash_bumper_b: RigidBody2D = $DashBumperB
@onready var dash_animatronic: Node2D = $DashAnimatronic


func _ready() -> void:
	add_to_group("zones")
	add_to_group("flutter_forest")
	
	# Connect signals
	connect_signpost()
	connect_dash_bumpers()
	
	# Initialize visual state
	_update_bumper_visuals()
	_update_dash_animatronic()


func connect_signpost() -> void:
	if signpost and signpost.has_signal("body_entered"):
		signpost.connect("body_entered", _on_signpost_hit)


func connect_dash_bumpers() -> void:
	# Connect each bumper's hit signal
	var bumpers = {
		"main": dash_bumper_main,
		"A": dash_bumper_a,
		"B": dash_bumper_b
	}
	
	for bumper_id in bumpers:
		var bumper = bumpers[bumper_id]
		if bumper and bumper.has_signal("bumper_hit"):
			bumper.connect("bumper_hit", _on_dash_bumper_hit.bind(bumper_id))


func _on_signpost_hit(body: Node) -> void:
	if body.is_in_group("balls") and signpost_active:
		signpost_active = false
		
		# Score points for signpost hit
		var points = 5000
		GameManagerV4.add_score(points)
		signpost_hit.emit(points)
		
		# Register as ramp hit for multiplier
		GameManagerV4.register_zone_ramp_hit("flutter_forest")
		
		# Visual feedback
		_show_signpost_activation()
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("signpost_hit")
		
		# Reactivate after delay
		await get_tree().create_timer(5.0).timeout
		signpost_active = true
		_reset_signpost_visual()


func _on_dash_bumper_hit(points: int, bumper_id: String) -> void:
	if bumper_id in dash_bumpers_lit:
		# Light up the bumper if not already lit
		if not dash_bumpers_lit[bumper_id]:
			dash_bumpers_lit[bumper_id] = true
			dash_nest_progress += 1
			
			# Score points (more for main bumper)
			var actual_points = points * 2 if bumper_id == "main" else points
			GameManagerV4.add_score(actual_points)
			dash_bumper_hit.emit(actual_points, bumper_id)
			
			# Update visual
			_update_bumper_visual(bumper_id)
			
			# Check for dash nest completion
			if dash_nest_progress >= DASH_NEST_REQUIRED:
				_on_dash_nest_completed()
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("bumper_hit")


func _on_dash_nest_completed() -> void:
	# Dash nest completed - activate Dash Nest bonus
	GameManagerV4.add_bonus(GameManagerV4.Bonus.DASH_NEST)
	dash_nest_completed.emit()
	
	# Large score bonus
	var points = 150000
	GameManagerV4.add_score(points)
	
	# Visual feedback
	_show_dash_nest_completion()
	
	# Play sound
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		sm.play_sound("nest_completed")
	
	# Reset nest after delay
	await get_tree().create_timer(5.0).timeout
	_reset_dash_nest()


func _show_signpost_activation() -> void:
	# Visual feedback for signpost hit
	if signpost and signpost.has_method("activate"):
		signpost.activate()


func _reset_signpost_visual() -> void:
	if signpost and signpost.has_method("deactivate"):
		signpost.deactivate()


func _show_dash_nest_completion() -> void:
	# Visual feedback for dash nest completion
	if dash_animatronic and dash_animatronic.has_method("celebrate"):
		dash_animatronic.celebrate()
	
	# Flash all bumpers
	for bumper in [dash_bumper_main, dash_bumper_a, dash_bumper_b]:
		if bumper and bumper.has_method("bonus_flash"):
			bumper.bonus_flash()


func _reset_dash_nest() -> void:
	# Reset dash nest progress
	for bumper_id in dash_bumpers_lit:
		dash_bumpers_lit[bumper_id] = false
	dash_nest_progress = 0
	
	_update_bumper_visuals()
	
	# Reset animatronic
	if dash_animatronic and dash_animatronic.has_method("reset"):
		dash_animatronic.reset()


func _update_bumper_visuals() -> void:
	for bumper_id in dash_bumpers_lit:
		_update_bumper_visual(bumper_id)


func _update_bumper_visual(bumper_id: String) -> void:
	var bumper_node = null
	match bumper_id:
		"main": bumper_node = dash_bumper_main
		"A": bumper_node = dash_bumper_a
		"B": bumper_node = dash_bumper_b
	
	if bumper_node and bumper_node.has_method("set_lit"):
		bumper_node.set_lit(dash_bumpers_lit[bumper_id])


func _update_dash_animatronic() -> void:
	if dash_animatronic and dash_animatronic.has_method("set_progress"):
		dash_animatronic.set_progress(dash_nest_progress)


func reset_zone() -> void:
	## Reset zone state for new round/game
	signpost_active = true
	for bumper_id in dash_bumpers_lit:
		dash_bumpers_lit[bumper_id] = false
	dash_nest_progress = 0
	
	_update_bumper_visuals()
	_reset_signpost_visual()
	
	if dash_animatronic and dash_animatronic.has_method("reset"):
		dash_animatronic.reset()
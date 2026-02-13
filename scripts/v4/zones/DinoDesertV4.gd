extends Node2D
## Dino Desert zone v4.0 - Chrome Dino mouth target, Dino walls, slingshots

# Zone-specific signals
signal dino_mouth_hit(points: int)
signal slingshot_hit(points: int, side: String)
signal wall_collision(points: int)

# Zone state
var dino_mouth_active: bool = true
var slingshot_left_hits: int = 0
var slingshot_right_hits: int = 0
var wall_hit_count: int = 0

# References
@onready var dino_mouth: Area2D = $ChromeDinoMouth
@onready var slingshot_left: Area2D = $SlingshotLeft
@onready var slingshot_right: Area2D = $SlingshotRight
@onready var dino_walls: Array[StaticBody2D] = []


func _ready() -> void:
	add_to_group("zones")
	add_to_group("dino_desert")
	
	# Collect dino walls
	for child in get_children():
		if child is StaticBody2D and "DinoWall" in child.name:
			dino_walls.append(child)
	
	# Connect signals
	connect_dino_mouth()
	connect_slingshots()
	connect_walls()
	
	# Initialize visual state
	_update_dino_mouth_visual()


func connect_dino_mouth() -> void:
	if dino_mouth and dino_mouth.has_signal("body_entered"):
		dino_mouth.connect("body_entered", _on_dino_mouth_hit)


func connect_slingshots() -> void:
	if slingshot_left and slingshot_left.has_signal("body_entered"):
		slingshot_left.connect("body_entered", _on_slingshot_hit.bind("left"))
	
	if slingshot_right and slingshot_right.has_signal("body_entered"):
		slingshot_right.connect("body_entered", _on_slingshot_hit.bind("right"))


func connect_walls() -> void:
	for wall in dino_walls:
		if wall and wall.has_signal("body_entered"):
			wall.connect("body_entered", _on_wall_collision)


func _on_dino_mouth_hit(body: Node) -> void:
	if body.is_in_group("balls") and dino_mouth_active:
		dino_mouth_active = false
		
		# Large score bonus
		var points = 200000
		GameManagerV4.add_score(points)
		dino_mouth_hit.emit(points)
		
		# Activate Dino Chomp bonus
		GameManagerV4.add_bonus(GameManagerV4.Bonus.DINO_CHOMP)
		
		# Trigger screen shake
		_trigger_screen_shake("extreme")
		
		# Spawn particles
		_spawn_particles()
		
		# Visual feedback
		_show_dino_chomp_activation()
		
		# Play sound
		_play_sound("chomp")
		
		# Reactivate after delay
		await get_tree().create_timer(15.0).timeout
		dino_mouth_active = true
		_reset_dino_mouth_visual()


func _on_slingshot_hit(body: Node, side: String) -> void:
	if body.is_in_group("balls"):
		# Score points for slingshot hit
		var points = 10000
		GameManagerV4.add_score(points)
		slingshot_hit.emit(points, side)
		
		# Track hits
		if side == "left":
			slingshot_left_hits += 1
		else:
			slingshot_right_hits += 1
		
		# Apply impulse to ball (slingshot effect)
		if body is RigidBody2D:
			var impulse = Vector2(300, -150) if side == "left" else Vector2(-300, -150)
			body.apply_impulse(impulse)
		
		# Visual feedback
		_show_slingshot_feedback(side)
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("slingshot_hit")
		
		# Check for alternating slingshot bonus
		_check_slingshot_bonus()


func _on_wall_collision(body: Node) -> void:
	if body.is_in_group("balls"):
		wall_hit_count += 1
		
		# Score points for wall hit
		var points = 500
		GameManagerV4.add_score(points)
		wall_collision.emit(points)
		
		# Register as ramp hit for multiplier (walls count as ramp hits in Dino Desert)
		GameManagerV4.register_zone_ramp_hit("dino_desert")
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("wall_hit")


func _check_slingshot_bonus() -> void:
	# Bonus for hitting both slingshots in quick succession
	if slingshot_left_hits > 0 and slingshot_right_hits > 0:
		# Check if last two hits were alternating
		var total_hits = slingshot_left_hits + slingshot_right_hits
		if total_hits % 2 == 0:  # Even number of total hits
			# Award bonus
			var points = 25000
			GameManagerV4.add_score(points)
			
			# Visual feedback
			_show_slingshot_bonus()
			
			# Reset counts
			slingshot_left_hits = 0
			slingshot_right_hits = 0


func _show_dino_chomp_activation() -> void:
	# Visual feedback for dino chomp activation
	if dino_mouth and dino_mouth.has_method("chomp"):
		dino_mouth.chomp()


func _reset_dino_mouth_visual() -> void:
	if dino_mouth and dino_mouth.has_method("reset"):
		dino_mouth.reset()


func _show_slingshot_feedback(side: String) -> void:
	var slingshot = slingshot_left if side == "left" else slingshot_right
	if slingshot and slingshot.has_method("flash"):
		slingshot.flash()


func _show_slingshot_bonus() -> void:
	# Visual feedback for slingshot bonus
	if slingshot_left and slingshot_left.has_method("bonus_flash"):
		slingshot_left.bonus_flash()
	if slingshot_right and slingshot_right.has_method("bonus_flash"):
		slingshot_right.bonus_flash()
	
	# Trigger screen shake
	_trigger_screen_shake("heavy")

func _trigger_screen_shake(type: String = "medium") -> void:
	var screen_shake = get_tree().get_first_node_in_group("screen_shake")
	if screen_shake:
		match type:
			"light":
				screen_shake.shake_light()
			"medium":
				screen_shake.shake_medium()
			"heavy":
				screen_shake.shake_heavy()
			"extreme":
				screen_shake.shake_extreme()

func _spawn_particles() -> void:
	var particles = get_tree().get_first_node_in_group("particle_system")
	if particles and particles.has_method("spawn_bonus_effect"):
		if dino_mouth:
			particles.spawn_bonus_effect(dino_mouth.global_position)

func _play_sound(sound_name: String) -> void:
	var audio = get_tree().get_first_node_in_group("sound_manager")
	if audio and audio.has_method("play_sound"):
		audio.play_sound(sound_name)

func _register_combo(hit_type: String, points: int) -> void:
	var combo = get_tree().get_first_node_in_group("combo_system")
	if combo and combo.has_method("register_hit"):
		combo.register_hit(hit_type, points)


func _update_dino_mouth_visual() -> void:
	if dino_mouth and dino_mouth.has_method("set_active"):
		dino_mouth.set_active(dino_mouth_active)


func reset_zone() -> void:
	## Reset zone state for new round/game
	dino_mouth_active = true
	slingshot_left_hits = 0
	slingshot_right_hits = 0
	wall_hit_count = 0
	
	_update_dino_mouth_visual()
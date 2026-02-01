extends Node2D
## Google Gallery zone v4.0 - Google word with 6 letters, left/right rollovers

# Zone-specific signals
signal letter_lit(letter: String, index: int)
signal word_completed()
signal rollover_hit(side: String, points: int)

# Zone state
var letters_lit: Array[bool] = [false, false, false, false, false, false]  # G O O G L E
var word_letters: Array[String] = ["G", "O", "O", "G", "L", "E"]
var rollover_left_active: bool = true
var rollover_right_active: bool = true
var rollover_hit_count: int = 0

# References
@onready var letter_nodes: Array[Area2D] = []
@onready var rollover_left: Area2D = $RolloverLeft
@onready var rollover_right: Area2D = $RolloverRight


func _ready() -> void:
	add_to_group("zones")
	add_to_group("google_gallery")
	
	# Collect letter nodes
	for i in range(1, 7):  # Letter1 through Letter6
		var node = get_node_or_null("Letter%d" % i)
		if node:
			letter_nodes.append(node)
	
	# Ensure we have 6 letters
	if letter_nodes.size() != 6:
		push_warning("GoogleGalleryV4: Expected 6 letter nodes, found %d" % letter_nodes.size())
	
	# Connect signals
	connect_letters()
	connect_rollovers()
	
	# Initialize visual state
	_update_letter_visuals()
	_update_rollover_visuals()


func connect_letters() -> void:
	for i in range(letter_nodes.size()):
		var letter_node = letter_nodes[i]
		if letter_node and letter_node.has_signal("body_entered"):
			letter_node.connect("body_entered", _on_letter_hit.bind(i))


func connect_rollovers() -> void:
	if rollover_left and rollover_left.has_signal("body_entered"):
		rollover_left.connect("body_entered", _on_rollover_hit.bind("left"))
	
	if rollover_right and rollover_right.has_signal("body_entered"):
		rollover_right.connect("body_entered", _on_rollover_hit.bind("right"))


func _on_letter_hit(body: Node, index: int) -> void:
	if body.is_in_group("balls") and index < letters_lit.size() and not letters_lit[index]:
		# Light up the letter
		letters_lit[index] = true
		
		# Score points for letter hit
		var points = 5000
		GameManagerV4.add_score(points)
		letter_lit.emit(word_letters[index], index)
		
		# Visual feedback
		_show_letter_activation(index)
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("letter_hit")
		
		# Check for word completion
		if _is_word_complete():
			_on_word_completed()


func _on_rollover_hit(body: Node, side: String) -> void:
	if body.is_in_group("balls"):
		rollover_hit_count += 1
		
		# Score points for rollover hit
		var points = 5000
		GameManagerV4.add_score(points)
		rollover_hit.emit(side, points)
		
		# Register as ramp hit for multiplier
		GameManagerV4.register_zone_ramp_hit("google_gallery")
		
		# Visual feedback
		_show_rollover_feedback(side)
		
		# Play sound
		var sm = get_tree().get_first_node_in_group("sound_manager")
		if sm and sm.has_method("play_sound"):
			sm.play_sound("rollover_hit")
		
		# Check for rollover bonus
		if rollover_hit_count % 10 == 0:  # Every 10 rollover hits
			_activate_rollover_bonus()


func _is_word_complete() -> bool:
	for lit in letters_lit:
		if not lit:
			return false
	return true


func _on_word_completed() -> void:
	# Word completed - activate Google Word bonus
	GameManagerV4.add_bonus(GameManagerV4.Bonus.GOOGLE_WORD)
	word_completed.emit()
	
	# Large score bonus
	var points = 100000
	GameManagerV4.add_score(points)
	
	# Visual feedback
	_show_word_completion_effect()
	
	# Play sound
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		sm.play_sound("word_completed")
	
	# Reset word after delay
	await get_tree().create_timer(3.0).timeout
	_reset_word()


func _reset_word() -> void:
	for i in range(letters_lit.size()):
		letters_lit[i] = false
	_update_letter_visuals()


func _activate_rollover_bonus() -> void:
	# Bonus for hitting many rollovers
	var points = 25000
	GameManagerV4.add_score(points)
	
	# Visual feedback
	_show_rollover_bonus()
	
	# Play sound
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		sm.play_sound("bonus_activation")


func _show_letter_activation(index: int) -> void:
	if index < letter_nodes.size():
		var letter_node = letter_nodes[index]
		if letter_node and letter_node.has_method("activate"):
			letter_node.activate()


func _show_rollover_feedback(side: String) -> void:
	var rollover = rollover_left if side == "left" else rollover_right
	if rollover and rollover.has_method("flash"):
		rollover.flash()


func _show_word_completion_effect() -> void:
	# Visual feedback for word completion
	for letter_node in letter_nodes:
		if letter_node and letter_node.has_method("celebrate"):
			letter_node.celebrate()


func _show_rollover_bonus() -> void:
	# Visual feedback for rollover bonus
	if rollover_left and rollover_left.has_method("bonus_flash"):
		rollover_left.bonus_flash()
	if rollover_right and rollover_right.has_method("bonus_flash"):
		rollover_right.bonus_flash()


func _update_letter_visuals() -> void:
	for i in range(letter_nodes.size()):
		if i < letter_nodes.size():
			var letter_node = letter_nodes[i]
			if letter_node and letter_node.has_method("set_lit"):
				letter_node.set_lit(letters_lit[i])


func _update_rollover_visuals() -> void:
	if rollover_left and rollover_left.has_method("set_active"):
		rollover_left.set_active(rollover_left_active)
	if rollover_right and rollover_right.has_method("set_active"):
		rollover_right.set_active(rollover_right_active)


func reset_zone() -> void:
	## Reset zone state for new round/game
	for i in range(letters_lit.size()):
		letters_lit[i] = false
	rollover_hit_count = 0
	
	_update_letter_visuals()
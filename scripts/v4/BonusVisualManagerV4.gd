extends Node2D
## v4.0 Bonus visual feedback system. Listens to GameManagerV4 bonus signals and shows visual effects.

# References
@onready var bonus_particles: CPUParticles2D = $BonusParticles
@onready var bonus_label: Label = $BonusLabel
@onready var bonus_animation_player: AnimationPlayer = $BonusAnimationPlayer

# Bonus visual configurations
var bonus_colors: Dictionary = {
	GameManagerV4.Bonus.GOOGLE_WORD: Color("4285F4"),  # Google blue
	GameManagerV4.Bonus.DASH_NEST: Color("EA4335"),    # Google red
	GameManagerV4.Bonus.SPARKY_TURBO_CHARGE: Color("FBBC05"),  # Google yellow
	GameManagerV4.Bonus.DINO_CHOMP: Color("34A853"),   # Google green
	GameManagerV4.Bonus.ANDROID_SPACESHIP: Color("3DDC84")     # Android green
}

var bonus_texts: Dictionary = {
	GameManagerV4.Bonus.GOOGLE_WORD: "GOOGLE WORD!",
	GameManagerV4.Bonus.DASH_NEST: "DASH NEST!",
	GameManagerV4.Bonus.SPARKY_TURBO_CHARGE: "TURBO CHARGE!",
	GameManagerV4.Bonus.DINO_CHOMP: "DINO CHOMP!",
	GameManagerV4.Bonus.ANDROID_SPACESHIP: "SPACESHIP!"
}

var bonus_scores: Dictionary = {
	GameManagerV4.Bonus.GOOGLE_WORD: 100000,
	GameManagerV4.Bonus.DASH_NEST: 150000,
	GameManagerV4.Bonus.SPARKY_TURBO_CHARGE: 100000,
	GameManagerV4.Bonus.DINO_CHOMP: 150000,
	GameManagerV4.Bonus.ANDROID_SPACESHIP: 200000
}


func _ready() -> void:
	# Connect to GameManagerV4 signals
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm and gm.has_signal("bonus_activated"):
		gm.bonus_activated.connect(_on_bonus_activated)
	
	# Hide initially
	bonus_label.visible = false
	if bonus_particles:
		bonus_particles.emitting = false


func _on_bonus_activated(bonus: GameManagerV4.Bonus) -> void:
	# Show visual feedback for bonus activation
	_show_bonus_effect(bonus)
	
	# Play sound
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		sm.play_sound("bonus_activated")


func _show_bonus_effect(bonus: GameManagerV4.Bonus) -> void:
	# Set bonus text and color
	if bonus in bonus_texts:
		bonus_label.text = bonus_texts[bonus]
		
		if bonus in bonus_colors:
			bonus_label.modulate = bonus_colors[bonus]
	
	# Position label at center of screen
	var viewport = get_viewport().get_visible_rect().size
	bonus_label.position = Vector2(viewport.x / 2, viewport.y / 2 - 50)
	
	# Show and animate
	bonus_label.visible = true
	
	if bonus_animation_player and bonus_animation_player.has_animation("bonus_popup"):
		bonus_animation_player.play("bonus_popup")
	
	# Show particles
	if bonus_particles:
		if bonus in bonus_colors:
			bonus_particles.color = bonus_colors[bonus]
		bonus_particles.emitting = true
		bonus_particles.restart()
	
	# Hide after animation
	await get_tree().create_timer(2.0).timeout
	bonus_label.visible = false


func show_score_popup(position: Vector2, points: int) -> void:
	## Show a score popup at the given position
	var popup_label = Label.new()
	popup_label.text = "+%s" % _format_score(points)
	popup_label.modulate = Color(1, 1, 0.5, 1)
	popup_label.add_theme_font_size_override("font_size", 24)
	
	add_child(popup_label)
	popup_label.global_position = position
	
	# Animate
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(popup_label, "position:y", position.y - 50, 0.5)
	tween.tween_property(popup_label, "modulate:a", 0.0, 0.5)
	
	await tween.finished
	popup_label.queue_free()


func _format_score(points: int) -> String:
	if points >= 1000000:
		return "%dM" % (points / 1000000)
	elif points >= 1000:
		return "%dK" % (points / 1000)
	else:
		return str(points)
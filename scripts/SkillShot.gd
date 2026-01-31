extends Area2D

## v3.0: Skill Shot System
## Launch ball through specific target zones for bonus points

signal skill_shot_hit(points: int)

@export var skill_shot_points: int = 200  # Points awarded for hitting this skill shot
@export var time_window: float = 2.5  # Time window in seconds after launch
@export var difficulty_level: int = 1  # 1=easy, 2=medium, 3=hard (affects points)

var is_active: bool = false
var activation_timer: float = 0.0
var has_been_hit: bool = false

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	# Add to skill_shots group for easy access
	add_to_group("skill_shots")
	
	# Configure Area2D
	collision_layer = 0
	collision_mask = 1  # Detect ball
	body_entered.connect(_on_body_entered)
	
	# Create visual indicator (glowing circle or target)
	_create_visual_indicator()
	
	# Initially inactive
	modulate = Color(0.5, 0.5, 0.5, 0.5)  # Dimmed when inactive
	
	if _get_debug_mode():
		add_visual_label("SKILL SHOT\n" + str(skill_shot_points) + " pts")

func _process(delta):
	if is_active:
		activation_timer -= delta
		
		# Blink effect when active
		var blink_speed = 3.0
		var alpha = 0.7 + 0.3 * sin(activation_timer * blink_speed * 10.0)
		modulate = Color(1.0, 1.0, 1.0, alpha)
		
		# Deactivate if time window expired
		if activation_timer <= 0.0:
			deactivate()
	else:
		# Dimmed state
		modulate = Color(0.5, 0.5, 0.5, 0.5)

func activate():
	"""Activate skill shot target - called when ball is launched"""
	is_active = true
	activation_timer = time_window
	has_been_hit = false
	
	# Visual feedback: glow effect
	modulate = Color(1.0, 1.0, 0.0, 1.0)  # Yellow glow
	
	if _get_debug_mode():
		print("[SkillShot] Activated - ", skill_shot_points, " points available")

func deactivate():
	"""Deactivate skill shot target"""
	is_active = false
	modulate = Color(0.5, 0.5, 0.5, 0.5)  # Dimmed
	
	if _get_debug_mode():
		print("[SkillShot] Deactivated")

func _on_body_entered(body: Node2D):
	"""Called when ball enters skill shot zone"""
	if not is_active:
		return
	
	if has_been_hit:
		return  # Already hit this skill shot
	
	if body is RigidBody2D and body.collision_layer == 1:  # Ball
		has_been_hit = true
		
		# Calculate points based on difficulty
		var final_points = skill_shot_points * difficulty_level
		
		# Award points
		skill_shot_hit.emit(final_points)
		
		# Visual feedback
		_play_hit_effect()
		
		# Deactivate
		deactivate()
		
		if _get_debug_mode():
			print("[SkillShot] Hit! Awarded ", final_points, " points")

func _create_visual_indicator():
	"""Create visual indicator for skill shot target"""
	# Create a circle shape
	var circle = CircleShape2D.new()
	circle.radius = 20.0
	
	# Add collision shape
	var collision_shape = CollisionShape2D.new()
	collision_shape.shape = circle
	add_child(collision_shape)
	
	# Create visual sprite (glowing target)
	var sprite = Sprite2D.new()
	var texture = ImageTexture.create_from_image(Image.create(40, 40, false, Image.FORMAT_RGBA8))
	sprite.texture = texture
	sprite.modulate = Color(1.0, 1.0, 0.0, 0.5)  # Yellow, semi-transparent
	add_child(sprite)
	
	# Alternative: Use ColorRect for simple visual
	var color_rect = ColorRect.new()
	color_rect.size = Vector2(40, 40)
	color_rect.position = Vector2(-20, -20)
	color_rect.color = Color(1.0, 1.0, 0.0, 0.3)  # Yellow glow
	add_child(color_rect)
	
	# v3.0: Add glow effect
	_add_glow_effect()

func _add_glow_effect():
	"""v3.0: Add glow effect to skill shot"""
	var glow_script = load("res://scripts/GlowEffect.gd")
	if glow_script:
		var glow = Node2D.new()
		glow.set_script(glow_script)
		glow.glow_color = Color(1.0, 1.0, 0.0, 1.0)  # Yellow
		glow.glow_size = 1.8
		glow.glow_intensity = 1.5
		glow.pulse_enabled = true
		glow.pulse_speed = 3.0
		add_child(glow)

func _play_hit_effect():
	"""Play visual/audio effect when skill shot is hit"""
	# Flash effect
	var tween = create_tween()
	tween.tween_property(self, "modulate", Color(1.0, 1.0, 1.0, 1.0), 0.1)
	tween.tween_property(self, "modulate", Color(0.5, 0.5, 0.5, 0.5), 0.2)
	
	# Play sound
	var sound_manager = get_tree().get_first_node_in_group("sound_manager")
	if sound_manager and sound_manager.has_method("play_sound"):
		sound_manager.play_sound("skill_shot")

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "VisualLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1.0, 1.0, 0.0, 1.0))  # Yellow
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-40, -40)
	add_child(label)

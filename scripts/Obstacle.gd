extends StaticBody2D

## Obstacle script for pinball game
## Handles obstacle collision, bounce, and scoring

signal obstacle_hit(points: int)

@export var obstacle_type: String = "basketball" : set = set_obstacle_type  # "basketball", "baseball_player", "baseball_bat", "soccer_goal"
@export var points_value: int = 10
@export var bounce_strength: float = 0.9

func set_obstacle_type(value: String):
	"""Setter for obstacle_type that updates sprite when changed"""
	obstacle_type = value
	if is_inside_tree():
		update_sprite()

var hit_cooldown: float = 0.0
var cooldown_time: float = 0.5  # Prevent multiple hits in quick succession

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	# Add to obstacles group
	add_to_group("obstacles")
	
	# Set collision layer for obstacles (layer 8)
	collision_layer = 8
	collision_mask = 0  # Static body doesn't need collision mask (Area2D handles detection)
	
	# Configure physics material based on type
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = bounce_strength
	physics_material.friction = 0.2
	physics_material_override = physics_material
	
	# Load sprite - will be called again if obstacle_type changes
	update_sprite()
	
	# Add Area2D for collision detection
	var area = Area2D.new()
	area.name = "DetectionArea"
	area.collision_layer = 0
	area.collision_mask = 1  # Detect ball
	add_child(area)
	
	# Copy collision shape to area
	var collision_shape = get_node_or_null("CollisionShape2D")
	if collision_shape:
		var area_shape = CollisionShape2D.new()
		area_shape.shape = collision_shape.shape.duplicate()
		area.add_child(area_shape)
		area.body_entered.connect(_on_body_entered)
	
	# Add visual label if debug mode enabled
	if _get_debug_mode():
		add_visual_label("OBSTACLE\n" + obstacle_type.to_upper())

func update_sprite():
	"""Update sprite based on obstacle type and add ColorRect fallback"""
	var visual_node = get_node_or_null("Visual")
	if visual_node and visual_node is Sprite2D:
		var sprite_path = ""
		
		match obstacle_type:
			"basketball":
				sprite_path = "res://assets/sprites/basketball_hoop.png"
			"baseball_player":
				sprite_path = "res://assets/sprites/baseball_player.png"
			"baseball_bat":
				sprite_path = "res://assets/sprites/baseball_bat.png"
			"soccer_goal":
				sprite_path = "res://assets/sprites/soccer_goal.png"
			# Fallback to old types for backwards compatibility
			"bumper":
				sprite_path = "res://assets/sprites/basketball_hoop.png"
			"peg":
				sprite_path = "res://assets/sprites/baseball_player.png"
			"wall":
				sprite_path = "res://assets/sprites/baseball_bat.png"
		
		if sprite_path != "":
			var texture = load(sprite_path)
			if texture:
				visual_node.texture = texture
				# Initial scale is 1,1 - ObstacleSpawner will adjust if needed
				visual_node.scale = Vector2(1, 1)
	
	# Add or update ColorRect fallback (only visible if sprite fails to load)
	var fallback_node = get_node_or_null("ColorRectFallback")
	if not fallback_node:
		fallback_node = ColorRect.new()
		fallback_node.name = "ColorRectFallback"
		add_child(fallback_node)
	
	# Hide fallback by default - only show if sprite is missing
	fallback_node.visible = false
	
	# Check if sprite loaded successfully, if not, show fallback
	var sprite_loaded = false
	if visual_node and visual_node is Sprite2D:
		if visual_node.texture != null:
			sprite_loaded = true
	
	# Set color and size based on obstacle type
	match obstacle_type:
		"basketball":
			fallback_node.color = Color(1, 0.5, 0, 1)  # Orange (basketball hoop)
			fallback_node.offset_left = -30.0
			fallback_node.offset_top = -30.0
			fallback_node.offset_right = 30.0
			fallback_node.offset_bottom = 30.0
		"baseball_player":
			fallback_node.color = Color(0.2, 0.2, 0.4, 1)  # Dark blue (player)
			fallback_node.offset_left = -10.0
			fallback_node.offset_top = -20.0
			fallback_node.offset_right = 10.0
			fallback_node.offset_bottom = 20.0
		"baseball_bat":
			fallback_node.color = Color(0.5, 0.3, 0.2, 1)  # Brown (bat)
			fallback_node.offset_left = -20.0
			fallback_node.offset_top = -6.0
			fallback_node.offset_right = 20.0
			fallback_node.offset_bottom = 6.0
		"soccer_goal":
			fallback_node.color = Color(0.8, 0.8, 0.8, 1)  # Light gray (goal)
			fallback_node.offset_left = -25.0
			fallback_node.offset_top = -15.0
			fallback_node.offset_right = 25.0
			fallback_node.offset_bottom = 15.0
		# Fallback to old types for backwards compatibility
		"bumper":
			fallback_node.color = Color(1, 0.5, 0, 1)  # Orange
			fallback_node.offset_left = -30.0
			fallback_node.offset_top = -30.0
			fallback_node.offset_right = 30.0
			fallback_node.offset_bottom = 30.0
		"peg":
			fallback_node.color = Color(0.2, 0.2, 0.4, 1)  # Dark blue
			fallback_node.offset_left = -8.0
			fallback_node.offset_top = -8.0
			fallback_node.offset_right = 8.0
			fallback_node.offset_bottom = 8.0
		"wall":
			fallback_node.color = Color(0.5, 0.3, 0.2, 1)  # Brown
			fallback_node.offset_left = -20.0
			fallback_node.offset_top = -5.0
			fallback_node.offset_right = 20.0
			fallback_node.offset_bottom = 5.0
	
	# Show fallback only if sprite failed to load
	if not sprite_loaded:
		fallback_node.visible = true
	
func _process(delta):
	if hit_cooldown > 0.0:
		hit_cooldown -= delta

func _on_body_entered(body: Node2D):
	"""Called when a body enters the obstacle detection area"""
	if hit_cooldown > 0.0:
		return
	
	if body is RigidBody2D and body.collision_layer == 1:  # Ball layer
		hit_cooldown = cooldown_time
		obstacle_hit.emit(points_value)
		# Visual feedback could be added here (flash, animation, etc.)

func add_visual_label(text: String):
	"""Add a visual label to identify this object"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "VisualLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 14)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(-40, -40)  # Offset from center
	add_child(label)

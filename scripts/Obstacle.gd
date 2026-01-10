extends StaticBody2D

## Obstacle script for pinball game
## Handles obstacle collision, bounce, and scoring

signal obstacle_hit(points: int)

@export var obstacle_type: String = "bumper" : set = set_obstacle_type  # "bumper", "peg", "wall"
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
			"bumper":
				sprite_path = "res://assets/sprites/bumper.png"
			"peg":
				sprite_path = "res://assets/sprites/peg.png"
			"wall":
				sprite_path = "res://assets/sprites/wall_obstacle.png"
		
		if sprite_path != "":
			var texture = load(sprite_path)
			if texture:
				visual_node.texture = texture
				# Initial scale is 1,1 - ObstacleSpawner will adjust if needed
				visual_node.scale = Vector2(1, 1)
	
	# Add or update ColorRect fallback
	var fallback_node = get_node_or_null("ColorRectFallback")
	if not fallback_node:
		fallback_node = ColorRect.new()
		fallback_node.name = "ColorRectFallback"
		add_child(fallback_node)
	
	# Set color and size based on obstacle type
	match obstacle_type:
		"bumper":
			fallback_node.color = Color(1, 1, 0.2, 1)  # Yellow
			fallback_node.offset_left = -30.0
			fallback_node.offset_top = -30.0
			fallback_node.offset_right = 30.0
			fallback_node.offset_bottom = 30.0
		"peg":
			fallback_node.color = Color(1, 1, 1, 1)  # White
			fallback_node.offset_left = -8.0
			fallback_node.offset_top = -8.0
			fallback_node.offset_right = 8.0
			fallback_node.offset_bottom = 8.0
		"wall":
			fallback_node.color = Color(0.5, 0.5, 0.5, 1)  # Gray
			fallback_node.offset_left = -20.0
			fallback_node.offset_top = -5.0
			fallback_node.offset_right = 20.0
			fallback_node.offset_bottom = 5.0

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

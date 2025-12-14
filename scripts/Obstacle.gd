extends StaticBody2D

## Obstacle script for pinball game
## Handles obstacle collision, bounce, and scoring

signal obstacle_hit(points: int)

@export var obstacle_type: String = "bumper"  # "bumper", "peg", "wall"
@export var points_value: int = 10
@export var bounce_strength: float = 0.9

var hit_cooldown: float = 0.0
var cooldown_time: float = 0.5  # Prevent multiple hits in quick succession

func _ready():
	# Add to obstacles group
	add_to_group("obstacles")
	
	# Set collision layer for obstacles (layer 8)
	collision_layer = 8
	collision_mask = 1  # Collide with ball
	
	# Configure physics material based on type
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = bounce_strength
	physics_material.friction = 0.2
	physics_material_override = physics_material
	
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

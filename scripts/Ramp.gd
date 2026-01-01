extends StaticBody2D

## Ramp script for pinball game
## Creates angled surfaces to guide ball movement

@export var ramp_length: float = 200.0
@export var ramp_angle: float = 30.0  # Angle in degrees (positive = upward slope)
@export var ramp_width: float = 40.0

func _ready():
	# Create collision shape for ramp
	var collision = CollisionShape2D.new()
	var shape = SegmentShape2D.new()
	
	# Calculate ramp endpoints based on angle
	var angle_rad = deg_to_rad(ramp_angle)
	var end_x = ramp_length * cos(angle_rad)
	var end_y = -ramp_length * sin(angle_rad)  # Negative because Y increases downward
	
	shape.a = Vector2(0, 0)
	shape.b = Vector2(end_x, end_y)
	
	collision.shape = shape
	add_child(collision)
	
	# Set collision layer
	collision_layer = 4  # Walls layer
	collision_mask = 0
	
	# Configure physics material
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.6
	physics_material.friction = 0.3
	physics_material_override = physics_material
	
	# Create visual representation
	var visual = ColorRect.new()
	visual.name = "Visual"
	visual.offset_left = -5.0
	visual.offset_top = -ramp_width / 2.0
	visual.offset_right = ramp_length + 5.0
	visual.offset_bottom = ramp_width / 2.0
	visual.color = Color(0.6, 0.4, 0.2, 1)  # Brown ramp color
	visual.rotation = angle_rad
	add_child(visual)
	
	# Add visual label
	var label = Label.new()
	label.name = "Label"
	label.text = "RAMP"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(1, 1, 1, 1))
	label.position = Vector2(ramp_length / 2.0, 0)
	add_child(label)


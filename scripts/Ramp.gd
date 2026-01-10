extends StaticBody2D

## Ramp script for pinball game
## Creates curved spline-based surfaces to guide ball movement

@export var ramp_length: float = 200.0
@export var ramp_angle: float = 30.0  # Starting angle in degrees (positive = upward slope)
@export var ramp_width: float = 40.0
@export var curve_points: int = 8  # Number of segments for spline curve (more = smoother)
@export var curve_type: String = "catmull"  # "catmull", "bezier", or "smooth"

func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _generate_spline_points(control_points: Array[Vector2], segments: int) -> Array[Vector2]:
	"""Generate spline curve points using Catmull-Rom interpolation"""
	var points: Array[Vector2] = []
	if control_points.size() < 2:
		return points
	
	for i in range(control_points.size() - 1):
		var p0 = control_points[max(0, i - 1)]
		var p1 = control_points[i]
		var p2 = control_points[i + 1]
		var p3 = control_points[min(control_points.size() - 1, i + 2)]
		
		# Generate points along this segment
		for j in range(segments):
			var t = float(j) / float(segments)
			var point = _catmull_rom(p0, p1, p2, p3, t)
			points.append(point)
	
	# Add final point
	points.append(control_points[control_points.size() - 1])
	return points

func _catmull_rom(p0: Vector2, p1: Vector2, p2: Vector2, p3: Vector2, t: float) -> Vector2:
	"""Catmull-Rom spline interpolation"""
	var t2 = t * t
	var t3 = t2 * t
	return 0.5 * (
		(2.0 * p1) +
		(-p0 + p2) * t +
		(2.0 * p0 - 5.0 * p1 + 4.0 * p2 - p3) * t2 +
		(-p0 + 3.0 * p1 - 3.0 * p2 + p3) * t3
	)

func _ready():
	# Set collision layer
	collision_layer = 4  # Walls layer
	collision_mask = 0
	
	# Configure physics material
	var physics_material = PhysicsMaterial.new()
	physics_material.bounce = 0.6
	physics_material.friction = 0.3
	physics_material_override = physics_material
	
	# Calculate control points for spline curve
	var angle_rad = deg_to_rad(ramp_angle)
	var end_x = ramp_length * cos(angle_rad)
	var end_y = -ramp_length * sin(angle_rad)  # Negative because Y increases downward
	
	# Create control points: start, middle control points for curve, end
	var control_points: Array[Vector2] = []
	control_points.append(Vector2(0, 0))
	# Add curved control points (create a smooth arc)
	control_points.append(Vector2(end_x * 0.33, end_y * 0.25))
	control_points.append(Vector2(end_x * 0.67, end_y * 0.5))
	control_points.append(Vector2(end_x, end_y))
	
	# Generate spline points
	var spline_points = _generate_spline_points(control_points, curve_points)
	
	# Create collision shapes using segments between spline points
	var segments_container = Node2D.new()
	segments_container.name = "RampSegments"
	add_child(segments_container)
	
	for i in range(spline_points.size() - 1):
		var collision = CollisionShape2D.new()
		var shape = SegmentShape2D.new()
		shape.a = spline_points[i]
		shape.b = spline_points[i + 1]
		collision.shape = shape
		segments_container.add_child(collision)
	
	# Create visual representation using Line2D for curved appearance
	var line = Line2D.new()
	line.name = "Visual"
	line.width = ramp_width
	line.default_color = Color(0.6, 0.4, 0.2, 1)  # Brown ramp color
	line.points = PackedVector2Array(spline_points)
	add_child(line)
	
	# Add visual label if debug mode enabled
	if _get_debug_mode():
		add_visual_label("CURVED RAMP")

func add_visual_label(text: String):
	"""Add a visual label to identify this object (debug mode)"""
	if not _get_debug_mode():
		return
	var label = Label.new()
	label.name = "DebugLabel"
	label.text = text
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 12)
	label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.4, 1))  # Brown
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(ramp_length / 2.0, 0)
	add_child(label)

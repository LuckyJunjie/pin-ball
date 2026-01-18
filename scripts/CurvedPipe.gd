extends StaticBody2D

## Curved Pipe script for pinball game
## Creates a curved pipe path from queue (right side) upward, then left toward center, then down to flippers

@export var pipe_width: float = 40.0
@export var curve_points: int = 16  # Number of segments for spline curve

var control_points: Array[Vector2] = []

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
	physics_material.bounce = 0.3  # Low bounce for pipe
	physics_material.friction = 0.1  # Low friction for smooth sliding
	physics_material_override = physics_material
	
	# Define curved pipe path in global coordinates:
	# Path: Launcher area (720, 400) -> Up -> Curve Left -> Center -> Fall to Flippers
	# 1. Start at launcher area (720, 400) - covers ball from launcher going up
	# 2. Go up first to (720, 50) - fly up
	# 3. Curve left toward center: (650, 50) -> (550, 100) -> (450, 200)
	# 4. Continue to center: (400, 280) - center of screen
	# 5. Fall down toward flippers: (400, 400) -> (400, 460) - above flipper area
	var start_pos = Vector2(720, 400)  # Launcher area - pipe starts here going up
	var up_pos = Vector2(720, 50)  # Go up first (fly up)
	var curve_left1 = Vector2(650, 50)  # Start curving left
	var curve_left2 = Vector2(550, 100)  # Curve more toward center
	var curve_center1 = Vector2(450, 200)  # Approaching center
	var center_pos = Vector2(400, 280)  # Center of screen
	var fall_down1 = Vector2(400, 380)  # Start falling
	var end_pos = Vector2(400, 460)  # Above flippers area (y=480) - players can hit or miss
	
	# Get pipe position (should be at launcher/queue start position)
	var pipe_pos = position if position != Vector2.ZERO else Vector2(720, 400)
	if is_inside_tree():
		pipe_pos = global_position
	
	# Create control points for the curved path (convert global to local)
	control_points = [
		start_pos - pipe_pos,  # Start at queue
		up_pos - pipe_pos,  # Go up first
		curve_left1 - pipe_pos,  # Start curving left
		curve_left2 - pipe_pos,  # Curve more left
		curve_center1 - pipe_pos,  # Approaching center
		center_pos - pipe_pos,  # Center of screen
		fall_down1 - pipe_pos,  # Start falling
		end_pos - pipe_pos  # Above flippers - ball can fall to be hit or missed
	]
	
	# Generate spline points
	var segments_per_curve = curve_points / (control_points.size() - 1)
	var spline_points = _generate_spline_points(control_points, max(4, int(segments_per_curve)))
	
	# Constrain points to playfield bounds
	var playfield_min_x = 20.0
	var playfield_max_x = 780.0
	var playfield_min_y = 20.0
	var playfield_max_y = 580.0
	
	for i in range(spline_points.size()):
		var local_point = spline_points[i]
		var global_point = local_point + pipe_pos
		
		# Clamp to playfield bounds
		global_point.x = clamp(global_point.x, playfield_min_x, playfield_max_x)
		global_point.y = clamp(global_point.y, playfield_min_y, playfield_max_y)
		
		# Convert back to local coordinates
		spline_points[i] = global_point - pipe_pos
	
	# Create visual representation using Line2D for both walls
	var left_points = PackedVector2Array()
	var right_points = PackedVector2Array()
	
	# Create collision walls on both sides of the path
	# IMPORTANT: CollisionShape2D must be direct children of StaticBody2D for collision to work
	for i in range(spline_points.size() - 1):
		var p1 = spline_points[i]
		var p2 = spline_points[i + 1]
		var dir = (p2 - p1).normalized()
		
		# Handle edge case where points are too close
		if dir.length() < 0.01:
			continue
		
		# Perpendicular to path direction (rotate 90° counter-clockwise)
		var perpendicular = Vector2(-dir.y, dir.x)
		var wall_offset = perpendicular * (pipe_width / 2.0)
		
		# Calculate wall points
		var left_a = p1 + wall_offset
		var left_b = p2 + wall_offset
		var right_a = p1 - wall_offset
		var right_b = p2 - wall_offset
		
		# Add to visual points arrays
		if i == 0:
			left_points.append(left_a)
			right_points.append(right_a)
		left_points.append(left_b)
		right_points.append(right_b)
		
		# Left wall segment collision - MUST be direct child of StaticBody2D
		var left_collision = CollisionShape2D.new()
		var left_shape = SegmentShape2D.new()
		left_shape.a = left_a
		left_shape.b = left_b
		left_collision.shape = left_shape
		add_child(left_collision)  # Direct child of StaticBody2D
		
		# Right wall segment collision - MUST be direct child of StaticBody2D
		var right_collision = CollisionShape2D.new()
		var right_shape = SegmentShape2D.new()
		right_shape.a = right_a
		right_shape.b = right_b
		right_collision.shape = right_shape
		add_child(right_collision)  # Direct child of StaticBody2D
	
	# Create visual representation using Line2D for both walls
	var left_line = Line2D.new()
	left_line.name = "VisualLeft"
	left_line.width = 8.0
	left_line.default_color = Color(0.6, 0.5, 0.3, 1)  # Brown pipe color
	left_line.points = left_points
	add_child(left_line)
	
	var right_line = Line2D.new()
	right_line.name = "VisualRight"
	right_line.width = 8.0
	right_line.default_color = Color(0.6, 0.5, 0.3, 1)
	right_line.points = right_points
	add_child(right_line)
	
	if _get_debug_mode():
		add_visual_label("CURVED PIPE")

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
	label.add_theme_color_override("font_color", Color(0.8, 0.6, 0.4, 1))
	label.add_theme_color_override("font_outline_color", Color(0, 0, 0, 1))
	label.add_theme_constant_override("outline_size", 2)
	label.position = Vector2(0, 0)
	add_child(label)

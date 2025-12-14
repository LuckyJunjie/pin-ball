extends Node2D

## Obstacle Spawner for pinball game
## Randomly places obstacles in the playfield

@export var obstacle_scene: PackedScene
@export var num_obstacles: int = 8
@export var min_distance_from_walls: float = 50.0
@export var min_distance_between: float = 80.0
@export var avoid_zones: Array[Rect2] = []

var spawned_obstacles: Array[Node2D] = []
var playfield_bounds: Rect2 = Rect2(20, 20, 760, 560)  # Left, Top, Width, Height

func _ready():
	# Define avoid zones (flipper areas, launcher area)
	# Left flipper zone: approximately x: 150-250, y: 500-600
	avoid_zones.append(Rect2(150, 500, 100, 100))
	# Right flipper zone: approximately x: 550-650, y: 500-600
	avoid_zones.append(Rect2(550, 500, 100, 100))
	# Launcher zone: approximately x: 350-450, y: 520-600
	avoid_zones.append(Rect2(350, 520, 100, 80))
	
	# Spawn obstacles
	spawn_obstacles()

func spawn_obstacles():
	"""Spawn random obstacles in the playfield"""
	if not obstacle_scene:
		push_error("Obstacle scene not set!")
		return
	
	var attempts = 0
	var max_attempts = num_obstacles * 50  # Prevent infinite loops
	
	while spawned_obstacles.size() < num_obstacles and attempts < max_attempts:
		attempts += 1
		
		# Generate random position
		var pos = Vector2(
			randf_range(playfield_bounds.position.x, playfield_bounds.position.x + playfield_bounds.size.x),
			randf_range(playfield_bounds.position.y, playfield_bounds.position.y + playfield_bounds.size.y)
		)
		
		# Check if position is valid
		if is_valid_position(pos):
			var obstacle = obstacle_scene.instantiate()
			add_child(obstacle)
			obstacle.global_position = pos
			
			# Randomly set obstacle type and properties
			var obstacle_script = obstacle.get_script()
			if obstacle_script:
				var type_rand = randi() % 3
				match type_rand:
					0:
						obstacle.obstacle_type = "bumper"
						obstacle.points_value = 20
						obstacle.bounce_strength = 0.95
						# Make bumper larger
						scale_obstacle(obstacle, 1.5)
					1:
						obstacle.obstacle_type = "peg"
						obstacle.points_value = 5
						obstacle.bounce_strength = 0.8
						# Make peg smaller
						scale_obstacle(obstacle, 0.6)
					2:
						obstacle.obstacle_type = "wall"
						obstacle.points_value = 15
						obstacle.bounce_strength = 0.85
						# Make wall rectangular
						make_wall_shape(obstacle)
			
			spawned_obstacles.append(obstacle)
	
	if spawned_obstacles.size() < num_obstacles:
		push_warning("Only spawned " + str(spawned_obstacles.size()) + " obstacles out of " + str(num_obstacles))

func is_valid_position(pos: Vector2) -> bool:
	"""Check if a position is valid for spawning an obstacle"""
	# Check distance from walls
	if pos.x < playfield_bounds.position.x + min_distance_from_walls or \
	   pos.x > playfield_bounds.position.x + playfield_bounds.size.x - min_distance_from_walls or \
	   pos.y < playfield_bounds.position.y + min_distance_from_walls or \
	   pos.y > playfield_bounds.position.y + playfield_bounds.size.y - min_distance_from_walls:
		return false
	
	# Check avoid zones
	for zone in avoid_zones:
		if zone.has_point(pos):
			return false
	
	# Check distance from other obstacles
	for obstacle in spawned_obstacles:
		if obstacle.global_position.distance_to(pos) < min_distance_between:
			return false
	
	return true

func scale_obstacle(obstacle: Node2D, scale_factor: float):
	"""Scale an obstacle visually and collision-wise"""
	obstacle.scale *= scale_factor
	# Also scale collision shapes
	for child in obstacle.get_children():
		if child is CollisionShape2D:
			var shape = child.shape
			if shape is CircleShape2D:
				shape.radius *= scale_factor
			elif shape is RectangleShape2D:
				shape.size *= scale_factor

func make_wall_shape(obstacle: Node2D):
	"""Convert obstacle to wall shape (rectangular)"""
	for child in obstacle.get_children():
		if child is CollisionShape2D:
			var rect_shape = RectangleShape2D.new()
			rect_shape.size = Vector2(40, 15)
			child.shape = rect_shape
			# Random rotation for variety
			obstacle.rotation_degrees = randf_range(-45, 45)

extends TileMapLayer

## Maze Pipe Manager for pinball game
## Manages tilemap-based pipe maze that guides balls through channels

@export var default_maze_layout: String = "level_1"  # Name of default layout to load
@export var tile_size: int = 32  # Tile size in pixels
@export var maze_layout_data: Dictionary = {}  # Runtime maze data


func _get_debug_mode() -> bool:
	"""Helper to get debug mode from GameManager"""
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if game_manager:
		var debug = game_manager.get("debug_mode")
		if debug != null:
			return bool(debug)
	return false

func _ready():
	if _get_debug_mode():
		print("[MazePipeManager] _ready() called")
	
	# Load default maze layout
	if default_maze_layout:
		load_maze_layout_by_name(default_maze_layout)
	else:
		# Create default maze path programmatically
		create_default_maze_path()

func load_maze_layout_by_name(layout_name: String):
	"""Load a maze layout by name from the levels/maze_layouts directory"""
	var layout_path = "res://levels/maze_layouts/" + layout_name + ".json"
	
	if ResourceLoader.exists(layout_path):
		var file = FileAccess.open(layout_path, FileAccess.READ)
		if file:
			var json_string = file.get_as_text()
			file.close()
			
			var json = JSON.new()
			var parse_result = json.parse(json_string)
			
			if parse_result == OK:
				var data = json.data
				load_maze_layout(data)
			else:
				push_error("Failed to parse maze layout JSON: " + json_string)
				create_default_maze_path()
		else:
			push_error("Failed to open maze layout file: " + layout_path)
			create_default_maze_path()
	else:
		if _get_debug_mode():
			print("[MazePipeManager] Layout file not found: " + layout_path + ", using default path")
		create_default_maze_path()

func load_maze_layout(level_data: Dictionary):
	"""Load maze layout from dictionary data"""
	if _get_debug_mode():
		print("[MazePipeManager] Loading maze layout: ", level_data)
	
	clear_maze()
	
	maze_layout_data = level_data
	
	if level_data.has("tiles"):
		var tiles = level_data["tiles"]
		var tile_set_size = tile_size
		
		if level_data.has("tile_size"):
			tile_set_size = level_data["tile_size"]
		
		for tile_data in tiles:
			if tile_data.has("position") and tile_data.has("tile_id"):
				var pos = tile_data["position"]
				var tile_id = tile_data["tile_id"]
				var coords = Vector2i(pos[0], pos[1])
				
				set_cell(coords, 0, Vector2i(tile_id, 0))
	
	if _get_debug_mode():
		print("[MazePipeManager] Maze layout loaded with ", get_used_cells().size(), " tiles")

func create_default_maze_path():
	"""Create a default maze path programmatically (replaces CurvedPipe path)"""
	if _get_debug_mode():
		print("[MazePipeManager] Creating default maze path")
	
	clear_maze()
	
	# Create a path that guides ball from queue (720, 400) → up → left → center → flippers
	# Convert world coordinates to tile coordinates (assuming tile_size = 32)
	# Pipe entry at (720, 400) ≈ tile (22, 12) in world coordinates
	# Ball needs an open channel to fall through - create walls on SIDES of channel
	# Channel should be at least 2-3 tiles wide for ball to pass
	
	# Ball entry point: world (720, 400) = tile (22.5, 12.5) ≈ tile (22, 12)
	# Create channel with walls on left and right sides, leaving middle open
	
	# Vertical channel going up from entry point (x=22)
	# Left wall: tile x=21 (world x=672)
	# Right wall: tile x=24 (world x=768)
	# Ball channel: between x=22-23 (world x=704-736)
	
	# Vertical walls on left side (x=21) - from entry point up to top
	for y in range(3, 13):
		set_cell(Vector2i(21, y), 0, Vector2i(1, 0))  # Vertical wall tile (tile_id 1)
	
	# Vertical walls on right side (x=24) - from entry point up to top
	for y in range(3, 13):
		set_cell(Vector2i(24, y), 0, Vector2i(1, 0))  # Vertical wall tile (tile_id 1)
	
	# Horizontal wall at top of vertical channel
	for x in range(21, 25):
		set_cell(Vector2i(x, 3), 0, Vector2i(2, 0))  # Horizontal wall tile (tile_id 2)
	
	# Curved section (leftward curve) - horizontal wall at y=7, from x=13 to x=21
	for x in range(13, 22):
		set_cell(Vector2i(x, 7), 0, Vector2i(2, 0))  # Horizontal wall
	
	# Vertical walls on right side after curve (x=24 continues down)
	for y in range(7, 15):
		set_cell(Vector2i(24, y), 0, Vector2i(1, 0))  # Vertical wall
	
	# Vertical wall on left side after curve (x=21 continues down)
	for y in range(7, 15):
		set_cell(Vector2i(21, y), 0, Vector2i(1, 0))  # Vertical wall
	
	# Exit channel (center down to flippers) - walls at x=11 and x=14, creating channel x=12-13
	for y in range(14, 19):
		set_cell(Vector2i(11, y), 0, Vector2i(1, 0))  # Vertical wall (left side)
		set_cell(Vector2i(14, y), 0, Vector2i(1, 0))  # Vertical wall (right side)
	
	if _get_debug_mode():
		print("[MazePipeManager] Default maze path created with ", get_used_cells().size(), " tiles")
		print("[MazePipeManager] Ball entry at world (720, 400) = tile (22.5, 12.5), channel between tiles x=22-23")

func create_pipe_path(path_points: Array[Vector2i], wall_tile_id: int = 1):
	"""Programmatically create a pipe path from point array"""
	clear_maze()
	
	if path_points.size() < 2:
		push_warning("Path points array too small: " + str(path_points.size()))
		return
	
	# Create walls along the path (simplified - assumes straight segments)
	for i in range(path_points.size() - 1):
		var start = path_points[i]
		var end = path_points[i + 1]
		
		# Create wall tiles along the path
		# This is a simplified version - full implementation would handle corners
		if start.x == end.x:
			# Vertical path
			var min_y = min(start.y, end.y)
			var max_y = max(start.y, end.y)
			for y in range(min_y, max_y + 1):
				set_cell(Vector2i(start.x, y), 0, Vector2i(wall_tile_id, 0))
		elif start.y == end.y:
			# Horizontal path
			var min_x = min(start.x, end.x)
			var max_x = max(start.x, end.x)
			for x in range(min_x, max_x + 1):
				set_cell(Vector2i(x, start.y), 0, Vector2i(wall_tile_id, 0))
	
	if _get_debug_mode():
		print("[MazePipeManager] Pipe path created with ", get_used_cells().size(), " tiles")

func clear_maze():
	"""Clear all tiles from the maze"""
	clear()

func is_position_in_maze(pos: Vector2) -> bool:
	"""Check if a world position is inside a maze wall tile"""
	# Convert world position to tile coordinates
	var local_pos = to_local(pos)
	var tile_coords = Vector2i(int(local_pos.x / tile_size), int(local_pos.y / tile_size))
	var source_id = get_cell_source_id(tile_coords)
	return source_id != -1  # If there's a tile (source_id != -1), it's in the maze

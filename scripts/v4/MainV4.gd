extends Node2D
## v4.0 Main game scene: wires GameManagerV4 to Balls/Launcher, BackboxManagerV4, camera.

var _camera: Camera2D = null

# Zone scene paths
const ZONE_SCENES: Dictionary = {
	"android_acres": "res://scenes/zones/AndroidAcres/AndroidAcres.tscn",
	"dino_desert": "res://scenes/zones/DinoDesert/DinoDesert.tscn",
	"google_gallery": "res://scenes/zones/GoogleGallery/GoogleGallery.tscn",
	"flutter_forest": "res://scenes/zones/FlutterForest/FlutterForest.tscn",
	"sparky_scorch": "res://scenes/zones/SparkyScorch/SparkyScorch.tscn"
}

# Zone positions (approximate based on Flutter layout)
const ZONE_POSITIONS: Dictionary = {
	"android_acres": Vector2(150, 150),    # Top-left area
	"dino_desert": Vector2(650, 150),      # Top-right area
	"google_gallery": Vector2(400, 100),   # Top-center area
	"flutter_forest": Vector2(200, 400),   # Bottom-left area
	"sparky_scorch": Vector2(600, 400)     # Bottom-right area
}

func _ready() -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	if not gm:
		return
	_camera = get_node_or_null("Camera2D")
	var balls_node = get_node_or_null("Balls")
	var launcher_node = get_node_or_null("Launcher")
	if balls_node:
		gm.balls_container = balls_node
	if launcher_node:
		gm.launcher_spawn_position = launcher_node.global_position + Vector2(0, -15)
	var ball_scene = load("res://scenes/Ball.tscn") as PackedScene
	if ball_scene:
		gm.ball_scene = ball_scene
	# Flutter bonus ball spawn: (29.2, -24.5) impulse (-40, 0) -> Godot 400+29.2*5, 300-24.5*5 = 546, 177.5
	gm.bonus_ball_spawn_position = Vector2(546, 178)
	gm.bonus_ball_impulse = Vector2(-200, 0)
	
	# Load and position game zones
	_load_game_zones()
	
	# Set character theme from BackboxManagerV4
	var backbox = get_node_or_null("/root/BackboxManagerV4")
	if backbox and backbox.has_property("selected_character_key"):
		var theme_key = backbox.selected_character_key
		if gm.has_method("set_character_theme"):
			gm.set_character_theme(theme_key)
	
	var back_btn = get_node_or_null("UI/BackToMenuButton")
	if back_btn and back_btn is BaseButton:
		back_btn.pressed.connect(_on_back_to_menu)
	if gm.has_signal("game_over"):
		gm.game_over.connect(_on_game_over)
	if gm.has_signal("game_started"):
		gm.game_started.connect(_on_game_started)
	_connect_obstacles()
	_apply_camera_status(gm.status)
	gm.start_game()


func _load_game_zones() -> void:
	## Load and position all 5 game zones
	var zones_container = get_node_or_null("Playfield/Zones")
	if not zones_container:
		# Create zones container if it doesn't exist
		zones_container = Node2D.new()
		zones_container.name = "Zones"
		var playfield = get_node_or_null("Playfield")
		if playfield:
			playfield.add_child(zones_container)
		else:
			# Fallback: add to root
			add_child(zones_container)
			zones_container.z_index = 0
	
	# Load each zone scene
	for zone_key in ZONE_SCENES:
		var zone_path = ZONE_SCENES[zone_key]
		var zone_scene = load(zone_path) as PackedScene
		if zone_scene:
			var zone_instance = zone_scene.instantiate()
			zones_container.add_child(zone_instance)
			
			# Position the zone
			if zone_key in ZONE_POSITIONS:
				zone_instance.position = ZONE_POSITIONS[zone_key]
			
			print("Loaded zone: %s at position %s" % [zone_key, zone_instance.position])
		else:
			push_warning("Failed to load zone scene: %s" % zone_path)


func _on_game_started() -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm:
		_apply_camera_status(gm.status)


func _on_game_over() -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	var backbox = get_node_or_null("/root/BackboxManagerV4")
	if gm and backbox and backbox.has_method("request_initials"):
		backbox.request_initials(gm.display_score(), backbox.selected_character_key)
	_apply_camera_status(GameManagerV4.Status.GAME_OVER)

func _connect_obstacles() -> void:
	var obstacles = get_tree().get_nodes_in_group("obstacles")
	for obs in obstacles:
		if obs.has_signal("obstacle_hit"):
			obs.obstacle_hit.connect(_on_obstacle_hit)

func _on_obstacle_hit(points: int) -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm and gm.has_method("add_score"):
		gm.add_score(points)
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		sm.play_sound("obstacle_hit")

func _on_back_to_menu() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenuV4.tscn")


## Flutter CameraFocusingBehavior: waiting zoom=size.y/175 pos(0,-112); playing zoom=size.y/160 pos(0,-7.8); gameOver zoom=size.y/100 pos(0,-111).
## Godot: position = center + (0, flutter_y*5); zoom: Flutter smaller divisor = more zoomed in; Godot zoom>1 = zoom out, so use divisor/vp.y.
func _apply_camera_status(status: int) -> void:
	if not _camera:
		return
	var vp := get_viewport().get_visible_rect().size
	var center := Vector2(400, 300)
	if status == GameManagerV4.Status.WAITING:
		_camera.zoom = Vector2(175.0 / vp.y, 175.0 / vp.y)
		_camera.position = center + Vector2(0, -112.0 * 5.0)
	elif status == GameManagerV4.Status.PLAYING:
		_camera.zoom = Vector2(160.0 / vp.y, 160.0 / vp.y)
		_camera.position = center + Vector2(0, -7.8 * 5.0)
	elif status == GameManagerV4.Status.GAME_OVER:
		_camera.zoom = Vector2(100.0 / vp.y, 100.0 / vp.y)
		_camera.position = center + Vector2(0, -111.0 * 5.0)

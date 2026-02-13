extends Node
## v4.0 Game state (GameBloc equivalent). Manages rounds, scoring, multiplier, bonuses.
## Use as autoload "GameManagerV4".

enum Status { WAITING, PLAYING, GAME_OVER }
enum Bonus { GOOGLE_WORD, DASH_NEST, SPARKY_TURBO_CHARGE, DINO_CHOMP, ANDROID_SPACESHIP }

signal scored(points: int)
signal round_lost()
signal bonus_activated(bonus: Bonus)
signal multiplier_increased()
signal game_over()
signal game_started()
signal zone_ramp_hit(zone_name: String, hit_count: int)  # For multiplier tracking
signal character_theme_changed(theme_key: String)

const MAX_SCORE: int = 9999999999
const INITIAL_ROUNDS: int = 3
const MAX_MULTIPLIER: int = 6
const BONUS_BALL_DELAY: float = 5.0
const RAMP_HITS_PER_MULTIPLIER: int = 5  # Every 5 ramp hits increases multiplier

# Save/Load System Constants
const SAVE_VERSION: int = 1
const SAVE_PATH: String = "user://saves/v4.0_save.json"
const BACKUP_PATH: String = "user://saves/v4.0_save_backup.json"
const AUTO_SAVE_INTERVAL: float = 30.0  # seconds
const MIN_SCORE_CHANGE_FOR_AUTO_SAVE: int = 100  # Minimum score change to trigger auto-save

# Use script reference to call BallPoolV4 static methods (autoload name refers to instance)
const BallPoolScript := preload("res://scripts/v4/BallPoolV4.gd")

var round_score: int = 0
var total_score: int = 0
var multiplier: int = 1
var rounds: int = INITIAL_ROUNDS
var bonus_history: Array[Bonus] = []
var status: Status = Status.WAITING
var balls_container: Node2D = null
var ball_scene: PackedScene = null:
	set(value):
		ball_scene = value
		_ball_scene_ready = true
		# Try to initialize ball pool when ball_scene is set
		if balls_container:
			call_deferred("_initialize_ball_pool")
var launcher_node: Node = null  # Set by MainV4; used to call set_ball after spawn
var launcher_spawn_position: Vector2 = Vector2(400, 500)
var bonus_ball_spawn_position: Vector2 = Vector2(400, 300)
var bonus_ball_impulse: Vector2 = Vector2(-200, 0)
var bonus_ball_timer: float = -1.0

# Save/Load System Variables
var auto_save_timer: float = 0.0
var last_saved_score: int = 0
var is_save_system_enabled: bool = true

# Initialization state tracking
var _ball_scene_ready: bool = false  # Tracks if ball_scene is ready for initialization

# Zone tracking for multiplier system
var zone_ramp_hits: Dictionary = {
	"android_acres": 0,
	"dino_desert": 0,
	"google_gallery": 0,
	"flutter_forest": 0,
	"sparky_scorch": 0
}

# Character theme support
var selected_character_theme: String = "sparky"  # Default theme

func _ready() -> void:
	add_to_group("game_manager_v4")
	add_to_group("game_manager")
	
	# Initialize ball pool when ball scene and container are set
	call_deferred("_initialize_ball_pool")
	
	# Load saved game state if available
	if is_save_system_enabled:
		call_deferred("load_game_state")

func _process(delta: float) -> void:
	if bonus_ball_timer > 0.0:
		bonus_ball_timer -= delta
		if bonus_ball_timer <= 0.0:
			bonus_ball_timer = -1.0
			_spawn_bonus_ball()
	
	# Auto-save timer
	if is_save_system_enabled and status == Status.PLAYING:
		auto_save_timer += delta
		if auto_save_timer >= AUTO_SAVE_INTERVAL:
			auto_save_timer = 0.0
			# Only auto-save if there's been a significant score change
			var current_display_score = display_score()
			if abs(current_display_score - last_saved_score) >= MIN_SCORE_CHANGE_FOR_AUTO_SAVE:
				save_game_state()
				last_saved_score = current_display_score

func _initialize_ball_pool() -> void:
	# Initialize BallPoolV4 if ball scene and container are available
	if ball_scene and balls_container:
		var ball_pool = BallPoolScript.get_instance()
		if ball_pool and not ball_pool.is_initialized():
			ball_pool.initialize(ball_scene, balls_container)
			print("GameManagerV4: BallPoolV4 initialized")
		elif ball_pool and ball_pool.is_initialized():
			print("GameManagerV4: BallPoolV4 already initialized")
		else:
			push_warning("GameManagerV4: BallPoolV4 instance not found")

func _ensure_ball_pool_initialized() -> void:
	# Ensure BallPoolV4 is initialized (re-inits if container was freed by scene change)
	if ball_scene and balls_container:
		var ball_pool = BallPoolScript.get_instance()
		if ball_pool:
			ball_pool.initialize(ball_scene, balls_container)
		else:
			push_warning("GameManagerV4: BallPoolV4 instance not found")

func display_score() -> int:
	## Returns the score to display (round_score + total_score)
	## Note: Multiplier is NOT applied to display score, only when round is lost
	return mini(round_score + total_score, MAX_SCORE)

func add_score(points: int) -> void:
	if status != Status.PLAYING:
		return
	round_score += points
	# Emit the raw points (without multiplier) for UI display
	# Multiplier will be applied when round is lost in on_round_lost()
	scored.emit(points)
	
	# Auto-save on significant score changes
	if is_save_system_enabled and points >= MIN_SCORE_CHANGE_FOR_AUTO_SAVE:
		force_save()

func on_round_lost() -> void:
	# Prevent multiple calls and ensure we're in playing state
	if status != Status.PLAYING:
		return
	
	# Get combo count before register_drain (which resets it)
	var combo_sys = get_tree().get_first_node_in_group("combo_system")
	var combo_count_at_drain := 0
	if combo_sys and "combo_count" in combo_sys:
		combo_count_at_drain = combo_sys.combo_count
	
	# Collect combo bonus and add to round score
	var combo_bonus = _collect_combo_bonus()
	round_score += combo_bonus
	
	# Notify achievement and statistics systems
	if combo_count_at_drain > 0:
		if AchievementSystemV4:
			AchievementSystemV4.on_combo_achieved(combo_count_at_drain)
		if StatisticsTrackerV4:
			StatisticsTrackerV4.on_combo_changed(combo_count_at_drain)
	
	var final_round = round_score * multiplier
	total_score = mini(total_score + final_round, MAX_SCORE)
	round_score = 0
	multiplier = 1
	rounds = maxi(0, rounds - 1)
	reset_zone_tracking()  # Reset ramp hits for new round
	round_lost.emit()
	
	# Auto-save on round completion
	if is_save_system_enabled:
		force_save()
	
	if rounds <= 0:
		status = Status.GAME_OVER
		var final_score = display_score()
		if AchievementSystemV4:
			AchievementSystemV4.on_game_ended(final_score)
		if StatisticsTrackerV4:
			StatisticsTrackerV4.on_game_ended(final_score)
		game_over.emit()
	else:
		_spawn_ball_at_launcher()

func increase_multiplier() -> void:
	if status != Status.PLAYING:
		return
	if multiplier >= MAX_MULTIPLIER:
		return
	
	var old_multiplier = multiplier
	multiplier += 1
	multiplier_increased.emit()
	
	# Notify achievement and statistics systems
	if AchievementSystemV4:
		AchievementSystemV4.on_multiplier_changed(multiplier)
	if StatisticsTrackerV4:
		StatisticsTrackerV4.on_multiplier_changed(multiplier)
	
	# Visual feedback
	_show_multiplier_effect(old_multiplier, multiplier)
	
	# Auto-save on multiplier increase
	if is_save_system_enabled:
		force_save()

func _show_multiplier_effect(from: int, to: int) -> void:
	var particles = get_tree().get_first_node_in_group("particle_system")
	if particles and particles.has_method("spawn_multiplier_effect"):
		particles.spawn_multiplier_effect(to)
	
	var audio = get_tree().get_first_node_in_group("sound_manager")
	if audio and audio.has_method("play_multiplier_sound"):
		audio.play_multiplier_sound(to)

func add_bonus(bonus: Bonus) -> void:
	bonus_history.append(bonus)
	bonus_activated.emit(bonus)
	
	# Notify achievement system (expects string: GOOGLE_WORD, DASH_NEST, etc.)
	var bonus_name := _bonus_enum_to_string(bonus)
	if AchievementSystemV4:
		AchievementSystemV4.on_bonus_earned(bonus_name)
	# Notify statistics (zone-specific)
	if StatisticsTrackerV4:
		match bonus:
			Bonus.GOOGLE_WORD: StatisticsTrackerV4.on_google_word()
			Bonus.DASH_NEST: StatisticsTrackerV4.on_dash_nest()
			Bonus.DINO_CHOMP: StatisticsTrackerV4.on_dino_chomp()
			Bonus.SPARKY_TURBO_CHARGE: StatisticsTrackerV4.on_sparky_turbo()
			Bonus.ANDROID_SPACESHIP: StatisticsTrackerV4.on_android_bonus()
	
	# Auto-save on bonus activation
	if is_save_system_enabled:
		force_save()
	
	# Handle bonus-specific logic
	match bonus:
		Bonus.GOOGLE_WORD, Bonus.DASH_NEST:
			# Start bonus ball timer
			bonus_ball_timer = BONUS_BALL_DELAY
			if AchievementSystemV4:
				AchievementSystemV4.on_bonus_ball_earned()
			if StatisticsTrackerV4:
				StatisticsTrackerV4.on_bonus_ball_earned()
		Bonus.ANDROID_SPACESHIP:
			# Add large score bonus
			add_score(200000)
		Bonus.DINO_CHOMP:
			# Dino chomp bonus - add score and visual effect
			add_score(150000)
		Bonus.SPARKY_TURBO_CHARGE:
			# Sparky turbo charge - temporary speed boost
			add_score(100000)

func register_zone_ramp_hit(zone_name: String) -> void:
	## Called by zones when their ramp is hit. Tracks hits for multiplier.
	if status != Status.PLAYING:
		return
	
	if zone_ramp_hits.has(zone_name):
		zone_ramp_hits[zone_name] += 1
	else:
		zone_ramp_hits[zone_name] = 1
	
	var hit_count = zone_ramp_hits[zone_name]
	zone_ramp_hit.emit(zone_name, hit_count)
	
	# Every 5 ramp hits increases multiplier (across all zones)
	var total_ramp_hits = 0
	for zone in zone_ramp_hits:
		total_ramp_hits += zone_ramp_hits[zone]
	
	# Auto-save on significant zone progress (every 5 hits)
	if is_save_system_enabled and total_ramp_hits % 5 == 0:
		force_save()
	
	if total_ramp_hits % RAMP_HITS_PER_MULTIPLIER == 0:
		increase_multiplier()

func set_character_theme(theme_key: String) -> void:
	## Set the active character theme (sparky, dino, dash, android)
	if theme_key in ["sparky", "dino", "dash", "android"]:
		selected_character_theme = theme_key
		character_theme_changed.emit(theme_key)

func get_character_theme() -> String:
	return selected_character_theme

func reset_zone_tracking() -> void:
	## Reset zone-specific tracking for new round/game
	for zone in zone_ramp_hits:
		zone_ramp_hits[zone] = 0

func _bonus_enum_to_string(b: Bonus) -> String:
	match b:
		Bonus.GOOGLE_WORD: return "GOOGLE_WORD"
		Bonus.DASH_NEST: return "DASH_NEST"
		Bonus.SPARKY_TURBO_CHARGE: return "SPARKY_TURBO_CHARGE"
		Bonus.DINO_CHOMP: return "DINO_CHOMP"
		Bonus.ANDROID_SPACESHIP: return "ANDROID_SPACESHIP"
	return ""

func _collect_combo_bonus() -> int:
	## Collect and add combo bonus to round score
	var combo = get_tree().get_first_node_in_group("combo_system")
	if combo and combo.has_method("register_drain"):
		return combo.register_drain()
	return 0

func _return_all_balls_to_pool() -> void:
	## Return all active balls to the pool (for game reset)
	var ball_pool = BallPoolScript.get_instance()
	if ball_pool and ball_pool.is_initialized():
		# Get all balls from container and return them to pool
		if balls_container:
			for child in balls_container.get_children():
				if child is RigidBody2D and child.is_in_group("balls"):
					ball_pool.return_ball(child)
		print("GameManagerV4: Returned all balls to pool")

func start_game() -> void:
	print("GameManagerV4: start_game() called")
	round_score = 0
	total_score = 0
	multiplier = 1
	rounds = INITIAL_ROUNDS
	bonus_history.clear()
	reset_zone_tracking()  # Reset all zone tracking
	status = Status.PLAYING
	
	# Return any active balls to the pool before starting new game
	_return_all_balls_to_pool()
	
	# Save initial game state
	if is_save_system_enabled:
		print("GameManagerV4: Calling force_save() from start_game()")
		force_save()
	
	# Notify achievement and statistics systems
	if AchievementSystemV4:
		AchievementSystemV4.on_game_started()
	if StatisticsTrackerV4:
		StatisticsTrackerV4.on_game_started()
	
	game_started.emit()
	_spawn_ball_at_launcher()

func get_ball_count() -> int:
	# Try to use BallPoolV4 if available for accurate active ball count
	var ball_pool = BallPoolScript.get_instance()
	if ball_pool and ball_pool.is_initialized():
		return ball_pool.get_active_ball_count()
	
	# Fallback to counting balls in container
	if not balls_container:
		return 0
	var n := 0
	for c in balls_container.get_children():
		if c is RigidBody2D and c.is_in_group("balls"):
			n += 1
	return n

func _spawn_ball_at_launcher() -> void:
	if not ball_scene or not balls_container:
		return
	
	# Ensure BallPoolV4 is initialized before attempting to use it
	_ensure_ball_pool_initialized()
	
	var ball_pool = BallPoolScript.get_instance()
	var ball: RigidBody2D = null
	if ball_pool and ball_pool.is_initialized():
		ball = ball_pool.spawn_ball_at_position(launcher_spawn_position, Vector2.ZERO, true)  # freeze=true for launcher ball
	
	if not ball:
		# Direct instantiation when pool unavailable or failed
		ball = ball_scene.instantiate()
		balls_container.add_child(ball)
		if ball.has_signal("ball_lost"):
			ball.ball_lost.connect(_on_ball_lost)
	
	if ball:
		ball.freeze = true  # Freeze immediately to prevent physics interaction
		ball.global_position = launcher_spawn_position
		ball.visible = true
		if ball.has_method("reset_ball"):
			ball.reset_ball()
		if ball.get("initial_position") != null:
			ball.initial_position = launcher_spawn_position
		_apply_character_theme_to_ball(ball)
		# Notify Launcher so it can launch the ball
		if launcher_node and launcher_node.has_method("set_ball"):
			launcher_node.set_ball(ball)

func _spawn_bonus_ball() -> void:
	if not ball_scene or not balls_container:
		return
	
	var ball: RigidBody2D = null
	# Try to use BallPoolV4 if available
	var ball_pool = BallPoolScript.get_instance()
	if ball_pool and ball_pool.is_initialized():
		ball = ball_pool.spawn_ball_at_position(bonus_ball_spawn_position, bonus_ball_impulse)
		if ball:
			# Connect ball lost signal
			if ball.has_signal("ball_lost") and not ball.ball_lost.is_connected(_on_ball_lost):
				ball.ball_lost.connect(_on_ball_lost)
			return
		else:
			push_warning("GameManagerV4: BallPoolV4 failed to provide bonus ball, falling back to direct instantiation")
	
	# Fallback to direct instantiation if pool is not available
	ball = ball_scene.instantiate() as RigidBody2D
	balls_container.add_child(ball)
	ball.global_position = bonus_ball_spawn_position
	if ball.has_method("reset_ball"):
		ball.reset_ball()
	if ball.get("initial_position") != null:
		ball.initial_position = bonus_ball_spawn_position
	if ball.has_signal("ball_lost"):
		ball.ball_lost.connect(_on_ball_lost)
	_apply_character_theme_to_ball(ball)
	ball.freeze = false
	ball.apply_impulse(bonus_ball_impulse)

func _on_ball_lost() -> void:
	# Drain removes ball; round_lost is triggered by DrainV4 when no balls left
	pass

func _apply_character_theme_to_ball(ball: RigidBody2D) -> void:
	# C.5: Apply current character theme ball texture (GDD §5.4)
	if not CharacterThemeManagerV4:
		return
	var tex = CharacterThemeManagerV4.get_theme_asset("ball")
	if not tex:
		return
	var visual = ball.get_node_or_null("Visual")
	if visual is Sprite2D:
		visual.texture = tex

# ============================================
# Save/Load System Implementation
# ============================================

func get_game_state() -> Dictionary:
	## Returns a dictionary containing all game state data for serialization
	var state := {
		"version": SAVE_VERSION,
		"round_score": round_score,
		"total_score": total_score,
		"multiplier": multiplier,
		"rounds": rounds,
		"bonus_history": bonus_history.map(func(b): return b as int),  # Convert enum to int
		"status": status as int,
		"zone_ramp_hits": zone_ramp_hits.duplicate(),
		"selected_character_theme": selected_character_theme,
		"timestamp": Time.get_unix_time_from_system()
	}
	return state

func validate_game_state(state: Dictionary) -> bool:
	## Validate loaded game state for consistency and safety
	if not state.has("version"):
		return false
	
	if state.version != SAVE_VERSION:
		print("GameManagerV4: Save version mismatch (expected %d, got %d)" % [SAVE_VERSION, state.version])
		return false
	
	# Validate required fields
	var required_fields = ["round_score", "total_score", "multiplier", "rounds", "bonus_history", "status", "zone_ramp_hits", "selected_character_theme"]
	for field in required_fields:
		if not state.has(field):
			print("GameManagerV4: Missing required field in save: %s" % field)
			return false
	
	# Validate value ranges
	if state.round_score < 0 or state.round_score > MAX_SCORE:
		return false
	if state.total_score < 0 or state.total_score > MAX_SCORE:
		return false
	if state.multiplier < 1 or state.multiplier > MAX_MULTIPLIER:
		return false
	if state.rounds < 0 or state.rounds > 10:  # Reasonable upper bound
		return false
	if state.status < 0 or state.status > Status.size() - 1:
		return false
	
	# Validate zone ramp hits
	if not state.zone_ramp_hits is Dictionary:
		return false
	
	# Validate character theme
	var valid_themes = ["sparky", "dino", "dash", "android"]
	if not state.selected_character_theme in valid_themes:
		return false
	
	return true

func save_game_state() -> bool:
	## Save current game state to file
	if not is_save_system_enabled:
		return false
	
	var state = get_game_state()
	
	# Create backup of existing save if it exists
	if FileAccess.file_exists(SAVE_PATH):
		if not _create_backup():
			print("GameManagerV4: Failed to create backup, proceeding with save anyway")
	
	# Ensure saves directory exists before writing
	if not _ensure_saves_directory():
		print("GameManagerV4: Failed to create saves directory")
		return false
	
	# Save to file
	var file = FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		var error = FileAccess.get_open_error()
		print("GameManagerV4: Failed to open save file for writing: %s" % error_string(error))
		return false
	
	var json_string = JSON.stringify(state, "\t")
	file.store_string(json_string)
	file.close()
	
	print("GameManagerV4: Game state saved successfully")
	last_saved_score = display_score()
	return true

func load_game_state() -> bool:
	## Load game state from file
	if not is_save_system_enabled:
		return false
	
	if not FileAccess.file_exists(SAVE_PATH):
		print("GameManagerV4: No save file found at %s" % SAVE_PATH)
		return false
	
	# Try to load from primary save file
	var file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		var error = FileAccess.get_open_error()
		print("GameManagerV4: Failed to open save file for reading: %s" % error_string(error))
		
		# Try to load from backup
		return _load_from_backup()
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("GameManagerV4: Failed to parse save JSON: %s" % json.get_error_message())
		return _load_from_backup()
	
	var state = json.get_data()
	if not validate_game_state(state):
		print("GameManagerV4: Invalid save data")
		return _load_from_backup()
	
	# Apply loaded state
	_apply_game_state(state)
	print("GameManagerV4: Game state loaded successfully")
	last_saved_score = display_score()
	return true

func _apply_game_state(state: Dictionary) -> void:
	## Apply validated game state to current instance
	round_score = state.round_score
	total_score = state.total_score
	multiplier = state.multiplier
	rounds = state.rounds
	
	# Convert int array back to Bonus enum array
	bonus_history.clear()
	for bonus_int in state.bonus_history:
		if bonus_int >= 0 and bonus_int < Bonus.size():
			bonus_history.append(bonus_int as Bonus)
	
	status = state.status as Status
	zone_ramp_hits = state.zone_ramp_hits.duplicate()
	selected_character_theme = state.selected_character_theme
	
	# Reset auto-save timer
	auto_save_timer = 0.0

func _ensure_saves_directory() -> bool:
	## Ensure the saves directory exists before attempting to write files
	var dir = DirAccess.open("user://")
	if dir == null:
		print("GameManagerV4: Failed to open user:// directory")
		return false
	
	# Check if saves directory exists
	if not dir.dir_exists("saves"):
		# Create the saves directory
		var error = dir.make_dir("saves")
		if error != OK:
			print("GameManagerV4: Failed to create saves directory, error: %s" % error_string(error))
			return false
		print("GameManagerV4: Created saves directory")
	
	return true

func _create_backup() -> bool:
	## Create a backup of the current save file
	if not FileAccess.file_exists(SAVE_PATH):
		return true  # Nothing to backup
	
	# Ensure saves directory exists before creating backup
	if not _ensure_saves_directory():
		return false
	
	var source_file = FileAccess.open(SAVE_PATH, FileAccess.READ)
	if source_file == null:
		return false
	
	var content = source_file.get_as_text()
	source_file.close()
	
	var backup_file = FileAccess.open(BACKUP_PATH, FileAccess.WRITE)
	if backup_file == null:
		return false
	
	backup_file.store_string(content)
	backup_file.close()
	
	print("GameManagerV4: Backup created at %s" % BACKUP_PATH)
	return true

func _load_from_backup() -> bool:
	## Attempt to load game state from backup file
	if not FileAccess.file_exists(BACKUP_PATH):
		print("GameManagerV4: No backup file found")
		return false
	
	var file = FileAccess.open(BACKUP_PATH, FileAccess.READ)
	if file == null:
		print("GameManagerV4: Failed to open backup file")
		return false
	
	var json_string = file.get_as_text()
	file.close()
	
	var json = JSON.new()
	var parse_result = json.parse(json_string)
	if parse_result != OK:
		print("GameManagerV4: Failed to parse backup JSON")
		return false
	
	var state = json.get_data()
	if not validate_game_state(state):
		print("GameManagerV4: Invalid backup data")
		return false
	
	_apply_game_state(state)
	print("GameManagerV4: Game state loaded from backup")
	last_saved_score = display_score()
	return true

func force_save() -> void:
	## Force an immediate save (call this on key game events)
	if is_save_system_enabled and status == Status.PLAYING:
		save_game_state()
		auto_save_timer = 0.0  # Reset timer after forced save

func delete_save() -> bool:
	## Delete the save file (for testing or reset)
	if FileAccess.file_exists(SAVE_PATH):
		# First ensure the saves directory exists
		if not _ensure_saves_directory():
			return false
		
		var dir = DirAccess.open("user://saves/")
		if dir:
			var result = dir.remove("v4.0_save.json")
			if result == OK:
				print("GameManagerV4: Save file deleted")
				return true
			else:
				print("GameManagerV4: Failed to delete save file")
				return false
	return false

func has_save_data() -> bool:
	## Check if save data exists
	return FileAccess.file_exists(SAVE_PATH) or FileAccess.file_exists(BACKUP_PATH)

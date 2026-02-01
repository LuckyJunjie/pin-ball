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

var round_score: int = 0
var total_score: int = 0
var multiplier: int = 1
var rounds: int = INITIAL_ROUNDS
var bonus_history: Array[Bonus] = []
var status: Status = Status.WAITING
var balls_container: Node2D = null
var ball_scene: PackedScene = null
var launcher_spawn_position: Vector2 = Vector2(400, 500)
var bonus_ball_spawn_position: Vector2 = Vector2(400, 300)
var bonus_ball_impulse: Vector2 = Vector2(-200, 0)
var bonus_ball_timer: float = -1.0

# Save/Load System Variables
var auto_save_timer: float = 0.0
var last_saved_score: int = 0
var is_save_system_enabled: bool = true

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
		var ball_pool = BallPoolV4.get_instance()
		if ball_pool and not ball_pool.is_initialized():
			ball_pool.initialize(ball_scene, balls_container)
			print("GameManagerV4: BallPoolV4 initialized")
		elif ball_pool and ball_pool.is_initialized():
			print("GameManagerV4: BallPoolV4 already initialized")
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
		game_over.emit()
	else:
		_spawn_ball_at_launcher()

func increase_multiplier() -> void:
	if status != Status.PLAYING:
		return
	if multiplier >= MAX_MULTIPLIER:
		return
	multiplier += 1
	multiplier_increased.emit()
	
	# Auto-save on multiplier increase
	if is_save_system_enabled:
		force_save()

func add_bonus(bonus: Bonus) -> void:
	bonus_history.append(bonus)
	bonus_activated.emit(bonus)
	
	# Auto-save on bonus activation
	if is_save_system_enabled:
		force_save()
	
	# Handle bonus-specific logic
	match bonus:
		Bonus.GOOGLE_WORD, Bonus.DASH_NEST:
			# Start bonus ball timer
			bonus_ball_timer = BONUS_BALL_DELAY
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

func _return_all_balls_to_pool() -> void:
	## Return all active balls to the pool (for game reset)
	var ball_pool = BallPoolV4.get_instance()
	if ball_pool and ball_pool.is_initialized():
		# Get all balls from container and return them to pool
		if balls_container:
			for child in balls_container.get_children():
				if child is RigidBody2D and child.is_in_group("balls"):
					ball_pool.return_ball(child)
		print("GameManagerV4: Returned all balls to pool")

func start_game() -> void:
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
		force_save()
	
	game_started.emit()
	_spawn_ball_at_launcher()

func get_ball_count() -> int:
	# Try to use BallPoolV4 if available for accurate active ball count
	var ball_pool = BallPoolV4.get_instance()
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
	
	# Try to use BallPoolV4 if available
	var ball_pool = BallPoolV4.get_instance()
	if ball_pool and ball_pool.is_initialized():
		var ball = ball_pool.spawn_ball_at_position(launcher_spawn_position)
		if ball:
			# Connect ball lost signal
			if ball.has_signal("ball_lost") and not ball.ball_lost.is_connected(_on_ball_lost):
				ball.ball_lost.connect(_on_ball_lost)
			return
		else:
			push_warning("GameManagerV4: BallPoolV4 failed to provide ball, falling back to direct instantiation")
	
	# Fallback to direct instantiation if pool is not available
	var ball: RigidBody2D = ball_scene.instantiate()
	balls_container.add_child(ball)
	ball.global_position = launcher_spawn_position
	if ball.has_method("reset_ball"):
		ball.reset_ball()
	if ball.get("initial_position") != null:
		ball.initial_position = launcher_spawn_position
	if ball.has_signal("ball_lost"):
		ball.ball_lost.connect(_on_ball_lost)
	ball.freeze = false

func _spawn_bonus_ball() -> void:
	if not ball_scene or not balls_container:
		return
	
	# Try to use BallPoolV4 if available
	var ball_pool = BallPoolV4.get_instance()
	if ball_pool and ball_pool.is_initialized():
		var ball = ball_pool.spawn_ball_at_position(bonus_ball_spawn_position, bonus_ball_impulse)
		if ball:
			# Connect ball lost signal
			if ball.has_signal("ball_lost") and not ball.ball_lost.is_connected(_on_ball_lost):
				ball.ball_lost.connect(_on_ball_lost)
			return
		else:
			push_warning("GameManagerV4: BallPoolV4 failed to provide bonus ball, falling back to direct instantiation")
	
	# Fallback to direct instantiation if pool is not available
	var ball: RigidBody2D = ball_scene.instantiate()
	balls_container.add_child(ball)
	ball.global_position = bonus_ball_spawn_position
	if ball.has_method("reset_ball"):
		ball.reset_ball()
	if ball.get("initial_position") != null:
		ball.initial_position = bonus_ball_spawn_position
	if ball.has_signal("ball_lost"):
		ball.ball_lost.connect(_on_ball_lost)
	ball.freeze = false
	ball.apply_impulse(bonus_ball_impulse)

func _on_ball_lost() -> void:
	# Drain removes ball; round_lost is triggered by DrainV4 when no balls left
	pass

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

func _create_backup() -> bool:
	## Create a backup of the current save file
	if not FileAccess.file_exists(SAVE_PATH):
		return true  # Nothing to backup
	
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

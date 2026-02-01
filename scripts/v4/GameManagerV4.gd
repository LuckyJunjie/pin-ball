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

func _process(delta: float) -> void:
	if bonus_ball_timer > 0.0:
		bonus_ball_timer -= delta
		if bonus_ball_timer <= 0.0:
			bonus_ball_timer = -1.0
			_spawn_bonus_ball()

func display_score() -> int:
	return mini(round_score + total_score, MAX_SCORE)

func add_score(points: int) -> void:
	if status != Status.PLAYING:
		return
	round_score += points
	scored.emit(points)

func on_round_lost() -> void:
	var final_round = round_score * multiplier
	total_score = mini(total_score + final_round, MAX_SCORE)
	round_score = 0
	multiplier = 1
	rounds = maxi(0, rounds - 1)
	reset_zone_tracking()  # Reset ramp hits for new round
	round_lost.emit()
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

func add_bonus(bonus: Bonus) -> void:
	bonus_history.append(bonus)
	bonus_activated.emit(bonus)
	
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

func start_game() -> void:
	round_score = 0
	total_score = 0
	multiplier = 1
	rounds = INITIAL_ROUNDS
	bonus_history.clear()
	reset_zone_tracking()  # Reset all zone tracking
	status = Status.PLAYING
	game_started.emit()
	_spawn_ball_at_launcher()

func get_ball_count() -> int:
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

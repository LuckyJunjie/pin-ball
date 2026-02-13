extends Node
## v4.0 Ball Pooling System for performance optimization.
## Implements object pooling for balls to reduce instantiation/destruction overhead.
## Use as autoload "BallPoolV4".

signal ball_activated(ball: RigidBody2D)
signal ball_deactivated(ball: RigidBody2D)
signal pool_expanded(new_size: int)
signal performance_metrics_updated(metrics: Dictionary)

const DEFAULT_POOL_SIZE: int = 5
const EXPANSION_INCREMENT: int = 3
const CONTRACTION_THRESHOLD: int = 10  # Minimum available balls before considering contraction
const MAX_IDLE_BALLS_RATIO: float = 0.7  # If available balls > 70% of total pool, consider contraction

# Performance metrics
var _metrics: Dictionary = {
	"total_balls_created": 0,
	"balls_activated": 0,
	"balls_deactivated": 0,
	"pool_expansions": 0,
	"pool_contractions": 0,
	"instantiation_time_saved_ms": 0.0,
	"average_activation_time_ms": 0.0,
	"peak_pool_size": 0,
	"current_pool_utilization": 0.0,
	"total_reuse_count": 0,
	"reuse_efficiency": 0.0,
	"memory_saved_kb": 0.0
}

# Pool management
var _pool_size: int = DEFAULT_POOL_SIZE
var _available_balls: Array[RigidBody2D] = []
var _active_balls: Array[RigidBody2D] = []
var _ball_scene: PackedScene = null
var _balls_container: Node2D = null

# Singleton instance
static var _instance: BallPoolV4 = null

func _ready() -> void:
	add_to_group("ball_pool_v4")
	add_to_group("ball_pool")
	
	# Singleton pattern
	if _instance == null:
		_instance = self
	else:
		queue_free()
		return

func _process(_delta: float) -> void:
	# Update performance metrics periodically
	_update_performance_metrics()
	
	# Check for pool contraction opportunities
	_check_pool_contraction()

## Initialize the ball pool with a specific scene and container.
## Re-initializes if container was freed (e.g. scene change).
func initialize(ball_scene: PackedScene, container: Node2D, initial_pool_size: int = DEFAULT_POOL_SIZE) -> void:
	# Re-init if container is invalid (scene change freed it) or different
	var container_valid = is_instance_valid(_balls_container) if _balls_container else false
	if _ball_scene != null and container_valid and _balls_container == container:
		return  # Already initialized with same valid container
	
	# Clear stale pool if re-initializing
	if _ball_scene != null:
		_available_balls.clear()
		_active_balls.clear()
	
	_ball_scene = ball_scene
	_balls_container = container
	_pool_size = initial_pool_size
	
	_preallocate_pool()
	
	print("BallPoolV4 initialized with pool size: %d" % _pool_size)

## Get a ball from the pool. Returns null if pool is empty and expansion fails.
func get_ball() -> RigidBody2D:
	if _available_balls.is_empty():
		_expand_pool()
		if _available_balls.is_empty():
			push_error("BallPoolV4: Failed to get ball - pool empty and expansion failed")
			return null
	
	var ball: RigidBody2D = _available_balls.pop_back()
	_active_balls.append(ball)
	
	# Update metrics
	_metrics["balls_activated"] += 1
	
	# Show the ball
	ball.show()
	ball.freeze = false
	
	ball_activated.emit(ball)
	return ball

## Return a ball to the pool for reuse.
func return_ball(ball: RigidBody2D) -> void:
	if not ball:
		return
	if _available_balls.has(ball):
		return  # Already in pool, avoid double-add
	
	if _active_balls.has(ball):
		_active_balls.erase(ball)
	
	# Reset ball state
	_reset_ball_state(ball)
	
	# Hide and freeze the ball
	ball.hide()
	ball.freeze = true
	
	_available_balls.append(ball)
	
	# Update metrics
	_metrics["balls_deactivated"] += 1
	
	ball_deactivated.emit(ball)

## Spawn a ball at a specific position with optional impulse.
func spawn_ball_at_position(position: Vector2, impulse: Vector2 = Vector2.ZERO, freeze: bool = false) -> RigidBody2D:
	var ball: RigidBody2D = get_ball()
	if not ball:
		return null
	
	ball.global_position = position
	
	# Reset ball properties
	if ball.has_method("reset_ball"):
		ball.reset_ball()
	if ball.get("initial_position") != null:
		ball.initial_position = position
	
	# Freeze if requested (e.g., for launcher balls)
	if freeze:
		ball.freeze = true
	
	# Apply impulse if provided
	if impulse != Vector2.ZERO:
		ball.apply_impulse(impulse)
	
	return ball

## Get the number of active balls.
func get_active_ball_count() -> int:
	return _active_balls.size()

## Get the number of available balls in the pool.
func get_available_ball_count() -> int:
	return _available_balls.size()

## Get the total pool size (active + available).
func get_total_pool_size() -> int:
	return _pool_size

## Alias for PerformanceMonitorV4 and other callers expecting get_pool_size.
func get_pool_size() -> int:
	return get_total_pool_size()

## Get performance metrics.
func get_performance_metrics() -> Dictionary:
	return _metrics.duplicate()

## Clear all balls from the pool (for game reset).
func clear_pool() -> void:
	for ball in _active_balls + _available_balls:
		if is_instance_valid(ball):
			ball.queue_free()
	
	_active_balls.clear()
	_available_balls.clear()
	_pool_size = DEFAULT_POOL_SIZE
	_metrics["total_balls_created"] = 0

# Private methods

func _preallocate_pool() -> void:
	for i in range(_pool_size):
		_create_ball_instance()

func _create_ball_instance() -> RigidBody2D:
	if not _ball_scene or not _balls_container:
		push_error("BallPoolV4: Cannot create ball instance - scene or container not set")
		return null
	
	var ball: RigidBody2D = _ball_scene.instantiate()
	_balls_container.add_child(ball)
	
	# Initialize ball in deactivated state
	ball.hide()
	ball.freeze = true
	
	# Connect ball lost signal if available
	if ball.has_signal("ball_lost"):
		ball.ball_lost.connect(_on_ball_lost.bind(ball))
	
	_available_balls.append(ball)
	_metrics["total_balls_created"] += 1
	
	return ball

func _expand_pool() -> void:
	var old_size = _pool_size
	_pool_size += EXPANSION_INCREMENT
	
	for i in range(EXPANSION_INCREMENT):
		_create_ball_instance()
	
	_metrics["pool_expansions"] += 1
	_metrics["peak_pool_size"] = max(_metrics["peak_pool_size"], _pool_size)
	pool_expanded.emit(_pool_size)
	
	print("BallPoolV4: Pool expanded from %d to %d balls" % [old_size, _pool_size])

func _check_pool_contraction() -> void:
	# Only consider contraction if we have enough idle balls
	if _available_balls.size() < CONTRACTION_THRESHOLD:
		return
	
	# Check if idle balls ratio exceeds threshold
	var idle_ratio = float(_available_balls.size()) / float(_pool_size)
	if idle_ratio > MAX_IDLE_BALLS_RATIO and _pool_size > DEFAULT_POOL_SIZE:
		_contract_pool()

func _contract_pool() -> void:
	# Calculate how many balls to remove (up to half of excess idle balls)
	var excess_idle = _available_balls.size() - int(DEFAULT_POOL_SIZE * MAX_IDLE_BALLS_RATIO)
	var balls_to_remove = min(excess_idle, _available_balls.size() - DEFAULT_POOL_SIZE)
	balls_to_remove = max(1, balls_to_remove)  # Remove at least 1 ball
	
	var old_size = _pool_size
	_pool_size -= balls_to_remove
	
	# Remove balls from the end of available balls array
	for i in range(balls_to_remove):
		if _available_balls.is_empty():
			break
		
		var ball = _available_balls.pop_back()
		if is_instance_valid(ball):
			ball.queue_free()
			_metrics["total_balls_created"] = max(0, _metrics["total_balls_created"] - 1)
	
	_metrics["pool_contractions"] += 1
	print("BallPoolV4: Pool contracted from %d to %d balls (removed %d idle balls)" % [old_size, _pool_size, balls_to_remove])

func _reset_ball_state(ball: RigidBody2D) -> void:
	# Reset physics properties
	ball.linear_velocity = Vector2.ZERO
	ball.angular_velocity = 0
	ball.rotation = 0
	
	# Reset ball-specific properties
	if ball.has_method("reset_ball"):
		ball.reset_ball()
	else:
		# Fallback: manually reset has_emitted_lost flag if reset_ball not available
		if ball.get("has_emitted_lost") != null:
			ball.has_emitted_lost = false
	
	# Disconnect and reconnect ball lost signal
	if ball.has_signal("ball_lost"):
		# Disconnect all connections to avoid duplicates
		if ball.ball_lost.is_connected(_on_ball_lost):
			ball.ball_lost.disconnect(_on_ball_lost)
		ball.ball_lost.connect(_on_ball_lost.bind(ball))

func _on_ball_lost(ball: RigidBody2D) -> void:
	# When a ball is lost (e.g., drained), return it to the pool
	return_ball(ball)
	# After returning, check if no active balls remain
	if get_active_ball_count() == 0:
		var gm = get_node_or_null("/root/GameManagerV4")
		if gm and gm.has_method("on_round_lost"):
			# Ensure game is in playing state before calling round lost
			if gm.has_method("get_status") and gm.get_status() == gm.Status.PLAYING:
				gm.on_round_lost()

func _update_performance_metrics() -> void:
	# Calculate estimated time saved (assuming 0.5ms per instantiation)
	var instantiation_time_per_ball_ms = 0.5
	_metrics["instantiation_time_saved_ms"] = _metrics["balls_activated"] * instantiation_time_per_ball_ms
	
	# Calculate pool utilization (active balls / total pool size)
	if _pool_size > 0:
		_metrics["current_pool_utilization"] = float(_active_balls.size()) / float(_pool_size)
	else:
		_metrics["current_pool_utilization"] = 0.0
	
	# Calculate reuse efficiency (balls deactivated / balls activated)
	if _metrics["balls_activated"] > 0:
		_metrics["reuse_efficiency"] = float(_metrics["balls_deactivated"]) / float(_metrics["balls_activated"])
	else:
		_metrics["reuse_efficiency"] = 0.0
	
	# Calculate total reuse count (how many times balls have been reused)
	_metrics["total_reuse_count"] = _metrics["balls_deactivated"]
	
	# Estimate memory saved (assuming 2KB per ball instance saved from GC)
	var memory_saved_per_reuse_kb = 2.0
	_metrics["memory_saved_kb"] = _metrics["total_reuse_count"] * memory_saved_per_reuse_kb
	
	# Emit metrics update signal
	performance_metrics_updated.emit(_metrics.duplicate())

## Static accessor for singleton instance.
static func get_instance() -> BallPoolV4:
	return _instance

## Check if pool is initialized.
func is_initialized() -> bool:
	return _ball_scene != null and _balls_container != null
extends Node
## v4.0 Performance Monitor & Optimizer
## FPS monitoring, performance tips, and auto-optimization

signal fps_updated(fps: float)
signal performance_warning(warning_type: String)
signal optimization_applied(optimization_type: String)

@export var target_fps: int = 60
@export var warning_threshold: int = 30  # FPS below this triggers warning
@export var critical_threshold: int = 20
@export var auto_optimize: bool = true
@export var check_interval: float = 1.0

var _fps_history: Array = []
var _history_size: int = 60
var _check_timer: float = 0.0
var _last_fps: float = 60.0
var _frame_count: int = 0
var _time_accumulator: float = 0.0

var _optimizations_applied: Array = []

func _ready() -> void:
	add_to_group("performance_monitor")
	Engine.framerate = target_fps

func _process(delta: float) -> void:
	_frame_count += 1
	_time_accumulator += delta
	_check_timer += delta
	
	if _check_timer >= check_interval:
		_check_timer = 0.0
		_measure_performance()

func _measure_performance() -> void:
	var current_fps = _frame_count / _time_accumulator if _time_accumulator > 0 else 60.0
	
	_fps_history.append(current_fps)
	if _fps_history.size() > _history_size:
		_fps_history.pop_front()
	
	_frame_count = 0
	_time_accumulator = 0.0
	_last_fps = current_fps
	
	fps_updated.emit(current_fps)
	
	if current_fps < critical_threshold:
		performance_warning.emit("critical_low_fps")
		if auto_optimize:
			_apply_optimizations()
	elif current_fps < warning_threshold:
		performance_warning.emit("low_fps")

func get_average_fps() -> float:
	if _fps_history.is_empty():
		return 60.0
	
	var total = 0.0
	for fps in _fps_history:
		total += fps
	
	return total / _fps_history.size()

func get_min_fps() -> float:
	if _fps_history.is_empty():
		return 60.0
	
	var min_fps = 999.0
	for fps in _fps_history:
		if fps < min_fps:
			min_fps = fps
	
	return min_fps

func get_max_fps() -> float:
	if _fps_history.is_empty():
		return 60.0
	
	var max_fps = 0.0
	for fps in _fps_history:
		if fps > max_fps:
			max_fps = fps
	
	return max_fps

func is_performing_well() -> bool:
	return get_average_fps() >= warning_threshold

func _apply_optimizations() -> void:
	var applied = []
	
	# Reduce particle counts
	var particle_systems = get_tree().get_nodes_in_group("particle_system")
	for ps in particle_systems:
		if ps.has_method("set_quality"):
			ps.set_quality("low")
			applied.append("particle_quality_reduced")
	
	# Reduce visual effects
	var crt_effects = get_tree().get_nodes_in_group("post_processing")
	for crt in crt_effects:
		if crt.has_method("set_enabled"):
			crt.set_enabled(false)
			applied.append("crt_disabled")
	
	# Disable shadows
	var lights = get_tree().get_nodes_in_group("lights")
	for light in lights:
		if light.has_method("set_shadow_enabled"):
			light.set_shadow_enabled(false)
			applied.append("shadows_disabled")
	
	# Reduce physics iterations
	PhysicsServer2D.iterations_per_second = 30
	
	for opt in applied:
		_optimizations_applied.append(opt)
		optimization_applied.emit(opt)
	
	if applied.size() > 0:
		print("Performance: Applied %d optimizations" % applied.size())

func reset_optimizations() -> void:
	# Re-enable CRT
	var crt_effects = get_tree().get_nodes_in_group("post_processing")
	for crt in crt_effects:
		if crt.has_method("set_enabled"):
			crt.set_enabled(true)
	
	# Re-enable shadows
	var lights = get_tree().get_nodes_in_group("lights")
	for light in lights:
		if light.has_method("set_shadow_enabled"):
			light.set_shadow_enabled(true)
	
	# Reset physics
	PhysicsServer2D.iterations_per_second = 60
	
	_optimizations_applied.clear()

func get_optimizations_applied() -> Array:
	return _optimizations_applied

func set_quality_preset(preset: String) -> void:
	match preset:
		"low":
			Engine.framerate = 30
			PhysicsServer2D.iterations_per_second = 30
			_disable_all_effects()
		"medium":
			Engine.framerate = 45
			PhysicsServer2D.iterations_per_second = 45
			_reduce_effects()
		"high":
			Engine.framerate = 60
			PhysicsServer2D.iterations_per_second = 60
			_enable_all_effects()
		"ultra":
			Engine.framerate = 120
			PhysicsServer2D.iterations_per_second = 120
			_enable_all_effects()

func _disable_all_effects() -> void:
	var crt = get_tree().get_first_node_in_group("post_processing")
	if crt and crt.has_method("set_enabled"):
		crt.set_enabled(false)

func _reduce_effects() -> void:
	var crt = get_tree().get_first_node_in_group("post_processing")
	if crt and crt.has_method("set_scanline_intensity"):
		crt.set_scanline_intensity(0.1)
		crt.set_glow_strength(0.2)

func _enable_all_effects() -> void:
	var crt = get_tree().get_first_node_in_group("post_processing")
	if crt and crt.has_method("set_enabled"):
		crt.set_enabled(true)
	if crt and crt.has_method("set_scanline_intensity"):
		crt.set_scanline_intensity(0.3)
		crt.set_glow_strength(0.5)

func get_memory_usage() -> Dictionary:
	var performance = Performance.get_monitor(Performance.MEMORY_STATIC)
	var performance_max = Performance.get_monitor(Performance.MEMORY_STATIC_MAX)
	
	return {
		"static": performance,
		"static_max": performance_max,
		"object_count": Performance.get_monitor(Performance.OBJECT_COUNT),
		"process_time": Performance.get_monitor(Performance.TIME_PROCESS),
		"physics_time": Performance.get_monitor(Performance.TIME_PHYSICS_PROCESS)
	}

func print_performance_report() -> void:
	var avg_fps = get_average_fps()
	var mem = get_memory_usage()
	
	print("=== Performance Report ===")
	print("FPS: %.1f (avg) / %.1f (min) / %.1f (max)" % [avg_fps, get_min_fps(), get_max_fps()])
	print("Memory: %.2f MB (%.2f MB max)" % [mem["static"] / 1048576.0, mem["static_max"] / 1048576.0])
	print("Objects: %d" % mem["object_count"])
	print("Process: %.3f ms" % (mem["process_time"] * 1000))
	print("Physics: %.3f ms" % (mem["physics_time"] * 1000))
	print("Optimizations: %d applied" % _optimizations_applied.size())
	print("==========================")

func get_status() -> Dictionary:
	return {
		"fps": _last_fps,
		"average_fps": get_average_fps(),
		"min_fps": get_min_fps(),
		"max_fps": get_max_fps(),
		"optimizations": _optimizations_applied.size(),
		"is_performing_well": is_performing_well()
	}

func start_benchmark(duration: float = 5.0) -> void:
	_fps_history.clear()
	_frame_count = 0
	_time_accumulator = 0.0
	_check_timer = 0.0
	
	await get_tree().create_timer(duration).timeout
	
	print_performance_report()

# ============================================
# Object Pooling Stats
# ============================================

func get_object_pool_stats() -> Dictionary:
	var stats = {
		"ball_pool": _get_ball_pool_stats()
	}
	return stats

func _get_ball_pool_stats() -> Dictionary:
	var ball_pool = get_tree().get_first_node_in_group("ball_pool")
	if ball_pool:
		return {
			"active": ball_pool.get_active_ball_count() if ball_pool.has_method("get_active_ball_count") else 0,
			"pooled": ball_pool.get_pool_size() if ball_pool.has_method("get_pool_size") else 0
		}
	return {"active": 0, "pooled": 0}

# ============================================
# Static Access
# ============================================

static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("performance_monitor")
	return null

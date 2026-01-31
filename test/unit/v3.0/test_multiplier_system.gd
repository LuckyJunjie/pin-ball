extends GutTest

## v3.0: Dynamic Multiplier System Tests
## Tests multiplier increases, decay, and limits

var multiplier_system: Node

func before_each():
	# Create MultiplierSystem instance
	var script = load("res://scripts/MultiplierSystem.gd")
	multiplier_system = Node.new()
	multiplier_system.set_script(script)
	multiplier_system.increase_per_hits = 5
	multiplier_system.multiplier_increment = 0.5
	multiplier_system.max_multiplier = 10.0
	add_child_autofree(multiplier_system)

func test_multiplier_initialization():
	"""Test multiplier system initializes correctly"""
	assert_not_null(multiplier_system, "MultiplierSystem should exist")
	assert_eq(multiplier_system.current_multiplier, 1.0, "Initial multiplier should be 1.0")

func test_multiplier_increase():
	"""Test multiplier increases with hits"""
	watch_signals(multiplier_system)
	
	# Register 5 hits (should trigger increase)
	for i in range(5):
		multiplier_system.register_hit()
	
	assert_eq(multiplier_system.current_multiplier, 1.5, "Multiplier should increase after 5 hits")
	assert_signal_emitted(multiplier_system, "multiplier_changed", "Should emit multiplier_changed signal")

func test_multiplier_max():
	"""Test multiplier respects max limit"""
	# Set multiplier near max
	multiplier_system.current_multiplier = 9.5
	
	# Try to increase beyond max
	for i in range(5):
		multiplier_system.register_hit()
	
	assert_le(multiplier_system.current_multiplier, 10.0, "Multiplier should not exceed max")

func test_multiplier_decay():
	"""Test multiplier decays after inactivity"""
	multiplier_system.current_multiplier = 2.0
	multiplier_system.decay_timer = 0.0
	multiplier_system._process(0.016)
	
	assert_lt(multiplier_system.current_multiplier, 2.0, "Multiplier should decay after timer expires")

func test_multiplier_reset():
	"""Test multiplier reset"""
	multiplier_system.current_multiplier = 5.0
	multiplier_system.hit_count = 20
	multiplier_system.reset()
	
	assert_eq(multiplier_system.current_multiplier, 1.0, "Multiplier should reset to 1.0")
	assert_eq(multiplier_system.hit_count, 0, "Hit count should reset to 0")

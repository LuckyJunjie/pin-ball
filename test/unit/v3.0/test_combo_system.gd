extends GutTest

## v3.0: Combo System Tests
## Tests combo tracking, multipliers, and timing

var combo_system: Node

func before_each():
	# Create ComboSystem instance
	var script = load("res://scripts/ComboSystem.gd")
	combo_system = Node.new()
	combo_system.set_script(script)
	combo_system.combo_window = 3.0
	add_child_autofree(combo_system)

func test_combo_initialization():
	"""Test combo system initializes correctly"""
	assert_not_null(combo_system, "ComboSystem should exist")
	assert_eq(combo_system.current_combo, 0, "Initial combo should be 0")
	assert_false(combo_system.is_combo_active, "Combo should start inactive")

func test_combo_start():
	"""Test combo starts on first hit"""
	watch_signals(combo_system)
	
	combo_system.register_hit()
	
	assert_true(combo_system.is_combo_active, "Combo should be active after first hit")
	assert_eq(combo_system.current_combo, 1, "Combo count should be 1")
	assert_signal_emitted(combo_system, "combo_started", "Should emit combo_started signal")

func test_combo_increase():
	"""Test combo increases with multiple hits"""
	combo_system.register_hit()
	combo_system.register_hit()
	combo_system.register_hit()
	
	assert_eq(combo_system.current_combo, 3, "Combo should increase with hits")

func test_combo_multiplier():
	"""Test combo multiplier calculation"""
	combo_system.register_hit()
	combo_system.register_hit()
	combo_system.register_hit()
	
	var multiplier = combo_system.get_combo_multiplier()
	
	assert_gt(multiplier, 1.0, "Combo multiplier should be > 1.0")
	assert_le(multiplier, 3.0, "Combo multiplier should not exceed max")

func test_combo_timeout():
	"""Test combo ends after timeout"""
	combo_system.register_hit()
	combo_system.combo_timer = 0.0
	combo_system._process(0.016)
	
	assert_false(combo_system.is_combo_active, "Combo should end after timeout")
	assert_eq(combo_system.current_combo, 0, "Combo count should reset")

func test_combo_max():
	"""Test combo max cap"""
	# Register many hits
	for i in range(25):
		combo_system.register_hit()
	
	assert_le(combo_system.current_combo, combo_system.max_combo, "Combo should not exceed max")

extends GutTest

## v2.0: Currency System Tests
## Tests coin and gem management

var currency_manager: Node

func before_each():
	# Create CurrencyManager instance
	var script = load("res://scripts/CurrencyManager.gd")
	currency_manager = Node.new()
	currency_manager.set_script(script)
	add_child_autofree(currency_manager)

func test_currency_initialization():
	"""Test currency manager initializes with zero currency"""
	assert_eq(currency_manager.get_coins(), 0, "Initial coins should be 0")
	assert_eq(currency_manager.get_gems(), 0, "Initial gems should be 0")

func test_add_coins():
	"""Test adding coins"""
	watch_signals(currency_manager)
	
	currency_manager.add_coins(100)
	
	assert_eq(currency_manager.get_coins(), 100, "Coins should increase")
	assert_signal_emitted(currency_manager, "currency_changed", "Should emit currency_changed signal")

func test_spend_coins():
	"""Test spending coins"""
	currency_manager.add_coins(200)
	
	var success = currency_manager.spend_coins(50)
	
	assert_true(success, "Should successfully spend coins")
	assert_eq(currency_manager.get_coins(), 150, "Coins should decrease")
	
	# Try to spend more than available
	success = currency_manager.spend_coins(200)
	assert_false(success, "Should fail to spend more than available")
	assert_eq(currency_manager.get_coins(), 150, "Coins should not change on failed spend")

func test_add_gems():
	"""Test adding gems"""
	currency_manager.add_gems(50)
	
	assert_eq(currency_manager.get_gems(), 50, "Gems should increase")

func test_spend_gems():
	"""Test spending gems"""
	currency_manager.add_gems(100)
	
	var success = currency_manager.spend_gems(30)
	
	assert_true(success, "Should successfully spend gems")
	assert_eq(currency_manager.get_gems(), 70, "Gems should decrease")

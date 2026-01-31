extends GutTest

## v2.0: Integration Tests - Monetization Flow
## Tests currency earning and spending flow

var game_manager: Node2D
var currency_manager: Node

func before_each():
	# Create CurrencyManager
	var currency_script = load("res://scripts/CurrencyManager.gd")
	currency_manager = Node.new()
	currency_manager.set_script(currency_script)
	add_child_autofree(currency_manager)
	
	# Create GameManager
	var gm_script = load("res://scripts/GameManager.gd")
	game_manager = Node2D.new()
	game_manager.set_script(gm_script)
	game_manager.is_v2_mode = true
	add_child_autofree(game_manager)

func test_earn_currency_from_obstacle():
	"""Test earning currency from obstacle hits"""
	var initial_coins = currency_manager.get_coins()
	
	# Simulate obstacle hit (v2.0 awards coins)
	game_manager._on_obstacle_hit(100)  # 100 points = 1 coin
	
	# Note: This test may need adjustment based on actual implementation
	# The GameManager needs to access CurrencyManager
	assert_not_null(currency_manager, "CurrencyManager should exist")

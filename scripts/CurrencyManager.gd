extends Node

## Currency manager singleton (Autoload)
## Manages coins and gems currency system

signal currency_changed(coins: int, gems: int)
signal coins_changed(new_amount: int)
signal gems_changed(new_amount: int)

var coins: int = 0
var gems: int = 0
var coins_earned_session: int = 0
var gems_earned_session: int = 0

func _ready():
	# Load currency from SaveManager if available
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		var loaded_data = save_mgr.load_currency()
		coins = loaded_data.get("coins", 0)
		gems = loaded_data.get("gems", 0)
		print("[CurrencyManager] Loaded currency - Coins: ", coins, ", Gems: ", gems)

func add_coins(amount: int):
	"""Add coins to balance"""
	coins += amount
	coins_earned_session += amount
	print("[CurrencyManager] Added ", amount, " coins. Total: ", coins)
	currency_changed.emit(coins, gems)
	coins_changed.emit(coins)
	
	# Save currency
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.save_currency(coins, gems)

func add_gems(amount: int):
	"""Add gems to balance"""
	gems += amount
	gems_earned_session += amount
	print("[CurrencyManager] Added ", amount, " gems. Total: ", gems)
	currency_changed.emit(coins, gems)
	gems_changed.emit(gems)
	
	# Save currency
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.save_currency(coins, gems)

func spend_coins(amount: int) -> bool:
	"""Attempt to spend coins, return true if successful"""
	if can_afford_coins(amount):
		coins -= amount
		print("[CurrencyManager] Spent ", amount, " coins. Remaining: ", coins)
		currency_changed.emit(coins, gems)
		coins_changed.emit(coins)
		
		# Save currency
		if SaveManager:
			SaveManager.save_currency(coins, gems)
		return true
	return false

func spend_gems(amount: int) -> bool:
	"""Attempt to spend gems, return true if successful"""
	if can_afford_gems(amount):
		gems -= amount
		print("[CurrencyManager] Spent ", amount, " gems. Remaining: ", gems)
		currency_changed.emit(coins, gems)
		gems_changed.emit(gems)
		
		# Save currency
		if SaveManager:
			SaveManager.save_currency(coins, gems)
		return true
	return false

func can_afford_coins(amount: int) -> bool:
	"""Check if player can afford coins"""
	return coins >= amount

func can_afford_gems(amount: int) -> bool:
	"""Check if player can afford gems"""
	return gems >= amount

func get_coins() -> int:
	"""Get current coin balance"""
	return coins

func get_gems() -> int:
	"""Get current gem balance"""
	return gems

func reset_session_earnings():
	"""Reset session earnings counter"""
	coins_earned_session = 0
	gems_earned_session = 0

func save_currency():
	"""Save currency to SaveManager"""
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		save_mgr.save_currency(coins, gems)

func load_currency():
	"""Load currency from SaveManager"""
	var save_mgr = get_node_or_null("/root/SaveManager")
	if save_mgr:
		var loaded_data = save_mgr.load_currency()
		coins = loaded_data.get("coins", 0)
		gems = loaded_data.get("gems", 0)

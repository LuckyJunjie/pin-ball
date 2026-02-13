extends CanvasLayer
## v4.0 Ad Watch UI
## Popup UI for watching ads to get rewards

signal ad_watched(reward_type: String, success: bool)

@onready var panel = $Panel
@onready var reward_icon = $Panel/VBox/RewardIcon
@onready var reward_name = $Panel/VBox/RewardName
@onready var description = $Panel/VBox/Description
@onready var countdown = $Panel/VBox/Countdown
@onready var watch_btn = $Panel/VBox/WatchButton
@onready var close_btn = $Panel/VBox/CloseButton

var _reward_type: String = ""
var _reward_value: Variant = null
var _ad_system: Node = null
var _countdown: int = 30

func _ready() -> void:
	_ad_system = get_tree().get_first_node_in_group("ad_system")
	
	watch_btn.pressed.connect(_on_watch)
	close_btn.pressed.connect(_on_close)
	
	# Start countdown
	_start_countdown()

func setup(reward_data: Dictionary) -> void:
	_reward_type = reward_data.get("reward_type", "")
	_reward_value = reward_data.get("reward_value", null)
	
	reward_icon.text = reward_data.get("icon", "🎁")
	reward_name.text = reward_data.get("name", "Reward")
	description.text = reward_data.get("description", "Watch an ad to get this reward!")
	
	visible = true

func _start_countdown() -> void:
	_countdown = 30
	_update_countdown()
	
	var timer = get_tree().create_timer(1.0)
	timer.timeout.connect(_on_countdown_tick)
	wait_for_countdown()

func _update_countdown() -> void:
	countdown.text = "Loading in %d seconds..." % _countdown

func wait_for_countdown() -> void:
	# This will be called by timer
	pass

func _on_countdown_tick() -> void:
	_countdown -= 1
	_update_countdown()
	
	if _countdown <= 0:
		watch_btn.disabled = false
		watch_btn.text = "▶️ Watch Ad"
		countdown.text = "Ad Ready!"
	else:
		watch_btn.disabled = true
		watch_btn.text = "⏳ %d" % _countdown
		
		var timer = get_tree().create_timer(1.0)
		timer.timeout.connect(_on_countdown_tick)

func _on_watch() -> void:
	if _ad_system:
		_ad_system.show_rewarded_ad(_reward_type, _on_ad_complete)
	
	visible = false

func _on_ad_complete(success: bool, reward_data: Dictionary) -> void:
	if success:
		ad_watched.emit(_reward_type, true)
		# Show success message
		_show_success()
	else:
		ad_watched.emit(_reward_type, false)
		visible = false

func _show_success() -> void:
	var success_panel = Panel.new()
	success_panel.name = "SuccessPanel"
	success_panel.anchor_left = 0.35
	success_panel.anchor_top = 0.35
	success_panel.anchor_right = 0.65
	success_panel.anchor_bottom = 0.65
	
	var label = Label.new()
	label.text = "🎉\n\nReward Granted!"
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	success_panel.add_child(label)
	
	get_tree().get_root().add_child(success_panel)
	
	await get_tree().create_timer(2.0).timeout
	success_panel.queue_free()

func _on_close() -> void:
	visible = false
	ad_watched.emit(_reward_type, false)

func show_for_reward(reward_id: String) -> void:
	var ad_system = get_tree().get_first_node_in_group("ad_system")
	if ad_system:
		var reward_info = ad_system.get_reward_info(reward_id)
		if not reward_info.is_empty():
			setup(reward_info)

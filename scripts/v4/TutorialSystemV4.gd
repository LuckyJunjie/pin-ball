extends Node
## v4.0 Tutorial System
## Step-by-step tutorial for new players

signal tutorial_step_completed(step_id: String)
signal tutorial_completed()
signal tutorial_skipped(step_id: String)

enum TutorialState { NOT_STARTED, IN_PROGRESS, COMPLETED, SKIPPED }

var _state: TutorialState = TutorialState.NOT_STARTED
var _current_step: int = 0
var _steps: Array = []
var _tutorial_active: bool = false

func _ready() -> void:
	add_to_group("tutorial_system")
	_setup_steps()

func _setup_steps() -> void:
	_steps = [
		{
			"id": "welcome",
			"title": "Welcome!",
			"message": "Welcome to Pinball! Let's learn how to play.",
			"highlight": "",
			"action": "next",
			"duration": 0
		},
		{
			"id": "flippers",
			"title": "Flippers",
			"message": "Use LEFT and RIGHT arrow keys to control the flippers.\n\nLeft flipper ← A key\nRight flipper → D key",
			"highlight": "flippers",
			"action": "wait_for_input",
			"input_action": "flipper_left",
			"duration": 0
		},
		{
			"id": "launch",
			"title": "Launch Ball",
			"message": "Press SPACE or DOWN arrow to launch the ball!\n\nWatch the power meter for best results.",
			"highlight": "launcher",
			"action": "wait_for_input",
			"input_action": "launch_ball",
			"duration": 0
		},
		{
			"id": "scoring",
			"title": "Scoring",
			"message": "Hit bumpers, ramps, and targets to score points!\n\nEach zone has different bonuses...",
			"highlight": "score",
			"action": "next",
			"duration": 5
		},
		{
			"id": "multiplier",
			"title": "Multiplier",
			"message": "Hit ramps to increase your multiplier!\n\nEvery 5 ramp hits = +1x (up to 6x)\n\nHigher multiplier = more points!",
			"highlight": "multiplier",
			"action": "next",
			"duration": 5
		},
		{
			"id": "zones",
			"title": "Zones",
			"message": "There are 5 zones:\n• Android Acres\n• Google Gallery\n• Flutter Forest\n• Dino Desert\n• Sparky Scorch",
			"highlight": "",
			"action": "next",
			"duration": 5
		},
		{
			"id": "bonuses",
			"title": "Bonuses",
			"message": "Complete zone objectives for bonus balls and points!\n\nWatch for special targets...",
			"highlight": "",
			"action": "next",
			"duration": 5
		},
		{
			"id": "ready",
			"title": "Ready to Play!",
			"message": "You're all set!\n\n• Hit targets to score\n• Build up your multiplier\n• Earn bonus balls\n• Get the highest score!",
			"highlight": "",
			"action": "complete",
			"duration": 0
		}
	]

func start_tutorial() -> void:
	if _state == TutorialState.IN_PROGRESS:
		return
	
	_state = TutorialState.IN_PROGRESS
	_current_step = 0
	_tutorial_active = true
	
	_show_current_step()
	tutorial_step_completed.emit("start")

func skip_tutorial() -> void:
	if _state != TutorialState.IN_PROGRESS:
		return
	
	_state = TutorialState.SKIPPED
	_tutorial_active = false
	
	_skip_all_ui_elements()
	tutorial_skipped.emit("user_request")

func complete_tutorial() -> void:
	_state = TutorialState.COMPLETED
	_tutorial_active = false
	
	_hide_all_ui_elements()
	tutorial_completed.emit()
	
	# Save tutorial completion
	_save_tutorial_completed()

func _show_current_step() -> void:
	if _current_step >= _steps.size():
		complete_tutorial()
		return
	
	var step = _steps[_current_step]
	_create_tutorial_ui(step)

func _create_tutorial_ui(step: Dictionary) -> void:
	# Remove existing tutorial UI
	_hide_all_ui_elements()
	
	# Create panel
	var panel = Panel.new()
	panel.name = "TutorialPanel"
	panel.anchor_left = 0.5
	panel.anchor_top = 0.5
	panel.offset_left = -200
	panel.offset_top = -150
	panel.offset_right = 200
	panel.offset_bottom = 150
	panel.z_index = 1000
	
	# Title
	var title = Label.new()
	title.name = "Title"
	title.text = step["title"]
	title.anchor_left = 0.1
	title.anchor_right = 0.9
	title.anchor_top = 0.05
	title.anchor_bottom = 0.2
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", 24)
	title.add_theme_color_override("font_color", Color(1, 0.8, 0))  # Gold
	panel.add_child(title)
	
	# Message
	var message = Label.new()
	message.name = "Message"
	message.text = step["message"]
	message.anchor_left = 0.1
	message.anchor_right = 0.9
	message.anchor_top = 0.25
	message.anchor_bottom = 0.75
	message.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	message.autowrap_mode = TextServer.AUTOWRAP_WORD
	panel.add_child(message)
	
	# Skip button
	var skip_btn = Button.new()
	skip_btn.name = "SkipButton"
	skip_btn.text = "Skip Tutorial"
	skip_btn.anchor_left = 0.3
	skip_btn.anchor_top = 0.85
	skip_btn.anchor_right = 0.7
	skip_btn.anchor_bottom = 0.95
	skip_btn.pressed.connect(skip_tutorial)
	panel.add_child(skip_btn)
	
	# Add to scene
	var main_scene = _get_main_scene()
	if main_scene:
		main_scene.add_child(panel)
	
	# Handle different action types
	match step["action"]:
		"next":
			await get_tree().create_timer(step.get("duration", 3.0)).timeout
			_current_step += 1
			_show_current_step()
		
		"wait_for_input":
			# Will continue when input is detected
			pass
		
		"complete":
			await get_tree().create_timer(3.0).timeout
			complete_tutorial()

func _hide_all_ui_elements() -> void:
	var main_scene = _get_main_scene()
	if main_scene:
		var existing = main_scene.get_node_or_null("TutorialPanel")
		if existing:
			existing.queue_free()
		
		var existing_overlay = main_scene.get_node_or_null("TutorialHighlight")
		if existing_overlay:
			existing_overlay.queue_free()

func _skip_all_ui_elements() -> void:
	_hide_all_ui_elements()

func _get_main_scene() -> Node:
	var tree = get_tree()
	if tree:
		var root = tree.get_root()
		if root:
			return root.get_child(0)  # Main scene is usually first child
	return null

func _save_tutorial_completed() -> void:
	var save_path = "user://saves/tutorial_completed.txt"
	var file = FileAccess.open(save_path, FileAccess.WRITE)
	file.store_string(str(Time.get_unix_time_from_system()))
	file.close()

func has_completed_tutorial() -> bool:
	var save_path = "user://saves/tutorial_completed.txt"
	return FileAccess.file_exists(save_path)

func is_tutorial_active() -> bool:
	return _tutorial_active

func get_current_step() -> Dictionary:
	if _current_step < _steps.size():
		return _steps[_current_step]
	return {}

func get_progress() -> float:
	return float(_current_step) / float(_steps.size())

func jump_to_step(step_id: String) -> void:
	for i in range(_steps.size()):
		if _steps[i]["id"] == step_id:
			_current_step = i
			_show_current_step()
			return

func _input(event: InputEvent) -> void:
	if not _tutorial_active:
		return
	
	var current_step_data = get_current_step()
	if current_step_data.is_empty():
		return
	
	if current_step_data.get("action") == "wait_for_input":
		var input_action = current_step_data.get("input_action", "")
		if input_action != "" and event.is_action_pressed(input_action):
			_current_step += 1
			_show_current_step()
			tutorial_step_completed.emit(current_step_data["id"])

# ============================================
# Tutorial Prompts (in-game hints)
# ============================================

func show_prompt(prompt_id: String, duration: float = 5.0) -> void:
	var prompts = {
		"flipper_hint": "💡 Tip: Use A and D keys for flippers!",
		"launch_hint": "💡 Tip: Hold SPACE for more power!",
		"multiplier_hint": "💡 Tip: Hit ramps to increase multiplier!",
		"bonus_hint": "💡 Tip: Complete zones for bonus balls!",
		"combo_hint": "💡 Tip: Keep hitting for combo bonus!"
	}
	
	var message = prompts.get(prompt_id, "")
	if message == "":
		return
	
	_show_toast(message, duration)

func _show_toast(message: String, duration: float) -> void:
	var label = Label.new()
	label.text = message
	label.anchor_top = 1.0
	label.anchor_bottom = 1.0
	label.offset_top = -80
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	var main_scene = _get_main_scene()
	if main_scene:
		main_scene.add_child(label)
		await get_tree().create_timer(duration).timeout
		label.queue_free()

# ============================================
# Static Access
# ============================================

static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("tutorial_system")
	return null

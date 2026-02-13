extends CanvasLayer
## v4.0 Achievement UI
## Displays achievement notifications and achievement list

var achievement_system: Node = null
var _notification_timer: float = 0.0
var _notification_display_time: float = 3.0

@onready var panel = $Panel
@onready var progress_label = $Panel/VBox/ProgressLabel
@onready var achievement_list = $Panel/VBox/ScrollContainer/AchievementList
@onready var close_button = $Panel/CloseButton
@onready var notification_panel = $UnlockNotification
@onready var notification_name = $UnlockNotification/VBox/AchievementName
@onready var notification_points = $UnlockNotification/VBox/Points

func _ready() -> void:
	close_button.pressed.connect(_on_close)
	
	achievement_system = AchievementSystemV4.get_instance()
	if achievement_system:
		achievement_system.achievement_unlocked.connect(_on_achievement_unlocked)
	
	_update_progress_display()

func _process(delta: float) -> void:
	if _notification_timer > 0:
		_notification_timer -= delta
		if _notification_timer <= 0:
			notification_panel.visible = false

func _on_achievement_unlocked(ach_id: String, ach_name: String) -> void:
	_show_notification(ach_name)
	_update_progress_display()

func _show_notification(name: String) -> void:
	notification_name.text = name
	notification_points.text = "+%d points" % _get_achievement_points(name)
	notification_panel.visible = true
	_notification_timer = _notification_display_time
	
	# Animate in
	var tween = create_tween()
	tween.tween_property(notification_panel, "position:y", 100, 0.3).set_trans(Tween.TRANS_BOUNCE)

func _get_achievement_points(name: String) -> int:
	var achievements = AchievementSystemV4.get_instance()
	if achievements:
		var all_achs = achievements.get_all_achievements()
		for ach in all_achs:
			if ach["name"] == name:
				return ach["points"]
	return 0

func _update_progress_display() -> void:
	var unlocked = AchievementSystemV4.get_instance().get_unlocked_count()
	var total = AchievementSystemV4.get_instance().get_total_count()
	progress_label.text = "%d / %d Unlocked (%d%%)" % [unlocked, total, int((float(unlocked) / total) * 100)]
	
	# Rebuild list
	_rebuild_achievement_list()

func _rebuild_achievement_list() -> void:
	# Clear existing items
	for child in achievement_list.get_children():
		child.queue_free()
	
	var achievements = AchievementSystemV4.get_instance()
	if not achievements:
		return
	
	var all_achs = achievements.get_all_achievements()
	
	for ach in all_achs:
		var item = _create_achievement_item(ach)
		achievement_list.add_child(item)

func _create_achievement_item(ach: Dictionary) -> Control:
	var container = HBoxContainer.new()
	container.add_theme_constant_override("separation", 10)
	
	# Status icon
	var icon = ColorRect.new()
	icon.custom_minimum_size = Vector2(20, 20)
	if ach["unlocked"]:
		icon.color = Color(0.2, 1.0, 0.4)  # Green for unlocked
	else:
		icon.color = Color(0.4, 0.4, 0.4)  # Gray for locked
	container.add_child(icon)
	
	# Name
	var name_label = Label.new()
	name_label.text = ach["name"]
	name_label.add_theme_color_override("font_color", Color.WHITE if ach["unlocked"] else Color(0.6, 0.6, 0.6))
	container.add_child(name_label)
	
	# Points
	var points_label = Label.new()
	points_label.text = "[%d]" % ach["points"]
	points_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	container.add_child(points_label)
	
	# Click to show details (optional)
	var panel_rect = Panel.new()
	panel_rect.custom_minimum_size = Vector2(380, 40)
	panel_rect.add_child(container)
	
	# Wrap in container for proper sizing
	var wrapper = Control.new()
	wrapper.custom_minimum_size = Vector2(0, 45)
	panel_rect.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	container.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	panel_rect.add_child(container)
	wrapper.add_child(panel_rect)
	
	return wrapper

func toggle_visibility() -> void:
	visible = not visible
	if visible:
		_update_progress_display()

func _on_close() -> void:
	visible = false

func show_notification_only(name: String) -> void:
	_show_notification(name)

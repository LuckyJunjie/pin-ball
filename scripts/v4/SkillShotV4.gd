extends Area2D
## v4.0 Skill shot: 1M points when ball enters.

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not (body is RigidBody2D and body.is_in_group("balls")):
		return
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm and gm.has_method("add_score"):
		gm.add_score(1000000)
	var sm = get_tree().get_first_node_in_group("sound_manager")
	if sm and sm.has_method("play_sound"):
		sm.play_sound("obstacle_hit")

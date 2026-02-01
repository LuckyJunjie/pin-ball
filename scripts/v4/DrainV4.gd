extends Area2D
## v4.0 Drain: on ball contact remove ball; if no balls left call GameManagerV4.on_round_lost().

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not (body is RigidBody2D and body.is_in_group("balls")):
		return
	var gm = get_node_or_null("/root/GameManagerV4")
	var was_last_ball: bool = false
	if gm and gm.has_method("get_ball_count"):
		was_last_ball = (gm.get_ball_count() == 1)
	body.queue_free()
	if was_last_ball and gm and gm.has_method("on_round_lost"):
		gm.on_round_lost()

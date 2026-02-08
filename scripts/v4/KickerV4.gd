extends Area2D
## Kicker - 5000 points per Flutter parity.

signal obstacle_hit(points: int)

func _ready() -> void:
	body_entered.connect(_on_body_entered)
	add_to_group("obstacles")

func _on_body_entered(body: Node2D) -> void:
	if not (body is RigidBody2D and body.is_in_group("balls")):
		return
	obstacle_hit.emit(5000)

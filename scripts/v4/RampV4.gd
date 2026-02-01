extends Area2D
## v4.0 Ramp (SpaceshipRamp equivalent). Every 5 ball entries → GameManagerV4.increase_multiplier().
## Flutter: RampMultiplierBehavior in android_acres.

var hit_count: int = 0

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if not body.is_in_group("balls"):
		return
	hit_count += 1
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm:
		if gm.has_method("add_score"):
			gm.add_score(5000)  # Flutter RampShotBehavior 5k
		if hit_count % 5 == 0 and gm.has_method("increase_multiplier"):
			gm.increase_multiplier()

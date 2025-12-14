extends CanvasLayer

## UI script for score display and game information

@onready var score_label: Label = $ScoreLabel

func _ready():
	# Find GameManager and connect score signal
	var game_manager = get_tree().get_first_node_in_group("game_manager")
	if not game_manager:
		# Try to find it in the scene tree
		game_manager = get_node("../GameManager")
	
	if game_manager:
		game_manager.score_changed.connect(_on_score_changed)

func _on_score_changed(new_score: int):
	"""Update score label when score changes"""
	if score_label:
		score_label.text = "Score: " + str(new_score)

func set_score_text(score: int):
	"""Set score text (for direct connection)"""
	_on_score_changed(score)

extends CanvasLayer
## v4.0 UI: Flutter-style backbox - score/Ball Ct; Game Over text when game over; backbox content (leaderboard/initials/game over info); Replay after initials.

var score_value_label: Label = null
var score_column: Control = null
var ball_ct_column: Control = null
var round_indicators: Array[ColorRect] = []
var game_over_panel: Control = null
var backbox_leaderboard: Control = null
var backbox_initials: Control = null
var backbox_game_over_info: Control = null
var initials_letter1: OptionButton = null
var initials_letter2: OptionButton = null
var initials_letter3: OptionButton = null
var initials_submit_btn: BaseButton = null
var multiplier_label: Label = null
var initials_character_icon: TextureRect = null  # C.5: character icon in initials panel

const ROUND_LIT := Color(1.0, 0.9, 0.2, 1.0)
const ROUND_DIM := Color(0.4, 0.4, 0.4, 1.0)
const LETTERS := "ABCDEFGHIJKLMNOPQRSTUVWXYZ"

func _ready() -> void:
	score_value_label = get_node_or_null("ScorePanel/HBox/ScoreColumn/ScoreValue")
	score_column = get_node_or_null("ScorePanel/HBox/ScoreColumn")
	ball_ct_column = get_node_or_null("ScorePanel/HBox/BallCtColumn")
	var indicators_node = get_node_or_null("ScorePanel/HBox/BallCtColumn/RoundIndicators")
	if indicators_node:
		for i in range(1, 4):
			var r = indicators_node.get_node_or_null("Round" + str(i))
			if r is ColorRect:
				round_indicators.append(r)
	game_over_panel = get_node_or_null("GameOverPanel")
	backbox_leaderboard = get_node_or_null("Backbox/BackboxContent/LeaderboardPanel")
	backbox_initials = get_node_or_null("Backbox/BackboxContent/InitialsPanel")
	backbox_game_over_info = get_node_or_null("Backbox/BackboxContent/GameOverInfoPanel")
	initials_letter1 = get_node_or_null("Backbox/BackboxContent/InitialsPanel/VBox/Letters/HBox/Letter1")
	initials_letter2 = get_node_or_null("Backbox/BackboxContent/InitialsPanel/VBox/Letters/HBox/Letter2")
	initials_letter3 = get_node_or_null("Backbox/BackboxContent/InitialsPanel/VBox/Letters/HBox/Letter3")
	initials_submit_btn = get_node_or_null("Backbox/BackboxContent/InitialsPanel/VBox/SubmitButton")
	multiplier_label = get_node_or_null("MultiplierLabel")
	var initials_vbox = get_node_or_null("Backbox/BackboxContent/InitialsPanel/VBox")
	if initials_vbox and not initials_vbox.get_node_or_null("CharacterIcon"):
		var icon = TextureRect.new()
		icon.name = "CharacterIcon"
		icon.custom_minimum_size = Vector2(32, 32)
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		initials_vbox.add_child(icon)
		initials_vbox.move_child(icon, 0)
	initials_character_icon = get_node_or_null("Backbox/BackboxContent/InitialsPanel/VBox/CharacterIcon") as TextureRect
	var gm = get_node_or_null("/root/GameManagerV4")
	if gm:
		gm.scored.connect(_on_scored)
		gm.round_lost.connect(_update_all)
		gm.multiplier_increased.connect(_update_all)
		gm.game_started.connect(_update_all)
		gm.game_over.connect(_on_game_over)
	var backbox = get_node_or_null("/root/BackboxManagerV4")
	if backbox:
		backbox.state_changed.connect(_on_backbox_state_changed)
	if game_over_panel:
		game_over_panel.visible = false
		var replay_btn = game_over_panel.get_node_or_null("VBox/ReplayButton")
		if replay_btn and replay_btn is BaseButton:
			replay_btn.pressed.connect(_on_replay)
	_setup_initials_letters()
	_update_backbox_visibility()
	_update_all()

func _setup_initials_letters() -> void:
	for i in range(26):
		var c := LETTERS.substr(i, 1)
		if initials_letter1 is OptionButton:
			initials_letter1.add_item(c, i)
		if initials_letter2 is OptionButton:
			initials_letter2.add_item(c, i)
		if initials_letter3 is OptionButton:
			initials_letter3.add_item(c, i)
	if initials_submit_btn:
		initials_submit_btn.pressed.connect(_on_initials_submit)

func _on_scored(_points: int) -> void:
	_update_all()

func _update_all() -> void:
	var gm = get_node_or_null("/root/GameManagerV4")
	if not gm:
		return
	var is_game_over: bool = (gm.status == GameManagerV4.Status.GAME_OVER)
	# Flutter ScoreView: when game over show "Game Over" instead of score + Ball Ct
	if score_value_label:
		score_value_label.text = "Game Over" if is_game_over else str(gm.display_score())
	if score_column:
		score_column.visible = true
	if ball_ct_column:
		ball_ct_column.visible = not is_game_over
	for i in range(round_indicators.size()):
		if round_indicators[i]:
			round_indicators[i].color = ROUND_LIT if gm.rounds >= (i + 1) else ROUND_DIM
	if multiplier_label:
		multiplier_label.text = "Multiplier: %dx" % gm.multiplier
		multiplier_label.visible = (gm.status == GameManagerV4.Status.PLAYING)

func _on_game_over() -> void:
	_update_all()
	_update_backbox_visibility()
	# Game Over panel (Replay) only after initials submitted (Flutter: GameOverInfoDisplay)
	# So don't show game_over_panel here; show when BackboxManagerV4 is INITIALS_SUCCESS

func _on_backbox_state_changed(_new_state: int, _data: Variant) -> void:
	_update_backbox_visibility()
	var backbox = get_node_or_null("/root/BackboxManagerV4")
	if backbox and backbox.current_state == BackboxManagerV4.State.INITIALS_SUCCESS:
		if game_over_panel:
			var final_label = game_over_panel.get_node_or_null("VBox/FinalScoreLabel")
			if final_label:
				final_label.text = "Final Score: %d" % backbox.initials_score
			game_over_panel.visible = true

func _update_backbox_visibility() -> void:
	var backbox = get_node_or_null("/root/BackboxManagerV4")
	if not backbox:
		return
	# Leaderboard panel: show for success, loading, or failure (C.1)
	if backbox_leaderboard:
		var show_leaderboard = backbox.current_state in [
			BackboxManagerV4.State.LEADERBOARD_SUCCESS,
			BackboxManagerV4.State.LOADING,
			BackboxManagerV4.State.LEADERBOARD_FAILURE
		]
		backbox_leaderboard.visible = show_leaderboard
		if show_leaderboard:
			var list_label = get_node_or_null("Backbox/BackboxContent/LeaderboardPanel/VBox/List")
			if list_label is Label:
				if backbox.current_state == BackboxManagerV4.State.LOADING:
					list_label.text = "Loading..."
				elif backbox.current_state == BackboxManagerV4.State.LEADERBOARD_FAILURE:
					list_label.text = "Failed to load leaderboard."
				else:
					var lines: PackedStringArray = []
					var rank := 1
					for e in backbox.leaderboard_entries:
						var r := "1st" if rank == 1 else ("2nd" if rank == 2 else ("3rd" if rank == 3 else str(rank) + "th"))
						lines.append("%s  %s  %s" % [r, _format_score(e.get("score", 0)), e.get("initials", "")])
						rank += 1
					list_label.text = "\n".join(lines)
	if backbox_initials:
		backbox_initials.visible = (backbox.current_state == BackboxManagerV4.State.INITIALS_FORM or backbox.current_state == BackboxManagerV4.State.INITIALS_FAILURE)
		if backbox.current_state == BackboxManagerV4.State.INITIALS_FORM or backbox.current_state == BackboxManagerV4.State.INITIALS_FAILURE:
			var score_lbl = get_node_or_null("Backbox/BackboxContent/InitialsPanel/VBox/ScoreValue")
			if score_lbl is Label:
				score_lbl.text = _format_score(backbox.initials_score)
			# C.5: Show character icon in initials panel
			if initials_character_icon and CharacterThemeManagerV4:
				var tex = CharacterThemeManagerV4.get_theme_asset("leaderboard_icon")
				if tex:
					initials_character_icon.texture = tex
					initials_character_icon.visible = true
				else:
					initials_character_icon.visible = false
	if backbox_game_over_info:
		backbox_game_over_info.visible = (backbox.current_state == BackboxManagerV4.State.INITIALS_SUCCESS)

func _on_initials_submit() -> void:
	var backbox = get_node_or_null("/root/BackboxManagerV4")
	if not backbox:
		return
	var idx1 := initials_letter1.selected if initials_letter1 is OptionButton else 0
	var idx2 := initials_letter2.selected if initials_letter2 is OptionButton else 0
	var idx3 := initials_letter3.selected if initials_letter3 is OptionButton else 0
	var c1 := LETTERS.substr(clampi(idx1, 0, 25), 1)
	var c2 := LETTERS.substr(clampi(idx2, 0, 25), 1)
	var c3 := LETTERS.substr(clampi(idx3, 0, 25), 1)
	backbox.submit_initials(c1 + c2 + c3)

func _format_score(s: int) -> String:
	if s >= 1000000:
		return "%d,%03d,%03d" % [s / 1000000, (s / 1000) % 1000, s % 1000]
	if s >= 1000:
		return "%d,%03d" % [s / 1000, s % 1000]
	return str(s)


func _on_replay() -> void:
	get_tree().change_scene_to_file("res://scenes/MainMenuV4.tscn")

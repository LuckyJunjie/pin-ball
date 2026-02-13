extends Node
## v4.0 Backbox state (BackboxBloc equivalent). Manages leaderboard, initials, share.
## Uses LeaderboardV4 for persistence; SocialSharingV4 for share.

enum State {
	LEADERBOARD_SUCCESS,
	LEADERBOARD_FAILURE,
	LOADING,
	INITIALS_FORM,
	INITIALS_SUCCESS,
	INITIALS_FAILURE,
	SHARE
}

signal state_changed(new_state: State, data: Variant)

var current_state: State = State.LEADERBOARD_SUCCESS
var leaderboard_entries: Array = []  # [{ initials, score, character_key }]
var initials_score: int = 0
var initials_character_key: String = ""
var share_score: int = 0
## Set by MainMenuV4 when user selects character (e.g. "sparky", "dino", "dash", "android").
var selected_character_key: String = "sparky"


func _ready() -> void:
	add_to_group("backbox_manager_v4")
	_load_leaderboard()


func _load_leaderboard() -> void:
	_set_state(State.LOADING, null)
	leaderboard_entries.clear()
	if LeaderboardV4:
		var raw = LeaderboardV4.get_leaderboard(10, "")
		for e in raw:
			leaderboard_entries.append({
				"initials": e.get("initials", "???"),
				"score": e.get("score", 0),
				"character_key": e.get("character", "sparky")
			})
		_set_state(State.LEADERBOARD_SUCCESS, leaderboard_entries)
	else:
		_set_state(State.LEADERBOARD_FAILURE, null)


func request_initials(score: int, character_theme_key: String) -> void:
	initials_score = score
	initials_character_key = character_theme_key
	_set_state(State.INITIALS_FORM, {"score": score, "character_key": character_theme_key})


func submit_initials(initials: String) -> void:
	_set_state(State.LOADING, null)
	
	# Validate initials
	if not _validate_initials(initials):
		submit_initials_failure()
		return
	
	var three = initials.to_upper().substr(0, 3)
	if LeaderboardV4:
		LeaderboardV4.submit_score(three, initials_score, initials_character_key)
		# Reload leaderboard for display
		leaderboard_entries.clear()
		var raw = LeaderboardV4.get_leaderboard(10, "")
		for e in raw:
			leaderboard_entries.append({
				"initials": e.get("initials", "???"),
				"score": e.get("score", 0),
				"character_key": e.get("character", "sparky")
			})
	
	_set_state(State.INITIALS_SUCCESS, {"score": initials_score})
	
	# Auto-transition to share after delay
	await get_tree().create_timer(2.0).timeout
	request_share(initials_score)


func submit_initials_failure() -> void:
	_set_state(State.INITIALS_FAILURE, {"score": initials_score, "character_key": initials_character_key})


func request_share(score: int) -> void:
	share_score = score
	_set_state(State.SHARE, score)
	# Invoke SocialSharingV4 so user can copy/share (GDD §4.3, §5.3)
	if SocialSharingV4 and SocialSharingV4.has_method("share_high_score"):
		SocialSharingV4.share_high_score(score, initials_character_key)


func go_to_leaderboard() -> void:
	_load_leaderboard()


func get_leaderboard_entries() -> Array:
	## Get current leaderboard entries
	return leaderboard_entries.duplicate()


func get_player_rank(score: int) -> int:
	## Calculate player's rank based on score
	var rank = 1
	for entry in leaderboard_entries:
		if score < entry.score:
			rank += 1
	return min(rank, 10)  # Max rank is 10


func _validate_initials(initials: String) -> bool:
	## Validate initials (3 letters, alphabetic)
	if initials.length() < 1 or initials.length() > 3:
		return false
	
	# Check if all characters are letters
	var regex = RegEx.new()
	regex.compile("^[A-Za-z]+$")
	return regex.search(initials) != null


func _load_leaderboard_from_storage() -> void:
	## Reload from LeaderboardV4 (e.g. after returning to menu)
	_load_leaderboard()


func _set_state(new_state: State, data: Variant) -> void:
	current_state = new_state
	state_changed.emit(new_state, data)

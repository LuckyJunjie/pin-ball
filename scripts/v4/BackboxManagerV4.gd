extends Node
## v4.0 Backbox state (BackboxBloc equivalent). Manages leaderboard, initials, share.
## Use as autoload "BackboxManagerV4". No Firebase; uses local mock leaderboard.

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

const MOCK_ENTRIES: Array = [
	{"initials": "ABC", "score": 5000000, "character_key": "sparky"},
	{"initials": "XYZ", "score": 3000000, "character_key": "dino"},
	{"initials": "IO", "score": 2000000, "character_key": "dash"},
	{"initials": "GD", "score": 1500000, "character_key": "android"},
	{"initials": "ME", "score": 1000000, "character_key": "sparky"},
]


func _ready() -> void:
	add_to_group("backbox_manager_v4")
	_load_leaderboard_mock()


func _load_leaderboard_mock() -> void:
	leaderboard_entries.clear()
	for e in MOCK_ENTRIES:
		leaderboard_entries.append(e.duplicate())
	_set_state(State.LEADERBOARD_SUCCESS, leaderboard_entries)


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
	
	# Mock: no network; add to local list and show success
	var entry = {"initials": initials.to_upper().substr(0, 3), "score": initials_score, "character_key": initials_character_key}
	leaderboard_entries.append(entry)
	leaderboard_entries.sort_custom(func(a, b): return a.score > b.score)
	if leaderboard_entries.size() > 10:
		leaderboard_entries.resize(10)
	
	# Save to local storage (mock)
	_save_leaderboard_to_storage()
	
	_set_state(State.INITIALS_SUCCESS, {"score": initials_score})
	
	# Auto-transition to share after delay
	await get_tree().create_timer(2.0).timeout
	request_share(initials_score)


func submit_initials_failure() -> void:
	_set_state(State.INITIALS_FAILURE, {"score": initials_score, "character_key": initials_character_key})


func request_share(score: int) -> void:
	share_score = score
	_set_state(State.SHARE, score)


func go_to_leaderboard() -> void:
	_load_leaderboard_mock()


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


func _save_leaderboard_to_storage() -> void:
	## Mock save to local storage
	# In a real implementation, this would save to file or database
	print("BackboxManagerV4: Saved leaderboard with %d entries" % leaderboard_entries.size())


func _load_leaderboard_from_storage() -> void:
	## Mock load from local storage
	# In a real implementation, this would load from file or database
	# For now, just use mock entries
	_load_leaderboard_mock()


func _set_state(new_state: State, data: Variant) -> void:
	current_state = new_state
	state_changed.emit(new_state, data)

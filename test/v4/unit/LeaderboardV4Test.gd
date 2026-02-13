extends "res://addons/gut/test.gd"
## Unit tests for LeaderboardV4.gd

var leaderboard: Node = null

func before_all():
	leaderboard = autoqfree(load("res://scripts/v4/LeaderboardV4.gd").new())
	add_child(leaderboard)

func test_leaderboard_exists():
	assert_not_null(leaderboard, "LeaderboardV4 should exist")
	assert_eq(leaderboard.get_script().resource_path, "res://scripts/v4/LeaderboardV4.gd")

func test_submit_score():
	watch_signals(leaderboard)
	var score_id = leaderboard.submit_score("ABC", 100000, "sparky")
	
	assert_gt(score_id.length(), 0, "Should return score ID")
	assert_signal_emitted(leaderboard, "score_submitted")
	assert_signal_emitted(leaderboard, "leaderboard_updated")

func test_get_leaderboard():
	leaderboard.submit_score("AAA", 100000, "sparky")
	leaderboard.submit_score("BBB", 80000, "dino")
	leaderboard.submit_score("CCC", 60000, "dash")
	
	var entries = leaderboard.get_leaderboard(3)
	assert_eq(entries.size(), 3, "Should return requested count")
	assert_ge(entries[0]["score"], entries[1]["score"], "Should be sorted descending")

func test_get_character_leaderboard():
	leaderboard.submit_score("AAA", 100000, "sparky")
	leaderboard.submit_score("BBB", 80000, "sparky")
	leaderboard.submit_score("CCC", 60000, "dino")
	
	var sparky_entries = leaderboard.get_leaderboard(10, "sparky")
	assert_ge(sparky_entries.size(), 2, "Should return character-specific entries")
	
	for entry in sparky_entries:
		assert_eq(entry["character"], "sparky", "All entries should be for sparky")

func test_is_high_score():
	leaderboard.clear_leaderboard()
	
	assert_true(leaderboard.is_high_score(1000), "Should be high score when empty")
	
	leaderboard.submit_score("AAA", 100000, "sparky")
	assert_true(leaderboard.is_high_score(200000), "Should be high score if higher")
	assert_false(leaderboard.is_high_score(50000), "Should not be high score if lower")

func test_get_highest_score():
	leaderboard.submit_score("AAA", 100000, "sparky")
	leaderboard.submit_score("BBB", 200000, "dino")
	
	assert_eq(leaderboard.get_highest_score(), 200000, "Should return highest score")

func test_get_average_score():
	leaderboard.clear_leaderboard()
	leaderboard.submit_score("AAA", 100000, "sparky")
	leaderboard.submit_score("BBB", 200000, "dino")
	
	var avg = leaderboard.get_average_score()
	assert_eq(avg, 150000, "Should calculate average correctly")

func test_get_rank():
	leaderboard.clear_leaderboard()
	var score_id = leaderboard.submit_score("ABC", 100000, "sparky")
	
	var rank = leaderboard.get_rank("ABC", 100000)
	assert_eq(rank, 1, "Should return correct rank")

func test_get_character_high_score():
	leaderboard.submit_score("AAA", 100000, "sparky")
	leaderboard.submit_score("BBB", 150000, "sparky")
	
	var high = leaderboard.get_character_high_score("sparky")
	assert_eq(high, 150000, "Should return character high score")

func test_remove_entry():
	leaderboard.clear_leaderboard()
	var score_id = leaderboard.submit_score("ABC", 100000, "sparky")
	
	var before_count = leaderboard.get_total_entries()
	leaderboard.remove_entry(score_id)
	var after_count = leaderboard.get_total_entries()
	
	assert_lt(after_count, before_count, "Entry should be removed")

func test_get_entry_by_id():
	var score_id = leaderboard.submit_score("XYZ", 50000, "dino")
	var entry = leaderboard.get_entry_by_id(score_id)
	
	assert_eq(entry["initials"], "XYZ", "Should return correct entry")
	assert_eq(entry["score"], 50000, "Should return correct score")

func test_clear_leaderboard():
	leaderboard.submit_score("AAA", 100000, "sparky")
	leaderboard.submit_score("BBB", 80000, "dino")
	
	watch_signals(leaderboard)
	leaderboard.clear_leaderboard()
	
	assert_signal_emitted(leaderboard, "leaderboard_updated")
	assert_eq(leaderboard.get_total_entries(), 0, "Leaderboard should be cleared")

func test_export_leaderboard():
	leaderboard.submit_score("AAA", 100000, "sparky")
	var exported = leaderboard.export_leaderboard()
	
	assert_gt(exported.length(), 0, "Export should return JSON string")
	assert_true(exported.contains("AAA"), "Export should contain entries")

func test_import_leaderboard():
	leaderboard.clear_leaderboard()
	leaderboard.submit_score("AAA", 100000, "sparky")
	var exported = leaderboard.export_leaderboard()
	
	leaderboard.clear_leaderboard()
	var success = leaderboard.import_leaderboard(exported, false)
	
	assert_true(success, "Import should succeed")
	assert_gt(leaderboard.get_total_entries(), 0, "Entries should be imported")

func test_get_statistics():
	leaderboard.submit_score("AAA", 100000, "sparky")
	var stats = leaderboard.get_statistics()
	
	assert_true(stats.has("total_entries"), "Stats should have total_entries")
	assert_true(stats.has("highest_score"), "Stats should have highest_score")
	assert_true(stats.has("character_counts"), "Stats should have character_counts")

func test_get_recent_entries():
	leaderboard.submit_score("AAA", 100000, "sparky")
	await get_tree().create_timer(0.1).timeout
	leaderboard.submit_score("BBB", 80000, "dino")
	
	var recent = leaderboard.get_recent_entries(2)
	assert_ge(recent.size(), 1, "Should return recent entries")
	assert_ge(recent[0]["timestamp"], recent[1]["timestamp"] if recent.size() > 1 else 0,
		"Should be sorted by timestamp descending")

func test_get_top_character():
	leaderboard.submit_score("AAA", 100000, "sparky")
	leaderboard.submit_score("BBB", 200000, "dino")
	
	var top = leaderboard.get_top_character()
	assert_eq(top, "dino", "Should return character with highest score")

func test_max_entries_limit():
	leaderboard.clear_leaderboard()
	for i in range(150):  # More than MAX_ENTRIES (100)
		leaderboard.submit_score("AAA", 1000 + i, "sparky")
	
	assert_le(leaderboard.get_total_entries(), leaderboard.MAX_ENTRIES,
		"Should not exceed MAX_ENTRIES")

func after_all():
	# Cleanup test save files
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive("user://saves")
		var save_dir = DirAccess.open("user://saves/")
		if save_dir:
			if save_dir.file_exists("leaderboard.json"):
				save_dir.remove("leaderboard.json")

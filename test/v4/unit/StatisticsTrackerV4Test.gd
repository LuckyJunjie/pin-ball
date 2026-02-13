extends "res://addons/gut/test.gd"
## Unit tests for StatisticsTrackerV4.gd

var statistics_tracker: Node = null

func before_all():
	statistics_tracker = autoqfree(load("res://scripts/v4/StatisticsTrackerV4.gd").new())
	add_child(statistics_tracker)

func test_statistics_tracker_exists():
	assert_not_null(statistics_tracker, "StatisticsTrackerV4 should exist")
	assert_eq(statistics_tracker.get_script().resource_path, "res://scripts/v4/StatisticsTrackerV4.gd")

func test_on_game_started():
	statistics_tracker.on_game_started()
	
	assert_eq(statistics_tracker.get_lifetime_stat("games_played"), 1,
		"games_played should increment")
	assert_gt(statistics_tracker.get_lifetime_stat("last_played"), 0,
		"last_played should be set")

func test_on_game_ended():
	statistics_tracker.on_game_started()
	statistics_tracker.on_game_ended(500000)
	
	assert_eq(statistics_tracker.get_lifetime_stat("total_score"), 500000,
		"total_score should accumulate")
	assert_eq(statistics_tracker.get_high_score(), 500000,
		"high_score should be set")

func test_high_score_tracking():
	statistics_tracker.on_game_started()
	statistics_tracker.on_game_ended(100000)
	
	var first_high = statistics_tracker.get_high_score()
	
	statistics_tracker.on_game_started()
	statistics_tracker.on_game_ended(200000)
	
	assert_gt(statistics_tracker.get_high_score(), first_high,
		"high_score should update when higher score achieved")
	
	statistics_tracker.on_game_started()
	statistics_tracker.on_game_ended(50000)
	
	assert_eq(statistics_tracker.get_high_score(), 200000,
		"high_score should not decrease")

func test_ball_lost_tracking():
	statistics_tracker.on_game_started()
	statistics_tracker.on_ball_lost()
	statistics_tracker.on_ball_lost()
	
	assert_eq(statistics_tracker.get_session_stat("balls_lost"), 2,
		"Session balls_lost should track")
	
	statistics_tracker.on_game_ended(100000)
	assert_ge(statistics_tracker.get_lifetime_stat("total_balls_lost"), 2,
		"Lifetime total_balls_lost should accumulate")

func test_bonus_ball_tracking():
	statistics_tracker.on_game_started()
	statistics_tracker.on_bonus_ball_earned()
	statistics_tracker.on_bonus_ball_earned()
	
	assert_eq(statistics_tracker.get_session_stat("bonus_balls"), 2,
		"Session bonus_balls should track")
	
	statistics_tracker.on_game_ended(100000)
	assert_ge(statistics_tracker.get_lifetime_stat("total_bonus_balls"), 2,
		"Lifetime total_bonus_balls should accumulate")

func test_scoring_stats():
	statistics_tracker.on_game_started()
	statistics_tracker.on_hit(100)
	statistics_tracker.on_bumper_hit()
	statistics_tracker.on_ramp_hit()
	statistics_tracker.on_letter_hit()
	statistics_tracker.on_word_completed()
	
	assert_gt(statistics_tracker.get_scoring_stat("total_hits"), 0)
	assert_gt(statistics_tracker.get_scoring_stat("total_bumper_hits"), 0)
	assert_gt(statistics_tracker.get_scoring_stat("total_ramp_hits"), 0)
	assert_gt(statistics_tracker.get_scoring_stat("total_letter_hits"), 0)
	assert_gt(statistics_tracker.get_scoring_stat("total_word_completions"), 0)

func test_multiplier_tracking():
	statistics_tracker.on_multiplier_changed(2)
	assert_eq(statistics_tracker.get_highest_multiplier(), 2)
	
	statistics_tracker.on_multiplier_changed(4)
	assert_eq(statistics_tracker.get_highest_multiplier(), 4)
	
	statistics_tracker.on_multiplier_changed(3)
	assert_eq(statistics_tracker.get_highest_multiplier(), 4,
		"Highest multiplier should not decrease")

func test_combo_tracking():
	statistics_tracker.on_game_started()
	statistics_tracker.on_combo_changed(5)
	assert_eq(statistics_tracker.get_session_stat("combo"), 5)
	assert_eq(statistics_tracker.get_session_stat("max_combo"), 5)
	
	statistics_tracker.on_combo_changed(10)
	assert_eq(statistics_tracker.get_session_stat("max_combo"), 10)
	assert_eq(statistics_tracker.get_highest_combo(), 10)

func test_zone_stats():
	statistics_tracker.on_android_bonus()
	statistics_tracker.on_google_word()
	statistics_tracker.on_dash_nest()
	statistics_tracker.on_dino_chomp()
	statistics_tracker.on_sparky_turbo()
	
	assert_gt(statistics_tracker.get_zone_stat("android_acres_bonuses"), 0)
	assert_gt(statistics_tracker.get_zone_stat("google_words_completed"), 0)
	assert_gt(statistics_tracker.get_zone_stat("dash_nests_completed"), 0)
	assert_gt(statistics_tracker.get_zone_stat("dino_chomps"), 0)
	assert_gt(statistics_tracker.get_zone_stat("sparky_turbos"), 0)

func test_favorite_zone():
	statistics_tracker.on_android_bonus()
	statistics_tracker.on_android_bonus()
	statistics_tracker.on_google_word()
	
	var favorite = statistics_tracker.get_favorite_zone()
	assert_eq(favorite, "android_acres",
		"Favorite zone should be most played")

func test_achievement_stats():
	statistics_tracker.on_achievement_unlocked()
	statistics_tracker.on_achievement_unlocked()
	statistics_tracker.on_achievement_points_earned(50)
	
	var stats = statistics_tracker.get_statistics_summary()
	assert_ge(stats["achievements"]["unlocked_count"], 2)
	assert_ge(stats["achievements"]["total_points"], 50)

func test_get_statistics_summary():
	var summary = statistics_tracker.get_statistics_summary()
	assert_true(summary.has("lifetime"), "Summary should have lifetime stats")
	assert_true(summary.has("scoring"), "Summary should have scoring stats")
	assert_true(summary.has("zones"), "Summary should have zone stats")
	assert_true(summary.has("achievements"), "Summary should have achievement stats")

func test_get_friendly_summary():
	var summary = statistics_tracker.get_friendly_summary()
	assert_true(summary.contains("Games Played"), "Summary should contain games played")
	assert_true(summary.contains("High Score"), "Summary should contain high score")

func test_get_milestones():
	var milestones = statistics_tracker.get_milestones()
	assert_gt(milestones.size(), 0, "Should return milestones")
	assert_true(milestones[0].has("name"), "Milestone should have name")
	assert_true(milestones[0].has("achieved"), "Milestone should have achieved status")

func test_reset_stats():
	statistics_tracker.on_game_started()
	statistics_tracker.on_game_ended(100000)
	statistics_tracker.on_hit(100)
	
	var games_before = statistics_tracker.get_games_played()
	assert_gt(games_before, 0)
	
	statistics_tracker.reset_stats()
	
	assert_eq(statistics_tracker.get_games_played(), 0,
		"Reset should clear all stats")

func test_time_played_tracking():
	statistics_tracker.on_game_started()
	await get_tree().create_timer(0.1).timeout
	statistics_tracker.on_game_ended(100000)
	
	var time_played = statistics_tracker.get_total_time_played()
	assert_gt(time_played, 0, "Time played should be tracked")

func after_all():
	# Cleanup test save files
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive("user://saves")
		var save_dir = DirAccess.open("user://saves/")
		if save_dir:
			if save_dir.file_exists("statistics.json"):
				save_dir.remove("statistics.json")

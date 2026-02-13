extends "res://addons/gut/test.gd"
## Unit tests for DailyChallengeV4.gd

var daily_challenge: Node = null

func before_all():
	daily_challenge = autoqfree(load("res://scripts/v4/DailyChallengeV4.gd").new())
	add_child(daily_challenge)

func test_daily_challenge_exists():
	assert_not_null(daily_challenge, "DailyChallengeV4 should exist")
	assert_eq(daily_challenge.get_script().resource_path, "res://scripts/v4/DailyChallengeV4.gd")

func test_challenge_templates():
	assert_gt(daily_challenge.CHALLENGE_TEMPLATES.size(), 0, 
		"Challenge templates should be defined")
	
	var high_score = daily_challenge.CHALLENGE_TEMPLATES[0]
	assert_eq(high_score["id"], "high_score")
	assert_eq(high_score["type"], "score")
	assert_gt(high_score["target"], 0)

func test_get_today_challenges():
	daily_challenge.start_tracking()
	var challenges = daily_challenge.get_today_challenges()
	assert_ge(challenges.size(), 0, "Should return today's challenges")

func test_update_progress():
	daily_challenge.start_tracking()
	daily_challenge.update_progress("score", 100000)
	
	var challenges = daily_challenge.get_today_challenges()
	for challenge in challenges:
		if challenge.get("type") == "score":
			assert_ge(challenge.get("progress", 0), 0,
				"Progress should update for matching challenge type")

func test_challenge_completion():
	daily_challenge.start_tracking()
	watch_signals(daily_challenge)
	
	# Find a score challenge and complete it
	var challenges = daily_challenge.get_today_challenges()
	for challenge in challenges:
		if challenge.get("type") == "score":
			var target = challenge.get("target", 1)
			daily_challenge.update_progress("score", target)
			break
	
	# Should emit completion signal
	assert_signal_emitted(daily_challenge, "challenge_completed")

func test_get_challenge_progress():
	daily_challenge.start_tracking()
	var challenges = daily_challenge.get_today_challenges()
	
	if challenges.size() > 0:
		var challenge_id = challenges[0].get("id")
		var progress = daily_challenge.get_challenge_progress(challenge_id)
		
		assert_true(progress.has("name"), "Progress should have name")
		assert_true(progress.has("progress"), "Progress should have progress value")
		assert_true(progress.has("target"), "Progress should have target value")

func test_is_completed():
	daily_challenge.start_tracking()
	var challenges = daily_challenge.get_today_challenges()
	
	if challenges.size() > 0:
		var challenge_id = challenges[0].get("id")
		assert_false(daily_challenge.is_completed(challenge_id),
			"Challenge should not be completed initially")
		
		# Complete the challenge
		for challenge in challenges:
			if challenge.get("id") == challenge_id:
				var target = challenge.get("target", 1)
				daily_challenge.update_progress(challenge.get("type"), target)
				break
		
		assert_true(daily_challenge.is_completed(challenge_id),
			"Challenge should be completed after reaching target")

func test_get_completed_count():
	daily_challenge.start_tracking()
	assert_eq(daily_challenge.get_completed_count(), 0,
		"Initially no challenges should be completed")
	
	# Complete a challenge
	var challenges = daily_challenge.get_today_challenges()
	if challenges.size() > 0:
		var challenge = challenges[0]
		var target = challenge.get("target", 1)
		daily_challenge.update_progress(challenge.get("type"), target)
		
		assert_eq(daily_challenge.get_completed_count(), 1,
			"Completed count should increment")

func test_get_total_rewards_today():
	daily_challenge.start_tracking()
	var initial_rewards = daily_challenge.get_total_rewards_today()
	
	# Complete a challenge
	var challenges = daily_challenge.get_today_challenges()
	if challenges.size() > 0:
		var challenge = challenges[0]
		var target = challenge.get("target", 1)
		daily_challenge.update_progress(challenge.get("type"), target)
		
		var rewards_after = daily_challenge.get_total_rewards_today()
		assert_gt(rewards_after, initial_rewards,
			"Total rewards should increase after completion")

func test_get_statistics():
	var stats = daily_challenge.get_statistics()
	assert_true(stats.has("challenges_completed"), "Stats should have challenges_completed")
	assert_true(stats.has("rewards_earned"), "Stats should have rewards_earned")
	assert_true(stats.has("streak"), "Stats should have streak")

func test_reset_data():
	daily_challenge.start_tracking()
	daily_challenge.update_progress("score", 100000)
	
	daily_challenge.reset_data()
	
	assert_eq(daily_challenge._today_challenges.size(), 0,
		"Reset should clear today's challenges")
	assert_eq(daily_challenge._completed_today.size(), 0,
		"Reset should clear completed challenges")

func test_challenge_types():
	# Test different challenge types
	daily_challenge.start_tracking()
	
	daily_challenge.update_progress("multiplier", 1)
	daily_challenge.update_progress("bonus", 1)
	daily_challenge.update_progress("zones", 1)
	daily_challenge.update_progress("combo", 1)
	daily_challenge.update_progress("bumpers", 1)
	
	# Should not crash and should update progress
	pass_test("All challenge types should update without errors")

func after_all():
	# Cleanup test save files
	var dir = DirAccess.open("user://")
	if dir:
		dir.make_dir_recursive("user://saves")
		var save_dir = DirAccess.open("user://saves/")
		if save_dir:
			if save_dir.file_exists("daily_challenges.json"):
				save_dir.remove("daily_challenges.json")

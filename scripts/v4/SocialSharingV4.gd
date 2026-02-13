extends Node
## v4.0 Social Sharing System
## Share scores and achievements on social media

signal share_completed(platform: String, success: bool)

@export var game_name: String = "Pinball"
@export var company_name: String = "OpenClaw Studios"

var _share_templates: Dictionary = {
	"high_score": {
		"title": "New High Score! 🎯",
		"template": "I just scored {score} points in {game}! Can you beat my score? 🏆\n\n#Pinball #Gaming",
		"url": "https://pinball.example.com"
	},
	"achievement": {
		"title": "Achievement Unlocked! 🏅",
		"template": "I just unlocked '{achievement}' in {game}!\n\n#Gaming #Achievement",
		"url": "https://pinball.example.com/achievements"
	},
	"challenge": {
		"title": "Daily Challenge Complete! ⭐",
		"template": "I completed the {challenge} daily challenge in {game} and earned {reward} coins!\n\n#DailyChallenge #Gaming",
		"url": "https://pinball.example.com/challenges"
	},
	"milestone": {
		"title": "Milestone Reached! 🚀",
		"template": "Just reached {milestone} in {game}! So proud! 🎉\n\n#Milestone #Gaming",
		"url": "https://pinball.example.com"
	}
}

func _ready() -> void:
	add_to_group("social_sharing")

func can_share() -> bool:
	# Check if sharing is available
	return OS.get_name() in ["Windows", "macOS", "Linux", "Android", "iOS"]

func share_high_score(score: int, character: String = "sparky") -> void:
	var template = _share_templates["high_score"]
	var message = template["template"].format({
		"score": str(score),
		"game": game_name,
		"character": character
	})
	
	_share_to_system(message, template["title"])

func share_achievement(achievement_name: String, points: int) -> void:
	var template = _share_templates["achievement"]
	var message = template["template"].format({
		"achievement": achievement_name,
		"game": game_name
	})
	
	_share_to_system(message, template["title"])

func share_challenge_completion(challenge_name: String, reward: int) -> void:
	var template = _share_templates["challenge"]
	var message = template["template"].format({
		"challenge": challenge_name,
		"game": game_name,
		"reward": str(reward)
	})
	
	_share_to_system(message, template["title"])

func share_milestone(milestone_name: String) -> void:
	var template = _share_templates["milestone"]
	var message = template["template"].format({
		"milestone": milestone_name,
		"game": game_name
	})
	
	_share_to_system(message, template["title"])

func share_custom(message: String, title: String = "") -> void:
	_share_to_system(message, title)

func _share_to_system(message: String, title: String) -> void:
	if OS.get_name() == "Android":
		_share_android(message, title)
	elif OS.get_name() == "iOS":
		_share_ios(message, title)
	else:
		_copy_to_clipboard(message)
		share_completed.emit("clipboard", true)

func _share_android(message: String, title: String) -> void:
	# Android sharing via intent
	var url = "https://pinball.example.com/share?text=%s" % message.uri_encode()
	
	# In a real implementation, would use Android Java interface
	print("Android share: %s" % message)
	share_completed.emit("android", true)

func _share_ios(message: String, title: String) -> void:
	# iOS sharing
	print("iOS share: %s" % message)
	share_completed.emit("ios", true)

func _copy_to_clipboard(text: String) -> void:
	DisplayServer.clipboard_set(text)

func generate_score_card(score: int, character: String, achievements: int, challenges: int) -> Texture2D:
	# Generate a shareable image with score info
	var image = Image.create(600, 400, false, Image.FORMAT_RGBA8)
	
	# Background
	image.fill(Color(0.1, 0.1, 0.2))
	
	# Draw title
	_draw_text(image, "HIGH SCORE", 300, 50, 32, Color(1, 0.8, 0))
	
	# Draw score
	_draw_text(image, str(score), 300, 150, 64, Color.WHITE)
	
	# Draw character
	_draw_text(image, character, 300, 220, 24, Color(0.5, 0.8, 1))
	
	# Draw stats
	_draw_text(image, "Achievements: %d" % achievements, 300, 280, 20, Color(0.7, 0.7, 0.7))
	_draw_text(image, "Daily Challenges: %d" % challenges, 300, 310, 20, Color(0.7, 0.7, 0.7))
	
	# Draw footer
	_draw_text(image, game_name, 300, 370, 16, Color(0.5, 0.5, 0.5))
	
	return ImageTexture.create_from_image(image)

func _draw_text(image: Image, text: String, x: int, y: int, size: int, color: Color) -> void:
	# Simplified text drawing - would need font rendering in real implementation
	pass

func get_shareable_url(content_type: String) -> String:
	if _share_templates.has(content_type):
		return _share_templates[content_type]["url"]
	return "https://pinball.example.com"

func generate_leaderboard_image(top_scores: Array) -> Texture2D:
	var image = Image.create(400, 600, false, Image.FORMAT_RGBA8)
	image.fill(Color(0.1, 0.1, 0.15))
	
	_draw_text(image, "LEADERBOARD", 200, 30, 28, Color(1, 0.8, 0))
	
	var y = 80
	for i in range(min(10, top_scores.size())):
		var entry = top_scores[i]
		var text = "%d. %s - %d" % [i + 1, entry.get("initials", "???"), entry.get("score", 0)]
		_draw_text(image, text, 20, y, 18, Color.WHITE)
		y += 45
	
	return ImageTexture.create_from_image(image)

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("social_sharing")
	return null

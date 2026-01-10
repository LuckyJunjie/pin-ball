extends Node

## Sound Manager for pinball game
## Manages sound effects playback

@export var master_volume: float = 1.0
@export var enabled: bool = true

var flipper_click_sound: AudioStreamPlayer = null
var obstacle_hit_sound: AudioStreamPlayer = null
var ball_launch_sound: AudioStreamPlayer = null
var hold_entry_sound: AudioStreamPlayer = null
var ball_lost_sound: AudioStreamPlayer = null

func _ready():
	# Add to sound_manager group for easy access
	add_to_group("sound_manager")
	
	# Create AudioStreamPlayer nodes for each sound
	_create_sound_players()
	
	# Load sound files (if they exist)
	_load_sound_files()

func _create_sound_players():
	"""Create AudioStreamPlayer nodes for each sound effect"""
	flipper_click_sound = AudioStreamPlayer.new()
	flipper_click_sound.name = "FlipperClickSound"
	add_child(flipper_click_sound)
	
	obstacle_hit_sound = AudioStreamPlayer.new()
	obstacle_hit_sound.name = "ObstacleHitSound"
	add_child(obstacle_hit_sound)
	
	ball_launch_sound = AudioStreamPlayer.new()
	ball_launch_sound.name = "BallLaunchSound"
	add_child(ball_launch_sound)
	
	hold_entry_sound = AudioStreamPlayer.new()
	hold_entry_sound.name = "HoldEntrySound"
	add_child(hold_entry_sound)
	
	ball_lost_sound = AudioStreamPlayer.new()
	ball_lost_sound.name = "BallLostSound"
	add_child(ball_lost_sound)

func _load_sound_files():
	"""Load sound files from assets/sounds/ directory - supports both WAV and OGG"""
	var sound_names = ["flipper_click", "obstacle_hit", "ball_launch", "hold_entry", "ball_lost"]
	var sound_players = {
		"flipper_click": flipper_click_sound,
		"obstacle_hit": obstacle_hit_sound,
		"ball_launch": ball_launch_sound,
		"hold_entry": hold_entry_sound,
		"ball_lost": ball_lost_sound
	}
	
	# Try to load sounds - check both WAV and OGG formats
	for sound_name in sound_names:
		var wav_path = "res://assets/sounds/" + sound_name + ".wav"
		var ogg_path = "res://assets/sounds/" + sound_name + ".ogg"
		var sound_path = null
		
		# Prefer OGG, fall back to WAV
		if ResourceLoader.exists(ogg_path):
			sound_path = ogg_path
		elif ResourceLoader.exists(wav_path):
			sound_path = wav_path
		
		if sound_path:
			var stream = load(sound_path)
			if stream:
				sound_players[sound_name].stream = stream

func play_sound(sound_name: String):
	"""Play a sound effect by name"""
	if not enabled:
		return
	
	var player: AudioStreamPlayer = null
	match sound_name:
		"flipper_click":
			player = flipper_click_sound
		"obstacle_hit":
			player = obstacle_hit_sound
		"ball_launch":
			player = ball_launch_sound
		"hold_entry":
			player = hold_entry_sound
		"ball_lost":
			player = ball_lost_sound
	
	if player and player.stream:
		player.volume_db = linear_to_db(master_volume)
		player.play()

func set_volume(volume: float):
	"""Set master volume (0.0 to 1.0)"""
	master_volume = clamp(volume, 0.0, 1.0)

func set_enabled(enabled_state: bool):
	"""Enable or disable all sounds"""
	enabled = enabled_state


extends Node

## Sound Manager for pinball game
## Manages sound effects playback

@export var master_volume: float = 1.0
@export var enabled: bool = true

# v3.0: Audio buses
var sfx_bus: String = "Master"
var music_bus: String = "Master"
var ui_bus: String = "Master"

var flipper_click_sound: AudioStreamPlayer = null
var obstacle_hit_sound: AudioStreamPlayer = null
var ball_launch_sound: AudioStreamPlayer = null
var hold_entry_sound: AudioStreamPlayer = null
var ball_lost_sound: AudioStreamPlayer = null

# v3.0: New sounds
var skill_shot_sound: AudioStreamPlayer = null
var multiball_activate_sound: AudioStreamPlayer = null
var multiball_end_sound: AudioStreamPlayer = null
var combo_hit_sound: AudioStreamPlayer = null
var background_music: AudioStreamPlayer = null

func _ready():
	# Add to sound_manager group for easy access
	add_to_group("sound_manager")
	
	# v3.0: Setup audio buses
	_setup_audio_buses()
	
	# Create AudioStreamPlayer nodes for each sound
	_create_sound_players()
	
	# Load sound files (if they exist)
	_load_sound_files()

func _setup_audio_buses():
	"""v3.0: Setup audio buses for separate SFX, music, and UI"""
	# Create buses if they don't exist
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(1)
		AudioServer.set_bus_name(1, "SFX")
		sfx_bus = "SFX"
	
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(2)
		AudioServer.set_bus_name(2, "Music")
		music_bus = "Music"
	
	if AudioServer.get_bus_index("UI") == -1:
		AudioServer.add_bus(3)
		AudioServer.set_bus_name(3, "UI")
		ui_bus = "UI"
	
	# Add reverb effect to SFX bus (optional)
	var sfx_bus_idx = AudioServer.get_bus_index("SFX")
	if sfx_bus_idx != -1:
		# Can add AudioEffectReverb here if needed
		pass

func _create_sound_players():
	"""Create AudioStreamPlayer nodes for each sound effect"""
	flipper_click_sound = AudioStreamPlayer.new()
	flipper_click_sound.name = "FlipperClickSound"
	flipper_click_sound.bus = sfx_bus
	add_child(flipper_click_sound)
	
	obstacle_hit_sound = AudioStreamPlayer.new()
	obstacle_hit_sound.name = "ObstacleHitSound"
	obstacle_hit_sound.bus = sfx_bus
	add_child(obstacle_hit_sound)
	
	ball_launch_sound = AudioStreamPlayer.new()
	ball_launch_sound.name = "BallLaunchSound"
	ball_launch_sound.bus = sfx_bus
	add_child(ball_launch_sound)
	
	hold_entry_sound = AudioStreamPlayer.new()
	hold_entry_sound.name = "HoldEntrySound"
	hold_entry_sound.bus = sfx_bus
	add_child(hold_entry_sound)
	
	ball_lost_sound = AudioStreamPlayer.new()
	ball_lost_sound.name = "BallLostSound"
	ball_lost_sound.bus = sfx_bus
	add_child(ball_lost_sound)
	
	# v3.0: New sound players
	skill_shot_sound = AudioStreamPlayer.new()
	skill_shot_sound.name = "SkillShotSound"
	skill_shot_sound.bus = sfx_bus
	add_child(skill_shot_sound)
	
	multiball_activate_sound = AudioStreamPlayer.new()
	multiball_activate_sound.name = "MultiballActivateSound"
	multiball_activate_sound.bus = sfx_bus
	add_child(multiball_activate_sound)
	
	multiball_end_sound = AudioStreamPlayer.new()
	multiball_end_sound.name = "MultiballEndSound"
	multiball_end_sound.bus = sfx_bus
	add_child(multiball_end_sound)
	
	combo_hit_sound = AudioStreamPlayer.new()
	combo_hit_sound.name = "ComboHitSound"
	combo_hit_sound.bus = sfx_bus
	add_child(combo_hit_sound)
	
	background_music = AudioStreamPlayer.new()
	background_music.name = "BackgroundMusic"
	background_music.bus = music_bus
	background_music.volume_db = -10.0  # Lower volume for music
	add_child(background_music)

func _load_sound_files():
	"""Load sound files from assets/sounds/ directory - supports both WAV and OGG"""
	var sound_names = [
		"flipper_click", "obstacle_hit", "ball_launch", "hold_entry", "ball_lost",
		"skill_shot", "multiball_activate", "multiball_end", "combo_hit"
	]
	var sound_players = {
		"flipper_click": flipper_click_sound,
		"obstacle_hit": obstacle_hit_sound,
		"ball_launch": ball_launch_sound,
		"hold_entry": hold_entry_sound,
		"ball_lost": ball_lost_sound,
		"skill_shot": skill_shot_sound,
		"multiball_activate": multiball_activate_sound,
		"multiball_end": multiball_end_sound,
		"combo_hit": combo_hit_sound
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
		"skill_shot":
			player = skill_shot_sound
		"multiball_activate":
			player = multiball_activate_sound
		"multiball_end":
			player = multiball_end_sound
		"combo_hit":
			player = combo_hit_sound
	
	if player and player.stream:
		player.volume_db = linear_to_db(master_volume)
		player.play()

func play_sound_with_pitch(sound_name: String, pitch_scale: float = 1.0):
	"""v3.0: Play sound with pitch variation"""
	if not enabled:
		return
	
	var player: AudioStreamPlayer = null
	match sound_name:
		"obstacle_hit":
			player = obstacle_hit_sound
		"combo_hit":
			player = combo_hit_sound
		_:
			player = get(sound_name + "_sound")
	
	if player and player.stream:
		player.pitch_scale = clamp(pitch_scale, 0.5, 2.0)
		player.volume_db = linear_to_db(master_volume)
		player.play()

func play_music(music_path: String, loop: bool = true):
	"""v3.0: Play background music"""
	if not enabled:
		return
	
	if ResourceLoader.exists(music_path):
		var stream = load(music_path)
		if stream:
			background_music.stream = stream
			background_music.volume_db = -10.0
			if loop and stream is AudioStreamOggVorbis:
				stream.loop = true
			background_music.play()

func stop_music():
	"""v3.0: Stop background music"""
	if background_music:
		background_music.stop()

func set_volume(volume: float):
	"""Set master volume (0.0 to 1.0)"""
	master_volume = clamp(volume, 0.0, 1.0)

func set_enabled(enabled_state: bool):
	"""Enable or disable all sounds"""
	enabled = enabled_state


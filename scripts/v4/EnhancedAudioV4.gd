extends Node
## v4.0 Enhanced Audio Manager
## Dynamic audio with speed-based volume, zone-specific sounds, and intensity-based music

signal music_intensity_changed(intensity: float)
signal zone_music_changed(zone_name: String)

@export var master_volume: float = 1.0
@export var sfx_volume: float = 1.0
@export var music_volume: float = 0.7
@export var ui_volume: float = 0.8
@export var enabled: bool = true

# Audio buses
var sfx_bus: String = "SFX"
var music_bus: String = "Music"
var ui_bus: String = "UI"

# Dynamic audio tracking
var _ball_speed: float = 0.0
var _current_intensity: float = 0.0
var _target_intensity: float = 0.0
var _intensity_tween: Tween = null

# Sound players
var _players: Dictionary = {}
var _background_music: AudioStreamPlayer = null
var _intensity_music: AudioStreamPlayer = null

# Zone-specific music
var _zone_music_tracks: Dictionary = {
	"android_acres": null,
	"google_gallery": null,
	"flutter_forest": null,
	"dino_desert": null,
	"sparky_scorch": null,
	"menu": null,
	"game_over": null
}

func _ready() -> void:
	add_to_group("sound_manager")
	_setup_audio_buses()
	_create_sound_players()
	_load_sound_files()
	
	# Start intensity tracking
	_target_intensity = 0.0
	_current_intensity = 0.0

func _process(delta: float) -> void:
	# Smoothly transition intensity
	if abs(_target_intensity - _current_intensity) > 0.01:
		_current_intensity = lerp(_current_intensity, _target_intensity, delta * 2.0)
		_update_music_intensity()

# ============================================
# Audio Bus Setup
# ============================================

func _setup_audio_buses() -> void:
	# Create audio buses if they don't exist
	if AudioServer.get_bus_index("SFX") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "SFX")
		sfx_bus = "SFX"
	
	if AudioServer.get_bus_index("Music") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "Music")
		music_bus = "Music"
	
	if AudioServer.get_bus_index("UI") == -1:
		AudioServer.add_bus(AudioServer.bus_count)
		AudioServer.set_bus_name(AudioServer.bus_count - 1, "UI")
		ui_bus = "UI"

# ============================================
# Player Creation
# ============================================

func _create_sound_players() -> void:
	var sound_names = [
		"bumper_hit", "android_bumper_hit", "dash_bumper_hit", "sparky_bumper_hit",
		"ramp_hit", "rollover_hit", "letter_hit", "word_completed",
		"slingshot_hit", "wall_hit", "signpost_hit", "computer_hit",
		"flipper_hit", "launch_ball", "ball_drain", "bonus_activation",
		"multiplier_increase", "nest_completed", "turbo_charge", "chomp",
		"skill_shot", "combo_sound", "game_over", "start_game"
	]
	
	for sound_name in sound_names:
		var player = AudioStreamPlayer.new()
		player.name = sound_name + "_player"
		player.bus = sfx_bus
		player.volume_db = 0.0
		add_child(player)
		_players[sound_name] = player
	
	# Background music players
	_background_music = AudioStreamPlayer.new()
	_background_music.name = "BackgroundMusic"
	_background_music.bus = music_bus
	_background_music.volume_db = -10.0
	_background_music.autoplay = false
	add_child(_background_music)
	
	_intensity_music = AudioStreamPlayer.new()
	_intensity_music.name = "IntensityMusic"
	_intensity_music.bus = music_bus
	_intensity_music.volume_db = -15.0
	_intensity_music.autoplay = false
	add_child(_intensity_music)

# ============================================
# Sound Loading
# ============================================

func _load_sound_files() -> void:
	var sounds_dir = "res://assets/audio/sfx/"
	var music_dir = "res://assets/audio/music/"
	
	# Load SFX
	for sound_name in _players:
		var paths = [
			sounds_dir + sound_name + ".ogg",
			sounds_dir + sound_name + ".wav",
			sounds_dir + sound_name + ".mp3"
		]
		for path in paths:
			if ResourceLoader.exists(path):
				_players[sound_name].stream = load(path)
				break
		
		# Load placeholder if not found (for development)
		if not _players[sound_name].stream:
			_players[sound_name].stream = _create_silent_stream()
	
	# Load music
	for zone in _zone_music_tracks:
		var paths = [
			music_dir + zone + ".ogg",
			music_dir + zone + ".mp3"
		]
		for path in paths:
			if ResourceLoader.exists(path):
				_zone_music_tracks[zone] = load(path)
				break

func _create_silent_stream() -> AudioStream:
	# Create a silent audio stream for missing sounds
	var stream = AudioStreamGenerator.new()
	stream.mix_rate = 44100
	return stream

# ============================================
# Sound Playback
# ============================================

func play_sound(sound_name: String, volume_override: float = -1.0, pitch_override: float = 1.0) -> void:
	if not enabled:
		return
	
	var player = _players.get(sound_name)
	if player and player.stream:
		# Apply volume based on ball speed
		var volume_db = 0.0
		if volume_override >= 0:
			volume_db = linear_to_db(volume_override * sfx_volume)
		else:
			# Dynamic volume based on ball speed
			var speed_factor = clamp(_ball_speed / 500.0, 0.0, 1.0)  # Max speed ~500
			volume_db = linear_to_db(sfx_volume * (0.5 + 0.5 * speed_factor))
		
		player.volume_db = volume_db
		
		# Pitch variation
		if pitch_override != 1.0:
			player.pitch_scale = clamp(pitch_override, 0.5, 2.0)
		else:
			# Random pitch variation for variety
			player.pitch_scale = randf_range(0.95, 1.05)
		
		player.play()

func play_zone_sound(zone_name: String, sound_suffix: String) -> void:
	var sound_name = zone_name + "_" + sound_suffix
	if _players.has(sound_name):
		play_sound(sound_name)
	else:
		# Fallback to generic sound
		play_sound(sound_suffix)

func stop_sound(sound_name: String) -> void:
	var player = _players.get(sound_name)
	if player:
		player.stop()

# ============================================
# Dynamic Audio
# ============================================

func update_ball_speed(speed: float) -> void:
	_ball_speed = speed
	# Intensity follows ball speed
	_target_intensity = clamp(speed / 400.0, 0.0, 1.0)

func _update_music_intensity() -> void:
	# Adjust music parameters based on intensity
	if _intensity_music and _intensity_music.playing:
		_intensity_music.pitch_scale = 0.8 + (_current_intensity * 0.4)  # 0.8x to 1.2x
		music_intensity_changed.emit(_current_intensity)

func set_music_intensity(intensity: float) -> void:
	_target_intensity = clamp(intensity, 0.0, 1.0)

func play_background_music(zone_name: String = "menu") -> void:
	if not enabled:
		return
	
	var track = _zone_music_tracks.get(zone_name)
	if track:
		if _background_music.playing:
			_fade_to_music(_background_music, track)
		else:
			_background_music.stream = track
			_background_music.play()
		
		zone_music_changed.emit(zone_name)

func _fade_to_music(current_player: AudioStreamPlayer, new_track: AudioStream) -> void:
	if _intensity_tween:
		_intensity_tween.kill()
	
	_intensity_tween = create_tween()
	_intensity_tween.tween_property(current_player, "volume_db", -40.0, 0.5)
	_intensity_tween.tween_callback(func():
		current_player.stream = new_track
		current_player.play()
	)
	_intensity_tween.tween_property(current_player, "volume_db", -10.0, 0.5)

func stop_music(fade_out: bool = true) -> void:
	if _background_music and _background_music.playing:
		if fade_out:
			var tween = create_tween()
			tween.tween_property(_background_music, "volume_db", -40.0, 0.5)
			tween.tween_callback(func():
				_background_music.stop()
			)
		else:
			_background_music.stop()

# ============================================
# Zone-Based Audio
# ============================================

func play_zone_music(zone_name: String) -> void:
	if zone_name in _zone_music_tracks:
		play_background_music(zone_name)

func set_zone_sfx_volume(zone_name: String, volume: float) -> void:
	# Zone-specific SFX boost
	var zone_players = []
	match zone_name:
		"android_acres":
			zone_players = ["android_bumper_hit", "ramp_hit"]
		"google_gallery":
			zone_players = ["letter_hit", "rollover_hit", "word_completed"]
		"flutter_forest":
			zone_players = ["signpost_hit", "bumper_hit", "nest_completed"]
		"dino_desert":
			zone_players = ["slingshot_hit", "wall_hit", "chomp"]
		"sparky_scorch":
			zone_players = ["sparky_bumper_hit", "computer_hit", "turbo_charge"]
	
	for player_name in zone_players:
		if player_name in _players:
			_players[player_name].volume_db = linear_to_db(volume)

# ============================================
# Volume Controls
# ============================================

func set_master_volume(volume: float) -> void:
	master_volume = clamp(volume, 0.0, 1.0)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Master"), volume == 0.0)

func set_sfx_volume(volume: float) -> void:
	sfx_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(sfx_bus)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(sfx_volume))

func set_music_volume(volume: float) -> void:
	music_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(music_bus)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(music_volume))

func set_ui_volume(volume: float) -> void:
	ui_volume = clamp(volume, 0.0, 1.0)
	var bus_idx = AudioServer.get_bus_index(ui_bus)
	if bus_idx != -1:
		AudioServer.set_bus_volume_db(bus_idx, linear_to_db(ui_volume))

# ============================================
# Convenience Methods
# ============================================

func play_bumper_hit(zone_type: String = "") -> void:
	if zone_type == "android":
		play_sound("android_bumper_hit")
	elif zone_type == "dash":
		play_sound("dash_bumper_hit")
	elif zone_type == "sparky":
		play_sound("sparky_bumper_hit")
	else:
		play_sound("bumper_hit")

func play_hit_feedback(base_points: int, is_critical: bool = false) -> void:
	# Dynamic feedback based on points
	var pitch = 1.0
	var volume = 1.0
	
	if is_critical:
		pitch = 1.2
		volume = 1.2
	elif base_points >= 100000:
		pitch = 1.1
		volume = 1.1
	elif base_points >= 50000:
		pitch = 1.05
	
	play_sound("bonus_activation", volume, pitch)

func play_combo_sound(combo_count: int) -> void:
	# Pitch increases with combo
	var pitch = 1.0 + (combo_count * 0.02)
	pitch = clamp(pitch, 0.8, 2.0)
	play_sound("combo_sound", 1.0, pitch)

func play_multiplier_sound(multiplier: int) -> void:
	# Celebratory sound for multiplier increase
	play_sound("multiplier_increase")
	
	# Play combo sound too for feedback
	if multiplier > 1:
		play_combo_sound(multiplier)

# Static access
static func get_instance() -> Node:
	var tree = Engine.get_main_loop() as SceneTree
	if tree:
		return tree.get_first_node_in_group("sound_manager")
	return null

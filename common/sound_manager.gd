extends Node

var sounds: Dictionary = {}
var players: Array[AudioStreamPlayer] = []
const POOL_SIZE: int = 8
var current_player_idx: int = 0

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	# Create pool of AudioStreamPlayers
	for i in range(POOL_SIZE):
		var p = AudioStreamPlayer.new()
		add_child(p)
		players.append(p)
		
	# Load all meme sounds
	_load_sound("vine_boom", "res://assets/sounds/vine_boom.mp3")
	_load_sound("punch", "res://assets/sounds/punch.mp3")
	_load_sound("slap", "res://assets/sounds/slap.mp3")
	_load_sound("bone_crack", "res://assets/sounds/bone_crack.mp3")
	_load_sound("fart", "res://assets/sounds/fart.mp3")
	_load_sound("anime_wow", "res://assets/sounds/anime_wow.mp3")
	_load_sound("are_baap_re", "res://assets/sounds/are_baap_re.mp3")
	_load_sound("aayein", "res://assets/sounds/aayein.mp3")
	_load_sound("chalo", "res://assets/sounds/chalo.mp3")
	_load_sound("dun_dun_dun", "res://assets/sounds/dun_dun_dun.mp3")
	_load_sound("fahhh", "res://assets/sounds/fahhh.mp3")
	_load_sound("huh", "res://assets/sounds/huh.mp3")
	_load_sound("ruko_zara", "res://assets/sounds/ruko_zara.mp3")
	_load_sound("modi_ji_bkl", "res://assets/sounds/modi_ji_bkl.mp3")

func _load_sound(name: String, path: String) -> void:
	if ResourceLoader.exists(path):
		var s = load(path)
		if s:
			sounds[name] = s

func play(sound_name: String, pitch_randomness: float = 0.0, volume_db: float = 0.0) -> void:
	if not sounds.has(sound_name):
		return
		
	var stream = sounds[sound_name]
	var player = players[current_player_idx]
	current_player_idx = (current_player_idx + 1) % POOL_SIZE
	
	player.stream = stream
	player.volume_db = volume_db
	if pitch_randomness > 0.0:
		player.pitch_scale = randf_range(1.0 - pitch_randomness, 1.0 + pitch_randomness)
	else:
		player.pitch_scale = 1.0
	player.play()

func play_random(sound_names: Array[String], pitch_randomness: float = 0.0, volume_db: float = 0.0) -> void:
	if sound_names.is_empty():
		return
	var chosen = sound_names[randi() % sound_names.size()]
	play(chosen, pitch_randomness, volume_db)

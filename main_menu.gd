extends Control

const GAMES: Array[Dictionary] = [
	{
		"title": "RAGDOLL SANDBOX",
		"icon": "🤼",
		"desc": "Physics doll • Grab & Punch • Meme Faces",
		"scene": "res://games/ragdoll_sandbox/ragdoll_sandbox.tscn"
	},
	{
		"title": "DRAW BRIDGE",
		"icon": "🌉",
		"desc": "Draw Bridge • Motor Car • 8 Unique Levels",
		"scene": "res://games/draw_bridge/draw_bridge.tscn"
	},
	{
		"title": "SWING DASH",
		"icon": "🎯",
		"desc": "Grappling Hook • Dash Boost • 10 Levels",
		"scene": "res://games/swing_dash/swing_dash.tscn"
	},
	{
		"title": "SAVE THE DOGE",
		"icon": "🐕",
		"desc": "Physics Shield • Angry Bee Swarm • 5 Levels",
		"scene": "res://games/save_the_doge/save_the_doge.tscn"
	},
	{
		"title": "STAIR DISMOUNT",
		"icon": "🪜",
		"desc": "Ragdoll Stair Launch • Bone Fractures • High Score",
		"scene": "res://games/stair_dismount/stair_dismount.tscn"
	},
	{
		"title": "SLAP CHAMPION",
		"icon": "👋",
		"desc": "1v1 Slap Duel • Timing Meter • Meme Bosses",
		"scene": "res://games/slap_champion/slap_champion.tscn"
	},
	{
		"title": "CHAPPAL DODGE",
		"icon": "🩴",
		"desc": "Jump & Slide • Flying Slippers & Belans • Survival",
		"scene": "res://games/chappal_dodge/chappal_dodge.tscn"
	},
	{
		"title": "BOTTLE FLIP",
		"icon": "🍾",
		"desc": "Swipe Torque • Platform Streaks • Realistic Physics",
		"scene": "res://games/bottle_flip/bottle_flip.tscn"
	},
	{
		"title": "FLAPPY BRAINROT",
		"icon": "🕳️",
		"desc": "Flap & Screams • Meme Pillars • Endless Runner",
		"scene": "res://games/flappy_brainrot/flappy_brainrot.tscn"
	},
	{
		"title": "WHACK-A-MEME",
		"icon": "🔨",
		"desc": "3x3 Reaction Tapper • Doge & Troll • Avoid Bombs",
		"scene": "res://games/whack_a_meme/whack_a_meme.tscn"
	},
	{
		"title": "RED LIGHT GREEN LIGHT",
		"icon": "🔴",
		"desc": "Chalo vs Ruko Zara • Doll Laser Scanning • Escape",
		"scene": "res://games/red_light_green_light/red_light_green_light.tscn"
	},
	{
		"title": "TUG OF WAR",
		"icon": "🪢",
		"desc": "Fast Tap Mash • Toxic Slime Pit • 1P vs CPU & 2P",
		"scene": "res://games/tug_of_war/tug_of_war.tscn"
	},
	{
		"title": "MEME PLINKO",
		"icon": "🎰",
		"desc": "Bouncy Pegboard • Multiplier Buckets • Jackpots",
		"scene": "res://games/meme_plinko/meme_plinko.tscn"
	}
]

@onready var cards_container: VBoxContainer = $VBox/Scroll/GameCards
@onready var quit_btn: Button = $QuitBtn

func _ready() -> void:
	quit_btn.pressed.connect(_on_quit_pressed)
	_populate_game_cards()

func _populate_game_cards() -> void:
	for child in cards_container.get_children():
		child.queue_free()
		
	for game in GAMES:
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(580, 110)
		btn.add_theme_font_size_override("font_size", 18)
		btn.text = "%s  %s\n\n%s" % [game["icon"], game["title"], game["desc"]]
		btn.pressed.connect(_launch_game.bind(game["scene"]))
		cards_container.add_child(btn)

func _launch_game(scene_path: String) -> void:
	SoundManager.play("chalo")
	get_tree().change_scene_to_file(scene_path)

func _on_quit_pressed() -> void:
	SoundManager.play("vine_boom")
	get_tree().quit()

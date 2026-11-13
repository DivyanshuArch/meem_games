extends Node2D

const RAGDOLL_SCENE = preload("res://games/ragdoll_sandbox/ragdoll.tscn")

@onready var room_background: Node2D = $RoomBackground
@onready var furniture: Node2D = $Furniture
@onready var hud: Control = $CanvasLayer/HUD
@onready var character_menu: Control = $CanvasLayer/CharacterMenu
@onready var pause_menu: Control = $CanvasLayer/PauseMenu
@onready var instructions: Label = $CanvasLayer/Instructions

var current_ragdoll: Ragdoll = null
var current_emoji: String = "face1"

func _ready() -> void:
	$CanvasLayer/HUD/PauseBtn.pressed.connect(_open_pause_menu)
	$CanvasLayer/PauseMenu/VBox/ResumeBtn.pressed.connect(_resume_game)
	$CanvasLayer/PauseMenu/VBox/ResetBtn.pressed.connect(reset_room)
	$CanvasLayer/PauseMenu/VBox/ChangeCharBtn.pressed.connect(_open_character_menu)
	$CanvasLayer/CharacterMenu/VBox/BackBtn.pressed.connect(_on_character_menu_back)
	
	# Connect character picker buttons
	var char_buttons = $CanvasLayer/CharacterMenu/VBox/Grid.get_children()
	for i in range(char_buttons.size()):
		var btn = char_buttons[i]
		if btn is Button:
			if i == 0:
				btn.pressed.connect(_on_character_selected.bind("face1"))
			elif i == 1:
				btn.pressed.connect(_on_character_selected.bind("face2"))
			else:
				btn.pressed.connect(_on_character_selected.bind(btn.text))
			
	# Start directly into the game with face1
	reset_room()

func _open_character_menu() -> void:
	SoundManager.play("huh")
	get_tree().paused = true
	hud.visible = false
	pause_menu.visible = false
	character_menu.visible = true
	instructions.visible = false

func _on_character_selected(emoji: String) -> void:
	SoundManager.play("chalo")
	current_emoji = emoji
	character_menu.visible = false
	hud.visible = true
	instructions.visible = true
	get_tree().paused = false
	reset_room()
	
	# Fade instructions after 5 seconds
	var tween = create_tween()
	tween.tween_interval(5.0)
	tween.tween_property(instructions, "modulate:a", 0.0, 1.0)

func _on_character_menu_back() -> void:
	if current_ragdoll:
		_resume_game()
	else:
		_on_character_selected(current_emoji)

func _open_pause_menu() -> void:
	SoundManager.play("vine_boom")
	get_tree().paused = true
	hud.visible = false
	pause_menu.visible = true

func _resume_game() -> void:
	pause_menu.visible = false
	character_menu.visible = false
	hud.visible = true
	get_tree().paused = false

func reset_room() -> void:
	SoundManager.play("chalo")
	if current_ragdoll:
		current_ragdoll.queue_free()
		current_ragdoll = null
		
	current_ragdoll = RAGDOLL_SCENE.instantiate()
	current_ragdoll.position = Vector2(360, 450)
	add_child(current_ragdoll)
	current_ragdoll.set_character(current_emoji)
	_resume_game()

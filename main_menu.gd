extends Control

func _ready() -> void:
	$VBox/GameCards/RagdollBtn.pressed.connect(_on_ragdoll_pressed)
	$VBox/GameCards/DrawBridgeBtn.pressed.connect(_on_draw_bridge_pressed)
	$VBox/GameCards/SwingDashBtn.pressed.connect(_on_swing_dash_pressed)
	$QuitBtn.pressed.connect(_on_quit_pressed)

func _on_ragdoll_pressed() -> void:
	SoundManager.play("chalo")
	get_tree().change_scene_to_file("res://games/ragdoll_sandbox/ragdoll_sandbox.tscn")

func _on_draw_bridge_pressed() -> void:
	SoundManager.play("chalo")
	get_tree().change_scene_to_file("res://games/draw_bridge/draw_bridge.tscn")

func _on_swing_dash_pressed() -> void:
	SoundManager.play("chalo")
	get_tree().change_scene_to_file("res://games/swing_dash/swing_dash.tscn")

func _on_quit_pressed() -> void:
	SoundManager.play("vine_boom")
	get_tree().quit()

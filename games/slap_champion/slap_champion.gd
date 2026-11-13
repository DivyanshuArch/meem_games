class_name SlapChampionGame
extends Node2D

enum TurnState { PLAYER_AIMING, PLAYER_SLAPPING, OPPONENT_TURN, ROUND_OVER }

var current_state: TurnState = TurnState.PLAYER_AIMING
var needle_val: float = 0.0 # 0.0 to 1.0
var needle_speed: float = 2.4
var needle_dir: float = 1.0

var player_hp: float = 100.0
var max_player_hp: float = 100.0
var opponent_hp: float = 100.0
var max_opponent_hp: float = 100.0
var current_stage: int = 1

var player_offset: Vector2 = Vector2.ZERO
var opponent_offset: Vector2 = Vector2.ZERO
var opponent_name: String = "Trollface"

@onready var hud: Control = $CanvasLayer/HUD
@onready var slap_btn: Button = $CanvasLayer/HUD/SlapBtn
@onready var needle_indicator: ColorRect = $CanvasLayer/HUD/Meter/Needle
@onready var player_hp_bar: ColorRect = $CanvasLayer/HUD/PlayerHealth/BarBg/Fill
@onready var opponent_hp_bar: ColorRect = $CanvasLayer/HUD/OpponentHealth/BarBg/Fill
@onready var player_hp_label: Label = $CanvasLayer/HUD/PlayerHealth/Label
@onready var opponent_name_label: Label = $CanvasLayer/HUD/OpponentHealth/NameLabel
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_title: Label = $CanvasLayer/ResultScreen/Box/Title
@onready var next_btn: Button = $CanvasLayer/ResultScreen/Box/NextBtn
const FACE1_TEX = preload("res://assets/face1.png")
const FACE2_TEX = preload("res://assets/face2.png")

func _ready() -> void:
	slap_btn.pressed.connect(_on_slap_pressed)
	$CanvasLayer/HUD/RestartBtn.pressed.connect(reset_game)
	
	next_btn.pressed.connect(_next_opponent)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(reset_game)
	
	start_stage(1)

func start_stage(stage: int) -> void:
	current_stage = stage
	max_opponent_hp = 80.0 + stage * 40.0
	opponent_hp = max_opponent_hp
	player_hp = max_player_hp
	needle_speed = 2.2 + stage * 0.4
	
	var names = ["Trollface 😈", "Pepe the Frog 🐸", "Cheems Doge 🐕", "Gigachad 🗿", "Final Boss 🔥"]
	opponent_name = names[(stage - 1) % names.size()]
	opponent_name_label.text = opponent_name
	
	player_offset = Vector2.ZERO
	opponent_offset = Vector2.ZERO
	result_overlay.visible = false
	slap_btn.disabled = false
	current_state = TurnState.PLAYER_AIMING
	_update_hp_bars()

func reset_game() -> void:
	SoundManager.play("chalo")
	start_stage(1)

func _next_opponent() -> void:
	SoundManager.play("chalo")
	start_stage(current_stage + 1)

func _process(delta: float) -> void:
	if current_state == TurnState.PLAYER_AIMING:
		needle_val += needle_dir * needle_speed * delta
		if needle_val >= 1.0:
			needle_val = 1.0
			needle_dir = -1.0
		elif needle_val <= 0.0:
			needle_val = 0.0
			needle_dir = 1.0
			
		# Meter width is 360px
		needle_indicator.position.x = needle_val * 350.0
		
	queue_redraw()

func _on_slap_pressed() -> void:
	if current_state != TurnState.PLAYER_AIMING:
		return
		
	current_state = TurnState.PLAYER_SLAPPING
	slap_btn.disabled = true
	
	# Determine accuracy: distance from 0.5 (center)
	var accuracy = 1.0 - abs(needle_val - 0.5) * 2.0
	var damage = 0.0
	var is_crit = false
	
	if accuracy >= 0.85: # Green center
		damage = 60.0 + current_stage * 10.0
		is_crit = true
	elif accuracy >= 0.50: # Yellow zone
		damage = 35.0 + current_stage * 5.0
	else: # Red outer zone
		damage = 15.0
		
	# Execute Player Slap Animation
	var tween = create_tween()
	# Windup
	tween.tween_property(self, "player_offset:x", -40.0, 0.25)
	# Smash forward
	tween.tween_property(self, "player_offset:x", 120.0, 0.1)
	tween.tween_callback(func():
		_execute_player_hit(damage, is_crit)
	)
	# Recover
	tween.tween_property(self, "player_offset:x", 0.0, 0.3)
	tween.tween_interval(0.6)
	tween.tween_callback(_start_opponent_turn)

func _execute_player_hit(dmg: float, is_crit: bool) -> void:
	opponent_hp = max(opponent_hp - dmg, 0.0)
	_update_hp_bars()
	
	# Opponent reaction
	var opp_tween = create_tween()
	opp_tween.tween_property(self, "opponent_offset:x", 80.0, 0.08)
	opp_tween.tween_property(self, "opponent_offset:x", 0.0, 0.2)
	
	if is_crit:
		SoundManager.play("vine_boom")
		SoundManager.play("punch", 0.1)
		_spawn_floating_text(Vector2(500, 520), "PERFECT SLAP! 💥\n-%d HP" % int(dmg), Color("#EF4444"))
	else:
		SoundManager.play("slap", 0.15)
		_spawn_floating_text(Vector2(500, 520), "SLAP! -%d HP" % int(dmg), Color("#F59E0B"))

func _start_opponent_turn() -> void:
	if opponent_hp <= 0:
		_on_opponent_defeated()
		return
		
	current_state = TurnState.OPPONENT_TURN
	
	var tween = create_tween()
	# Opponent windup
	tween.tween_property(self, "opponent_offset:x", 40.0, 0.4)
	# Smash forward
	tween.tween_property(self, "opponent_offset:x", -120.0, 0.1)
	tween.tween_callback(_execute_opponent_hit)
	# Recover
	tween.tween_property(self, "opponent_offset:x", 0.0, 0.3)
	tween.tween_callback(func():
		if player_hp > 0:
			current_state = TurnState.PLAYER_AIMING
			slap_btn.disabled = false
	)

func _execute_opponent_hit() -> void:
	var dmg = randf_range(20.0, 35.0) + current_stage * 5.0
	player_hp = max(player_hp - dmg, 0.0)
	_update_hp_bars()
	
	var plyr_tween = create_tween()
	plyr_tween.tween_property(self, "player_offset:x", -70.0, 0.08)
	plyr_tween.tween_property(self, "player_offset:x", 0.0, 0.2)
	
	SoundManager.play("slap")
	_spawn_floating_text(Vector2(220, 520), "-%d HP" % int(dmg), Color("#EF4444"))
	
	if player_hp <= 0:
		_on_player_defeated()

func _on_opponent_defeated() -> void:
	current_state = TurnState.ROUND_OVER
	SoundManager.play("are_baap_re")
	SoundManager.play("anime_wow")
	
	# Opponent flies off screen
	var fly_tween = create_tween()
	fly_tween.tween_property(self, "opponent_offset", Vector2(400, -300), 0.6).set_trans(Tween.TRANS_BACK)
	
	result_title.text = "KNOCKOUT! 🏆"
	next_btn.visible = true
	result_overlay.visible = true

func _on_player_defeated() -> void:
	current_state = TurnState.ROUND_OVER
	SoundManager.play("aayein")
	
	var fly_tween = create_tween()
	fly_tween.tween_property(self, "player_offset", Vector2(-400, -300), 0.6).set_trans(Tween.TRANS_BACK)
	
	result_title.text = "YOU GOT SLAPPED! 💀"
	next_btn.visible = false
	result_overlay.visible = true

func _update_hp_bars() -> void:
	var p_pct = clamp(player_hp / max_player_hp, 0.0, 1.0)
	player_hp_bar.size.x = 220.0 * p_pct
	player_hp_label.text = "HP: %d/%d" % [int(player_hp), int(max_player_hp)]
	
	var o_pct = clamp(opponent_hp / max_opponent_hp, 0.0, 1.0)
	opponent_hp_bar.size.x = 220.0 * o_pct

func _spawn_floating_text(pos: Vector2, text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.position = pos
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "position:y", pos.y - 70.0, 0.8)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.8)
	tween.tween_callback(label.queue_free)

func _draw() -> void:
	# Arena background
	draw_rect(Rect2(0, 0, 720, 1280), Color("#0F172A"))
	draw_rect(Rect2(0, 750, 720, 530), Color("#1E293B"))
	draw_line(Vector2(0, 750), Vector2(720, 750), Color("#334155"), 4.0)
	
	# Arena spotlight
	draw_circle(Vector2(360, 740), 280.0, Color(1, 1, 1, 0.04))
	
	# Table / Podium in between
	draw_rect(Rect2(310, 640, 100, 150), Color("#475569"))
	draw_rect(Rect2(290, 630, 140, 16), Color("#64748B"))
	
	# Draw Player Figure (Left side)
	var p_base = Vector2(220, 720) + player_offset
	# Body
	draw_circle(p_base + Vector2(0, -90), 40.0, Color("#38BDF8")) # Blue jersey
	draw_rect(Rect2(p_base.x - 30, p_base.y - 80, 60, 90), Color("#0284C7"))
	# Head with face1 texture
	draw_circle(p_base + Vector2(0, -150), 38.0, Color("#0F172A"))
	draw_texture_rect(FACE1_TEX, Rect2(p_base.x - 35, p_base.y - 185, 70, 70), false)
	# Slapping arm
	draw_line(p_base + Vector2(15, -90), p_base + Vector2(55, -80), Color("#FDBA74"), 16.0)
	draw_circle(p_base + Vector2(55, -80), 12.0, Color("#FDBA74"))
	
	# Draw Opponent Figure (Right side)
	var o_base = Vector2(500, 720) + opponent_offset
	# Body
	draw_circle(o_base + Vector2(0, -90), 44.0, Color("#EF4444")) # Red jersey
	draw_rect(Rect2(o_base.x - 35, o_base.y - 80, 70, 90), Color("#DC2626"))
	# Head with face2 texture
	draw_circle(o_base + Vector2(0, -150), 40.0, Color("#0F172A"))
	draw_texture_rect(FACE2_TEX, Rect2(o_base.x - 37, o_base.y - 187, 74, 74), false)
	# Arm
	draw_line(o_base + Vector2(-15, -90), o_base + Vector2(-55, -80), Color("#FDBA74"), 16.0)
	draw_circle(o_base + Vector2(-55, -80), 12.0, Color("#FDBA74"))

class_name TugOfWarGame
extends Node2D

enum State { PLAYING, P1_WON, P2_WON }

var current_state: State = State.PLAYING
var rope_offset: float = 0.0 # -180 = P1 wins, +180 = P2/CPU wins
var is_2player: bool = false
var cpu_timer: float = 0.0
var cpu_pull_strength: float = 22.0
var tension_wobble: float = 0.0

# Base positions
const CENTER_X: float = 360.0
const ARENA_Y: float = 850.0
const WIN_THRESHOLD: float = 160.0

@onready var hud: Control = $CanvasLayer/HUD
@onready var pull_btn_p1: Button = $CanvasLayer/HUD/PullBtnP1
@onready var pull_btn_p2: Button = $CanvasLayer/HUD/PullBtnP2
@onready var mode_btn: Button = $CanvasLayer/HUD/ModeBtn
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_title: Label = $CanvasLayer/ResultScreen/Box/Title

const FACE1_TEX = preload("res://assets/face1.png")
const FACE2_TEX = preload("res://assets/face2.png")

func _ready() -> void:
	pull_btn_p1.pressed.connect(_on_p1_pull)
	pull_btn_p2.pressed.connect(_on_p2_pull)
	mode_btn.pressed.connect(_toggle_mode)
	
	$CanvasLayer/HUD/RestartBtn.pressed.connect(reset_game)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(reset_game)
	
	reset_game()

func reset_game() -> void:
	SoundManager.play("chalo")
	current_state = State.PLAYING
	rope_offset = 0.0
	cpu_timer = 0.0
	result_overlay.visible = false
	pull_btn_p1.disabled = false
	pull_btn_p2.visible = is_2player
	queue_redraw()

func _toggle_mode() -> void:
	is_2player = not is_2player
	mode_btn.text = "MODE: 2 PLAYERS" if is_2player else "MODE: 1P VS CPU"
	pull_btn_p2.visible = is_2player
	reset_game()

func _on_p1_pull() -> void:
	if current_state != State.PLAYING:
		return
	rope_offset -= 9.5
	SoundManager.play("punch", 0.1, -6.0)
	_check_win()

func _on_p2_pull() -> void:
	if current_state != State.PLAYING:
		return
	rope_offset += 9.5
	SoundManager.play("punch", 0.1, -6.0)
	_check_win()

func _unhandled_input(event: InputEvent) -> void:
	if current_state != State.PLAYING:
		return
	if event.is_action_pressed("ui_left"):
		_on_p1_pull()
	if is_2player and event.is_action_pressed("ui_right"):
		_on_p2_pull()

func _process(delta: float) -> void:
	if current_state != State.PLAYING:
		return
		
	tension_wobble += delta * 15.0
	
	# CPU logic if in 1P mode
	if not is_2player:
		cpu_timer += delta
		var tap_interval = randf_range(0.12, 0.22)
		if cpu_timer >= tap_interval:
			cpu_timer = 0.0
			rope_offset += randf_range(7.0, 10.5)
			_check_win()
			
	# Slight natural spring tension back to center
	rope_offset = move_toward(rope_offset, 0.0, delta * 8.0)
	queue_redraw()

func _check_win() -> void:
	if rope_offset <= -WIN_THRESHOLD:
		_p1_wins()
	elif rope_offset >= WIN_THRESHOLD:
		_p2_wins()

func _p1_wins() -> void:
	current_state = State.P1_WON
	pull_btn_p1.disabled = true
	SoundManager.play("fart")
	SoundManager.play("anime_wow")
	
	result_title.text = "PLAYER 1 WINS! 🏆\nOPPONENT FELL IN SLIME!"
	result_overlay.visible = true

func _p2_wins() -> void:
	current_state = State.P2_WON
	pull_btn_p1.disabled = true
	SoundManager.play("fart")
	SoundManager.play("fahhh")
	
	var loser_msg = "PLAYER 2 WINS! 🏆" if is_2player else "CPU WINS! YOU GOT DUNKED! 💀"
	result_title.text = loser_msg
	result_overlay.visible = true

func _draw() -> void:
	# Background
	draw_rect(Rect2(0, 0, 720, 1280), Color("#0F172A"))
	
	# Cliff Left
	draw_rect(Rect2(0, ARENA_Y, 260, 430), Color("#334155"))
	draw_rect(Rect2(0, ARENA_Y, 260, 16), Color("#64748B"))
	
	# Cliff Right
	draw_rect(Rect2(460, ARENA_Y, 260, 430), Color("#334155"))
	draw_rect(Rect2(460, ARENA_Y, 260, 16), Color("#64748B"))
	
	# Toxic Slime Pit in the Center (260 to 460)
	draw_rect(Rect2(260, ARENA_Y + 70, 200, 360), Color("#15803D"))
	# Slime bubbles
	var bubble_y = ARENA_Y + 70 + sin(tension_wobble) * 4.0
	draw_rect(Rect2(260, bubble_y, 200, 20), Color("#22C55E"))
	draw_circle(Vector2(320, bubble_y), 14.0, Color("#4ADE80"))
	draw_circle(Vector2(400, bubble_y), 18.0, Color("#4ADE80"))
	
	# Player 1 (Left character with face1)
	var p1_x = 160.0 + rope_offset
	var p1_y = ARENA_Y - 20.0
	draw_circle(Vector2(p1_x, p1_y - 60), 32.0, Color("#0F172A"))
	draw_texture_rect(FACE1_TEX, Rect2(p1_x - 30, p1_y - 90, 60, 60), false)
	draw_rect(Rect2(p1_x - 16, p1_y - 35, 32, 40), Color("#38BDF8"))
	
	# Player 2 / CPU (Right character with face2)
	var p2_x = 560.0 + rope_offset
	var p2_y = ARENA_Y - 20.0
	draw_circle(Vector2(p2_x, p2_y - 60), 32.0, Color("#0F172A"))
	draw_texture_rect(FACE2_TEX, Rect2(p2_x - 30, p2_y - 90, 60, 60), false)
	draw_rect(Rect2(p2_x - 16, p2_y - 35, 32, 40), Color("#EF4444"))
	
	# Rope connecting both characters
	var rope_start = Vector2(p1_x + 15, p1_y - 25)
	var rope_end = Vector2(p2_x - 15, p2_y - 25)
	var sag = sin(tension_wobble) * 3.0
	var rope_mid = (rope_start + rope_end) * 0.5 + Vector2(0, sag)
	
	draw_line(rope_start, rope_mid, Color("#D97706"), 12.0)
	draw_line(rope_mid, rope_end, Color("#D97706"), 12.0)
	
	# Red Marker Ribbon in center of rope
	draw_circle(rope_mid, 14.0, Color("#EF4444"))
	draw_line(rope_mid, rope_mid + Vector2(0, 18), Color("#DC2626"), 6.0)

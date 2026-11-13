class_name RedLightGreenLightGame
extends Node2D

enum LightState { GREEN, TURNING, RED }
enum GameState { PLAYING, WON, ELIMINATED }

var game_state: GameState = GameState.PLAYING
var light_state: LightState = LightState.GREEN
var state_timer: float = 0.0
var current_round: int = 1

# Player runner
var player_pos: Vector2 = Vector2(360, 1100)
var player_vel: Vector2 = Vector2.ZERO
var is_running: bool = false
const RUN_SPEED: float = 230.0
const FINISH_LINE_Y: float = 340.0
const START_LINE_Y: float = 1100.0

# Doll rotation (0.0 = back facing player [green], 1.0 = staring directly at player [red])
var doll_facing: float = 0.0

@onready var hud: Control = $CanvasLayer/HUD
@onready var light_banner: Label = $CanvasLayer/HUD/LightBanner
@onready var progress_bar: ColorRect = $CanvasLayer/HUD/ProgressContainer/BarBg/Fill
@onready var round_label: Label = $CanvasLayer/HUD/RoundBadge
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_title: Label = $CanvasLayer/ResultScreen/Box/Title
@onready var next_btn: Button = $CanvasLayer/ResultScreen/Box/NextBtn

const FACE1_TEX = preload("res://assets/face1.png")
const FACE2_TEX = preload("res://assets/face2.png")

func _ready() -> void:
	$CanvasLayer/HUD/RestartBtn.pressed.connect(reset_game)
	next_btn.pressed.connect(_next_round)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(reset_game)
	
	start_round(1)

func start_round(r: int) -> void:
	current_round = r
	round_label.text = "ROUND %d" % current_round
	game_state = GameState.PLAYING
	player_pos = Vector2(360, START_LINE_Y)
	player_vel = Vector2.ZERO
	is_running = false
	result_overlay.visible = false
	_set_green_light()

func reset_game() -> void:
	SoundManager.play("chalo")
	start_round(1)

func _next_round() -> void:
	SoundManager.play("chalo")
	start_round(current_round + 1)

func _set_green_light() -> void:
	light_state = LightState.GREEN
	light_banner.text = "🟢 CHALO! (RUN!)"
	light_banner.add_theme_color_override("font_color", Color("#22C55E"))
	state_timer = randf_range(2.2, 4.0) - min(current_round * 0.2, 1.2)
	doll_facing = 0.0
	SoundManager.play("chalo", 0.1)

func _set_turning() -> void:
	light_state = LightState.TURNING
	light_banner.text = "⚠️ RUKO ZARA..."
	light_banner.add_theme_color_override("font_color", Color("#F59E0B"))
	state_timer = 0.55
	SoundManager.play("ruko_zara")

func _set_red_light() -> void:
	light_state = LightState.RED
	light_banner.text = "🔴 RED LIGHT! FREEZE!"
	light_banner.add_theme_color_override("font_color", Color("#EF4444"))
	state_timer = randf_range(1.8, 3.2)
	doll_facing = 1.0

func _unhandled_input(event: InputEvent) -> void:
	if game_state != GameState.PLAYING:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		is_running = event.pressed
	elif event is InputEventScreenTouch:
		is_running = event.pressed
	elif event.is_action_pressed("ui_up") or event.is_action_pressed("ui_accept"):
		is_running = true
	elif event.is_action_released("ui_up") or event.is_action_released("ui_accept"):
		is_running = false

func _process(delta: float) -> void:
	if game_state != GameState.PLAYING:
		return
		
	# Doll state timer
	state_timer -= delta
	if state_timer <= 0.0:
		if light_state == LightState.GREEN:
			_set_turning()
		elif light_state == LightState.TURNING:
			_set_red_light()
		elif light_state == LightState.RED:
			_set_green_light()
			
	# Turning animation
	if light_state == LightState.TURNING:
		doll_facing = move_toward(doll_facing, 1.0, delta * 3.0)
	elif light_state == LightState.GREEN:
		doll_facing = move_toward(doll_facing, 0.0, delta * 4.0)
		
	# Player movement
	if is_running:
		player_vel = Vector2(0, -RUN_SPEED)
		player_pos.y += player_vel.y * delta
	else:
		player_vel = player_vel.move_toward(Vector2.ZERO, delta * 1200.0)
		player_pos.y += player_vel.y * delta
		
	# Progress bar
	var total_dist = START_LINE_Y - FINISH_LINE_Y
	var curr_dist = START_LINE_Y - player_pos.y
	var pct = clamp(curr_dist / total_dist, 0.0, 1.0)
	progress_bar.size.x = 240.0 * pct
	
	# Win condition
	if player_pos.y <= FINISH_LINE_Y:
		_win_game()
		return
		
	# Red light movement check (if player is running or still decelerating during Red Light)
	if light_state == LightState.RED and (is_running or player_vel.length() > 15.0):
		_eliminate_player()
		return
		
	queue_redraw()

func _eliminate_player() -> void:
	game_state = GameState.ELIMINATED
	SoundManager.play("vine_boom")
	SoundManager.play("fahhh")
	
	# Blast player back
	var tween = create_tween()
	tween.tween_property(self, "player_pos:y", player_pos.y + 160.0, 0.4).set_trans(Tween.TRANS_BACK)
	
	result_title.text = "ELIMINATED! 💀"
	next_btn.visible = false
	result_overlay.visible = true

func _win_game() -> void:
	game_state = GameState.WON
	SoundManager.play("anime_wow")
	
	result_title.text = "ESCAPED! 🏆"
	next_btn.visible = true
	result_overlay.visible = true

func _draw() -> void:
	# Sand courtyard
	draw_rect(Rect2(0, 0, 720, 1280), Color("#FEF08A", 0.4))
	
	# Tree and wall at top
	draw_rect(Rect2(0, 0, 720, 320), Color("#1E293B"))
	
	# Finish line (checkered)
	var check_w = 24.0
	for i in range(30):
		var col = Color.WHITE if i % 2 == 0 else Color("#1E293B")
		draw_rect(Rect2(i * check_w, FINISH_LINE_Y, check_w, 16), col)
		
	# Red scanning laser line if RED light
	if light_state == LightState.RED:
		draw_line(Vector2(0, FINISH_LINE_Y + 16), Vector2(720, FINISH_LINE_Y + 16), Color("#EF4444", 0.8), 4.0)
		draw_rect(Rect2(0, FINISH_LINE_Y + 16, 720, 750), Color(1, 0, 0, 0.05))
		
	# Draw Giant Doll at (360, 180)
	var doll_pos = Vector2(360, 180)
	# Body (Orange dress)
	draw_colored_polygon(PackedVector2Array([
		doll_pos + Vector2(-30, 20), doll_pos + Vector2(30, 20),
		doll_pos + Vector2(45, 90), doll_pos + Vector2(-45, 90)
	]), Color("#F97316"))
	
	if doll_facing > 0.5:
		# Front face with face2 texture
		draw_circle(doll_pos, 44.0, Color("#0F172A"))
		draw_texture_rect(FACE2_TEX, Rect2(doll_pos.x - 40, doll_pos.y - 40, 80, 80), false)
		if light_state == LightState.RED:
			draw_circle(doll_pos, 44.0, Color(1, 0, 0, 0.35))
	else:
		# Back of head (black pigtails)
		draw_circle(doll_pos, 42.0, Color("#0F172A"))
		draw_circle(doll_pos + Vector2(-46, -10), 16.0, Color("#0F172A"))
		draw_circle(doll_pos + Vector2(46, -10), 16.0, Color("#0F172A"))
		
	# Draw Player Runner
	var p_color = Color("#38BDF8") if game_state != GameState.ELIMINATED else Color("#94A3B8")
	# Body
	draw_circle(player_pos + Vector2(0, -35), 20.0, p_color)
	draw_rect(Rect2(player_pos.x - 14, player_pos.y - 30, 28, 30), Color("#0284C7"))
	# Head with face1 texture
	draw_circle(player_pos + Vector2(0, -65), 22.0, Color("#0F172A"))
	draw_texture_rect(FACE1_TEX, Rect2(player_pos.x - 20, player_pos.y - 85, 40, 40), false)
	# Green runner shirt number
	draw_circle(player_pos + Vector2(0, -20), 4.0, Color.WHITE)

class_name ChappalDodgeGame
extends Node2D

enum State { PLAYING, GAME_OVER }

var current_state: State = State.PLAYING
var survival_time: float = 0.0
var best_time: float = 0.0
var score: int = 0
var spawn_timer: float = 0.0
var next_spawn_delay: float = 1.4

# Player state
var player_pos: Vector2 = Vector2(180, 950)
var player_vel_y: float = 0.0
var is_grounded: bool = true
var is_crouching: bool = false
const GROUND_Y: float = 950.0
const GRAVITY: float = 1800.0
const JUMP_FORCE: float = -750.0
const MOVE_SPEED: float = 340.0

var move_dir: float = 0.0

# Projectiles array: each is { "pos": Vector2, "vel": Vector2, "type": String, "rot": float, "rot_speed": float, "passed": bool }
var projectiles: Array[Dictionary] = []

@onready var hud: Control = $CanvasLayer/HUD
@onready var time_label: Label = $CanvasLayer/HUD/TimeBadge
@onready var score_label: Label = $CanvasLayer/HUD/ScoreBadge
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_time: Label = $CanvasLayer/ResultScreen/Box/TimeLabel
@onready var result_score: Label = $CanvasLayer/ResultScreen/Box/ScoreLabel

const FACE1_TEX = preload("res://assets/face1.png")
const FACE2_TEX = preload("res://assets/face2.png")

func _ready() -> void:
	$CanvasLayer/HUD/RestartBtn.pressed.connect(reset_game)
	
	# Touch controls
	$CanvasLayer/HUD/TouchControls/LeftBtn.button_down.connect(func(): move_dir = -1.0)
	$CanvasLayer/HUD/TouchControls/LeftBtn.button_up.connect(func(): if move_dir < 0: move_dir = 0.0)
	$CanvasLayer/HUD/TouchControls/RightBtn.button_down.connect(func(): move_dir = 1.0)
	$CanvasLayer/HUD/TouchControls/RightBtn.button_up.connect(func(): if move_dir > 0: move_dir = 0.0)
	$CanvasLayer/HUD/TouchControls/JumpBtn.pressed.connect(_jump)
	$CanvasLayer/HUD/TouchControls/DuckBtn.button_down.connect(func(): is_crouching = true)
	$CanvasLayer/HUD/TouchControls/DuckBtn.button_up.connect(func(): is_crouching = false)
	
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(reset_game)
	
	reset_game()

func reset_game() -> void:
	SoundManager.play("chalo")
	current_state = State.PLAYING
	survival_time = 0.0
	score = 0
	spawn_timer = 0.0
	next_spawn_delay = 1.4
	projectiles.clear()
	player_pos = Vector2(180, GROUND_Y)
	player_vel_y = 0.0
	is_grounded = true
	is_crouching = false
	result_overlay.visible = false
	_update_hud()

func _jump() -> void:
	if is_grounded and not is_crouching and current_state == State.PLAYING:
		player_vel_y = JUMP_FORCE
		is_grounded = false
		SoundManager.play("fahhh", 0.2, -4.0)

func _unhandled_input(event: InputEvent) -> void:
	if current_state != State.PLAYING:
		return
		
	if event.is_action_pressed("ui_up") or event.is_action_pressed("ui_accept"):
		_jump()
	if event.is_action_pressed("ui_down"):
		is_crouching = true
	elif event.is_action_released("ui_down"):
		is_crouching = false

func _process(delta: float) -> void:
	if current_state != State.PLAYING:
		return
		
	survival_time += delta
	_update_hud()
	
	# Horizontal movement
	var k_dir = Input.get_axis("ui_left", "ui_right")
	var dir = k_dir if k_dir != 0 else move_dir
	player_pos.x = clamp(player_pos.x + dir * MOVE_SPEED * delta, 60.0, 660.0)
	
	# Vertical movement (jump & gravity)
	if not is_grounded:
		player_vel_y += GRAVITY * delta
		player_pos.y += player_vel_y * delta
		if player_pos.y >= GROUND_Y:
			player_pos.y = GROUND_Y
			player_vel_y = 0.0
			is_grounded = true
			
	# Spawner logic
	spawn_timer += delta
	if spawn_timer >= next_spawn_delay:
		spawn_timer = 0.0
		# Frequency accelerates
		next_spawn_delay = max(0.55, 1.4 - survival_time * 0.018)
		_spawn_projectile()
		
	# Update projectiles & collision
	_update_projectiles(delta)
	queue_redraw()

func _spawn_projectile() -> void:
	var roll = randf()
	var p_type = "chappal"
	var spawn_y = GROUND_Y - 25.0 # Low chappal (must jump!)
	var speed = 400.0 + randf_range(0, 150) + survival_time * 5.0
	
	if roll < 0.4:
		p_type = "chappal"
		spawn_y = GROUND_Y - 25.0
	elif roll < 0.75:
		p_type = "belan" # High rolling pin (must duck!)
		spawn_y = GROUND_Y - 95.0
	else:
		p_type = "broom" # Medium fast
		spawn_y = GROUND_Y - 55.0
		speed += 80.0
		
	projectiles.append({
		"pos": Vector2(760, spawn_y),
		"vel": Vector2(-speed, 0),
		"type": p_type,
		"rot": 0.0,
		"rot_speed": randf_range(8.0, 16.0),
		"passed": false
	})

func _update_projectiles(delta: float) -> void:
	# Player hitbox
	var p_height = 45.0 if is_crouching else 90.0
	var p_width = 40.0
	var p_rect = Rect2(player_pos.x - p_width * 0.5, player_pos.y - p_height, p_width, p_height)
	
	var i = projectiles.size() - 1
	while i >= 0:
		var p = projectiles[i]
		p["pos"] += p["vel"] * delta
		p["rot"] += p["rot_speed"] * delta
		
		# Projectile bounding circle
		var pradius = 18.0
		var p_circle_rect = Rect2(p["pos"].x - pradius, p["pos"].y - pradius, pradius * 2, pradius * 2)
		
		# Collision check
		if p_rect.intersects(p_circle_rect):
			_game_over()
			return
			
		# Passed player check
		if not p["passed"] and p["pos"].x < player_pos.x:
			p["passed"] = true
			score += 100
			
		# Offscreen check
		if p["pos"].x < -80:
			projectiles.remove_at(i)
			
		i -= 1

func _game_over() -> void:
	current_state = State.GAME_OVER
	SoundManager.play("vine_boom")
	SoundManager.play("are_baap_re", 0.1)
	
	if survival_time > best_time:
		best_time = survival_time
		
	result_time.text = "SURVIVED: %.1fs" % survival_time
	result_score.text = "SCORE: %d PTS" % score
	result_overlay.visible = true

func _update_hud() -> void:
	time_label.text = "⏱️ %.1fs" % survival_time
	score_label.text = "⭐ %d" % score

func _draw() -> void:
	# Room background
	draw_rect(Rect2(0, 0, 720, 1280), Color("#1E293B"))
	# Floor
	draw_rect(Rect2(0, GROUND_Y, 720, 1280 - GROUND_Y), Color("#0F172A"))
	draw_line(Vector2(0, GROUND_Y), Vector2(720, GROUND_Y), Color("#38BDF8"), 4.0)
	
	# Draw Angry Aunty on the right edge with face2
	draw_circle(Vector2(685, GROUND_Y - 90), 30.0, Color("#0F172A"))
	draw_texture_rect(FACE2_TEX, Rect2(655, GROUND_Y - 120, 60, 60), false)
	draw_rect(Rect2(660, GROUND_Y - 60, 50, 60), Color("#DC2626"))
	
	# Draw Player with face1
	var p_h = 45.0 if is_crouching else 90.0
	var head_y = player_pos.y - p_h + 16.0
	
	# Body
	draw_rect(Rect2(player_pos.x - 16, player_pos.y - p_h + 30, 32, p_h - 30), Color("#38BDF8"))
	# Head
	draw_circle(Vector2(player_pos.x, head_y), 20.0, Color("#0F172A"))
	draw_texture_rect(FACE1_TEX, Rect2(player_pos.x - 18, head_y - 18, 36, 36), false)
	
	# Draw Projectiles
	for p in projectiles:
		var pos = p["pos"]
		var rot = p["rot"]
		var p_type = p["type"]
		
		draw_set_transform(pos, rot, Vector2.ONE)
		if p_type == "chappal":
			# Brown rubber slipper shape
			draw_line(Vector2(-18, 0), Vector2(18, 0), Color("#78350F"), 12.0)
			draw_circle(Vector2(14, 0), 7.0, Color("#92400E"))
			draw_line(Vector2(-4, -6), Vector2(6, 6), Color("#FACC15"), 3.0)
			draw_line(Vector2(-4, 6), Vector2(6, -6), Color("#FACC15"), 3.0)
		elif p_type == "belan":
			# Wooden rolling pin
			draw_line(Vector2(-24, 0), Vector2(24, 0), Color("#D97706"), 14.0)
			draw_line(Vector2(-32, 0), Vector2(-24, 0), Color("#92400E"), 6.0)
			draw_line(Vector2(24, 0), Vector2(32, 0), Color("#92400E"), 6.0)
		else:
			# Broom
			draw_line(Vector2(-26, 0), Vector2(14, 0), Color("#B45309"), 6.0)
			draw_colored_polygon(PackedVector2Array([
				Vector2(14, -10), Vector2(30, -16), Vector2(30, 16), Vector2(14, 10)
			]), Color("#FDE047"))
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

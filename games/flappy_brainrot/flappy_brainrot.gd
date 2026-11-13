class_name FlappyBrainrotGame
extends Node2D

enum State { READY, PLAYING, DEAD }

var current_state: State = State.READY
var score: int = 0
var best_score: int = 0

# Bird physics
var bird_pos: Vector2 = Vector2(220, 600)
var bird_vel_y: float = 0.0
var bird_rot: float = 0.0
const GRAVITY: float = 1600.0
const FLAP_FORCE: float = -520.0

# Pipes
# Array of { "x": float, "gap_y": float, "passed": bool }
var pipes: Array[Dictionary] = []
const PIPE_SPEED: float = 240.0
const PIPE_GAP: float = 250.0
const PIPE_WIDTH: float = 80.0
var spawn_timer: float = 0.0
const SPAWN_INTERVAL: float = 1.7

@onready var hud: Control = $CanvasLayer/HUD
@onready var score_label: Label = $CanvasLayer/HUD/ScoreBadge
@onready var instruction_label: Label = $CanvasLayer/HUD/Instruction
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_score: Label = $CanvasLayer/ResultScreen/Box/ScoreLabel
@onready var result_best: Label = $CanvasLayer/ResultScreen/Box/BestLabel

const FACE1_TEX = preload("res://assets/face1.png")
const FACE2_TEX = preload("res://assets/face2.png")

func _ready() -> void:
	$CanvasLayer/HUD/RestartBtn.pressed.connect(reset_game)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(reset_game)
	
	reset_game()

func reset_game() -> void:
	current_state = State.READY
	score = 0
	pipes.clear()
	bird_pos = Vector2(220, 600)
	bird_vel_y = 0.0
	bird_rot = 0.0
	spawn_timer = 0.0
	result_overlay.visible = false
	instruction_label.text = "TAP TO FLAP & SCREAM!"
	instruction_label.visible = true
	_update_hud()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if current_state == State.DEAD:
		return
		
	var do_flap = false
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		do_flap = true
	elif event is InputEventScreenTouch and event.pressed:
		do_flap = true
	elif event.is_action_pressed("ui_accept") or event.is_action_pressed("ui_up"):
		do_flap = true
		
	if do_flap:
		if current_state == State.READY:
			current_state = State.PLAYING
			instruction_label.visible = false
		_flap()

func _flap() -> void:
	bird_vel_y = FLAP_FORCE
	# Random pitch-shifted meme screams
	var sounds = ["aayein", "fahhh", "huh", "are_baap_re"]
	var sound = sounds[randi() % sounds.size()]
	var pitch = 1.0 + min(score * 0.04, 0.6)
	SoundManager.play(sound, 0.1, 0.0)

func _process(delta: float) -> void:
	if current_state == State.PLAYING:
		# Gravity & Velocity
		bird_vel_y += GRAVITY * delta
		bird_pos.y += bird_vel_y * delta
		
		# Rotation based on velocity
		bird_rot = clamp(bird_vel_y * 0.0018, -0.6, 1.2)
		
		# Floor & Ceiling collision
		if bird_pos.y >= 1180 or bird_pos.y <= 40:
			_die()
			return
			
		# Pipe spawn
		spawn_timer += delta
		if spawn_timer >= SPAWN_INTERVAL:
			spawn_timer = 0.0
			var gap_y = randf_range(300.0, 900.0)
			pipes.append({
				"x": 760.0,
				"gap_y": gap_y,
				"passed": false
			})
			
		# Pipe movement & collision
		_update_pipes(delta)
		
	elif current_state == State.DEAD:
		# Fall to ground
		if bird_pos.y < 1180:
			bird_vel_y += GRAVITY * delta
			bird_pos.y += bird_vel_y * delta
			
	queue_redraw()

func _update_pipes(delta: float) -> void:
	var bird_radius = 24.0
	var i = pipes.size() - 1
	while i >= 0:
		var p = pipes[i]
		p["x"] -= PIPE_SPEED * delta
		
		# Check score pass
		if not p["passed"] and p["x"] + PIPE_WIDTH < bird_pos.x:
			p["passed"] = true
			score += 1
			_update_hud()
			SoundManager.play("chalo", 0.1, -4.0)
			
		# Hitbox checks
		# Top pipe rect: x to x + PIPE_WIDTH, 0 to gap_y - PIPE_GAP * 0.5
		var top_pipe_h = p["gap_y"] - PIPE_GAP * 0.5
		var top_rect = Rect2(p["x"], 0, PIPE_WIDTH, top_pipe_h)
		
		# Bottom pipe rect: x to x + PIPE_WIDTH, gap_y + PIPE_GAP * 0.5 to 1280
		var bot_y = p["gap_y"] + PIPE_GAP * 0.5
		var bot_rect = Rect2(p["x"], bot_y, PIPE_WIDTH, 1280 - bot_y)
		
		var bird_rect = Rect2(bird_pos.x - bird_radius, bird_pos.y - bird_radius, bird_radius * 2, bird_radius * 2)
		
		if bird_rect.intersects(top_rect) or bird_rect.intersects(bot_rect):
			_die()
			return
			
		# Despawn
		if p["x"] < -PIPE_WIDTH - 20.0:
			pipes.remove_at(i)
			
		i -= 1

func _die() -> void:
	if current_state == State.DEAD:
		return
	current_state = State.DEAD
	SoundManager.play("vine_boom")
	
	if score > best_score:
		best_score = score
		
	result_score.text = "SCORE: %d" % score
	result_best.text = "BEST: %d" % best_score
	result_overlay.visible = true

func _update_hud() -> void:
	score_label.text = "%d" % score

func _draw() -> void:
	# Sky background
	draw_rect(Rect2(0, 0, 720, 1280), Color("#38BDF8"))
	
	# Pipes
	for p in pipes:
		var x = p["x"]
		var gap_y = p["gap_y"]
		var top_h = gap_y - PIPE_GAP * 0.5
		var bot_y = gap_y + PIPE_GAP * 0.5
		
		# Top pipe
		draw_rect(Rect2(x, 0, PIPE_WIDTH, top_h), Color("#22C55E"))
		draw_rect(Rect2(x - 5, top_h - 30, PIPE_WIDTH + 10, 30), Color("#16A34A"))
		draw_line(Vector2(x, 0), Vector2(x, top_h), Color("#14532D"), 3.0)
		draw_line(Vector2(x + PIPE_WIDTH, 0), Vector2(x + PIPE_WIDTH, top_h), Color("#14532D"), 3.0)
		
		# Bottom pipe
		draw_rect(Rect2(x, bot_y, PIPE_WIDTH, 1280 - bot_y), Color("#22C55E"))
		draw_rect(Rect2(x - 5, bot_y, PIPE_WIDTH + 10, 30), Color("#16A34A"))
		draw_line(Vector2(x, bot_y), Vector2(x, 1280), Color("#14532D"), 3.0)
		draw_line(Vector2(x + PIPE_WIDTH, bot_y), Vector2(x + PIPE_WIDTH, 1280), Color("#14532D"), 3.0)
		
	# Ground
	draw_rect(Rect2(0, 1180, 720, 100), Color("#854D0E"))
	draw_rect(Rect2(0, 1180, 720, 18), Color("#22C55E"))
	
	# Draw Bird with face1/face2
	draw_set_transform(bird_pos, bird_rot, Vector2.ONE)
	var face_tex = FACE1_TEX if best_score % 2 == 0 else FACE2_TEX
	draw_circle(Vector2.ZERO, 28.0, Color("#0F172A"))
	draw_texture_rect(face_tex, Rect2(-26, -26, 52, 52), false)
	# Beak
	draw_colored_polygon(PackedVector2Array([
		Vector2(20, -4), Vector2(38, 2), Vector2(20, 10)
	]), Color("#F97316"))
	# Wing
	var wing_offset = sin(bird_vel_y * 0.05) * 6.0
	draw_circle(Vector2(-14, 6 + wing_offset), 10.0, Color("#EA580C"))
	draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

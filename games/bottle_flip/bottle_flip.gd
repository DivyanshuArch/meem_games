class_name BottleFlipGame
extends Node2D

enum State { READY, FLIPPING, LANDED, FAILED }

var current_state: State = State.READY
var score: int = 0
var streak: int = 0
var best_streak: int = 0

var drag_start: Vector2 = Vector2.ZERO
var is_dragging: bool = false

var bottle: RigidBody2D = null
var current_platform: StaticBody2D = null
var next_platform: StaticBody2D = null
var settle_timer: float = 0.0

@onready var camera: Camera2D = $Camera2D
@onready var hud: Control = $CanvasLayer/HUD
@onready var score_label: Label = $CanvasLayer/HUD/ScoreBadge
@onready var streak_label: Label = $CanvasLayer/HUD/StreakBadge
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_score: Label = $CanvasLayer/ResultScreen/Box/ScoreLabel
@onready var result_streak: Label = $CanvasLayer/ResultScreen/Box/StreakLabel

const FACE1_TEX = preload("res://assets/face1.png")
const FACE2_TEX = preload("res://assets/face2.png")

func _ready() -> void:
	$CanvasLayer/HUD/RestartBtn.pressed.connect(reset_game)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(reset_game)
	
	reset_game()

func reset_game() -> void:
	SoundManager.play("chalo")
	score = 0
	streak = 0
	settle_timer = 0.0
	result_overlay.visible = false
	_clear_all()
	
	# Initial platform at (200, 950)
	current_platform = _spawn_platform(Vector2(200, 950), 220.0)
	# Next target platform
	_spawn_next_target(Vector2(200, 950))
	# Spawn bottle on initial platform
	_spawn_bottle(Vector2(200, 890))
	
	camera.position = Vector2(360, 800)
	_update_hud()
	current_state = State.READY

func _clear_all() -> void:
	if bottle and is_instance_valid(bottle):
		bottle.queue_free()
		bottle = null
	if current_platform and is_instance_valid(current_platform):
		current_platform.queue_free()
		current_platform = null
	if next_platform and is_instance_valid(next_platform):
		next_platform.queue_free()
		next_platform = null

func _spawn_platform(pos: Vector2, width: float) -> StaticBody2D:
	var sb = StaticBody2D.new()
	sb.position = pos
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(width, 24.0)
	col.shape = shape
	sb.add_child(col)
	
	var canvas = Node2D.new()
	canvas.draw.connect(func():
		var r = Rect2(-width * 0.5, -12, width, 24)
		canvas.draw_rect(r, Color("#92400E"))
		canvas.draw_rect(Rect2(-width * 0.5, -12, width, 4), Color("#B45309"))
	)
	sb.add_child(canvas)
	add_child(sb)
	return sb

func _spawn_next_target(prev_pos: Vector2) -> void:
	var offset_x = randf_range(250.0, 360.0)
	var offset_y = randf_range(-80.0, 60.0)
	var target_pos = prev_pos + Vector2(offset_x, offset_y)
	target_pos.y = clamp(target_pos.y, 600.0, 1000.0)
	var width = max(110.0, 190.0 - streak * 6.0)
	next_platform = _spawn_platform(target_pos, width)

func _spawn_bottle(pos: Vector2) -> void:
	bottle = RigidBody2D.new()
	bottle.position = pos
	bottle.mass = 1.2
	bottle.gravity_scale = 1.8
	
	var mat = PhysicsMaterial.new()
	mat.bounce = 0.08
	mat.friction = 0.85
	bottle.physics_material_override = mat
	
	# Collision shape (bottle body)
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(28.0, 75.0)
	col.shape = shape
	bottle.add_child(col)
	
	# Visual bottle drawing
	var canvas = Node2D.new()
	canvas.draw.connect(func():
		# Body
		canvas.draw_rect(Rect2(-14, -20, 28, 57), Color("#38BDF8", 0.65))
		canvas.draw_rect(Rect2(-14, -20, 28, 57), Color("#0284C7"), false, 2.0)
		# Meme face badge on bottle label
		var face_tex = FACE1_TEX if streak % 2 == 0 else FACE2_TEX
		canvas.draw_rect(Rect2(-11, -12, 22, 22), Color.WHITE)
		canvas.draw_texture_rect(face_tex, Rect2(-10, -11, 20, 20), false)
		# Water fill inside
		canvas.draw_rect(Rect2(-12, 12, 24, 23), Color("#0284C7", 0.85))
		# Neck
		canvas.draw_rect(Rect2(-7, -35, 14, 15), Color("#38BDF8", 0.65))
		# Red Cap
		canvas.draw_rect(Rect2(-8, -38, 16, 6), Color("#EF4444"))
	)
	bottle.add_child(canvas)
	
	add_child(bottle)
	bottle.freeze = true

func _unhandled_input(event: InputEvent) -> void:
	if current_state != State.READY:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_dragging = true
			drag_start = event.position
		else:
			if is_dragging:
				is_dragging = false
				_launch_bottle(event.position)
				
	elif event is InputEventScreenTouch:
		if event.pressed:
			is_dragging = true
			drag_start = event.position
		else:
			if is_dragging:
				is_dragging = false
				_launch_bottle(event.position)

func _launch_bottle(release_pos: Vector2) -> void:
	var drag_vec = release_pos - drag_start
	# Swipe up detection: negative Y
	var impulse_y = clamp(-abs(drag_vec.y) * 4.5, -1100.0, -600.0)
	var impulse_x = clamp(drag_vec.x * 2.5 + 280.0, 200.0, 550.0)
	
	bottle.freeze = false
	bottle.apply_central_impulse(Vector2(impulse_x, impulse_y))
	# Apply torque for flip
	var torque = -12000.0 - abs(impulse_y) * 8.0
	bottle.apply_torque_impulse(torque)
	
	current_state = State.FLIPPING
	settle_timer = 0.0
	SoundManager.play("fahhh", 0.15, -2.0)

func _physics_process(delta: float) -> void:
	if not bottle or not is_instance_valid(bottle):
		return
		
	# Camera follows bottle
	var cam_target = bottle.position + Vector2(80, -50)
	camera.position = camera.position.lerp(cam_target, delta * 3.5)
	
	if current_state == State.FLIPPING:
		# Check if bottle fell below screen
		if bottle.position.y > 1200:
			_fail_flip()
			return
			
		var speed = bottle.linear_velocity.length()
		var ang_speed = abs(bottle.angular_velocity)
		
		# If bottle has slowed down on a surface
		if speed < 30.0 and ang_speed < 1.5:
			settle_timer += delta
			if settle_timer > 0.4:
				_check_landing()
		else:
			settle_timer = 0.0

func _check_landing() -> void:
	# Normalize rotation angle
	var angle_deg = fposmod(rad_to_deg(bottle.rotation) + 180.0, 360.0) - 180.0
	
	# Upright condition: within +/- 22 degrees
	if abs(angle_deg) <= 22.0:
		# Check if landed on or near next_platform
		var dist = bottle.position.distance_to(next_platform.position)
		if dist < 160.0 and bottle.position.y <= next_platform.position.y:
			_success_landing()
			return
			
	_fail_flip()

func _success_landing() -> void:
	current_state = State.LANDED
	streak += 1
	score += 100 * streak
	if streak > best_streak:
		best_streak = streak
	_update_hud()
	
	SoundManager.play("anime_wow")
	
	# Current platform becomes old, next becomes current
	if current_platform and is_instance_valid(current_platform):
		current_platform.queue_free()
	current_platform = next_platform
	next_platform = null
	
	_spawn_next_target(current_platform.position)
	
	# Ready for next flip
	var tween = create_tween()
	tween.tween_interval(0.6)
	tween.tween_callback(func():
		current_state = State.READY
	)

func _fail_flip() -> void:
	current_state = State.FAILED
	SoundManager.play("vine_boom")
	SoundManager.play("huh", 0.1)
	
	result_score.text = "SCORE: %d PTS" % score
	result_streak.text = "BEST STREAK: %d" % best_streak
	result_overlay.visible = true

func _update_hud() -> void:
	score_label.text = "⭐ %d" % score
	streak_label.text = "🔥 STREAK: %d" % streak

func _draw() -> void:
	# Room background
	draw_rect(Rect2(-1000, -1000, 3000, 3000), Color("#0F172A"))

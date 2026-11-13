class_name MemePlinkoGame
extends Node2D

enum State { PLAYING, GAME_OVER }

var current_state: State = State.PLAYING
var balls_left: int = 10
var total_score: int = 0
var active_balls: Array[RigidBody2D] = []

# Pegs and multipliers
var peg_nodes: Array[StaticBody2D] = []
# Multiplier buckets at bottom: width 720 / 7 = ~102.8px each
const BUCKET_COUNT: int = 7
const MULTIPLIERS: Array[float] = [10.0, 3.0, 1.2, 0.5, 1.2, 3.0, 10.0]
const BUCKET_COLORS: Array[String] = ["#EF4444", "#F59E0B", "#3B82F6", "#64748B", "#3B82F6", "#F59E0B", "#EF4444"]

@onready var hud: Control = $CanvasLayer/HUD
@onready var balls_label: Label = $CanvasLayer/HUD/BallsBadge
@onready var score_label: Label = $CanvasLayer/HUD/ScoreBadge
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_score: Label = $CanvasLayer/ResultScreen/Box/ScoreLabel
@onready var result_rank: Label = $CanvasLayer/ResultScreen/Box/RankLabel

const FACE1_TEX = preload("res://assets/face1.png")
const FACE2_TEX = preload("res://assets/face2.png")

func _ready() -> void:
	$CanvasLayer/HUD/RestartBtn.pressed.connect(reset_game)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(reset_game)
	
	_build_board()
	reset_game()

func reset_game() -> void:
	SoundManager.play("chalo")
	current_state = State.PLAYING
	balls_left = 10
	total_score = 0
	result_overlay.visible = false
	_clear_active_balls()
	_update_hud()

func _clear_active_balls() -> void:
	for b in active_balls:
		if is_instance_valid(b):
			b.queue_free()
	active_balls.clear()

func _build_board() -> void:
	# Clear old pegs
	for p in peg_nodes:
		if is_instance_valid(p):
			p.queue_free()
	peg_nodes.clear()
	
	# Wall colliders
	_create_static_wall(Rect2(0, 200, 24, 950))
	_create_static_wall(Rect2(696, 200, 24, 950))
	
	# Create triangular/hexagonal peg grid
	# 9 rows of pegs between y = 350 and y = 1000
	var start_y = 350.0
	var row_height = 70.0
	for row in range(9):
		var peg_count = 3 + row
		var row_y = start_y + row * row_height
		var spacing = 580.0 / (peg_count + 1)
		var start_x = 70.0 + spacing
		
		for col in range(peg_count):
			var px = start_x + col * spacing
			_create_peg(Vector2(px, row_y))

func _create_peg(pos: Vector2) -> void:
	var sb = StaticBody2D.new()
	sb.position = pos
	var col = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 8.0
	col.shape = circle
	sb.add_child(col)
	
	var mat = PhysicsMaterial.new()
	mat.bounce = 0.85
	mat.friction = 0.05
	sb.physics_material_override = mat
	
	add_child(sb)
	peg_nodes.append(sb)

func _create_static_wall(rect: Rect2) -> void:
	var sb = StaticBody2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.position + rect.size * 0.5
	sb.add_child(col)
	
	var mat = PhysicsMaterial.new()
	mat.bounce = 0.6
	sb.physics_material_override = mat
	add_child(sb)

func _unhandled_input(event: InputEvent) -> void:
	if current_state != State.PLAYING or balls_left <= 0:
		return
		
	var drop_x = 0.0
	var dropped = false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		if event.position.y < 300.0:
			drop_x = clamp(event.position.x, 80.0, 640.0)
			dropped = true
	elif event is InputEventScreenTouch and event.pressed:
		if event.position.y < 300.0:
			drop_x = clamp(event.position.x, 80.0, 640.0)
			dropped = true
			
	if dropped:
		_drop_ball(Vector2(drop_x, 240.0))

func _drop_ball(pos: Vector2) -> void:
	balls_left -= 1
	_update_hud()
	
	var ball = RigidBody2D.new()
	ball.position = pos
	ball.mass = 1.5
	ball.gravity_scale = 1.3
	
	var mat = PhysicsMaterial.new()
	mat.bounce = 0.75
	mat.friction = 0.1
	ball.physics_material_override = mat
	
	var col = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 16.0
	col.shape = circle
	ball.add_child(col)
	
	ball.contact_monitor = true
	ball.max_contacts_reported = 4
	ball.body_entered.connect(func(_other):
		SoundManager.play("slap", 0.4, -8.0)
	)
	
	# Procedural ball graphics with face1/face2
	var face_tex = FACE1_TEX if randf() < 0.5 else FACE2_TEX
	var canvas = Node2D.new()
	canvas.draw.connect(func():
		canvas.draw_circle(Vector2.ZERO, 16.0, Color("#0F172A"))
		canvas.draw_texture_rect(face_tex, Rect2(-14, -14, 28, 28), false)
	)
	ball.add_child(canvas)
	
	add_child(ball)
	active_balls.append(ball)
	SoundManager.play("chalo", 0.2, -6.0)

func _physics_process(_delta: float) -> void:
	if current_state != State.PLAYING:
		return
		
	var bucket_y = 1080.0
	var bucket_w = 720.0 / BUCKET_COUNT
	
	var i = active_balls.size() - 1
	while i >= 0:
		var ball = active_balls[i]
		if not is_instance_valid(ball):
			active_balls.remove_at(i)
			i -= 1
			continue
			
		if ball.position.y >= bucket_y:
			var b_idx = clamp(int(ball.position.x / bucket_w), 0, BUCKET_COUNT - 1)
			var mult = MULTIPLIERS[b_idx]
			var pts = int(100 * mult)
			total_score += pts
			
			if mult >= 10.0:
				SoundManager.play("anime_wow")
				_spawn_floating_text(ball.position, "JACKPOT! +%d 🌟" % pts, Color("#EF4444"))
			else:
				SoundManager.play("punch", 0.2, -4.0)
				_spawn_floating_text(ball.position, "+%d" % pts, Color("#F59E0B"))
				
			ball.queue_free()
			active_balls.remove_at(i)
			_update_hud()
			
			# Check game over
			if balls_left <= 0 and active_balls.is_empty():
				_game_over()
				
		i -= 1

func _spawn_floating_text(pos: Vector2, text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.position = pos + Vector2(-60, -30)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "position:y", pos.y - 70.0, 0.7)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free)

func _game_over() -> void:
	current_state = State.GAME_OVER
	SoundManager.play("anime_wow")
	
	result_score.text = "TOTAL: %d PTS" % total_score
	var rank = "AMATEUR DROPPER"
	if total_score > 3500:
		rank = "SSS - PLINKO MASTER! 🎰"
	elif total_score > 2000:
		rank = "S - HIGH ROLLER 💎"
	elif total_score > 1000:
		rank = "A - SOLID WINNER 🎯"
	result_rank.text = rank
	result_overlay.visible = true

func _update_hud() -> void:
	balls_label.text = "🟡 BALLS: %d" % balls_left
	score_label.text = "⭐ %d" % total_score

func _draw() -> void:
	# Board background
	draw_rect(Rect2(0, 0, 720, 1280), Color("#0F172A"))
	
	# Top Drop Zone Banner
	draw_rect(Rect2(24, 180, 672, 80), Color("#1E293B"))
	draw_rect(Rect2(24, 180, 672, 80), Color("#334155"), false, 4.0)
	
	# Side walls
	draw_rect(Rect2(0, 180, 24, 950), Color("#475569"))
	draw_rect(Rect2(696, 180, 24, 950), Color("#475569"))
	
	# Draw pegs
	for p in peg_nodes:
		draw_circle(p.position, 8.0, Color("#38BDF8"))
		draw_circle(p.position, 5.0, Color.WHITE)
		
	# Draw bottom multiplier buckets
	var bucket_w = 720.0 / BUCKET_COUNT
	var bucket_y = 1080.0
	for i in range(BUCKET_COUNT):
		var bx = i * bucket_w
		draw_rect(Rect2(bx, bucket_y, bucket_w, 200), Color(BUCKET_COLORS[i]))
		draw_rect(Rect2(bx, bucket_y, bucket_w, 200), Color("#0F172A"), false, 4.0)
		
		# Multiplier label
		var m_str = "%sx" % str(MULTIPLIERS[i])
		draw_string(ThemeDB.fallback_font, Vector2(bx + bucket_w * 0.5 - 20, bucket_y + 50), m_str, HORIZONTAL_ALIGNMENT_CENTER, -1, 20, Color.WHITE)

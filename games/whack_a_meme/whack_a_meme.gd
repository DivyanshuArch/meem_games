class_name WhackAMemeGame
extends Node2D

enum State { PLAYING, GAME_OVER }

var current_state: State = State.PLAYING
var time_left: float = 30.0
var score: int = 0
var combo: int = 0
var best_score: int = 0

# 9 Hole positions in 3x3 grid
var hole_positions: Array[Vector2] = []
# Each mole in active_moles: { "idx": int, "type": String, "pos": Vector2, "scale_y": float, "timer": float, "is_hit": bool }
var active_moles: Dictionary = {}
var spawn_cooldown: float = 0.0

@onready var hud: Control = $CanvasLayer/HUD
@onready var time_label: Label = $CanvasLayer/HUD/TimeBadge
@onready var score_label: Label = $CanvasLayer/HUD/ScoreBadge
@onready var combo_label: Label = $CanvasLayer/HUD/ComboBadge
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_score: Label = $CanvasLayer/ResultScreen/Box/ScoreLabel
@onready var result_rank: Label = $CanvasLayer/ResultScreen/Box/RankLabel

const FACE1_TEX = preload("res://assets/face1.png")
const FACE2_TEX = preload("res://assets/face2.png")

func _ready() -> void:
	$CanvasLayer/HUD/RestartBtn.pressed.connect(reset_game)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(reset_game)
	
	# Generate 3x3 grid centered in portrait screen
	var start_x = 160.0
	var start_y = 480.0
	var spacing_x = 200.0
	var spacing_y = 200.0
	for row in range(3):
		for col in range(3):
			hole_positions.append(Vector2(start_x + col * spacing_x, start_y + row * spacing_y))
			
	reset_game()

func reset_game() -> void:
	SoundManager.play("chalo")
	current_state = State.PLAYING
	time_left = 30.0
	score = 0
	combo = 0
	active_moles.clear()
	spawn_cooldown = 0.4
	result_overlay.visible = false
	_update_hud()
	queue_redraw()

func _unhandled_input(event: InputEvent) -> void:
	if current_state != State.PLAYING:
		return
		
	var tap_pos = Vector2.ZERO
	var tapped = false
	
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		tap_pos = event.position
		tapped = true
	elif event is InputEventScreenTouch and event.pressed:
		tap_pos = event.position
		tapped = true
		
	if tapped:
		_check_hit(tap_pos)

func _check_hit(pos: Vector2) -> void:
	for hole_idx in active_moles.keys():
		var mole = active_moles[hole_idx]
		if mole["is_hit"]:
			continue
			
		var hole_pos = hole_positions[hole_idx]
		var hit_center = hole_pos + Vector2(0, -mole["scale_y"] * 45.0)
		if pos.distance_to(hit_center) < 65.0:
			mole["is_hit"] = true
			_process_mole_hit(mole, hit_center)
			break

func _process_mole_hit(mole: Dictionary, pos: Vector2) -> void:
	var mtype = mole["type"]
	if mtype == "bomb":
		combo = 0
		score = max(0, score - 200)
		SoundManager.play("vine_boom")
		_spawn_floating_text(pos, "BOOM! -200 💀", Color("#EF4444"))
	else:
		combo += 1
		var pts = 100
		if mtype == "pepe":
			pts = 150
		elif mtype == "troll":
			pts = 200
			
		var multiplier = 2 if combo >= 5 else 1
		var final_pts = pts * multiplier
		score += final_pts
		
		SoundManager.play("punch", 0.15)
		var text = "+%d" % final_pts
		if multiplier == 2:
			text += " (FEVER! 🔥)"
		_spawn_floating_text(pos, text, Color("#22C55E") if multiplier == 1 else Color("#F59E0B"))
		
	_update_hud()
	queue_redraw()

func _process(delta: float) -> void:
	if current_state != State.PLAYING:
		return
		
	time_left -= delta
	if time_left <= 0.0:
		time_left = 0.0
		_game_over()
		return
		
	_update_hud()
	
	# Spawn moles
	spawn_cooldown -= delta
	if spawn_cooldown <= 0.0:
		spawn_cooldown = randf_range(0.35, 0.7)
		_try_spawn_mole()
		
	# Update active moles
	var to_remove = []
	for idx in active_moles.keys():
		var m = active_moles[idx]
		m["timer"] -= delta
		if m["is_hit"]:
			m["scale_y"] = max(0.0, m["scale_y"] - delta * 5.0)
			if m["scale_y"] <= 0.0:
				to_remove.append(idx)
		else:
			if m["timer"] > 0.4:
				# Pop up
				m["scale_y"] = min(1.0, m["scale_y"] + delta * 6.0)
			else:
				# Sink back down
				m["scale_y"] = max(0.0, m["scale_y"] - delta * 4.0)
				if m["scale_y"] <= 0.0:
					to_remove.append(idx)
					if m["type"] != "bomb":
						combo = 0 # Missed a meme
						_update_hud()
						
	for idx in to_remove:
		active_moles.erase(idx)
		
	queue_redraw()

func _try_spawn_mole() -> void:
	var available_holes: Array[int] = []
	for i in range(hole_positions.size()):
		if not active_moles.has(i):
			available_holes.append(i)
			
	if available_holes.is_empty():
		return
		
	var chosen_idx = available_holes[randi() % available_holes.size()]
	var roll = randf()
	var mole_type = "face1"
	if roll < 0.2:
		mole_type = "bomb"
	elif roll < 0.6:
		mole_type = "face1"
	else:
		mole_type = "face2"
		
	active_moles[chosen_idx] = {
		"idx": chosen_idx,
		"type": mole_type,
		"scale_y": 0.0,
		"timer": randf_range(1.1, 1.8),
		"is_hit": false
	}

func _spawn_floating_text(pos: Vector2, text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.position = pos + Vector2(-60, -30)
	label.add_theme_font_size_override("font_size", 22)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "position:y", pos.y - 70.0, 0.6)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.6)
	tween.tween_callback(label.queue_free)

func _game_over() -> void:
	current_state = State.GAME_OVER
	SoundManager.play("anime_wow")
	
	if score > best_score:
		best_score = score
		
	result_score.text = "SCORE: %d PTS" % score
	var rank = "AMATEUR SLAPPER"
	if score > 4500:
		rank = "SSS - MEME GOD! 👑"
	elif score > 3000:
		rank = "S - FASTEST HANDS IN THE WEST ⚡"
	elif score > 1800:
		rank = "A - SOLID MEME HUNTER 🎯"
	elif score > 800:
		rank = "B - CASUAL TAPPER"
	result_rank.text = rank
	result_overlay.visible = true

func _update_hud() -> void:
	time_label.text = "⏱️ %.1fs" % time_left
	score_label.text = "⭐ %d" % score
	combo_label.text = "🔥 COMBO: x%d" % combo if combo >= 2 else ""

func _draw() -> void:
	# Arcade wood cabinet
	draw_rect(Rect2(0, 0, 720, 1280), Color("#1E1B4B"))
	draw_rect(Rect2(40, 360, 640, 680), Color("#78350F"))
	draw_rect(Rect2(40, 360, 640, 680), Color("#B45309"), false, 8.0)
	
	# Draw holes & active moles
	for i in range(hole_positions.size()):
		var h_pos = hole_positions[i]
		
		# Draw active mole popping out
		if active_moles.has(i):
			var mole = active_moles[i]
			var sy = mole["scale_y"]
			var mtype = mole["type"]
			var mole_center = h_pos + Vector2(0, -sy * 45.0)
			
			if mtype == "bomb":
				draw_circle(mole_center, 34.0 * sy, Color("#18181B"))
				# Fuse spark
				draw_line(mole_center + Vector2(0, -34.0 * sy), mole_center + Vector2(10, -48.0 * sy), Color("#EA580C"), 4.0)
				draw_circle(mole_center + Vector2(10, -48.0 * sy), 6.0, Color("#FACC15"))
				draw_circle(mole_center + Vector2(-8, -4), 5.0, Color.RED)
				draw_circle(mole_center + Vector2(8, -4), 5.0, Color.RED)
			elif mtype == "face2":
				draw_circle(mole_center, 36.0 * sy, Color("#0F172A"))
				var r = 34.0 * sy
				draw_texture_rect(FACE2_TEX, Rect2(mole_center.x - r, mole_center.y - r, r * 2, r * 2), false)
			else: # face1
				draw_circle(mole_center, 36.0 * sy, Color("#0F172A"))
				var r = 34.0 * sy
				draw_texture_rect(FACE1_TEX, Rect2(mole_center.x - r, mole_center.y - r, r * 2, r * 2), false)
				
		# Hole ellipse (rim & dark interior)
		draw_set_transform(h_pos, 0.0, Vector2(1.0, 0.45))
		draw_circle(Vector2.ZERO, 65.0, Color("#292524"))
		draw_arc(Vector2.ZERO, 65.0, 0, TAU, 24, Color("#44403C"), 8.0)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)

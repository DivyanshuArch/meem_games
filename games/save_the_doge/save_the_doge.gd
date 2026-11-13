class_name SaveTheDogeGame
extends Node2D

const DOGE_SCENE = preload("res://games/save_the_doge/doge.gd")
const BEE_SCENE = preload("res://games/save_the_doge/bee.gd")

enum State { DRAWING, DEFENDING, WON, LOST }

var current_state: State = State.DRAWING
var current_level_idx: int = 0
var defend_time_left: float = 5.0
var active_doge: SaveTheDogeCharacter = null
var active_bees: Array[DogeBee] = []
var terrain_nodes: Array[Node2D] = []

@onready var ink_drawer: DogeInkDrawer = $InkDrawer
@onready var hud: Control = $CanvasLayer/HUD
@onready var level_label: Label = $CanvasLayer/HUD/LevelBadge
@onready var instruction_label: Label = $CanvasLayer/HUD/Instruction
@onready var timer_label: Label = $CanvasLayer/HUD/TimerBadge
@onready var ink_bar: ColorRect = $CanvasLayer/HUD/InkContainer/BarBg/InkBar
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_title: Label = $CanvasLayer/ResultScreen/Box/Title
@onready var next_btn: Button = $CanvasLayer/ResultScreen/Box/NextBtn

func _ready() -> void:
	ink_drawer.ink_changed.connect(_on_ink_changed)
	ink_drawer.drawing_finished.connect(_on_drawing_finished)
	
	$CanvasLayer/HUD/RestartBtn.pressed.connect(_restart_level)
	
	next_btn.pressed.connect(_next_level)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(_restart_level)
	
	load_level(0)

func load_level(idx: int) -> void:
	current_level_idx = idx % SaveTheDogeLevels.LEVELS.size()
	var lvl = SaveTheDogeLevels.LEVELS[current_level_idx]
	current_state = State.DRAWING
	defend_time_left = 5.0
	result_overlay.visible = false
	timer_label.visible = false
	instruction_label.text = "DRAW A SHIELD FOR DOGE!"
	instruction_label.visible = true
	level_label.text = "LEVEL %d: %s" % [lvl["id"], lvl["name"]]
	
	_clear_level()
	_build_terrain(lvl)
	_spawn_doge(lvl)
	ink_drawer.setup(lvl["ink"])
	
	queue_redraw()

func _clear_level() -> void:
	for n in terrain_nodes:
		if is_instance_valid(n):
			n.queue_free()
	terrain_nodes.clear()
	
	for b in active_bees:
		if is_instance_valid(b):
			b.queue_free()
	active_bees.clear()
	
	if active_doge and is_instance_valid(active_doge):
		active_doge.queue_free()
		active_doge = null

func _build_terrain(lvl: Dictionary) -> void:
	# Platforms
	for p in lvl["platforms"]:
		var sb = StaticBody2D.new()
		var col = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		var r: Rect2 = p["rect"]
		rect_shape.size = r.size
		col.shape = rect_shape
		col.position = r.position + r.size * 0.5
		sb.add_child(col)
		add_child(sb)
		terrain_nodes.append(sb)
	
	# Hazards
	for h in lvl["hazards"]:
		var area = Area2D.new()
		area.add_to_group("hazards")
		var col = CollisionShape2D.new()
		var rect_shape = RectangleShape2D.new()
		var r: Rect2 = h["rect"]
		rect_shape.size = r.size
		col.shape = rect_shape
		col.position = r.position + r.size * 0.5
		area.add_child(col)
		add_child(area)
		terrain_nodes.append(area)

func _spawn_doge(lvl: Dictionary) -> void:
	active_doge = SaveTheDogeCharacter.new()
	active_doge.position = lvl["doge_pos"]
	active_doge.set_character(lvl.get("doge_type", "doge"))
	active_doge.stung.connect(_on_doge_stung)
	add_child(active_doge)

func _on_drawing_finished() -> void:
	if current_state != State.DRAWING:
		return
	current_state = State.DEFENDING
	instruction_label.text = "SURVIVE FOR 5 SECONDS!"
	timer_label.visible = true
	SoundManager.play("ruko_zara")
	
	if active_doge:
		active_doge.set_mood(SaveTheDogeCharacter.Mood.SCARED)
		
	_release_bees()

func _release_bees() -> void:
	var lvl = SaveTheDogeLevels.LEVELS[current_level_idx]
	var hives: Array = lvl["hives"]
	var count_per_hive: int = lvl.get("bees_per_hive", 6)
	
	for hive_pos in hives:
		for i in range(count_per_hive):
			var bee = DogeBee.new()
			bee.position = hive_pos + Vector2(randf_range(-15, 15), randf_range(-15, 15))
			add_child(bee)
			active_bees.append(bee)
			bee.launch(active_doge, 220.0)

func _process(delta: float) -> void:
	if current_state == State.DEFENDING:
		defend_time_left -= delta
		timer_label.text = "⏱️ %.1fs" % max(defend_time_left, 0.0)
		
		# Check if Doge fell off screen
		if active_doge and active_doge.global_position.y > 1350:
			_on_doge_stung()
			
		if defend_time_left <= 0.0:
			_on_level_won()

func _on_doge_stung() -> void:
	if current_state == State.WON or current_state == State.LOST:
		return
	current_state = State.LOST
	instruction_label.text = "DOGE GOT STUNG! 💀"
	result_title.text = "DOGE FELL! 😭"
	next_btn.visible = false
	result_overlay.visible = true

func _on_level_won() -> void:
	if current_state != State.DEFENDING:
		return
	current_state = State.WON
	instruction_label.text = "DOGE SURVIVED! 🎉"
	result_title.text = "SAFE AND SOUND! 🏆"
	next_btn.visible = true
	result_overlay.visible = true
	SoundManager.play("anime_wow")
	if active_doge:
		active_doge.set_mood(SaveTheDogeCharacter.Mood.HAPPY)

func _on_ink_changed(current: float, max_val: float) -> void:
	var pct = clamp(current / max_val, 0.0, 1.0)
	ink_bar.size.x = 240.0 * pct

func _restart_level() -> void:
	SoundManager.play("chalo")
	load_level(current_level_idx)

func _next_level() -> void:
	SoundManager.play("chalo")
	load_level(current_level_idx + 1)

func _draw() -> void:
	# Draw background sky & clouds
	draw_rect(Rect2(0, 0, 720, 1280), Color("#7DD3FC"))
	
	# Draw level terrain and hives
	var lvl = SaveTheDogeLevels.LEVELS[current_level_idx]
	for p in lvl["platforms"]:
		var r: Rect2 = p["rect"]
		draw_rect(r, p["color"])
		draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 8), Color("#86EFAC"))
		
	for h in lvl["hazards"]:
		var r: Rect2 = h["rect"]
		if h["type"] == "lava":
			draw_rect(r, Color("#EF4444"))
			draw_rect(Rect2(r.position.x, r.position.y, r.size.x, 6), Color("#F97316"))
		elif h["type"] == "spikes":
			# Draw spike triangles
			var spike_w = 20.0
			var count = int(r.size.x / spike_w)
			for i in range(count):
				var sx = r.position.x + i * spike_w
				var sy = r.position.y + r.size.y
				draw_colored_polygon(PackedVector2Array([
					Vector2(sx, sy), Vector2(sx + spike_w * 0.5, r.position.y), Vector2(sx + spike_w, sy)
				]), Color("#475569"))
				
	# Draw beehives
	for hive_pos in lvl["hives"]:
		draw_circle(hive_pos, 28.0, Color("#D97706"))
		draw_circle(hive_pos, 22.0, Color("#F59E0B"))
		draw_circle(hive_pos + Vector2(0, 6), 9.0, Color("#78350F"))
		draw_arc(hive_pos, 28.0, 0, TAU, 16, Color("#92400E"), 3.0)

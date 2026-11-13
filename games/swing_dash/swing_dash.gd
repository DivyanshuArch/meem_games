extends Node2D

const PLAYER_SCENE = preload("res://games/swing_dash/player.tscn")
const ANCHOR_SCENE = preload("res://games/swing_dash/anchor.tscn")

const SCREEN_W: float = 720.0
const SCREEN_H: float = 1280.0

enum State { MENU, LEVEL_SELECT, PLAYING, WIN, LOSE }

var current_state: State = State.MENU
var current_level_idx: int = 0
var unlocked_level: int = 1

var active_player: SwingPlayer = null
var active_anchors: Array[SwingAnchor] = []
var platform_bodies: Array[StaticBody2D] = []
var confetti_particles: Array[Dictionary] = []

@onready var camera: Camera2D = $Camera2D
@onready var world_container: Node2D = $WorldContainer
@onready var hud: Control = $CanvasLayer/HUD
@onready var level_label: Label = $CanvasLayer/HUD/LevelBadge
@onready var instruction_label: Label = $CanvasLayer/HUD/Instructions
@onready var main_menu_overlay: Control = $CanvasLayer/MainMenu
@onready var level_select_overlay: Control = $CanvasLayer/LevelSelect
@onready var win_overlay: Control = $CanvasLayer/WinScreen
@onready var lose_overlay: Control = $CanvasLayer/LoseScreen

func _ready() -> void:
	$CanvasLayer/MainMenu/Box/PlayBtn.pressed.connect(_on_play_current)
	$CanvasLayer/MainMenu/Box/LevelsBtn.pressed.connect(_open_level_select)
	$CanvasLayer/LevelSelect/Box/BackBtn.pressed.connect(_open_main_menu)
	$CanvasLayer/HUD/MenuBtn.pressed.connect(_open_main_menu)
	
	$CanvasLayer/WinScreen/Box/NextBtn.pressed.connect(_on_next_level)
	$CanvasLayer/WinScreen/Box/BtnRow/ReplayBtn.pressed.connect(_restart_current_level)
	$CanvasLayer/WinScreen/Box/BtnRow/MenuBtn.pressed.connect(_open_main_menu)
	
	$CanvasLayer/LoseScreen/Box/BtnRow/RestartBtn.pressed.connect(_restart_current_level)
	$CanvasLayer/LoseScreen/Box/BtnRow/MenuBtn.pressed.connect(_open_main_menu)
	
	_populate_level_select()
	_open_main_menu()

func _open_main_menu() -> void:
	current_state = State.MENU
	_hide_all_screens()
	main_menu_overlay.visible = true

func _open_level_select() -> void:
	current_state = State.LEVEL_SELECT
	_hide_all_screens()
	_populate_level_select()
	level_select_overlay.visible = true

func _hide_all_screens() -> void:
	main_menu_overlay.visible = false
	level_select_overlay.visible = false
	win_overlay.visible = false
	lose_overlay.visible = false
	hud.visible = false

func _populate_level_select() -> void:
	var grid = $CanvasLayer/LevelSelect/Box/LevelGrid
	for child in grid.get_children():
		child.queue_free()
		
	for i in range(SwingDashLevels.LEVELS.size()):
		var btn = Button.new()
		btn.custom_minimum_size = Vector2(70, 70)
		btn.add_theme_font_size_override("font_size", 28)
		if i + 1 <= unlocked_level:
			btn.text = str(i + 1)
			btn.pressed.connect(load_level.bind(i))
		else:
			btn.text = "🔒"
			btn.disabled = true
		grid.add_child(btn)

func _on_play_current() -> void:
	SoundManager.play("chalo")
	load_level(min(current_level_idx, unlocked_level - 1))

func load_level(level_idx: int) -> void:
	current_level_idx = level_idx
	current_state = State.PLAYING
	_hide_all_screens()
	hud.visible = true
	level_label.text = "LEVEL " + str(current_level_idx + 1)
	
	if current_level_idx == 0:
		instruction_label.text = "HOLD TO SWING\nRELEASE FOR BOOST!"
		instruction_label.visible = true
		instruction_label.modulate.a = 1.0
	else:
		instruction_label.visible = false
		
	_clear_level()
	confetti_particles.clear()
	camera.position = Vector2(SCREEN_W * 0.5, SCREEN_H * 0.5)
	
	var lvl_data = SwingDashLevels.LEVELS[current_level_idx]
	var base_w: float = SCREEN_W
	var base_h: float = SCREEN_H
	var start_y: float = lvl_data["start"].get("y", 0.75) * base_h
	var end_y: float = lvl_data["end"].get("y", 0.75) * base_h
	
	# Create Start Platform
	var start_w = base_w * lvl_data["start"]["w"]
	_create_platform(0.0, start_y, start_w, base_h - start_y + 100.0, false)
	
	# Create End Platform
	var end_x = base_w * lvl_data["end"]["x"]
	var end_w = base_w * lvl_data["end"]["w"]
	_create_platform(end_x, end_y, end_w, base_h - end_y + 100.0, true)
	
	# Create Anchors
	for a_data in lvl_data["anchors"]:
		var a = ANCHOR_SCENE.instantiate()
		a.position = Vector2(base_w * a_data["x"], base_h * a_data["y"])
		world_container.add_child(a)
		active_anchors.append(a)
		
	# Create Player
	active_player = PLAYER_SCENE.instantiate()
	active_player.position = Vector2(start_w * 0.5, start_y - 20.0)
	active_player.setup_level(active_anchors, end_x)
	active_player.won.connect(_on_level_won)
	active_player.lost.connect(_on_level_lost)
	world_container.add_child(active_player)

func _clear_level() -> void:
	if active_player:
		active_player.queue_free()
		active_player = null
	for a in active_anchors:
		a.queue_free()
	active_anchors.clear()
	for p in platform_bodies:
		p.queue_free()
	platform_bodies.clear()

func _create_platform(x: float, y: float, w: float, h: float, is_end: bool) -> void:
	var body = StaticBody2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = Vector2(w, h)
	col.shape = shape
	col.position = Vector2(x + w * 0.5, y + h * 0.5)
	body.add_child(col)
	world_container.add_child(body)
	platform_bodies.append(body)
	body.set_meta("is_end", is_end)
	body.set_meta("rect", Rect2(x, y, w, h))

func _process(delta: float) -> void:
	if current_state == State.PLAYING and active_player:
		# Smooth camera horizontal follow
		var target_x = max(SCREEN_W * 0.5, active_player.position.x + 120.0)
		camera.position.x = lerp(camera.position.x, target_x, 8.0 * delta)
		camera.position.y = SCREEN_H * 0.5
		
	# Confetti physics
	for i in range(confetti_particles.size() - 1, -1, -1):
		var p = confetti_particles[i]
		p["pos"] += p["vel"] * delta
		p["vel"].y += 400.0 * delta # Gravity
		p["life"] -= delta
		if p["life"] <= 0.0:
			confetti_particles.remove_at(i)
			
	queue_redraw()

func _on_level_won() -> void:
	current_state = State.WIN
	if current_level_idx + 1 == unlocked_level and unlocked_level < SwingDashLevels.LEVELS.size():
		unlocked_level += 1
		
	_hide_all_screens()
	win_overlay.visible = true
	$CanvasLayer/WinScreen/Box/NextBtn.visible = current_level_idx < SwingDashLevels.LEVELS.size() - 1
	_spawn_confetti(active_player.position)

func _on_level_lost() -> void:
	current_state = State.LOSE
	_hide_all_screens()
	lose_overlay.visible = true

func _spawn_confetti(pos: Vector2) -> void:
	for i in range(70):
		var angle = randf_range(0, TAU)
		var spd = randf_range(200.0, 600.0)
		var p = {
			"pos": pos,
			"vel": Vector2(cos(angle), sin(angle) * 1.5 - 0.5) * spd,
			"size": randf_range(5.0, 10.0),
			"color": Color.from_hsv(randf(), 0.9, 1.0),
			"life": randf_range(1.5, 3.0)
		}
		confetti_particles.append(p)

func _on_next_level() -> void:
	if current_level_idx < SwingDashLevels.LEVELS.size() - 1:
		load_level(current_level_idx + 1)
	else:
		_open_main_menu()

func _restart_current_level() -> void:
	load_level(current_level_idx)

func _draw() -> void:
	var cam_x = camera.position.x - (SCREEN_W * 0.5)

	# 1. Sky
	draw_rect(Rect2(cam_x, 0, SCREEN_W, SCREEN_H), Color("#79D1ED"))

	# 2. Sun (parallax)
	draw_circle(Vector2(cam_x + 550.0 - cam_x * 0.05, 140.0), 45.0, Color("#FFF5B8"))

	# 3. Clouds (parallax)
	_draw_cloud(Vector2(cam_x + 150.0 - cam_x * 0.1, 200.0), 1.8)
	_draw_cloud(Vector2(cam_x + 500.0 - cam_x * 0.15, 280.0), 1.5)
	_draw_cloud(Vector2(cam_x + 900.0 - cam_x * 0.1, 160.0), 1.6)

	# 4. Hills (parallax)
	draw_circle(Vector2(240.0 + cam_x * 0.7, 1350.0), 450.0, Color("#A3E489"))
	draw_circle(Vector2(700.0 + cam_x * 0.6, 1300.0), 550.0, Color("#91D975"))
	draw_circle(Vector2(1150.0 + cam_x * 0.5, 1400.0), 500.0, Color("#7AC95B"))

	# 5. Platforms Visuals
	for p_body in platform_bodies:
		var rect: Rect2 = p_body.get_meta("rect")
		# Platform Dark Base
		draw_rect(rect, Color("#303030"))
		# Platform Grass Top
		draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 15.0), Color("#65B147"))

		# Checkered Goal Flag
		if p_body.get_meta("is_end"):
			var flag_x = rect.position.x + 80.0
			var flag_y = rect.position.y
			# Pole
			draw_line(Vector2(flag_x, flag_y), Vector2(flag_x, flag_y - 80.0), Color("#CCCCCC"), 5.0)
			# Flag
			draw_rect(Rect2(flag_x + 3, flag_y - 80, 50, 30), Color.WHITE)
			draw_rect(Rect2(flag_x + 3, flag_y - 80, 12.5, 15), Color("#222222"))
			draw_rect(Rect2(flag_x + 28, flag_y - 80, 12.5, 15), Color("#222222"))
			draw_rect(Rect2(flag_x + 15.5, flag_y - 65, 12.5, 15), Color("#222222"))
			draw_rect(Rect2(flag_x + 40.5, flag_y - 65, 12.5, 15), Color("#222222"))

	# 6. Confetti
	for p in confetti_particles:
		draw_circle(p["pos"], p["size"], p["color"])

func _draw_cloud(pos: Vector2, scale_factor: float) -> void:
	draw_circle(pos + Vector2(0, 0), 20 * scale_factor, Color(1, 1, 1, 0.8))
	draw_circle(pos + Vector2(15 * scale_factor, -10 * scale_factor), 25 * scale_factor, Color(1, 1, 1, 0.8))
	draw_circle(pos + Vector2(35 * scale_factor, 0), 20 * scale_factor, Color(1, 1, 1, 0.8))
	draw_rect(Rect2(pos.x, pos.y, 35 * scale_factor, 20 * scale_factor), Color(1, 1, 1, 0.8))

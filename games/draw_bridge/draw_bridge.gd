extends Node2D

const CAR_SCENE = preload("res://games/draw_bridge/car.tscn")
const FLAG_SCENE = preload("res://games/draw_bridge/flag.tscn")

enum State { MENU, LEVEL_SELECT, DRAWING, DRIVING, ENDED }

var current_state: State = State.MENU
var current_level_idx: int = 0
var unlocked_level: int = 1
var active_car: DrawBridgeCar = null
var active_flag: Area2D = null
var terrain_bodies: Array[StaticBody2D] = []

@onready var bridge_drawer: BridgeDrawer = $BridgeDrawer
@onready var hud: Control = $CanvasLayer/HUD
@onready var main_menu_overlay: Control = $CanvasLayer/MainMenu
@onready var level_select_overlay: Control = $CanvasLayer/LevelSelect
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var ink_container: Control = $CanvasLayer/HUD/InkContainer
@onready var ink_bar: ColorRect = $CanvasLayer/HUD/InkContainer/BarBg/InkBar
@onready var level_label: Label = $CanvasLayer/HUD/LevelBadge
@onready var instruction_label: Label = $CanvasLayer/HUD/Instruction

func _ready() -> void:
	bridge_drawer.ink_changed.connect(_on_ink_changed)
	bridge_drawer.bridge_completed.connect(_on_bridge_completed)
	
	$CanvasLayer/MainMenu/Box/PlayBtn.pressed.connect(_on_play_current)
	$CanvasLayer/MainMenu/Box/LevelsBtn.pressed.connect(_open_level_select)
	$CanvasLayer/LevelSelect/Box/BackBtn.pressed.connect(_open_main_menu)
	$CanvasLayer/HUD/RestartBtn.pressed.connect(_restart_current_level)
	$CanvasLayer/HUD/HomeBtn.pressed.connect(_open_main_menu)
	
	$CanvasLayer/ResultScreen/Box/NextBtn.pressed.connect(_on_next_level_pressed)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(_restart_current_level)
	$CanvasLayer/ResultScreen/Box/BtnRow/HomeBtn.pressed.connect(_open_main_menu)
	$CanvasLayer/ResultScreen/Box/BtnRow/ExitBtn.pressed.connect(_exit_to_hub)
	
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
	result_overlay.visible = false
	hud.visible = false

func _populate_level_select() -> void:
	var grid = $CanvasLayer/LevelSelect/Box/LevelGrid
	for child in grid.get_children():
		child.queue_free()
		
	for i in range(DrawBridgeLevels.LEVELS.size()):
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
	current_state = State.DRAWING
	_hide_all_screens()
	hud.visible = true
	ink_container.visible = true
	level_label.text = "LEVEL " + str(current_level_idx + 1)
	instruction_label.text = "DRAW A BRIDGE!"
	instruction_label.visible = true
	
	var tween = create_tween()
	tween.tween_interval(2.0)
	tween.tween_property(instruction_label, "modulate:a", 0.0, 0.5)
	
	_clear_level()
	
	var cfg = DrawBridgeLevels.LEVELS[current_level_idx]
	_build_terrain(cfg)
	
	# Instantiate Flag
	active_flag = FLAG_SCENE.instantiate()
	active_flag.position = Vector2(1200.0 * cfg["flag_pos"].x, 800.0 * cfg["flag_pos"].y)
	active_flag.goal_reached.connect(_on_level_won)
	add_child(active_flag)
	
	# Instantiate Car
	active_car = CAR_SCENE.instantiate()
	active_car.position = Vector2(1200.0 * cfg["car_pos"].x, 800.0 * cfg["car_pos"].y - 20.0)
	active_car.crashed.connect(_on_level_lost)
	add_child(active_car)
	
	# Setup Bridge Drawer
	bridge_drawer.setup(cfg["ink"])
	queue_redraw()

func _clear_level() -> void:
	if active_car:
		active_car.queue_free()
		active_car = null
	if active_flag:
		active_flag.queue_free()
		active_flag = null
	for b in terrain_bodies:
		b.queue_free()
	terrain_bodies.clear()

func _build_terrain(cfg: Dictionary) -> void:
	var terrain_data: Array = cfg["terrain"]
	for item in terrain_data:
		var x: float = item["x"] * 1200.0
		var w: float = item["w"] * 1200.0
		var y: float = item["y"] * 800.0
		var h: float = 800.0 - y
		
		var body = StaticBody2D.new()
		var col = CollisionShape2D.new()
		var shape = RectangleShape2D.new()
		shape.size = Vector2(w, h)
		col.shape = shape
		col.position = Vector2(x + w * 0.5, y + h * 0.5)
		body.add_child(col)
		add_child(body)
		terrain_bodies.append(body)

func _on_ink_changed(current: float, max_val: float) -> void:
	var pct = clamp(current / max_val, 0.0, 1.0)
	ink_bar.size.x = 240.0 * pct
	if pct < 0.2:
		ink_bar.color = Color("#EF5350")
	else:
		ink_bar.color = Color("#8BC34A")

func _on_bridge_completed() -> void:
	current_state = State.DRIVING
	ink_container.visible = false
	instruction_label.text = "GO!"
	instruction_label.modulate.a = 1.0
	instruction_label.visible = true
	SoundManager.play("ruko_zara")
	
	var tween = create_tween()
	tween.tween_interval(1.0)
	tween.tween_property(instruction_label, "modulate:a", 0.0, 0.5)
	
	if active_car:
		active_car.start_driving()

func _on_level_won() -> void:
	if current_state == State.ENDED:
		return
	current_state = State.ENDED
	if current_level_idx + 1 == unlocked_level and unlocked_level < DrawBridgeLevels.LEVELS.size():
		unlocked_level += 1
	SoundManager.play("modi_ji_bkl")
	_show_result_screen(true)

func _on_level_lost() -> void:
	if current_state == State.ENDED:
		return
	current_state = State.ENDED
	SoundManager.play("dun_dun_dun")
	_show_result_screen(false)

func _show_result_screen(won: bool) -> void:
	_hide_all_screens()
	result_overlay.visible = true
	var title = $CanvasLayer/ResultScreen/Box/Title
	var sub = $CanvasLayer/ResultScreen/Box/Subtitle
	var stars = $CanvasLayer/ResultScreen/Box/Stars
	var next_btn = $CanvasLayer/ResultScreen/Box/NextBtn
	
	if won:
		title.text = "🎉 LEVEL COMPLETE"
		title.modulate = Color("#FFD54F")
		sub.text = "Bridge Master!"
		stars.visible = true
		next_btn.visible = current_level_idx < DrawBridgeLevels.LEVELS.size() - 1
	else:
		title.text = "💥 CRASHED!"
		title.modulate = Color("#EF5350")
		sub.text = "The bridge failed..."
		stars.visible = false
		next_btn.visible = false

func _on_next_level_pressed() -> void:
	if current_level_idx < DrawBridgeLevels.LEVELS.size() - 1:
		load_level(current_level_idx + 1)
	else:
		_open_main_menu()

func _restart_current_level() -> void:
	load_level(current_level_idx)

func _exit_to_hub() -> void:
	get_tree().change_scene_to_file("res://main_menu.tscn")

func _draw() -> void:
	# Sky background
	draw_rect(Rect2(0, 0, 1200, 800), Color("#6BB5FF"))

	# Background hills
	draw_circle(Vector2(240, 720), 400.0, Color("#B4E396"))
	draw_circle(Vector2(960, 750), 450.0, Color("#9BD37A"))

	# Sun
	draw_circle(Vector2(900, 90), 38.0, Color("#FFF5B8"))

	# Stylized flat-bottom fluffy clouds
	_draw_cloud(Vector2(240, 200), 1.2)
	_draw_cloud(Vector2(720, 260), 1.5)
	_draw_cloud(Vector2(550, 380), 0.9)

	# Draw Terrain Platforms for current level
	if current_state != State.MENU and current_state != State.LEVEL_SELECT:
		var cfg = DrawBridgeLevels.LEVELS[current_level_idx]
		var terrain_data: Array = cfg["terrain"]
		for item in terrain_data:
			var x: float = item["x"] * 1200.0
			var w: float = item["w"] * 1200.0
			var y: float = item["y"] * 800.0
			var h: float = 800.0 - y

			# Dirt body
			draw_rect(Rect2(x, y + 15, w, h - 15), Color("#9C663C"))
			# Dirt speck details
			for sx in range(int(x) + 15, int(x + w), 35):
				for sy in range(int(y) + 35, int(y + h), 35):
					var off_x = sin(sx * 13.0 + sy * 3.0) * 10.0
					var off_y = cos(sx * 7.0 + sy * 11.0) * 10.0
					draw_circle(Vector2(sx + off_x, sy + off_y), 2.5, Color("#795034"))
			# Grass top
			draw_rect(Rect2(x, y, w, 15), Color("#6BC235"))

func _draw_cloud(pos: Vector2, scale_factor: float) -> void:
	draw_circle(pos + Vector2(-20 * scale_factor, 0), 15 * scale_factor, Color.WHITE)
	draw_circle(pos + Vector2(0, -10 * scale_factor), 20 * scale_factor, Color.WHITE)
	draw_circle(pos + Vector2(20 * scale_factor, 0), 15 * scale_factor, Color.WHITE)
	draw_rect(Rect2(pos.x - 20 * scale_factor, pos.y, 40 * scale_factor, 15 * scale_factor), Color.WHITE)

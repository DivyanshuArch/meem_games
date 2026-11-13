class_name StairDismountGame
extends Node2D

const RAGDOLL_SCENE = preload("res://games/ragdoll_sandbox/ragdoll.tscn")

enum State { AIMING, TUMBLING, FINISHED }

var current_state: State = State.AIMING
var ragdoll_instance: Ragdoll = null
var total_damage: int = 0
var total_fractures: int = 0
var still_timer: float = 0.0
var push_power: float = 600.0
var push_angle: float = 0.3 # radians
var is_aiming: bool = false
var aim_start_pos: Vector2 = Vector2.ZERO

@onready var camera: Camera2D = $Camera2D
@onready var hud: Control = $CanvasLayer/HUD
@onready var damage_label: Label = $CanvasLayer/HUD/DamageBadge
@onready var fractures_label: Label = $CanvasLayer/HUD/FracturesBadge
@onready var power_bar: ColorRect = $CanvasLayer/HUD/PowerContainer/BarBg/PowerBar
@onready var result_overlay: Control = $CanvasLayer/ResultScreen
@onready var result_damage: Label = $CanvasLayer/ResultScreen/Box/DamageScore
@onready var result_rank: Label = $CanvasLayer/ResultScreen/Box/RankLabel

func _ready() -> void:
	$CanvasLayer/HUD/RestartBtn.pressed.connect(reset_game)
	$CanvasLayer/ResultScreen/Box/BtnRow/RetryBtn.pressed.connect(reset_game)
	
	_build_staircase_course()
	reset_game()

func reset_game() -> void:
	SoundManager.play("chalo")
	current_state = State.AIMING
	total_damage = 0
	total_fractures = 0
	still_timer = 0.0
	result_overlay.visible = false
	_update_hud()
	
	if ragdoll_instance and is_instance_valid(ragdoll_instance):
		ragdoll_instance.queue_free()
		
	ragdoll_instance = RAGDOLL_SCENE.instantiate()
	ragdoll_instance.position = Vector2(160, 180)
	add_child(ragdoll_instance)
	ragdoll_instance.set_character("face1" if randf() < 0.5 else "face2")
	
	# Enable contact reporting on all limbs for impact detection
	for part in ragdoll_instance.all_parts:
		part.contact_monitor = true
		part.max_contacts_reported = 4
		part.body_entered.connect(_on_limb_impact.bind(part))
		# Freeze initially until push
		part.freeze = true
		
	camera.position = Vector2(360, 400)
	queue_redraw()

func _build_staircase_course() -> void:
	# Top launch platform
	_create_static_box(Rect2(40, 240, 220, 40), Color("#334155"))
	
	# Descending staircase (24 steps)
	var step_w = 40.0
	var step_h = 35.0
	var start_x = 240.0
	var start_y = 260.0
	for i in range(24):
		var x = start_x + i * step_w
		var y = start_y + i * step_h
		_create_static_box(Rect2(x, y, step_w + 6, step_h * 2), Color("#475569") if i % 2 == 0 else Color("#64748B"))
		
		# Add a bouncer on step 8 and step 16
		if i == 8 or i == 16:
			var bounce_box = _create_static_box(Rect2(x, y - 10, step_w, 14), Color("#EC4899"), 1.8)
			bounce_box.name = "Bouncer"
			
	# Bottom runway
	var bot_x = start_x + 24 * step_w
	var bot_y = start_y + 24 * step_h
	_create_static_box(Rect2(bot_x - 50, bot_y, 800, 50), Color("#1E293B"))
	# End wall
	_create_static_box(Rect2(bot_x + 750, bot_y - 250, 40, 300), Color("#0F172A"))

func _create_static_box(rect: Rect2, color: Color, bounce: float = 0.1) -> StaticBody2D:
	var sb = StaticBody2D.new()
	var col = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.size = rect.size
	col.shape = shape
	col.position = rect.position + rect.size * 0.5
	sb.add_child(col)
	
	var mat = PhysicsMaterial.new()
	mat.bounce = bounce
	mat.friction = 0.7
	sb.physics_material_override = mat
	
	add_child(sb)
	
	# Draw visual rect inside sb
	var canvas = Node2D.new()
	canvas.draw.connect(func():
		canvas.draw_rect(rect, color)
		canvas.draw_rect(Rect2(rect.position.x, rect.position.y, rect.size.x, 4), color.lightened(0.25))
	)
	sb.add_child(canvas)
	return sb

func _unhandled_input(event: InputEvent) -> void:
	if current_state != State.AIMING:
		return
		
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			is_aiming = true
			aim_start_pos = event.position
		else:
			if is_aiming:
				is_aiming = false
				_launch_ragdoll()
				
	elif event is InputEventMouseMotion and is_aiming:
		var diff = aim_start_pos - event.position
		push_power = clamp(diff.length() * 4.0, 300.0, 1600.0)
		push_angle = diff.angle()
		power_bar.size.x = 220.0 * ((push_power - 300.0) / 1300.0)
		queue_redraw()
		
	elif event is InputEventScreenTouch:
		if event.pressed:
			is_aiming = true
			aim_start_pos = event.position
		else:
			if is_aiming:
				is_aiming = false
				_launch_ragdoll()
				
	elif event is InputEventScreenDrag and is_aiming:
		var diff = aim_start_pos - event.position
		push_power = clamp(diff.length() * 4.0, 300.0, 1600.0)
		push_angle = diff.angle()
		power_bar.size.x = 220.0 * ((push_power - 300.0) / 1300.0)
		queue_redraw()

func _launch_ragdoll() -> void:
	current_state = State.TUMBLING
	SoundManager.play("punch")
	
	var impulse = Vector2.from_angle(push_angle) * push_power
	# Ensure some rightward/downward force if aimed randomly
	if impulse.x < 150:
		impulse.x = 400.0
		
	for part in ragdoll_instance.all_parts:
		part.freeze = false
		part.apply_central_impulse(impulse * 0.4)
		
	ragdoll_instance.torso.apply_central_impulse(impulse)
	ragdoll_instance.torso.apply_torque_impulse(push_power * 15.0)
	queue_redraw()

func _on_limb_impact(other: Node, limb: RigidBody2D) -> void:
	if current_state != State.TUMBLING:
		return
		
	var speed = limb.linear_velocity.length()
	if speed > 220.0:
		var dmg = int(speed * 1.5)
		total_damage += dmg
		total_fractures += 1
		_update_hud()
		
		# Sound based on severity
		if speed > 600.0:
			SoundManager.play("bone_crack", 0.15)
			_spawn_hit_text(limb.global_position, "CRUSH! +%d" % dmg, Color("#EF4444"))
		else:
			SoundManager.play("slap", 0.2)
			_spawn_hit_text(limb.global_position, "CRACK! +%d" % dmg, Color("#F59E0B"))

func _spawn_hit_text(pos: Vector2, text: String, color: Color) -> void:
	var label = Label.new()
	label.text = text
	label.position = pos + Vector2(-30, -20)
	label.add_theme_font_size_override("font_size", 18)
	label.add_theme_color_override("font_color", color)
	add_child(label)
	
	var tween = create_tween()
	tween.parallel().tween_property(label, "position:y", pos.y - 60.0, 0.7)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.7)
	tween.tween_callback(label.queue_free)

func _physics_process(delta: float) -> void:
	if current_state == State.TUMBLING and ragdoll_instance and is_instance_valid(ragdoll_instance.torso):
		# Camera follows torso smoothly
		var target_pos = ragdoll_instance.torso.global_position + Vector2(100, 50)
		camera.position = camera.position.lerp(target_pos, delta * 4.0)
		
		# Check if ragdoll has stopped tumbling
		var avg_speed = 0.0
		for part in ragdoll_instance.all_parts:
			avg_speed += part.linear_velocity.length()
		avg_speed /= ragdoll_instance.all_parts.size()
		
		if avg_speed < 30.0 or ragdoll_instance.torso.global_position.y > 1500:
			still_timer += delta
			if still_timer > 2.0:
				_finish_round()
		else:
			still_timer = 0.0

func _finish_round() -> void:
	current_state = State.FINISHED
	SoundManager.play("modi_ji_bkl")
	
	result_damage.text = "DAMAGE: %d PTS" % total_damage
	var rank = "C - AMATEUR TUMBLE"
	if total_damage > 12000:
		rank = "SSS - ABSOLUTE DISASTER! 💀"
	elif total_damage > 7000:
		rank = "S - BONE SHATTERING! 💥"
	elif total_damage > 3500:
		rank = "A - SERIOUS DAMAGE! 🦴"
	elif total_damage > 1500:
		rank = "B - BRUISED & BATTERED"
	result_rank.text = rank
	result_overlay.visible = true

func _update_hud() -> void:
	damage_label.text = "💥 DAMAGE: %d" % total_damage
	fractures_label.text = "🦴 FRACTURES: %d" % total_fractures

func _draw() -> void:
	if current_state == State.AIMING and is_aiming and ragdoll_instance:
		var start = ragdoll_instance.position + Vector2(0, -30)
		var end = start + Vector2.from_angle(push_angle) * (push_power * 0.15)
		draw_line(start, end, Color("#EF4444"), 8.0)
		draw_circle(end, 10.0, Color("#F87171"))

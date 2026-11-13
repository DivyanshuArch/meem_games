extends CharacterBody2D
class_name SwingPlayer

signal won
signal lost

const FACE_TEX = preload("res://assets/face1.png")

@export var run_speed: float = 360.0
@export var gravity_val: float = 850.0
@export var air_friction: float = 0.994
@export var release_boost_x: float = 320.0
@export var release_boost_y: float = -380.0

var is_swinging: bool = false
var current_anchor: SwingAnchor = null
var rope_length: float = 0.0
var hold_time: float = 0.0
var trail_positions: Array[Vector2] = []
var anchors_list: Array[SwingAnchor] = []
var end_platform_x: float = 0.0
var has_ended: bool = false

func _ready() -> void:
	pass

func setup_level(anchors: Array[SwingAnchor], goal_x: float) -> void:
	anchors_list = anchors
	end_platform_x = goal_x
	has_ended = false
	is_swinging = false
	current_anchor = null
	trail_positions.clear()
	velocity = Vector2.ZERO
	rotation = 0.0

func _unhandled_input(event: InputEvent) -> void:
	if has_ended:
		return
		
	# Touch screen events
	if event is InputEventScreenTouch:
		if event.pressed:
			_attach_rope()
		else:
			_detach_rope()
			
	# Mouse events
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_attach_rope()
		else:
			_detach_rope()

func _attach_rope() -> void:
	var best_anchor: SwingAnchor = null
	var best_score: float = -999999.0

	# Smart Auto-Aim forward anchor
	for a in anchors_list:
		var dx = a.global_position.x - global_position.x
		var dy = a.global_position.y - global_position.y
		var dist = sqrt(dx * dx + dy * dy)

		if dx > -80.0 and dist < 900.0:
			var score = dx * 1.5 - dist
			if score > best_score:
				best_score = score
				best_anchor = a

	# Fallback to closest
	if not best_anchor and anchors_list.size() > 0:
		var min_d = 999999.0
		for a in anchors_list:
			var d = global_position.distance_to(a.global_position)
			if d < min_d:
				min_d = d
				best_anchor = a

	if best_anchor:
		is_swinging = true
		current_anchor = best_anchor
		rope_length = global_position.distance_to(best_anchor.global_position)
		hold_time = 0.0
		best_anchor.set_active(true)
		# Small initial tug
		velocity += Vector2(100.0, -100.0)
		if randf() < 0.35:
			SoundManager.play("huh", 0.1)

func _detach_rope() -> void:
	if not is_swinging:
		return
		
	if velocity.x > 0:
		var charge_mult = 1.0 + min(hold_time * 1.8, 1.5)
		velocity.x += release_boost_x * charge_mult
		velocity.y += release_boost_y * (charge_mult * 0.8)
		SoundManager.play_random(["fahhh", "vine_boom"], 0.15)

	if current_anchor:
		current_anchor.set_active(false)
		current_anchor = null
	is_swinging = false
	queue_redraw()

func _physics_process(delta: float) -> void:
	if has_ended:
		return

	# Apply Gravity
	velocity.y += gravity_val * delta

	# Ground Running vs Air Friction
	if is_on_floor():
		velocity.x = run_speed
	else:
		velocity.x *= air_friction
		velocity.y *= air_friction

	# Swing Tension & Physics
	if is_swinging and current_anchor:
		hold_time += delta
		var swing_accel = 30.0 + min(hold_time * 80.0, 160.0)
		velocity.x += swing_accel * delta * 60.0

		var diff = global_position - current_anchor.global_position
		var dist = diff.length()
		if dist > rope_length and dist > 0.001:
			global_position = current_anchor.global_position + (diff / dist) * rope_length
			var norm = diff / dist
			var vr = velocity.dot(norm)
			if vr > 0:
				velocity -= norm * vr

	move_and_slide()

	# Subtle dynamic tilt towards motion
	if not is_on_floor():
		var target_rot = clamp(velocity.y * 0.0006, -0.35, 0.35)
		rotation = lerp_angle(rotation, target_rot, 8.0 * delta)
	else:
		rotation = lerp_angle(rotation, 0.0, 12.0 * delta)

	# Trail update
	trail_positions.append(global_position)
	if trail_positions.size() > 18:
		trail_positions.pop_front()

	# Check Win Condition
	if is_on_floor() and global_position.x > end_platform_x + 50.0:
		has_ended = true
		_detach_rope()
		SoundManager.play("modi_ji_bkl")
		won.emit()
		return

	# Check Lose Condition (Fell off screen)
	if global_position.y > 1350.0:
		has_ended = true
		_detach_rope()
		SoundManager.play_random(["vine_boom", "dun_dun_dun", "fart", "are_baap_re"])
		lost.emit()
		return

	queue_redraw()

func _draw() -> void:
	# Draw Rope
	if is_swinging and current_anchor:
		var local_anchor = to_local(current_anchor.global_position)
		var charge_ratio = clamp(hold_time / 0.6, 0.0, 1.0)
		var rope_col = Color("#5C4033").lerp(Color("#FF7800"), charge_ratio)
		var width = 4.0 + charge_ratio * 4.0
		draw_line(Vector2.ZERO, local_anchor, rope_col, width)

	# Draw Trail
	if trail_positions.size() > 1:
		for i in range(trail_positions.size() - 1):
			var p1 = to_local(trail_positions[i])
			var p2 = to_local(trail_positions[i + 1])
			var alpha = float(i) / float(trail_positions.size()) * 0.45
			draw_line(p1, p2, Color(1.0, 0.71, 0.76, alpha), 18.0)

	# Draw Player Face
	var face_w = 32.0
	var face_h = 42.0
	var face_rect = Rect2(-face_w * 0.5, -face_h * 0.5, face_w, face_h)
	draw_texture_rect(FACE_TEX, face_rect, false)

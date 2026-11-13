extends Node2D
class_name BridgeDrawer

signal ink_changed(current: float, max_val: float)
signal bridge_completed

@export var min_segment_length: float = 14.0
@export var bridge_thickness: float = 14.0

var max_ink: float = 1000.0
var current_ink: float = 1000.0
var drawn_points: Array[Vector2] = []
var is_drawing: bool = false
var can_draw: bool = true
var bridge_body: StaticBody2D = null

func setup(ink_amount: float) -> void:
	max_ink = ink_amount
	current_ink = ink_amount
	drawn_points.clear()
	is_drawing = false
	can_draw = true
	if bridge_body:
		bridge_body.queue_free()
		bridge_body = null
	queue_redraw()
	ink_changed.emit(current_ink, max_ink)

func _unhandled_input(event: InputEvent) -> void:
	if not can_draw:
		return
		
	# Touch screen events
	if event is InputEventScreenTouch:
		if event.pressed:
			_start_drawing(event.position)
		else:
			_end_drawing()
	elif event is InputEventScreenDrag and is_drawing:
		_add_point(event.position)
		
	# Mouse events
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_start_drawing(event.position)
		else:
			_end_drawing()
	elif event is InputEventMouseMotion and is_drawing:
		_add_point(event.position)

func _start_drawing(start_pos: Vector2) -> void:
	is_drawing = true
	drawn_points.clear()
	drawn_points.append(start_pos)
	queue_redraw()

func _add_point(pos: Vector2) -> void:
	if current_ink <= 0:
		_end_drawing()
		return
		
	var last_pt = drawn_points[-1]
	var dist = last_pt.distance_to(pos)
	if dist >= min_segment_length:
		var ink_used = min(dist, current_ink)
		current_ink -= ink_used
		drawn_points.append(pos)
		queue_redraw()
		ink_changed.emit(current_ink, max_ink)

func _end_drawing() -> void:
	if not is_drawing:
		return
	is_drawing = false
	
	if drawn_points.size() > 1:
		can_draw = false
		_build_physics_bridge()
		bridge_completed.emit()
	else:
		drawn_points.clear()
		current_ink = max_ink
		ink_changed.emit(current_ink, max_ink)
		queue_redraw()

func _build_physics_bridge() -> void:
	if bridge_body:
		bridge_body.queue_free()
		
	bridge_body = StaticBody2D.new()
	var mat = PhysicsMaterial.new()
	mat.friction = 1.0
	mat.bounce = 0.05
	bridge_body.physics_material_override = mat
	add_child(bridge_body)
	
	# Create segment collision shapes
	for i in range(drawn_points.size() - 1):
		var p1 = drawn_points[i]
		var p2 = drawn_points[i + 1]
		var seg = SegmentShape2D.new()
		seg.a = p1
		seg.b = p2
		var col = CollisionShape2D.new()
		col.shape = seg
		bridge_body.add_child(col)

func _draw() -> void:
	if drawn_points.size() < 2:
		return
		
	var pts = PackedVector2Array(drawn_points)
	
	# 1. Dark border
	draw_polyline(pts, Color("#5E381A"), 18.0, true)
	
	# 2. Road surface
	draw_polyline(pts, Color("#935F36"), 14.0, true)
	
	# 3. Center line
	for i in range(drawn_points.size() - 1):
		var p1 = drawn_points[i]
		var p2 = drawn_points[i + 1]
		var mid = (p1 + p2) * 0.5
		draw_circle(mid, 2.0, Color.WHITE)

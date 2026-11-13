class_name DogeInkDrawer
extends Node2D

signal ink_changed(current: float, max_val: float)
signal drawing_finished

@export var min_segment_length: float = 12.0
@export var stroke_thickness: float = 12.0

var max_ink: float = 600.0
var current_ink: float = 600.0
var drawn_points: Array[Vector2] = []
var local_points: PackedVector2Array = []
var is_drawing: bool = false
var can_draw: bool = true
var drawn_body: RigidBody2D = null

func setup(ink_amount: float) -> void:
	max_ink = ink_amount
	current_ink = ink_amount
	drawn_points.clear()
	local_points.clear()
	is_drawing = false
	can_draw = true
	if drawn_body and is_instance_valid(drawn_body):
		drawn_body.queue_free()
		drawn_body = null
	queue_redraw()
	ink_changed.emit(current_ink, max_ink)

func _unhandled_input(event: InputEvent) -> void:
	if not can_draw:
		return
		
	if event is InputEventScreenTouch:
		if event.pressed:
			_start_drawing(event.position)
		else:
			_end_drawing()
	elif event is InputEventScreenDrag and is_drawing:
		_add_point(event.position)
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
		_create_physics_shield()
		drawing_finished.emit()
	else:
		drawn_points.clear()
		current_ink = max_ink
		ink_changed.emit(current_ink, max_ink)
		queue_redraw()

func _create_physics_shield() -> void:
	if drawn_body and is_instance_valid(drawn_body):
		drawn_body.queue_free()
		
	# Centroid
	var center := Vector2.ZERO
	for pt in drawn_points:
		center += pt
	center /= drawn_points.size()
	
	local_points.clear()
	for pt in drawn_points:
		local_points.append(pt - center)
		
	drawn_body = RigidBody2D.new()
	drawn_body.position = center
	drawn_body.mass = 4.0
	drawn_body.gravity_scale = 1.0
	var mat = PhysicsMaterial.new()
	mat.friction = 0.8
	mat.bounce = 0.1
	drawn_body.physics_material_override = mat
	add_child(drawn_body)
	
	# Add segment collision shapes in local space
	for i in range(local_points.size() - 1):
		var p1 = local_points[i]
		var p2 = local_points[i + 1]
		var seg = SegmentShape2D.new()
		seg.a = p1
		seg.b = p2
		var col = CollisionShape2D.new()
		col.shape = seg
		drawn_body.add_child(col)

func _process(_delta: float) -> void:
	if drawn_body and is_instance_valid(drawn_body):
		queue_redraw()

func _draw() -> void:
	if drawn_body and is_instance_valid(drawn_body):
		draw_set_transform(drawn_body.position, drawn_body.rotation, Vector2.ONE)
		draw_polyline(local_points, Color("#0F172A"), stroke_thickness + 6.0, true)
		draw_polyline(local_points, Color("#0EA5E9"), stroke_thickness, true)
		draw_set_transform(Vector2.ZERO, 0.0, Vector2.ONE)
	elif drawn_points.size() >= 2:
		var pts = PackedVector2Array(drawn_points)
		draw_polyline(pts, Color("#0F172A"), stroke_thickness + 6.0, true)
		draw_polyline(pts, Color("#0EA5E9"), stroke_thickness, true)

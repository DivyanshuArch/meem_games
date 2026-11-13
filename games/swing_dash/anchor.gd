extends Node2D
class_name SwingAnchor

@export var radius: float = 20.0
var is_active: bool = false

func set_active(active: bool) -> void:
	if is_active != active:
		is_active = active
		queue_redraw()

func _draw() -> void:
	var col = Color("#FFD54F") if is_active else Color("#333333")
	# Outer ring
	draw_arc(Vector2.ZERO, radius, 0, TAU, 32, col, 5.0)
	# Center dot
	draw_circle(Vector2.ZERO, radius * 0.4, col)

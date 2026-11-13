extends Node2D

const FACE_TEX = preload("res://assets/face1.png")

func _draw() -> void:
	if get_parent().name == "Chassis":
		# Antenna
		draw_line(Vector2(-25, -10), Vector2(-25, -35), Color("#222222"), 2.0)
		
		# Driver Body
		draw_rect(Rect2(-5, -20, 10, 10), Color("#333333"))
		# Driver Head
		draw_texture_rect(FACE_TEX, Rect2(-10, -42, 20, 26), false)
		# Steering Wheel
		draw_line(Vector2(8, -15), Vector2(12, -22), Color("#222222"), 2.0)

		# Car Red Body
		var body_pts = PackedVector2Array([
			Vector2(-30, -10),
			Vector2(25, -10),
			Vector2(30, -2),
			Vector2(30, 8),
			Vector2(-30, 8)
		])
		draw_colored_polygon(body_pts, Color("#D32F2F"))

		# Bumpers
		draw_rect(Rect2(-32, 2, 5, 6), Color("#222222"))
		draw_rect(Rect2(27, 2, 5, 6), Color("#222222"))

	elif "Wheel" in get_parent().name:
		# Tire
		draw_circle(Vector2.ZERO, 12.0, Color("#222222"))
		# Rim
		draw_circle(Vector2.ZERO, 6.0, Color("#999999"))
		# Spoke accents
		draw_circle(Vector2(3, 0), 2.0, Color.WHITE)
		draw_circle(Vector2(-3, 0), 2.0, Color.WHITE)

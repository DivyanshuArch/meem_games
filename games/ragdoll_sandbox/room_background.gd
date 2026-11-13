extends Node2D

func _draw() -> void:
	var hw: float = 1200.0
	var hh: float = 800.0

	# Back Wall
	draw_rect(Rect2(hw * 0.15, hh * 0.1, hw * 0.7, hh * 0.6), Color("#E0D7CD"))

	# Left Wall
	var left_wall_pts = PackedVector2Array([
		Vector2(0, 0),
		Vector2(hw * 0.15, hh * 0.1),
		Vector2(hw * 0.15, hh * 0.7),
		Vector2(0, hh)
	])
	draw_colored_polygon(left_wall_pts, Color("#D1C7BB"))

	# Right Wall
	var right_wall_pts = PackedVector2Array([
		Vector2(hw, 0),
		Vector2(hw * 0.85, hh * 0.1),
		Vector2(hw * 0.85, hh * 0.7),
		Vector2(hw, hh)
	])
	draw_colored_polygon(right_wall_pts, Color("#C2B8AB"))

	# Ceiling
	var ceiling_pts = PackedVector2Array([
		Vector2(0, 0),
		Vector2(hw, 0),
		Vector2(hw * 0.85, hh * 0.1),
		Vector2(hw * 0.15, hh * 0.1)
	])
	draw_colored_polygon(ceiling_pts, Color("#F5F0EA"))

	# Floor
	var floor_pts = PackedVector2Array([
		Vector2(0, hh),
		Vector2(hw * 0.15, hh * 0.7),
		Vector2(hw * 0.85, hh * 0.7),
		Vector2(hw, hh)
	])
	draw_colored_polygon(floor_pts, Color("#A0714E"))

	# Floor boards lines
	for i in range(1, 11):
		var p: float = float(i) / 11.0
		var start_pt = Vector2(hw * p, hh)
		var target_x = hw * 0.15 + (hw * 0.7) * p
		var target_pt = Vector2(target_x, hh * 0.7)
		draw_line(start_pt, target_pt, Color(0, 0, 0, 0.1), 2.0)

	# Wainscoting (white paneling)
	draw_rect(Rect2(hw * 0.15, hh * 0.5, hw * 0.7, hh * 0.2), Color("#FAFAFA"))
	draw_rect(Rect2(hw * 0.15, hh * 0.5, hw * 0.7, hh * 0.2), Color("#DDDDDD"), false, 2.0)

	var left_panel = PackedVector2Array([
		Vector2(0, hh * 0.6),
		Vector2(hw * 0.15, hh * 0.5),
		Vector2(hw * 0.15, hh * 0.7),
		Vector2(0, hh)
	])
	draw_colored_polygon(left_panel, Color("#F0F0F0"))
	draw_polyline(left_panel, Color("#DDDDDD"), 2.0)

	var right_panel = PackedVector2Array([
		Vector2(hw, hh * 0.6),
		Vector2(hw * 0.85, hh * 0.5),
		Vector2(hw * 0.85, hh * 0.7),
		Vector2(hw, hh)
	])
	draw_colored_polygon(right_panel, Color("#E8E8E8"))
	draw_polyline(right_panel, Color("#DDDDDD"), 2.0)

	# Rug (dark red with gold border)
	var rug_pts = PackedVector2Array([
		Vector2(hw * 0.3, hh * 0.95),
		Vector2(hw * 0.25, hh * 0.75),
		Vector2(hw * 0.75, hh * 0.75),
		Vector2(hw * 0.7, hh * 0.95)
	])
	draw_colored_polygon(rug_pts, Color("#A93226"))
	var rug_outline = rug_pts.duplicate()
	rug_outline.append(rug_pts[0])
	draw_polyline(rug_outline, Color("#F1C40F"), 4.0)

	# Sky Window
	var win_rect = Rect2(hw * 0.4, hh * 0.2, hw * 0.2, hh * 0.25)
	draw_rect(win_rect, Color("#85C1E9"))
	draw_rect(win_rect, Color(1, 1, 1, 0.35))
	draw_rect(win_rect, Color.WHITE, false, 6.0)
	draw_line(Vector2(hw * 0.5, hh * 0.2), Vector2(hw * 0.5, hh * 0.45), Color.WHITE, 4.0)
	draw_line(Vector2(hw * 0.4, hh * 0.325), Vector2(hw * 0.6, hh * 0.325), Color.WHITE, 4.0)

	# Pink Curtains
	draw_rect(Rect2(hw * 0.38, hh * 0.18, hw * 0.05, hh * 0.29), Color("#F5B7B1"))
	draw_rect(Rect2(hw * 0.57, hh * 0.18, hw * 0.05, hh * 0.29), Color("#F5B7B1"))

	# Pictures
	draw_rect(Rect2(hw * 0.65, hh * 0.25, hw * 0.06, hh * 0.08), Color("#5D6D7E"))
	draw_rect(Rect2(hw * 0.655, hh * 0.255, hw * 0.05, hh * 0.07), Color("#FAD7A1"))

	draw_rect(Rect2(hw * 0.73, hh * 0.2, hw * 0.04, hh * 0.1), Color("#5D6D7E"))
	draw_rect(Rect2(hw * 0.735, hh * 0.205, hw * 0.03, hh * 0.09), Color("#ABEBC6"))

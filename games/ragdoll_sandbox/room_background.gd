extends Node2D

func _draw() -> void:
	var hw: float = 720.0
	var hh: float = 1280.0

	# Back Wall
	draw_rect(Rect2(hw * 0.12, hh * 0.08, hw * 0.76, hh * 0.62), Color("#E0D7CD"))

	# Left Wall
	var left_wall_pts = PackedVector2Array([
		Vector2(0, 0),
		Vector2(hw * 0.12, hh * 0.08),
		Vector2(hw * 0.12, hh * 0.7),
		Vector2(0, hh)
	])
	draw_colored_polygon(left_wall_pts, Color("#D1C7BB"))

	# Right Wall
	var right_wall_pts = PackedVector2Array([
		Vector2(hw, 0),
		Vector2(hw * 0.88, hh * 0.08),
		Vector2(hw * 0.88, hh * 0.7),
		Vector2(hw, hh)
	])
	draw_colored_polygon(right_wall_pts, Color("#C2B8AB"))

	# Ceiling
	var ceiling_pts = PackedVector2Array([
		Vector2(0, 0),
		Vector2(hw, 0),
		Vector2(hw * 0.88, hh * 0.08),
		Vector2(hw * 0.12, hh * 0.08)
	])
	draw_colored_polygon(ceiling_pts, Color("#F5F0EA"))

	# Floor
	var floor_pts = PackedVector2Array([
		Vector2(0, hh),
		Vector2(hw * 0.12, hh * 0.7),
		Vector2(hw * 0.88, hh * 0.7),
		Vector2(hw, hh)
	])
	draw_colored_polygon(floor_pts, Color("#A0714E"))

	# Floor boards lines (perspective)
	for i in range(1, 9):
		var p: float = float(i) / 9.0
		var start_pt = Vector2(hw * p, hh)
		var target_x = hw * 0.12 + (hw * 0.76) * p
		var target_pt = Vector2(target_x, hh * 0.7)
		draw_line(start_pt, target_pt, Color(0, 0, 0, 0.12), 2.0)

	# Wainscoting (white paneling)
	draw_rect(Rect2(hw * 0.12, hh * 0.52, hw * 0.76, hh * 0.18), Color("#FAFAFA"))
	draw_rect(Rect2(hw * 0.12, hh * 0.52, hw * 0.76, hh * 0.18), Color("#DDDDDD"), false, 2.0)

	var left_panel = PackedVector2Array([
		Vector2(0, hh * 0.62),
		Vector2(hw * 0.12, hh * 0.52),
		Vector2(hw * 0.12, hh * 0.7),
		Vector2(0, hh)
	])
	draw_colored_polygon(left_panel, Color("#F0F0F0"))
	draw_polyline(left_panel, Color("#DDDDDD"), 2.0)

	var right_panel = PackedVector2Array([
		Vector2(hw, hh * 0.62),
		Vector2(hw * 0.88, hh * 0.52),
		Vector2(hw * 0.88, hh * 0.7),
		Vector2(hw, hh)
	])
	draw_colored_polygon(right_panel, Color("#E8E8E8"))
	draw_polyline(right_panel, Color("#DDDDDD"), 2.0)

	# Rug (dark red with gold border)
	var rug_pts = PackedVector2Array([
		Vector2(hw * 0.22, hh * 0.94),
		Vector2(hw * 0.20, hh * 0.76),
		Vector2(hw * 0.80, hh * 0.76),
		Vector2(hw * 0.78, hh * 0.94)
	])
	draw_colored_polygon(rug_pts, Color("#A93226"))
	var rug_outline = rug_pts.duplicate()
	rug_outline.append(rug_pts[0])
	draw_polyline(rug_outline, Color("#F1C40F"), 4.0)

	# Sky Window on back wall
	var win_rect = Rect2(hw * 0.35, hh * 0.16, hw * 0.3, hh * 0.2)
	draw_rect(win_rect, Color("#85C1E9"))
	draw_rect(win_rect, Color(1, 1, 1, 0.35))
	draw_rect(win_rect, Color.WHITE, false, 5.0)
	draw_line(Vector2(hw * 0.5, hh * 0.16), Vector2(hw * 0.5, hh * 0.36), Color.WHITE, 4.0)
	draw_line(Vector2(hw * 0.35, hh * 0.26), Vector2(hw * 0.65, hh * 0.26), Color.WHITE, 4.0)

	# Pink Curtains
	draw_rect(Rect2(hw * 0.32, hh * 0.14, hw * 0.05, hh * 0.24), Color("#F5B7B1"))
	draw_rect(Rect2(hw * 0.63, hh * 0.14, hw * 0.05, hh * 0.24), Color("#F5B7B1"))

	# Pictures
	draw_rect(Rect2(hw * 0.72, hh * 0.22, hw * 0.1, hh * 0.08), Color("#5D6D7E"))
	draw_rect(Rect2(hw * 0.73, hh * 0.225, hw * 0.08, hh * 0.07), Color("#FAD7A1"))

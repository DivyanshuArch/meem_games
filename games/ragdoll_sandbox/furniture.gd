extends Node2D

func _draw() -> void:
	# Bookshelf visuals (at 260, 950, size 90x260)
	draw_rect(Rect2(260 - 45, 950 - 130, 90, 260), Color("#D4AC0D"))
	for i in range(1, 5):
		draw_rect(Rect2(260 - 40, 950 - 130 + (260.0 / 5.0) * i, 80, 6), Color("#B7950B"))
	# Books
	draw_rect(Rect2(225, 850, 12, 26), Color("#E74C3C"))
	draw_rect(Rect2(240, 845, 10, 31), Color("#3498DB"))
	draw_rect(Rect2(253, 855, 16, 21), Color("#2ECC71"))
	draw_rect(Rect2(230, 920, 20, 32), Color("#9B59B6"))
	draw_rect(Rect2(255, 925, 10, 25), Color("#F39C12"))

	# Sofa visuals (Base at 140, 1180, size 200x80; Back at 50, 1100, size 40x90)
	draw_rect(Rect2(140 - 100, 1180 - 40, 200, 80), Color("#7FB3D5"))
	draw_rect(Rect2(50 - 20, 1100 - 45, 40, 90), Color("#5499C7"))

	# Bed visuals (Base at 570, 1180, size 240x80; Headboard at 680, 1100, size 20x90)
	draw_rect(Rect2(570 - 120, 1180 - 40, 240, 80), Color("#E6B0AA")) # Mattress
	draw_rect(Rect2(615, 1145, 55, 25), Color("#D7BDE2")) # Pillow
	draw_rect(Rect2(570 - 120, 1205, 240, 15), Color("#BA4A00")) # Bed Frame
	draw_rect(Rect2(680 - 10, 1100 - 45, 20, 90), Color("#BA4A00")) # Headboard

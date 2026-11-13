extends Node2D

func _draw() -> void:
	# Bookshelf visuals (at 400, 600, size 120x350)
	draw_rect(Rect2(400 - 60, 600 - 175, 120, 350), Color("#D4AC0D"))
	for i in range(1, 5):
		draw_rect(Rect2(400 - 55, 600 - 175 + (350.0 / 5.0) * i, 110, 8), Color("#B7950B"))
	# Books
	draw_rect(Rect2(355, 450, 15, 30), Color("#E74C3C"))
	draw_rect(Rect2(372, 445, 12, 35), Color("#3498DB"))
	draw_rect(Rect2(386, 455, 20, 25), Color("#2ECC71"))
	draw_rect(Rect2(360, 520, 25, 40), Color("#9B59B6"))
	draw_rect(Rect2(390, 530, 10, 30), Color("#F39C12"))

	# Sofa visuals (Base at 200, 725, size 250x100; Back at 100, 625, size 50x100)
	draw_rect(Rect2(200 - 125, 725 - 50, 250, 100), Color("#7FB3D5"))
	draw_rect(Rect2(100 - 25, 625 - 50, 50, 100), Color("#5499C7"))

	# Bed visuals (Base at 950, 725, size 300x100; Headboard at 1090, 625, size 20x100)
	draw_rect(Rect2(950 - 150, 725 - 50, 300, 100), Color("#E6B0AA")) # Mattress
	draw_rect(Rect2(1010, 685, 70, 30), Color("#D7BDE2")) # Pillow
	draw_rect(Rect2(950 - 150, 755, 300, 20), Color("#BA4A00")) # Bed Frame
	draw_rect(Rect2(1090 - 10, 625 - 50, 20, 100), Color("#BA4A00")) # Headboard

extends Area2D

signal goal_reached

var has_triggered: bool = false

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node2D) -> void:
	if has_triggered:
		return
	if body.name.begins_with("Chassis") or body.name.begins_with("Wheel") or body.get_parent().name == "Car":
		has_triggered = true
		goal_reached.emit()

func _draw() -> void:
	# Base checkered line
	draw_rect(Rect2(-25, -5, 50, 10), Color.WHITE)
	for i in range(5):
		draw_rect(Rect2(-25 + (i * 10), -5, 5, 5), Color.BLACK)
		draw_rect(Rect2(-20 + (i * 10), 0, 5, 5), Color.BLACK)

	# Small decorative tree next to flag
	draw_rect(Rect2(-35, -25, 6, 25), Color("#8B5A2B"))
	draw_circle(Vector2(-32, -30), 16.0, Color("#5A9E27"))

	# Wooden flag pole
	draw_rect(Rect2(-2, -75, 4, 70), Color("#A0522D"))
	# Gold finial ball
	draw_circle(Vector2(0, -75), 5.0, Color("#FFCA28"))

	# Checkered flag
	draw_rect(Rect2(2, -70, 30, 20), Color.WHITE)
	draw_rect(Rect2(2, -70, 10, 10), Color("#222222"))
	draw_rect(Rect2(22, -70, 10, 10), Color("#222222"))
	draw_rect(Rect2(12, -60, 10, 10), Color("#222222"))

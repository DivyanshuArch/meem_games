class_name SaveTheDogeCharacter
extends RigidBody2D

signal stung

const FACE1_TEX = preload("res://assets/face1.png")
const FACE2_TEX = preload("res://assets/face2.png")

enum Mood { NORMAL, SCARED, HURT, HAPPY }
var current_mood: Mood = Mood.NORMAL
var character_type: String = "face1"
var is_dead: bool = false
var radius: float = 38.0

func _ready() -> void:
	mass = 2.0
	gravity_scale = 1.0
	var col = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = radius
	col.shape = circle
	add_child(col)
	
	# Hurt detector area
	var area = Area2D.new()
	area.name = "HurtBox"
	var area_col = CollisionShape2D.new()
	var area_circle = CircleShape2D.new()
	area_circle.radius = radius + 2.0
	area_col.shape = area_circle
	area.add_child(area_col)
	add_child(area)
	area.body_entered.connect(_on_hurtbox_entered)
	area.area_entered.connect(_on_hazard_entered)

func set_character(type: String) -> void:
	character_type = type
	queue_redraw()

func set_mood(mood: Mood) -> void:
	current_mood = mood
	queue_redraw()

func _on_hurtbox_entered(body: Node2D) -> void:
	if is_dead:
		return
	if body is DogeBee:
		take_damage("bee")

func _on_hazard_entered(area: Area2D) -> void:
	if is_dead:
		return
	if area.is_in_group("hazards"):
		take_damage("hazard")

func take_damage(source: String) -> void:
	if is_dead:
		return
	is_dead = true
	set_mood(Mood.HURT)
	if source == "bee":
		SoundManager.play("aayein")
	else:
		SoundManager.play("vine_boom")
	stung.emit()

func _draw() -> void:
	var tex = FACE2_TEX if character_type == "face2" else FACE1_TEX
	
	# Outer border
	var border_color = Color("#0F172A")
	if current_mood == Mood.SCARED:
		border_color = Color("#EF4444")
	elif current_mood == Mood.HAPPY:
		border_color = Color("#22C55E")
	draw_circle(Vector2.ZERO, radius, border_color)
	
	# Draw face texture
	var face_rect = Rect2(-radius + 3, -radius + 3, (radius - 3) * 2, (radius - 3) * 2)
	draw_texture_rect(tex, face_rect, false)
	
	# Mood overlays
	if current_mood == Mood.SCARED:
		# Sweat drops
		draw_circle(Vector2(26, -18), 5.0, Color("#38BDF8"))
		draw_circle(Vector2(-24, -14), 4.0, Color("#38BDF8"))
	elif current_mood == Mood.HURT:
		# Red flash overlay & X marks
		draw_circle(Vector2.ZERO, radius - 3, Color(1, 0, 0, 0.4))
		draw_line(Vector2(-16, -10), Vector2(-4, 2), Color.BLACK, 3.0)
		draw_line(Vector2(-4, -10), Vector2(-16, 2), Color.BLACK, 3.0)
		draw_line(Vector2(4, -10), Vector2(16, 2), Color.BLACK, 3.0)
		draw_line(Vector2(16, -10), Vector2(4, 2), Color.BLACK, 3.0)
	elif current_mood == Mood.HAPPY:
		# Golden glow
		draw_arc(Vector2.ZERO, radius + 4.0, 0, TAU, 16, Color("#FACC15"), 3.0)

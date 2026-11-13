class_name DogeBee
extends CharacterBody2D

var target: Node2D = null
var speed: float = 190.0
var active: bool = false
var wing_state: float = 0.0

func _ready() -> void:
	var col = CollisionShape2D.new()
	var circle = CircleShape2D.new()
	circle.radius = 9.0
	col.shape = circle
	add_child(col)

func launch(target_node: Node2D, base_speed: float = 200.0) -> void:
	target = target_node
	speed = base_speed + randf_range(-30, 40)
	active = true

func _physics_process(delta: float) -> void:
	if not active or not is_instance_valid(target):
		return
		
	wing_state += delta * 25.0
	queue_redraw()
	
	var dir = (target.global_position - global_position).normalized()
	# Add slight jitter/wobble for realistic swarm behavior
	var wobble = Vector2(-dir.y, dir.x) * sin(wing_state * 2.0) * 0.4
	velocity = (dir + wobble).normalized() * speed
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		var collider = collision.get_collider()
		if collider is SaveTheDogeCharacter:
			collider.take_damage("bee")
		else:
			# Bounce/slide off walls and drawn shield
			velocity = velocity.bounce(collision.get_normal())

func _draw() -> void:
	# Bee body (yellow with black stripes)
	draw_circle(Vector2.ZERO, 9.0, Color("#FACC15"))
	draw_line(Vector2(-3, -7), Vector2(-3, 7), Color("#1E293B"), 2.5)
	draw_line(Vector2(2, -7), Vector2(2, 7), Color("#1E293B"), 2.5)
	
	# Stinger
	draw_polygon(PackedVector2Array([
		Vector2(-9, 0), Vector2(-13, -2), Vector2(-13, 2)
	]), PackedColorArray([Color("#1E293B"), Color("#1E293B"), Color("#1E293B")]))
	
	# Eye
	draw_circle(Vector2(5, -2), 2.5, Color.BLACK)
	
	# Translucent wings flapping
	var wing_y = -9.0 + sin(wing_state) * 5.0
	draw_circle(Vector2(-2, wing_y), 5.5, Color(1, 1, 1, 0.7))

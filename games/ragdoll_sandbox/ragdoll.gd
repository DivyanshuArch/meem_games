extends Node2D
class_name Ragdoll

@export var punch_force_min: float = 800.0
@export var punch_force_max: float = 1400.0
@export var grab_strength: float = 25.0
@export var grab_damping: float = 10.0

@onready var head: RigidBody2D = $Head
@onready var torso: RigidBody2D = $Torso
@onready var left_upper_arm: RigidBody2D = $LeftUpperArm
@onready var left_lower_arm: RigidBody2D = $LeftLowerArm
@onready var right_upper_arm: RigidBody2D = $RightUpperArm
@onready var right_lower_arm: RigidBody2D = $RightLowerArm
@onready var left_upper_leg: RigidBody2D = $LeftUpperLeg
@onready var left_lower_leg: RigidBody2D = $LeftLowerLeg
@onready var right_upper_leg: RigidBody2D = $RightUpperLeg
@onready var right_lower_leg: RigidBody2D = $RightLowerLeg

var all_parts: Array[RigidBody2D] = []
var grabbed_body: RigidBody2D = null
var grab_offset: Vector2 = Vector2.ZERO
var mouse_press_pos: Vector2 = Vector2.ZERO
var mouse_press_time: float = 0.0

func _ready() -> void:
	all_parts = [
		head, torso,
		left_upper_arm, left_lower_arm,
		right_upper_arm, right_lower_arm,
		left_upper_leg, left_lower_leg,
		right_upper_leg, right_lower_leg
	]
	
	# Prevent self-collisions between ragdoll limbs
	for i in range(all_parts.size()):
		for j in range(i + 1, all_parts.size()):
			all_parts[i].add_collision_exception_with(all_parts[j])
			
	for part in all_parts:
		part.input_pickable = true

func set_character(char_id: String) -> void:
	var sprite = get_node_or_null("Head/FaceSprite")
	var label = get_node_or_null("Head/FaceLabel")
	var visual = get_node_or_null("Head/Visual")
	
	if char_id == "face1" or char_id == "" or char_id == "default":
		if sprite:
			sprite.visible = true
		if label:
			label.visible = false
		if visual:
			visual.visible = false
	else:
		if sprite:
			sprite.visible = false
		if label:
			label.visible = true
			label.text = char_id
		if visual:
			visual.visible = true

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			_check_grab_or_punch(event.position)
		else:
			_release_grab(event.position)

func _check_grab_or_punch(click_pos: Vector2) -> void:
	mouse_press_pos = click_pos
	mouse_press_time = Time.get_ticks_msec() / 1000.0
	
	# Check if clicked any ragdoll part
	var closest_part: RigidBody2D = null
	var closest_dist: float = 60.0 # Pixel tolerance
	
	for part in all_parts:
		var dist = part.global_position.distance_to(click_pos)
		if dist < closest_dist:
			closest_dist = dist
			closest_part = part
			
	if closest_part:
		grabbed_body = closest_part
		grab_offset = closest_part.global_position - click_pos
		if randf() < 0.4:
			SoundManager.play_random(["are_baap_re", "aayein", "huh"], 0.1)

func _release_grab(release_pos: Vector2) -> void:
	if not grabbed_body:
		return
		
	var press_duration = (Time.get_ticks_msec() / 1000.0) - mouse_press_time
	var move_dist = release_pos.distance_to(mouse_press_pos)
	
	# If quick tap without movement: execute punch!
	if press_duration < 0.25 and move_dist < 18.0:
		apply_punch(grabbed_body)
	elif grabbed_body.linear_velocity.length() > 500.0 and randf() < 0.5:
		SoundManager.play_random(["fahhh", "fart", "vine_boom"], 0.1)
		
	grabbed_body = null

func apply_punch(target: RigidBody2D) -> void:
	var force_mag = randf_range(punch_force_min, punch_force_max)
	var impulse = Vector2(randf_range(-0.5, 0.5) * force_mag * 0.6, -force_mag)
	target.apply_central_impulse(impulse)
	target.apply_torque_impulse(randf_range(-1.5, 1.5) * force_mag * 4.0)
	SoundManager.play_random(["punch", "slap", "bone_crack", "vine_boom", "fahhh"], 0.15)

func _physics_process(_delta: float) -> void:
	if grabbed_body:
		var target_pos = get_global_mouse_position() + grab_offset
		var to_target = target_pos - grabbed_body.global_position
		var desired_vel = to_target * grab_strength
		var impulse = (desired_vel - grabbed_body.linear_velocity) * grabbed_body.mass
		grabbed_body.apply_central_force(impulse * grab_damping)

extends Node2D
class_name DrawBridgeCar

signal crashed

@export var motor_speed: float = 16.0
@export var stuck_time_threshold: float = 3.0

@onready var chassis: RigidBody2D = $Chassis
@onready var wheel_a: RigidBody2D = $WheelA
@onready var wheel_b: RigidBody2D = $WheelB

var is_driving: bool = false
var stuck_timer: float = 0.0
var has_crashed: bool = false

func _ready() -> void:
	# Ignore collisions between chassis and wheels
	chassis.add_collision_exception_with(wheel_a)
	chassis.add_collision_exception_with(wheel_b)
	wheel_a.add_collision_exception_with(wheel_b)
	# Freeze until driving starts
	chassis.freeze = true
	wheel_a.freeze = true
	wheel_b.freeze = true

func start_driving() -> void:
	is_driving = true
	chassis.freeze = false
	wheel_a.freeze = false
	wheel_b.freeze = false

func _physics_process(delta: float) -> void:
	if not is_driving or has_crashed:
		return
		
	# Apply motor torque to wheels
	wheel_a.angular_velocity = motor_speed
	wheel_b.angular_velocity = motor_speed

	# Check fall off screen
	if chassis.global_position.y > 880.0:
		_trigger_crash()
		return

	# Check if flipped over (> 90 degrees)
	var rot = wrapf(chassis.rotation, -PI, PI)
	var is_upside_down = abs(rot) > (PI * 0.55)

	# Check if stuck (barely moving)
	var is_slow = chassis.linear_velocity.length() < 12.0

	if is_upside_down or is_slow:
		stuck_timer += delta
		if stuck_timer >= stuck_time_threshold:
			_trigger_crash()
	else:
		stuck_timer = 0.0

func _trigger_crash() -> void:
	if has_crashed:
		return
	has_crashed = true
	SoundManager.play_random(["vine_boom", "fart", "are_baap_re"])
	crashed.emit()

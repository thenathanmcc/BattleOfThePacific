extends KinematicBody

onready var forward_camera_target : Spatial = $ForwardFacingCameraTarget
onready var rearfacing_camera_target : Spatial = $RearFacingCameraTarget
onready var projectile_spawn_point_1 : Position3D = $ProjectileSpawnPoint1
onready var projectile_spawn_point_2 : Position3D = $ProjectileSpawnPoint2
onready var plane_body : MeshInstance = $PlaneBody
onready var plane_wings : MeshInstance = $PlaneWings
onready var parent_player : Node = get_node("..")

var min_flight_speed : float = 0
var max_flight_speed : float = 50.0
var turn_speed : float = 0.75
var pitch_speed : float = 0.5
var roll_speed : float = 3.0
var throttle_delta : float = 30.0
var acceleration : float = 30.0

var forward_speed : float = 0.0
var target_speed : float = 0.0
var velocity : Vector3 = Vector3.ZERO

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED) 
	
	# Set initial Velocity
	forward_speed = min_flight_speed
	target_speed = min_flight_speed

func get_player_parent() -> Node:
	return parent_player

func get_forward_camera_target() -> Node:
	return forward_camera_target

func get_rearfacing_camera_target() -> Node:
	return rearfacing_camera_target

func get_projectile_spawn_point1() -> Node:
	return projectile_spawn_point_1

func get_projectile_spawn_point2() -> Node:
	return projectile_spawn_point_2

func throttle_up(throttle_input, delta) -> void:
	target_speed = min(forward_speed + throttle_input * acceleration * delta, max_flight_speed)

func throttle_down(throttle_input, delta) -> void:
	target_speed = max(forward_speed - throttle_input * acceleration * delta, min_flight_speed)

func move(pitch_input, turn_input, roll_input, delta):
	global_transform.basis = global_transform.basis.rotated(global_transform.basis.x.normalized(), pitch_input * pitch_speed * delta)
	global_transform.basis = global_transform.basis.rotated(global_transform.basis.y.normalized(), turn_input * turn_speed * delta)
	global_transform.basis = global_transform.basis.rotated(global_transform.basis.z.normalized(), roll_input * roll_speed * delta)
	
	forward_speed = lerp(forward_speed, target_speed, acceleration * delta)
	
	velocity = -global_transform.basis.z * forward_speed
	velocity = move_and_slide(velocity, Vector3.UP)
	
	# Reset input values
	pitch_input = 0
	turn_input = 0

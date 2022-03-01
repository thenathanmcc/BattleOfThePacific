extends Spatial

# References to other nodes in the scene
onready var plane : KinematicBody = $Plane
onready var forward_camera : Camera = $ForwardFacingCamera
onready var backward_camera : Camera = $RearFacingCamera
onready var projectile_container : Spatial = get_node("../../ProjectileContainer")
onready var projectile_spawn_point1 : Position3D
onready var projectile_spawn_point2 : Position3D
onready var ingame_ui : Control = $InGameUI

# Input variables
var throttle_input : float = 0.0
var pitch_input : float = 0.0
var turn_input : float = 0.0
var roll_input : float = 0.0

# Health variables
const MAX_HEALTH_POINTS : int = 100
var health_points : int = 100

# Projectile variables
const MAX_TOTAL_AMMO_COUNT : int = 800
const MAX_AMMO_COUNT : int = 200
var ammo_count : int = 200
var reserve_ammo_count : int = 200
var projectile_spawn_count : int = 0
var reloading : bool = false
var reload_timer : Timer
var weapon_cooldown : bool = false
var weapon_cooldown_timer : Timer

export (PackedScene) var Projectile

func _ready():
	_setup_cameras()
	_setup_projectile_spawns()
	_setup_timers()

func _setup_projectile_spawns() -> void:
	projectile_spawn_point1 = plane.get_projectile_spawn_point1()
	projectile_spawn_point2 = plane.get_projectile_spawn_point2()

func _setup_cameras() -> void:
	# Assign each camera a target
	forward_camera.setCameraTarget(plane.get_forward_camera_target())
	backward_camera.setCameraTarget(plane.get_rearfacing_camera_target())

func _setup_timers() -> void:
	_setup_reload_timer()
	_setup_weapon_cooldown_timer()

func _setup_reload_timer() -> void:
	reload_timer = Timer.new()
	reload_timer.set_timer_process_mode(0)
	reload_timer.set_one_shot(true)
	reload_timer.wait_time = 3
	reload_timer.connect("timeout", self, "_on_reload_timeout")
	add_child(reload_timer)

func _setup_weapon_cooldown_timer() -> void:
	weapon_cooldown_timer = Timer.new()
	weapon_cooldown_timer.set_timer_process_mode(0)
	weapon_cooldown_timer.set_one_shot(true)
	weapon_cooldown_timer.wait_time = 0.1
	weapon_cooldown_timer.connect("timeout", self, "_on_weapon_cooldown_timeout")
	add_child(weapon_cooldown_timer)

func get_ammo_count() -> int:
	return ammo_count

func get_reserve_ammo_count() -> int:
	return reserve_ammo_count

func get_health_points() -> int:
	return health_points

func _input(event):
	if event is InputEventMouseMotion:
		pitch_input = (event.relative.y * 0.05)
		roll_input = (-event.relative.x * 0.05)

func _process(delta):
	if Input.is_action_pressed("shoot"):
		_shoot_projectile()
	
	# Switch between cameras
	if Input.is_action_pressed("switch_camera"):
		backward_camera.current = true
	else:
		forward_camera.current = true
	
	if Input.is_action_pressed("throttle_up"):
		throttle_input = Input.get_action_strength("throttle_up")
		plane.throttle_up(throttle_input, delta)
	elif Input.is_action_pressed("throttle_down"):
		throttle_input = Input.get_action_strength("throttle_down")
		plane.throttle_down(throttle_input, delta)
	
	if Input.is_action_pressed("turn_left"):
		turn_input = Input.get_action_strength("turn_left")
	elif Input.is_action_pressed("turn_right"):
		turn_input = -Input.get_action_strength("turn_right")
	
	#Update plane's position
	plane.move(pitch_input, turn_input, roll_input, delta)
	
	# reset input values
	pitch_input = 0
	turn_input = 0
	roll_input = 0

func _reload() -> void:
	print("Reloading")
	reloading = true
	reload_timer.start()

func ui_update_ammo_count() -> void:
	ingame_ui.update_ammo_count_label(str(ammo_count))

func ui_update_ammo_reserve_label() -> void:
	ingame_ui.update_reserve_ammo_count_label(str(reserve_ammo_count))

func _shoot_projectile() -> void:
	if reloading:
		return
	
	if ammo_count == 0 and reserve_ammo_count != 0:
		_reload()
		return
	elif ammo_count == 0 and reserve_ammo_count == 0:
		print("Out of Ammo")
		return
	
	if weapon_cooldown:
		return
	else:
		weapon_cooldown = true
		weapon_cooldown_timer.start()
	
	var p = Projectile.instance()
	projectile_container.add_child(p)
	if projectile_spawn_count == 0:
		p.global_transform.origin = projectile_spawn_point1.global_transform.origin
		p.global_transform.basis = projectile_spawn_point1.global_transform.basis
	else:
		p.global_transform.origin = projectile_spawn_point2.global_transform.origin
		p.global_transform.basis = projectile_spawn_point1.global_transform.basis
	p.velocity = -plane.global_transform.basis.z * p.initial_velocity
	
	ammo_count -= 1
	ui_update_ammo_count()
	
	projectile_spawn_count = (projectile_spawn_count + 1) % 2


#############
# SIGNAL CONNECTIONS
#############

func _on_reload_timeout():
	if reserve_ammo_count == 0: 
		return
	elif reserve_ammo_count >= 200:
		ammo_count = 200
		reserve_ammo_count -= 200
	else:
		ammo_count = reserve_ammo_count
		reserve_ammo_count = 0
	print("Done Reloading")
	reloading = false
	ui_update_ammo_count()
	ui_update_ammo_reserve_label()

func _on_weapon_cooldown_timeout():
	weapon_cooldown = false

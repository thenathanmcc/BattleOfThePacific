extends Area

signal exploded

onready var forward_ray : RayCast = $RayCast

export var initial_velocity = 450
export var g = Vector3.DOWN * 9.8

var velocity : Vector3 = Vector3.ZERO

# Lifetime of projectile, will explode when
# timer reaches zero
var life_timer : Timer

func _ready():	
	_setup_life_timer()
	_configure_raycast()
	life_timer.start() 

func _configure_raycast() -> void:
	#forward_ray.enabled = true
	pass

func _setup_life_timer() -> void:
	life_timer = Timer.new()
	life_timer.set_timer_process_mode(0)
	life_timer.set_one_shot(true)
	life_timer.wait_time = 3
	life_timer.connect("timeout", self, "_on_life_timer_timeout")
	add_child(life_timer)

func _physics_process(delta):
	#Update velocity
	velocity += g * delta
	
	# Check for collision between frames
	forward_ray.cast_to = to_local(global_transform.origin + velocity * delta)
	if forward_ray.is_colliding():
		print("I have hit ", forward_ray.get_collider())
		_explode_projectile()
	
	look_at(global_transform.origin + velocity.normalized(), Vector3.UP)
	global_transform.origin += velocity * delta

func _explode_projectile() -> void:
	# Add projectile explosion animation here
	queue_free()

##################
# SINGAL FUNCTIONS
##################

func _on_Projectile_body_entered(body):
	print(self, ": I have hit something")
	#emit_signal("exploded", global_transform.origin)
	queue_free()

func _on_life_timer_timeout() -> void:
	print(self, ": timing out")
	queue_free()

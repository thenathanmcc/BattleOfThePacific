extends Spatial

onready var projectile_container : Node = $ProjectileContainer

var frame_count : int = 0

func _ready():
	pass

func _process(delta):
	frame_count = (frame_count + 1) % 10
	if frame_count == 0:
		print("Projectiles: \n", projectile_container.get_children())

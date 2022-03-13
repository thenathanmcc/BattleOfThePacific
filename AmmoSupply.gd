extends Area

var ammo_amount : int = 200


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_AmmoSupply_body_entered(body):
	if body.has_method("get_player_parent"):
		var parent : Node = body.get_player_parent()
		parent.increase_ammo_count(ammo_amount)

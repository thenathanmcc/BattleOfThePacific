extends Control

onready var ammo_count_label : Label = $AmmoCountLabel
onready var reserve_count_label : Label = $ReserveAmmoCountLabel
onready var health_bar_texture : TextureRect = $HealthBarTexture
onready var health_bar_label : Label = $HealthBarLabel
onready var plane_type_label : Label = $PlaneTypeLabel


func _ready():
	pass

func update_ammo_count_label(ammo_count : String) -> void:
	ammo_count_label.text = ammo_count

func update_reserve_ammo_count_label(ammo_count : String) -> void:
	reserve_count_label.text = ammo_count

func update_health_bar_label(health : String) -> void:
	health_bar_label.text = health

func update_health_bar_texture(health : String) -> void:
	pass

func update_plane_type_label(plane_type : String) -> void:
	plane_type_label.text = plane_type

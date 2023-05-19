@tool
class_name VendingMachine
extends QodotEntity
 
var weapon_type
var spawned_weapon
var cooldown = 1

func update_properties():
	super.update_properties()
	if 'weapon_type' in properties:
		weapon_type = preload("res://Scenes/Weapons/weapon.tscn")

func _ready():
	spawn_new()


func spawn_new():
	spawned_weapon = preload("res://Scenes/Weapons/weapon.tscn").instantiate()
	find_parent("QodotMap").call_deferred("add_child",spawned_weapon)
	spawned_weapon.set_global_position($VendingSlot.get_global_position()+Vector3(0,.2,0))

func _on_area_3d_body_exited(body):
	print(body == spawned_weapon)
	if body != spawned_weapon:
		return
	spawned_weapon = null
	$SpawnCooldown.start(cooldown)
	cooldown += 1


func _on_spawn_cooldown_timeout():
	spawn_new()

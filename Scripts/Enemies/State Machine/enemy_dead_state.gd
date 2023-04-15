extends EnemyBaseState

func enter():
	drop_weapon()
	body.call_deferred("queue_free")

#Handles droping the held weapon
func drop_weapon() -> void:
	var weapon = body.get_weapon()
	var pos = weapon.get_global_transform()
	weapon.get_parent().remove_child(weapon)
	find_parent("QodotMap").add_child(weapon)
	weapon.set_transform(pos)
	weapon.set_collectable(true)
	weapon.throw(body.get_transform().basis*Vector3(0,0,-5))

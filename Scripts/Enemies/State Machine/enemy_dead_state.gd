extends EnemyBaseState

func enter():
	drop_weapon()
	body.call_deferred("queue_free")

#Handles droping the held weapon
func drop_weapon() -> void:
	var weapon = body.get_weapon()
	body.remove_child(weapon)
	body.get_parent().add_child(weapon)
	weapon.throw(body.get_transform().basis*Vector3(0,0,-5))

extends EnemyBaseState


func process(delta) -> EnemyBaseState.State:
	aim_at()
	return EnemyBaseState.State.None

func aim_at():
	var ray = body.get_attack_ray()
	ray.look_at(body.get_target().get_position(), Vector3.UP)
	body.rotate_y(deg_to_rad(ray.get_rotation().y * body.get_stats().get_turn_speed()))
	if !ray.is_colliding() :
		return
	if ray.get_collider() == body.get_target():
		attack()

#Handles the shooting of the attack state
func attack() -> void:
	body.get_weapon().look_at(body.get_target())
	body.get_weapon().attack()

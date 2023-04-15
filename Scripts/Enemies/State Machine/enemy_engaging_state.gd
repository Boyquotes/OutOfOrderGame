extends EnemyBaseState

var navigation: NavigationAgent3D

func enter():
	navigation = body.get_navigation()

func process(delta) -> EnemyBaseState.State:
	if !body.get_target():
		navigation.set_target_position(body.get_position())
		return EnemyBaseState.State.Patrolling
	aim_at()
	return EnemyBaseState.State.None

func aim_at():
	var ray = body.get_attack_ray()
	ray.look_at(body.get_target().get_position(), Vector3.UP)
	body.rotate_y(deg_to_rad(ray.get_rotation().y * body.get_stats().get_turn_speed()))
	if !ray.is_colliding() :
		return
	if body.is_target_visible():
		attack()

#Handles the shooting of the attack state
func attack() -> void:
	body.get_weapon().look_at(body.get_target().get_position())
	body.get_weapon().attack(["Player"])

func physics_process(delta):
	if !body.get_target():
		return
	navigation.set_max_speed(body.get_stats().get_move_speed())
	navigation.set_target_position(body.get_target().get_position())
	var direction = body.get_position().direction_to(navigation.get_next_path_position())
	body.set_velocity(direction*body.get_stats().get_move_speed())
	body.move_and_slide()

extends EnemyBaseState


func process(delta) -> EnemyBaseState.State:
	if body.get_target():
		return EnemyBaseState.State.Engaging
	return EnemyBaseState.State.None

func physics_process(delta):
	body.move_and_slide()

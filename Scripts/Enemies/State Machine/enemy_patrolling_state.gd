extends EnemyBaseState

var navigation: NavigationAgent3D

func enter():
	navigation = body.get_navigation()

func process(delta) -> EnemyBaseState.State:
	return EnemyBaseState.State.Idle

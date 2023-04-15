extends PlayerBaseState

@onready var dash_timer = $DashTimer

func enter():
	dash_timer.start(.25)
	body.set_energy(body.get_energy()-body.get_dash_cost())
	dash()

func dash():
	var dir = body.get_velocity().normalized()
	if movement_input() == Vector3.ZERO:
		body.set_velocity(body.get_transform().basis * Vector3(0, 0, -body.get_dash_speed()))
	else:
		body.set_velocity(movement_input() * Vector3(body.get_dash_speed(), 0, body.get_dash_speed()))

func movement_input() -> Vector3:
	var input = Input.get_vector("Player_Left", "Player_Right", "Player_Forward", "Player_Back")
	return (input.x * body.global_transform.basis.x + input.y * body.global_transform.basis.z).normalized()

#Switches to states from idle
func process(delta) -> PlayerBaseState.State:
	if !dash_timer.get_time_left():
		return PlayerBaseState.State.Idle
	check_attack()
	return PlayerBaseState.State.None

#Checks if the player is attacking
func check_attack():
	if Input.is_action_just_pressed("Player_Attack"):
		body.attack()
	elif Input.is_action_pressed("Player_Attack"):
		body.auto_attack()

func physics_process(delta) -> void:
	body.move_and_slide()

func input(event) -> void:
	move_camera(event as InputEventMouseMotion)
	check_throw(event)

#Handles camera movement
func move_camera(mouse_movement:InputEventMouseMotion) -> void:
	if !mouse_movement:
		return
	
	if !MouseController.is_mouse_locked():
		return
	
	var cam_rotation = body.get_camera().get_rotation()
	cam_rotation.y -= mouse_movement.relative.x * MouseController.get_sensitivity()
	cam_rotation.x -= mouse_movement.relative.y * MouseController.get_sensitivity()
	body.get_camera().set_rotation(Vector3(clamp(cam_rotation.x, -1.3, 1.3),body.get_camera().get_rotation().y,body.get_camera().get_rotation().z))
	body.set_rotation(body.get_rotation()+Vector3(0,cam_rotation.y,0))

#Checks if the player is throwing their weapon
func check_throw(input):
	if Input.is_action_just_pressed("Player_Throw"):
		body.throw()

extends PlayerBaseState

func enter():
	if body.get_velocity().length() < body.get_max_speed():
		body.set_velocity(body.get_transform().basis * Vector3(0, 0, -body.get_max_speed()))

func process(delta):
	if !is_slide_pressed():
		return PlayerBaseState.State.Idle
	return PlayerBaseState.State.None

func is_slide_pressed() -> bool:
	return Input.is_action_pressed("Player_Slide") and body.is_on_floor()

func physics_process(delta) -> void:
	movement(delta)

#Handles player movement, moving the player in a straight line
func movement(delta) -> void:
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

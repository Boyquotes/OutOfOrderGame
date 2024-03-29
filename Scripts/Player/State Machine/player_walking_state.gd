extends PlayerBaseState

func process(delta):
	if movement_input() == Vector3.ZERO:
		return PlayerBaseState.State.Idle
	elif is_dash_pressed():
		return PlayerBaseState.State.Dashing
	elif is_slide_pressed():
		return PlayerBaseState.State.Sliding
	check_attack()
	check_pull(delta)
	recover_energy(delta)
	return PlayerBaseState.State.None

func movement_input() -> Vector3:
	var input_dir = Input.get_vector("Player_Left", "Player_Right", "Player_Forward", "Player_Back")
	return (body.get_transform().basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()

func is_dash_pressed() -> bool:
	return Input.is_action_just_pressed("Player_Dash")

func is_slide_pressed() -> bool:
	return Input.is_action_pressed("Player_Slide") and body.is_on_floor()

#Checks if the player is attacking
func check_attack():
	if Input.is_action_just_pressed("Player_Attack"):
		body.attack()
	elif Input.is_action_pressed("Player_Attack"):
		body.auto_attack()

func check_pull(delta):
	if Input.is_action_pressed("Player_Pull") and body.get_energy()>=body.get_magnet_cost():
		body.pull_magnet(delta)

func recover_energy(delta):
	body.set_energy(clamp(body.get_energy()+delta/4,0,body.get_max_energy()))

func physics_process(delta) -> void:
	movement(delta)

#Handles player movement, uses the same movement system as quake allowing for strafe jumping
func movement(delta) -> void:
	var vel = body.get_velocity()
	
	if body.is_on_floor():
		vel = update_ground_velocity(vel,movement_input(),delta)
	else:
		vel = update_air_velocity(vel,movement_input(),delta)
	
	if !body.is_on_floor():
		vel.y -= ProjectSettings.get_setting("physics/3d/default_gravity")*delta
	elif body.is_on_floor() and Input.is_action_pressed("Player_Jump"):
		vel.y += body.get_jump_strength()
	
	body.set_velocity(vel)
	body.move_and_slide()

func update_ground_velocity(vel:Vector3,wish_dir:Vector3,delta:float) -> Vector3:
	vel = apply_friction(vel, delta)
	return vel + clamp(body.get_max_ground_speed() - vel.dot(wish_dir), 0 , body.get_acceleration()) * wish_dir

func update_air_velocity(vel:Vector3,wish_dir:Vector3,delta:float) -> Vector3:
	return vel + clamp(body.get_max_air_speed() - vel.dot(wish_dir), 0 , body.get_acceleration()) * wish_dir

#Takes a velocity and aplies a friction force
func apply_friction(vel: Vector3, delta: float) -> Vector3:
	var speed: float = vel.length()
	var drop: float = 0
	if speed < 0.01:
		return vel*Vector3(0,1,0)
	if body.is_on_floor():
		drop += speed*body.get_friction()*delta
	return vel*clamp(speed - drop,0,INF)/speed

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

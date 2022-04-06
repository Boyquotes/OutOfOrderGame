extends KinematicBody

export var _camera: NodePath 
export var _raycast: NodePath
export var _mouse_sensitivity: float = 0.08
export var _move_speed: float = 3.0
export var _jump_height: float = 5.0
export var _gravity: float = 0.25

var _floor_direction: Vector3 = Vector3(0,1,0)
var _jump_vector: Vector3


#Checks mouse movement every frame
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#Handles aiming every frame
func _input(event) -> void:
	aim(event)
	shoot()


#Handles player physics every frame
func _physics_process(delta):
	movement()


#Handles movement by modifying two vector3s, one for lateral movement and one for longitudinal movement
#these two vectors3s are then added together and normalised to create the movement vector
#the move_and_slide function is then called with the movement vector multiplied by the movespeed 
#Handles jumping by checking if the player is on the floor, if so, the player can jump, if not, gravity is added
func movement():
	var movement_vector: Vector3
	var forward_movement: Vector3
	var sideways_movement: Vector3
	
	
	if Input.is_action_pressed("move_forward"):
		forward_movement = -transform.basis.z
	elif Input.is_action_pressed("move_back"):
		forward_movement = transform.basis.z
	
	
	if Input.is_action_pressed("move_left"):
		sideways_movement = -transform.basis.x
	elif Input.is_action_pressed("move_right"):
		sideways_movement = transform.basis.x
	
	
	if is_on_floor() && Input.is_action_pressed("jump"):
		_jump_vector = transform.basis.y*_jump_height
	elif !is_on_floor():
		_jump_vector.y = clamp(_jump_vector.y - _gravity,-20,100)
	elif is_on_floor():
		_jump_vector.y = 0
	
	
	movement_vector = forward_movement + sideways_movement  
	movement_vector = movement_vector.normalized()
	movement_vector += _jump_vector
	move_and_slide(movement_vector * _move_speed, _floor_direction)


#Takes an event, checks if the event is mouse motion. 
#Gets relative change of mouse position and rotates camera node acordingly
func aim(event) -> void:
	var mouse_motion = event as InputEventMouseMotion
	if mouse_motion:
		rotation_degrees.y -= mouse_motion.relative.x * _mouse_sensitivity
		
		var current_tilt: float = get_node(_camera).rotation_degrees.x
		current_tilt -= mouse_motion.relative.y * _mouse_sensitivity
		
		get_node(_camera).rotation_degrees.x = clamp(current_tilt, -90, 90)


func shoot() -> void:
	var raycast = get_node(_raycast)
	var bullet_hole = preload("res://bulletHole.tscn")
	
	
	if Input.is_action_pressed("shoot"):
		var target: Object = raycast.get_collider()
		var bullet_child = bullet_hole.instance()
		var surface_direction_up = Vector3(0, 1, 0)
		var surface_direction_down = Vector3(0, -1, 0)
		
		
		target.add_child(bullet_child)
		print (raycast.get_collision_normal())
		
		
		bullet_child.global_transform.origin = raycast.get_collision_point() 
		if raycast.get_collision_normal() == surface_direction_up:
			bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
		elif raycast.get_collision_normal() == surface_direction_down:
			bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
		else:
			bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.DOWN)
		
	
	

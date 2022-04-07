extends KinematicBody

export var _world: NodePath
export var _camera: NodePath 
export var _shoot_raycast: NodePath
export var _interact_raycast: NodePath
export var _hand: NodePath
export var _mouse_sensitivity: float = 0.08
export var _move_speed: float = 3.0
export var _jump_height: float = 5.0
export var _gravity: float = 0.25

var _floor_direction: Vector3 = Vector3(0,1,0)
var _jump_vector: Vector3

var _weapon_to_throw: Object
var _weapon_to_pickup: Object

var _can_shoot: bool = true
var _shot_delay: Timer

var _pistol: Object = preload("res://Guns/pistol.tscn")
var _rifle: Object = preload("res://Guns/rifle.tscn")
var _empty_hand: Object = preload("res://EmptyHand.tscn")

var _first_punch: bool = false

#Checks mouse movement every frame
func _ready():
	add_timer()
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


#Handles input based processes every frame
func _input(event) -> void:
	aim(event)
	atacking()


#Handles all non-physics processes every frame
func _process(delta):
	pickup_and_drop()

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


#Handles shooting of the given weapon using raycasts
func atacking() -> void:
	var hand: Node = get_node(_hand)
	var shoot_raycast: Node = get_node(_shoot_raycast)
	var punch_raycast: Node = get_node(_interact_raycast)
	
	if Input.is_action_pressed("shoot"):
		var target: Object
		var surface_direction_up: Vector3 = Vector3(0, 1, 0)
		var surface_direction_down: Vector3 = Vector3(0, -1, 0)
		
		if hand.get_child_count() != 0 && hand.get_child(0).get_name() != "EmptyHand":
			target = shoot_raycast.get_collider() 
			if target != null:
				_weapon_to_throw._can_shoot = _can_shoot
				_weapon_to_throw.shoot(target,shoot_raycast)
				_can_shoot = false
				_shot_delay.start(_weapon_to_throw._delay)
		
		elif hand.get_child_count() != 0:
			target = punch_raycast.get_collider()
			if target != null:
				punch(target,shoot_raycast)


func punch(target, raycast) -> void:
	var bullet_child: Object = preload("res://punchHole.tscn").instance()
	var surface_direction_up: Vector3 = Vector3(0, 1, 0)
	var surface_direction_down: Vector3 = Vector3(0, -1, 0)
	
	target.add_child(bullet_child)
	bullet_child.global_transform.origin = raycast.get_collision_point() 
	
	if raycast.get_collision_normal() == surface_direction_up:
		bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	elif raycast.get_collision_normal() == surface_direction_down:
		bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	else:
		bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.DOWN)


#Handles picking up weapons by adding instance to child 0 of hand
#Handles droping weapons by setting position of old weapon to hand and setting drop to true (in gun script)
func pickup_and_drop() -> void:
	var reach: Node = get_node(_interact_raycast)
	var hand: Node = get_node(_hand)
	var world: Node = get_node(_world)
	
	if hand.get_child_count() == 0:
		hand.add_child(_empty_hand.instance())
		_first_punch = true
	
	if reach.is_colliding() && reach.get_collider().get_name() == "pistol":
		_weapon_to_pickup= _pistol.instance()
	elif reach.is_colliding() && reach.get_collider().get_name() == "rifle":
		_weapon_to_pickup = _rifle.instance()
	else:
		_weapon_to_pickup = null
	
	if hand.get_child_count() != 0 && get_child(0) != null:
		
		if hand.get_child(0).get_name() == "pistol":
			_weapon_to_throw = _pistol.instance()
		elif hand.get_child(0).get_name() == "rifle":
			_weapon_to_throw = _rifle.instance()
	else:
		_weapon_to_throw = null
	
	if Input.is_action_just_pressed("drop") && hand.get_child(0).get_name() != "EmptyHand":
		if hand.get_child_count() != 0 && hand.get_child(0) != null:
			world.add_child(_weapon_to_throw)
			_weapon_to_throw.global_transform = hand.global_transform
			_weapon_to_throw._dropped = true
			hand.get_child(0).queue_free()
	
	if Input.is_action_just_pressed("interact"):
		if _weapon_to_pickup != null:
			if hand.get_child_count() != 0 && hand.get_child(0) != null:
				if hand.get_child(0).get_name() != "EmptyHand":
					world.add_child(_weapon_to_throw)
					_weapon_to_throw.global_transform = hand.global_transform
					_weapon_to_throw._dropped = true
					hand.get_child(0).queue_free()
				else:
					hand.get_child(0).queue_free()
			reach.get_collider().queue_free()
			hand.add_child(_weapon_to_pickup)
			_weapon_to_pickup.rotation = hand.rotation


func _on_timer_timeout():
	print("d")
	_can_shoot = true


func add_timer():
	_can_shoot = true
	_shot_delay = Timer.new()
	_shot_delay.set_one_shot(true)
	_shot_delay.connect("timeout", self, "_on_timer_timeout") 
	add_child(_shot_delay)

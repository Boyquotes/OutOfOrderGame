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



var _pistol: Resource = preload("res://Guns/pistol.tscn")
var _rifle: Resource = preload("res://Guns/rifle.tscn")
var _sniper: Resource = preload("res://Guns/sniper.tscn")

var _empty_hand: Resource = preload("res://Guns/emptyHand.tscn")

#Checks mouse movement every frame
func _ready():
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
	
	#Checks if the player can jump (if they're on the floor)
	if is_on_floor() && Input.is_action_pressed("jump"):
		_jump_vector = transform.basis.y*_jump_height
	elif !is_on_floor():
		_jump_vector.y = clamp(_jump_vector.y - _gravity,-20,100)
	else:
		_jump_vector.y = 0
	
	#Sets movement vector
	movement_vector = forward_movement + sideways_movement  
	movement_vector = movement_vector.normalized()
	movement_vector += _jump_vector
	move_and_slide(movement_vector * _move_speed, _floor_direction)


#Takes an event, checks if the event is mouse motion. 
#Gets relative change of mouse position and rotates camera node acordingly
func aim(event) -> void:
	#Only sets variable if the event is mouse motion
	var mouse_motion = event as InputEventMouseMotion
	
	if mouse_motion:
		var current_tilt: float = get_node(_camera).rotation_degrees.x
		
		#Moves camera acording to relative mouse movement
		rotation_degrees.y -= mouse_motion.relative.x * _mouse_sensitivity
		current_tilt -= mouse_motion.relative.y * _mouse_sensitivity
		get_node(_camera).rotation_degrees.x = clamp(current_tilt, -90, 90)


#Handles shooting of the given weapon using raycasts
func atacking() -> void:
	var hand: Node = get_node(_hand)
	var shoot_raycast: Node = get_node(_shoot_raycast)
	var punch_raycast: Node = get_node(_interact_raycast)
	
	#Checks if the player clicks the shoot button (single shot)
	if Input.is_action_just_pressed("shoot"):
		var target: Object
		var surface_direction_up: Vector3 = Vector3(0, 1, 0)
		var surface_direction_down: Vector3 = Vector3(0, -1, 0)
		
		#Checks if the player has a weapon to shoot or has to punch
		if hand.get_child_count() != 0 && hand.get_child(0).get_name() != "EmptyHand":
			#The game finds if the raycast in interacting with any objects
			target = shoot_raycast.get_collider() 
			
			#If there is a taget hit, the shot function is called handleing the damage and bullet holes
			if target != null:
				_weapon_to_throw.shoot(target,shoot_raycast)
		
		#If the player doesn't have a weapon, the short range punch_raycast is used
		elif hand.get_child_count() != 0:
			target = punch_raycast.get_collider()
			if target != null:
				hand.get_child(0).shoot(target, punch_raycast)
	
	#Checks if the player is holding down the shoot button (trys to use auto)
	elif Input.is_action_pressed("shoot"):
		var target: Object
		
		#If the player has a weapon, the long range shoot_raycast is used
		if hand.get_child_count() != 0 && hand.get_child(0).get_name() != "EmptyHand":
			#The game finds if the raycast in interacting with any objects
			target = shoot_raycast.get_collider() 
			
			#If there is a taget hit, the shot_auto function is called handleing the damage and bullet holes
			if target != null:
				_weapon_to_throw.shoot_auto(target,shoot_raycast)
		
		#If the player doesn't have a weapon, the short range punch_raycast is used
		elif hand.get_child_count() != 0:
			target = punch_raycast.get_collider()
			if target != null:
				hand.get_child(0).shoot_auto(target,shoot_raycast)




#Handles picking up weapons by adding instance to child 0 of hand
#Handles droping weapons by setting position of old weapon to hand and setting drop to true (in gun script)
func pickup_and_drop() -> void:
	var reach: Node = get_node(_interact_raycast)
	var hand: Node = get_node(_hand)
	var world: Node = get_node(_world)
	
	#If no weapon is in hand, add empty hand model
	if hand.get_child_count() == 0:
		hand.add_child(_empty_hand.instance())
	
	#If the player is looking at a weapon in range to pick up, the game checks what weapon it is and whether it's broken
	#An instance of that weapon is then stored in _weapon_to_pickup ready for the player to pick it up 
	if reach.is_colliding() && "Pistol" in reach.get_collider().get_name()  && reach.get_collider()._broken != true:
		_weapon_to_pickup= _pistol.instance()
	elif reach.is_colliding() && "Rifle" in reach.get_collider().get_name()  && reach.get_collider()._broken != true:
		_weapon_to_pickup = _rifle.instance()
	elif reach.is_colliding() && "Sniper" in reach.get_collider().get_name()  && reach.get_collider()._broken != true:
		_weapon_to_pickup = _sniper.instance()
	else:
		_weapon_to_pickup = null
	
	#Checks if the hand node has a child 
	if hand.get_child_count() != 0 && get_child(0) != null:
		
		#The game then determines what the name of the held weapon is (set to null if the child is empty hand)
		if hand.get_child(0).get_name() == "Pistol" :
			if _weapon_to_throw == null || _weapon_to_throw.get_name() != "Pistol":
				_weapon_to_throw = _pistol.instance()
		elif hand.get_child(0).get_name() == "Rifle":
			if _weapon_to_throw == null || _weapon_to_throw.get_name() != "Rifle":
				_weapon_to_throw = _rifle.instance()
		elif hand.get_child(0).get_name() == "Sniper":
			if _weapon_to_throw == null || _weapon_to_throw.get_name() != "Sniper":
				_weapon_to_throw = _sniper.instance()
	else:
		_weapon_to_throw = null
	
	#If the player wants to throw their weapon, and they have a held weapon
	if Input.is_action_just_pressed("drop") && hand.get_child(0).get_name() != "EmptyHand":
		if hand.get_child_count() != 0 && hand.get_child(0) != null:
			#An instance of the held weapon is added to the level node (path stored in world)
			world.add_child(_weapon_to_throw)
			
			#Position of the new child is set to the hand
			_weapon_to_throw.global_transform = hand.global_transform
			
			#The weapon has the dropped var set to true this appies an impulse on the weapon (find in gun.gd) 
			_weapon_to_throw._dropped = true
			
			#The actual held weapon (the child of the hand node) is then deleted
			hand.get_child(0).queue_free()
			
			#_weapon_to_throw is then set to null to avoid trying to interact with a deleted node
			_weapon_to_throw = null
	
	#Checks if the player wants to pick up a weapon
	if Input.is_action_just_pressed("interact") && _weapon_to_pickup != null:
		
		#Checks if the player is currently holding a weapon
		if hand.get_child_count() != 0 && hand.get_child(0) != null:
			if hand.get_child(0).get_name() != "EmptyHand":
				#Runs the same code for dropping a weapon (look there for explination)
				world.add_child(_weapon_to_throw)
				_weapon_to_throw.global_transform = hand.global_transform
				_weapon_to_throw._dropped = true
				_weapon_to_throw = null
			else:
				#If the player has doesn't have a weapon e.g only child of hand is emptyHand, this is deleted
				hand.get_child(0).queue_free()
		#Deletes the weapon on the ground
		reach.get_collider().queue_free()
		
		#Adds an instance of the weapon in _weapon_to_pickup to the hand node
		hand.add_child(_weapon_to_pickup)
		
		#Sets the rotation for the gun to be correct
		_weapon_to_pickup.rotation = hand.rotation







extends KinematicBody

signal shoot()
signal shoot_auto()

export var world_path: NodePath
export var camera_path: NodePath 
export var interact_raycast_path: NodePath
export var grapple_raycast_path: NodePath
export var hand_path: NodePath

onready var world: Node = get_node(world_path)
onready var camera: Camera = get_node(camera_path)
onready var interact_raycast: RayCast = get_node(interact_raycast_path)
onready var grapple_raycast: RayCast = get_node(grapple_raycast_path)
onready var hand: Node = get_node(hand_path)

export var mouse_sensitivity: float = 0.08
export var move_speed: float = 6.0
export var sprint_multi: float = 1.5
export var jump_height: float = 8.0
export var gravity: float = 0.1
export var acceleration: float = 50.0
export var grapple_recharge: float = 5.0
export var health: int = 100

var floor_direction: Vector3 = Vector3(0,1,0)
var vertical_vector: Vector3
var velocity: Vector3

var available_gapples: int = 3
var last_grapple: float

var weapon_to_throw: Object
var weapon_to_pickup: Object

var empty_hand: Resource = preload("res://Guns/Gun Scenes/emptyHand.tscn")

#Checks mouse movement every frame
func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	if hand.get_child_count() != 0:
		connect_weapon(hand.get_child(0))


#Handles input based processes every frame
func _input(event) -> void:
	aim(event)


#Handles all non-physics processes every frame
func _process(_delta):
	pickup_and_drop()
	grapple()
	atacking()

#Handles player physics every frame
func _physics_process(delta):
	movement(delta)


#Handles movement by modifying two vector3s, one for lateral movement and one for longitudinal movement
#these two vectors3s are then added together and normalised to create the movement vector
#the move_and_slide function is then called with the movement vector multiplied by the movespeed 
#Handles jumping by checking if the player is on the floor, if so, the player can jump, if not, gravity is added
func movement(delta):
	var movement_direction: Vector3 = Vector3(0,0,0)
	var current_move_speed: float = move_speed
	
	#Sets sprint speed
	if Input.is_action_pressed("sprint"):
		current_move_speed = move_speed * sprint_multi
	
	if Input.is_action_pressed("move_forward"):
		movement_direction += -transform.basis.z
	elif Input.is_action_pressed("move_back"):
		movement_direction += transform.basis.z
	
	if Input.is_action_pressed("move_left"):
		movement_direction += -transform.basis.x
	elif Input.is_action_pressed("move_right"):
		movement_direction += transform.basis.x
	
	#Checks if the player can jump (if they're on the floor)
	if is_on_floor() && Input.is_action_pressed("jump"):
		vertical_vector.y = jump_height
	elif not is_on_floor():
		vertical_vector.y -= gravity
	
	#Sets movement vector
	movement_direction = movement_direction.normalized()
	velocity = velocity.linear_interpolate(movement_direction*current_move_speed, acceleration * delta)
	velocity = move_and_slide(velocity, floor_direction)
	var _movement = move_and_slide(vertical_vector, floor_direction)


#Takes an event, checks if the event is mouse motion. 
#Gets relative change of mouse position and rotates camera node acordingly
func aim(event) -> void:
	#Only sets variable if the event is mouse motion
	var mouse_motion = event as InputEventMouseMotion
	
	if mouse_motion:
		var current_tilt: float = camera.rotation_degrees.x
		
		#Moves camera acording to relative mouse movement
		rotation_degrees.y -= mouse_motion.relative.x * mouse_sensitivity
		current_tilt -= mouse_motion.relative.y * mouse_sensitivity
		camera.rotation_degrees.x = clamp(current_tilt, -90, 90)


#Handles shooting of the given weapon using raycasts
func atacking() -> void:
		
	#Checks if the player clicks the shoot button (single shot)
	if Input.is_action_just_pressed("shoot"):
		#Stops shooting and dropping at the same time (causing a crash)
		if Input.is_action_just_pressed("drop"):
			return
		
		#Emits the shoot signal to the held weapon
		emit_signal("shoot")
		return
	
	#Checks if the player is holding down the shoot button (trys to use auto)
	elif Input.is_action_pressed("shoot"):
		
		#Stops shooting and dropping at the same time (causing a crash)
		if Input.is_action_just_pressed("drop"):
			return
		
		#Emits the shoot signal to the held weapon
		emit_signal("shoot_auto")


#Handles picking up weapons by adding instance to child 0 of hand
#Handles droping weapons by setting position of old weapon to hand and setting drop to true (in gun script)
func pickup_and_drop() -> void:
	
	#If no weapon is in hand, add empty hand model
	if hand.get_child_count() == 0:
		var new_hand: Object = empty_hand.instance()
		connect_weapon(new_hand)
		hand.add_child(new_hand)
	
	#If the player is looking at a weapon in range to pick up, the game checks what weapon it is and whether it can be picked up
	#An instance of that weapon is then stored in weapon_to_pickup ready for the player to pick it up 
	weapon_to_pickup = null
	
	for gun in GlobalVariables.gun_list:
		if interact_raycast.is_colliding() && gun[0] in interact_raycast.get_collider().get_parent().get_name():
			if interact_raycast.get_collider().get_parent().can_be_picked_up != false:
				weapon_to_pickup = gun[1].instance()
	
	#Checks if the hand node has a child 
	if hand.get_child_count() != 0 && get_child(0) != null:
		
		weapon_to_throw = null
		
		#The game then determines what the name of the held weapon is (left as null if the child is empty hand)
		for gun in GlobalVariables.gun_list:
			if gun[0] in hand.get_child(0).get_name():
				if weapon_to_throw == null || weapon_to_throw.get_name() != gun[0]:
					weapon_to_throw = gun[1].instance()
	
	#If the player wants to throw their weapon, and they have a held weapon
	if Input.is_action_just_pressed("drop") && hand.get_child(0).get_name() != "EmptyHand":
		if hand.get_child_count() != 0 && hand.get_child(0) != null:
			
			
			#An instance of the held weapon is added to the level node (path stored in world)
			world.add_child(weapon_to_throw)
			
			#Position of the new child is set to the camera
			weapon_to_throw.global_transform = camera.global_transform
			
			#The weapon has the dropped var set to true this appies an impulse on the weapon (find in gun.gd) 
			weapon_to_throw.dropped = true
			
			#The actual held weapon (the child of the hand node) is then deleted
			hand.get_child(0).queue_free()
			
			#weapon_to_throw is then set to null to avoid trying to interact with a deleted node
			weapon_to_throw = null
	
	#Checks if the player wants to pick up a weapon
	if Input.is_action_just_pressed("interact") && weapon_to_pickup != null:
		
		#Checks if the player is currently holding a weapon
		if hand.get_child_count() != 0 && hand.get_child(0) != null:
			if hand.get_child(0).get_name() != "EmptyHand":
				#Runs the same code for dropping a weapon (look there for explination)
				world.add_child(weapon_to_throw)
				weapon_to_throw.global_transform = camera.global_transform
				weapon_to_throw.dropped = true
				weapon_to_throw = null
			#If the player has doesn't have a weapon e.g only child of hand is emptyHand, this is deleted
			hand.get_child(0).queue_free()
		#Deletes the weapon on the ground
		interact_raycast.get_collider().get_parent().queue_free()
		
		connect_weapon(weapon_to_pickup)
		
		#Adds an instance of the weapon in weapon_to_pickup to the hand node
		hand.add_child(weapon_to_pickup)
		
		#Sets the rotation for the gun to be correct
		weapon_to_pickup.rotation = hand.rotation

#Handles grappling weapons to pick them up from affar
func grapple():
	
	var grapple_target: Object
	
	#Checks if your hand is empty and you have a grapple charge
	if Input.is_action_just_pressed("drop") && hand.get_child(0).get_name() == "EmptyHand" && available_gapples > 0:
		#Check if the raycast is colliding with the pickup area of a weapon (why get_parent() is used)
		if grapple_raycast.is_colliding() && grapple_raycast.get_collider().get_parent().is_in_group("Weapon"):
			if grapple_raycast.get_collider().get_parent().can_be_picked_up == false:
				return
			#Decreases grpple charges by 1 
			available_gapples -= 1
			#Sets the time of the gapple
			last_grapple = get_time()
			#Gets the grapple target
			grapple_target = grapple_raycast.get_collider().get_parent()
	
	#Checks if there's a grapple targed
	if grapple_target != null:
		#Changes the grapple targets parent to the players hand and deletes the empty hand
		grapple_target.get_parent().remove_child(grapple_target)
		hand.get_child(0).queue_free()
		connect_weapon(grapple_target)
		hand.add_child(grapple_target)
		grapple_target.global_transform = hand.global_transform
		
		#Clears the grapple target
		grapple_target = null
	
	#Refils a grapple charge after the recharge time
	if get_time() - last_grapple > grapple_recharge && available_gapples < 3:
		available_gapples += 1
		#Resets grapple timer
		last_grapple = get_time()
	

#Handles connecting new weapons to the shoot signals
func connect_weapon(weapon) -> void:
	var _con = connect("shoot",weapon,"_on_shoot")
	_con = connect("shoot_auto",weapon,"_on_shoot_auto")


#Gets current time, painless way of making timers
func get_time():
	return OS.get_ticks_msec() / 1000.0

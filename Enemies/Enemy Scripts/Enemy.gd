extends KinematicBody

enum {
	IDLE=-1,
	ACTIVE=-2,
	DEAD=-3
}

export var stats: Resource

onready var hand: Node = $Hand
onready var raycast: Node = $RayCast
onready var eyes: Node = $Eyes
onready var anim_player: Node = $AnimationPlayer
onready var world: Node = get_node("/root/").get_child(0) 

var local_health: int 

var target: Node
var shoot_target: Node
var last_shot: float = 0.0

var state = IDLE

#Handles setup
func _ready():
	
	local_health = stats.health
	
	#Makes the held gun be unable to be picked ups
	if hand.get_child_count() != 0:
		hand.get_child(0).can_be_picked_up = false
		hand.get_child(0).get_child(0).disabled = true

#Handles health checks and position of weapons
func _process(_delta):
	state_handler()
	hold_item()
	check_on_floor()


#Handles updating held item position
func hold_item() -> void:
	
	#Makes item follow hand position
	if hand.get_child_count() != 0:
		hand.get_child(0).global_transform = hand.global_transform

#Handles checking the enemies health
func check_health() -> void:
	
	#Checks if the health drops below 0
	if local_health <= 0:
		state = DEAD

#Handles droping the held weapon
func drop_weapon() -> void:
	
	var gun = stats.weapon.instance()
	
	#Creates an instance of the given weapon in the scene
	world.add_child(gun)
	
	#Makes the dropped weapon be able to be picked up
	gun.can_be_picked_up = true
	
	#Sets position of dropped weapon to the hand
	gun.global_transform = hand.global_transform


func _on_Area_body_entered(body) -> void:
	#Does nothing is the enemy is dead
	if state == DEAD:
		return
	
	##Checks if the player enters the detection range
	if body.is_in_group("Player"):
		#Changes the state and sets the target
		state = ACTIVE
		target = body


func _on_Area_body_exited(body) -> void:
	#Does nothing is enemy is dead
	if state == DEAD:
		return
	
	#Checks if the leaving body is the player
	if body.is_in_group("Player"):
		#Changes the state
		state = IDLE

#State handler for the enemy AI
func state_handler() -> void:
	#Checks the default states (Idle, Active, and Dead)
	#If there is no match, additional_states() is called, this handles the unique states of enemy types 
	check_health()
	match state:
		DEAD:
			start_death()
		IDLE:
			anim_player.play("Idle")
			pass
		ACTIVE:
			active()
		_:
			additional_states()

func shoot() -> void:
	shoot_target = null
	
	if raycast.is_colliding():
		shoot_target = raycast.get_collider()
	
	#Checks if the enemy is aiming at the player, then shoots
	if shoot_target != null && shoot_target.is_in_group("Player"):
		shoot_target.health = clamp(shoot_target.health-stats.damage,0,999)
	
	#Handles the shot delay
	last_shot = get_time()

func active() -> void:
	anim_player.play("Active")
	#Allows the enemy to "look at", chase, and shoot the player
	eyes.look_at(target.global_transform.origin, Vector3.UP)
	rotate_y(deg2rad(eyes.rotation.y * stats.turn_speed))
	if get_time() - last_shot > stats.attack_delay:
		shoot()
	var _mov = move_and_slide(-transform.basis.z*stats.move_speed,Vector3.UP)

#Handles the death and deleation of the enemy
func die() -> void:
	drop_weapon()
	self.queue_free()
	GlobalVariables.remaining_enemies -= 1

func start_death():
	anim_player.play("Death")

#Gets current time, painless way of making timers
func get_time() -> float:
	return OS.get_ticks_msec() / 1000.0

#Handles custom states of enemy types (made to be overriden)
func additional_states() -> void:
	pass

#Checks if the enemy is on the floor, adds a gravity effect if not
func check_on_floor():
	if not is_on_floor():
		var _mov = move_and_slide(Vector3(0,-2,0),Vector3.UP) 


func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "Death":
		die()

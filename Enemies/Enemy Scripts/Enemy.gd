extends KinematicBody

enum {
	ATTACK,
	IDLE,
	ALERT,
	DEAD
}

export var stats: Resource

export var hand_path: NodePath
export var raycast_path: NodePath
export var eyes_path: NodePath

onready var hand: Node = get_node(hand_path)
onready var raycast: Node = get_node(raycast_path)
onready var eyes: Node = get_node(eyes_path)
onready var world: Node = get_node("/root/").get_child(0) 

var local_health: int 

var target: Node
var shoot_target: Node
var last_shot: float = 0.0
var fire_rate: float
var rotation_time: float = 0.0

var state = IDLE

#Handles setup
func _ready():
	
	local_health = stats.health
	
	GlobalVariables.remaining_enemies += 1
	
	#Makes the held gun be unable to be picked ups
	if hand.get_child_count() != 0:
		hand.get_child(0).can_be_picked_up = false
		hand.get_child(0).get_child(0).disabled = true
		fire_rate = hand.get_child(0).stats.fire_rate

#Handles health checks and position of weapons
func _process(_delta):
	check_health()
	state_handler()
	hold_item()

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


func _on_Area_body_entered(body):
	
	if state == DEAD:
		return
	
	if body.is_in_group("Player"):
		state = ALERT
		target = body


func _on_Area_body_exited(body):
	
	if state == DEAD:
		return
	
	if body.is_in_group("Player"):
		rotation_time = 0.0
		state = IDLE

func state_handler():
	
	if not is_on_floor():
		var _mov = move_and_slide(Vector3(0,-2,0),Vector3.UP) 
	
	match state:
		IDLE:
			
			pass
		ALERT:
			eyes.look_at(target.global_transform.origin, Vector3.UP)
			rotate_y(deg2rad(eyes.rotation.y * stats.turn_speed))
			if get_time() - last_shot > fire_rate:
				shoot()
			var _mov = move_and_slide(-transform.basis.z*stats.move_speed,Vector3.UP)
		DEAD:
			drop_weapon()
			self.queue_free()
			GlobalVariables.remaining_enemies -= 1

func shoot():
	shoot_target = null
	
	var damage: float = hand.get_child(0).stats.damage
	
	if raycast.is_colliding():
		shoot_target = raycast.get_collider()
	
	if shoot_target != null && shoot_target.is_in_group("Player"):
		shoot_target.health = clamp(shoot_target.health-damage,0,999)
	
	last_shot = get_time()


#Gets current time, painless way of making timers
func get_time():
	return OS.get_ticks_msec() / 1000.0

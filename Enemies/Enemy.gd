extends KinematicBody


export var health: int = 100
var _hand: NodePath = "Hand"

var _world: Node 
var _gun: Object = preload("res://Guns/pistol.tscn")

#Handles setup
func _ready():
	#Finds the main world node, used for spawing a gun
	_world = get_node("/root/").get_child(0)
	
	var hand: Node = get_node(_hand)
	
	#Makes the held gun be unable to be picked ups
	if hand.get_child_count() != 0:
		hand.get_child(0)._can_be_picked_up = false

#Handles health checks and position of weapons
func _process(delta):
	var hand: Node = get_node(_hand)
	
	#Makes gun follow hand position
	if hand.get_child_count() != 0:
		hand.get_child(0).global_transform = hand.global_transform
	
	#Checks if the health drops below 0
	if health <= 0:
		
		#Drops weapon
		drop_weapon()
		
		#Deletes enemy
		queue_free()

#Handles droping the held weapon
func drop_weapon() -> void:
	var hand: Node = get_node(_hand)
	var gun: Node = _gun.instance()
	
	#Creates an instance of the given weapon in the scene
	_world.add_child(gun)
	
	#Makes the dropped weapon be able to be picked up
	gun._can_be_picked_up = true
	
	#Sets position of dropped weapon to the hand
	gun.global_transform = hand.global_transform

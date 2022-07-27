extends Spatial

export var enemy_list_resource: Resource
export(Array, NodePath) var spawn_locations_list: Array
export var spawn_cooldown: int

onready var enemy_list: Array = enemy_list_resource.enemies
onready var world = get_node("/root/").get_child(1)
onready var remaining_spawns = GlobalVariables.current_wave*2
onready var timer = Timer.new()

var can_spawn = true

func _process(_delta):
	try_spawn()
	check_wave()

func _ready():
	#Connects timeout signal 
	timer.connect("timeout",self,"_on_cooldown_timeout") 
	add_child(timer)

#Reduces the remaining spawns when an enemy is spawned
func _on_Spawner_enemy_spawned():
	remaining_spawns -= 1

#Handles the spawn cooldown
func _on_cooldown_timeout():
	can_spawn = true

#Handles checking the end of a wave then incrementing the wave number
func check_wave():
	
	#Checks if all enemies for the wave have been spawned and killed
	if GlobalVariables.remaining_enemies != 0:
		return
	
	if remaining_spawns != 0:
		return
	
	#Increments wave count and adds remaining spawns for the next wave
	GlobalVariables.current_wave += 1
	remaining_spawns = GlobalVariables.current_wave*2

#Handles spawning of enemies
func try_spawn() -> void:
	
	#Checks if there are avalible spawns and the cooldown has expired
	if  remaining_spawns < 1:
		return
	
	if  can_spawn == false:
		return
	
	#Gets a random spawn location in the given list
	var spawn_location = get_node(spawn_locations_list[randi()%spawn_locations_list.size()])
	
	#Reduces avalible spawns and put the spawner on cooldown
	can_spawn = false
	remaining_spawns -= 1
	GlobalVariables.remaining_enemies += 1
	
	#Gets the enemy instance from the given list and spawns one at the given location
	var enemy_instance = enemy_list[0].instance()
	world.add_child(enemy_instance)
	enemy_instance.global_transform = spawn_location.global_transform
	
	#Creates a timer to count down the cooldown
	timer.set_wait_time(spawn_cooldown)
	timer.start() 


extends CharacterBody3D

#Const

const FRICTION = 6

#Variables

#Node References
@onready var state_controller: Node = $StateController
@onready var camera: Camera3D = $Camera3D
@onready var shader: ShaderMaterial = $CanvasLayer/ColorRect.get_material()
@onready var interact_ray = $Camera3D/InteractRay
@onready var hand = $Camera3D/Hand
@onready var animation_player = $AnimationPlayer

@onready var debug_label = $CanvasLayer/Label

#Movement Variables
@export var max_ground_speed: float = 12
@export var max_air_speed: float = 4
@export var acceleration: float = 3
@export var jump_strength: float = 5
@export var dash_speed: float = 25

#Health Variables
@export var max_health: int = 100
@onready var health: int = get_max_health()

#Getters

func get_state_controller() -> Node:
	return state_controller

func get_camera() -> Camera3D:
	return camera

func get_shader() -> ShaderMaterial:
	return shader

func get_shader_pix_size() -> float:
	return shader.get_shader_parameter("pixelSize")

func get_interact_raycast() -> RayCast3D:
	return interact_ray

func get_animation_player() -> AnimationPlayer:
	return animation_player

func get_max_ground_speed() -> float:
	return max_ground_speed

func get_max_air_speed() -> float:
	return max_air_speed

func get_acceleration() -> float:
	return acceleration

func get_jump_strength() -> float:
	return jump_strength

func get_friction() -> float:
	return FRICTION

func get_dash_speed() -> float:
	return dash_speed

func get_max_health() -> int:
	return max_health

func get_health() -> int:
	return health

#Setters

func set_shader_pix_size(value:float) -> void:
	shader.set_shader_parameter("pixelSize", value)

func set_max_ground_speed(value:float) -> void:
	max_ground_speed = value

func set_max_air_speed(value:float) -> void:
	max_air_speed = value

func set_acceleration(value:float) -> void:
	acceleration = value

func set_jump_strength(value:float) -> void:
	jump_strength = value

func set_dash_speed(value:float) -> void:
	dash_speed = value

func set_max_health(value:float) -> void:
	max_health = value

func set_health(value:float) -> void:
	health = value

#Functions

func _ready() -> void:
	state_controller.init(self)
	
	#Debug stuff
	for child in hand.get_children():
		if !child is Weapon:
			continue
		child.set_held(true)
		return

func _process(delta) -> void:
	state_controller.process(delta)
	debug_label.set_text("Pos: {pos} Vel: {vel}".format({"pos":get_position(),"vel":get_velocity().length()}))

func _physics_process(delta) -> void:
	state_controller.physics_process(delta)

func _input(event) -> void:
	state_controller.input(event)

#Handles the player interacting with objects
func interact() -> void:
	if !interact_ray.get_collider():
		return
	print(interact_ray.get_collider())
	if interact_ray.get_collider().is_in_group("Interactable"):
		interact_ray.get_collider().interact(self)
	elif interact_ray.get_collider().is_in_group("Weapon"):
		pickup_weapon(interact_ray.get_collider().get_parent())

#Handles picking up a given weapon, adding it to the players hand
func pickup_weapon(weapon:RigidBody3D):
	if !weapon is Weapon:
		return
	
	if !weapon.is_collectable():
		return
	
	for child in hand.get_children():
		if !child is Weapon:
			continue
		hand.remove_child(child)
		get_parent().add_child(child)
		child.set_position(get_position())
		child.throw(Vector3.ZERO)
	
	if weapon.get_parent():
		weapon.get_parent().remove_child(weapon)
	
	hand.add_child(weapon)
	weapon.set_global_transform(hand.get_global_transform())
	weapon.set_held(true)

#Handles calling attack on held weapon
func attack() -> void:
	for child in hand.get_children():
		if !child is Weapon:
			continue
		child.attack()
		return

#Handles calling auto attack on held weapon
func auto_attack() -> void:
	for child in hand.get_children():
		if !child is Weapon:
			continue
		child.auto_attack()
		return

#Handles throwing the held weapon
func throw() -> void:
	for child in hand.get_children():
		if !child is Weapon:
			continue
		hand.remove_child(child)
		get_parent().add_child(child)
		child.set_global_position(camera.get_global_position())
		var cam_rot = camera.get_global_rotation().normalized()
		child.throw(Vector3(0,0,-35).rotated(Vector3(1,0,0),cam_rot.x).rotated(Vector3(0,1,0),get_rotation().y).rotated(Vector3(0,0,1),cam_rot.z))
		return

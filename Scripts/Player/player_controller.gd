extends CharacterBody3D

#Const

const FRICTION = 8

#Variables

#Node References
@onready var state_controller: Node = $StateController
@onready var camera: Camera3D = $Camera3D
@onready var shader: ShaderMaterial = $CanvasLayer/ColorRect.get_material()
@onready var interact_ray = $Camera3D/InteractRay
@onready var aim_ray = $Camera3D/AimRay
@onready var hand = $Camera3D/SubViewportContainer/SubViewport/WeaponCam/Hand
@onready var weapon_cam = $Camera3D/SubViewportContainer/SubViewport/WeaponCam
@onready var magnet_area = $Camera3D/MagnetArea
@onready var animation_player = $AnimationPlayer
@onready var debug_label = $CanvasLayer/Label

var weapon: Node3D

#Movement Variables
var max_ground_speed: float = 8
var max_air_speed: float = 4
var acceleration: float = 3
var jump_strength: float = 5
var dash_speed: float = 30

#Health Variables
var max_health: float = 100
@onready var health: float = get_max_health()

#Energy Variables
var max_energy: float = 5
@onready var energy: float = get_max_energy()
var dash_cost: float = 1
var pull_cost: float = .5

#Magnetic Variables
var magnetic_bodies: Array = []
var pull_strength: float = 15

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

func get_weapon() -> Node3D:
	return weapon

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

func get_max_health() -> float:
	return max_health

func get_health() -> float:
	return health

func get_max_energy() -> float:
	return max_energy

func get_energy() -> float:
	return energy

func get_dash_cost() -> float:
	return dash_cost

#Setters

func set_shader_pix_size(value:float) -> void:
	shader.set_shader_parameter("pixelSize", value)

func set_weapon(value:Node3D) -> void:
	weapon = value

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

func set_max_energy(value:float) -> void:
	max_energy = value

func set_energy(value:float) -> void:
	energy = value

func set_dash_cost(value:float) -> void:
	dash_cost = value

#Functions

func _ready() -> void:
	state_controller.init(self)
	
	#Debug stuff
	for child in hand.get_children():
		if !child is Weapon:
			continue
		pickup_weapon(child)
		return

func _process(delta) -> void:
	state_controller.process(delta)
	weapon_cam.set_transform(camera.get_global_transform())
	set_weapon_aim()

func set_weapon_aim() -> void:
	if !aim_ray.is_colliding():
		return
	var weapon = null
	for child in hand.get_children():
		if !child is Weapon:
			continue
		weapon = child
	if !weapon:
		return
	weapon.set_projectile_spawn_direction(aim_ray.get_collision_point())

func _physics_process(delta) -> void:
	state_controller.physics_process(delta)

func _input(event) -> void:
	state_controller.input(event)

#Handles the player interacting with objects
func interact() -> void:
	if !interact_ray.get_collider():
		return
	if interact_ray.get_collider().is_in_group("Interactable"):
		interact_ray.get_collider().interact(self)
	elif interact_ray.get_collider().is_in_group("Weapon"):
		pickup_weapon(interact_ray.get_collider().get_parent())

#Handles picking up a given weapon, adding it to the players hand
func pickup_weapon(new_weapon:RigidBody3D):
	if !new_weapon is Weapon:
		return
	
	#Removes previous weapon
	if get_weapon():
		var old_weapon = get_weapon()
		hand.remove_child(old_weapon)
		find_parent("QodotMap").call_deferred("add_child",old_weapon)
		old_weapon.set_collectable(true)
		old_weapon.set_position(get_position())
		var cam_rot = camera.get_global_rotation().normalized()
		old_weapon.call_deferred("throw",Vector3(0,0,-5).rotated(Vector3(1,0,0),cam_rot.x).rotated(Vector3(0,1,0),get_rotation().y).rotated(Vector3(0,0,1),cam_rot.z))
	
	#Equips new weapon
	if !new_weapon.get_parent():
		hand.add_child(new_weapon)
	elif new_weapon.get_parent() != hand:
		new_weapon.get_parent().remove_child(new_weapon)
		hand.add_child(new_weapon)
	new_weapon.set_global_transform(hand.get_global_transform())
	new_weapon.set_held(true)
	new_weapon.set_model_layer(2)
	set_weapon(new_weapon)

#Handles calling attack on held weapon
func attack() -> void:
	for child in hand.get_children():
		if !child is Weapon:
			continue
		child.attack(["Enemy"])
		return

#Handles calling auto attack on held weapon
func auto_attack() -> void:
	for child in hand.get_children():
		if !child is Weapon:
			continue
		child.auto_attack(["Enemy"])
		return

#Handles throwing the held weapon
func throw() -> void:
	if !get_weapon():
		return
	hand.remove_child(get_weapon())
	find_parent("QodotMap").add_child(get_weapon())
	get_weapon().set_global_position(camera.get_global_position())
	get_weapon().set_collectable(false)
	var cam_rot = camera.get_global_rotation().normalized()
	get_weapon().throw(Vector3(0,0,-35).rotated(Vector3(1,0,0),cam_rot.x).rotated(Vector3(0,1,0),get_rotation().y).rotated(Vector3(0,0,1),cam_rot.z))
	set_weapon(null)

func pull_weapons() -> void:
	set_energy(get_energy()-pull_cost)
	for body in magnetic_bodies:
		if body is RigidBody3D:
			var time = .5
			var pos = camera.get_global_position()+Vector3(0,1,0)+get_velocity()*time
			body.apply_central_impulse(body.get_position().direction_to(pos).normalized()*pull_strength)
	

#Handles taking damage
func take_damage(damage) -> void:
	set_health(clamp(get_health()-damage,0,INF))

#Signal Functions

func _on_magnet_area_body_entered(body):
	if body.is_in_group("Magnetic"):
		magnetic_bodies.append(body)

func _on_magnet_area_body_exited(body):
	if magnetic_bodies.has(body):
		magnetic_bodies.erase(body)

func _on_auto_pickup_area_entered(area):
	if area.is_in_group("Weapon") and !get_weapon():
		pickup_weapon(area.get_parent())

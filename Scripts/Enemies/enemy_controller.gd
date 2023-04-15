extends CharacterBody3D


#Node References

@onready var state_controller = $StateController
@onready var hand: Node = $Hand
@onready var attack_ray = $AttackRay
@onready var navigation = $Navigation

#Variables

@export var stats: Resource

@onready var health: float = stats.get_health() 

var target: Node3D

#Getters

func get_weapon() -> Weapon:
	for child in hand.get_children():
		if !child is Weapon:
			continue
		return child
	return null

func get_attack_ray() -> RayCast3D:
	return attack_ray

func get_target() -> Node3D:
	return target

func is_target_visible() -> bool:
	if !attack_ray.is_colliding():
		return false
	return attack_ray.get_collider() == target

func get_navigation() -> NavigationAgent3D:
	return navigation

func get_stats() -> Resource:
	return stats

func get_health() -> float:
	return health

#Setters

func set_health(value:float) -> void:
	health = value

#Functions 

func _ready():
	state_controller.init(self)
	for child in hand.get_children():
		if !child is Weapon:
			continue
		child.set_held(true)

func _process(delta):
	state_controller.process(delta)

func _physics_process(delta):
	state_controller.physics_process(delta)

func _input(event):
	state_controller.input(event)

func take_damage(damage) -> void:
	print(damage)
	set_health(clamp(get_health()-damage,0,INF))

func set_weapon_aim() -> void:
	if !attack_ray.is_colliding():
		return
	var weapon = null
	for child in hand.get_children():
		if !child is Weapon:
			continue
		weapon = child
	if !weapon:
		return
	get_weapon().set_projectile_spawn_direction(attack_ray.get_collision_point())

#Signal Functions

func _on_player_detection_body_entered(body):
	if body.is_in_group("Player"):
		target = body

func _on_player_detection_body_exited(body):
	if body == target:
		target = null

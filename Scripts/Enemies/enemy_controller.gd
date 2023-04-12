extends CharacterBody3D


#Node References

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

func get_navigation() -> NavigationAgent3D:
	return navigation

func get_health() -> float:
	return health

#Setters

func set_health(value:float) -> void:
	health = value

#Functions 

func _ready():
	for child in hand.get_children():
		if !child is Weapon:
			continue
		child.set_held(true)

func take_damage(damage) -> void:
	print(damage)
	set_health(get_health()-damage)

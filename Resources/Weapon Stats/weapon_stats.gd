extends Resource
class_name WeaponStats

@export var damage: float = 10.0
@export var fire_rate: float = 2
@export var max_ammo: int = 10
@export var reload_time: float = 1
@export var auto: bool = true
@export var mass: float = 15.0
@export var thrown_damage: float = 10.0
@export var jam_chance: float = 0
@export var projectile: PackedScene

#Getters

func get_damage() -> float:
	return damage

func get_fire_rate() -> float:
	return fire_rate

func get_max_ammo() -> int:
	return max_ammo

func get_reload_time() -> float:
	return reload_time

func is_auto() -> bool:
	return auto

func get_mass() -> float:
	return mass

func get_thrown_damage() -> float:
	return thrown_damage

func get_jam_chance() -> float:
	return jam_chance

func get_projectile() -> PackedScene:
	return projectile

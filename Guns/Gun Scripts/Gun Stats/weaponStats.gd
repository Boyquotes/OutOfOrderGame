extends Resource
class_name WeaponStats

export var damage: float = 10.0
export var fire_rate: float = 0.2
export var ammo: int = 10
export var is_auto: bool = false
export var throw_strength: float = 15.0
export var throw_damage: float = 10.0
export var can_jam: bool = true
export var inv_chance_to_jam: int = 40
export var decay_time: float = 3
export var bullet_hole: PackedScene

#Get the ammo on the sheet
func get_ammo() -> int:
	return ammo

#Checks if the gun randomly jams
func try_jam() -> bool:
	
	if can_jam == false:
		return false
	
	randomize()
	
	if randi()%inv_chance_to_jam+1 == inv_chance_to_jam:
		return true
	
	return false

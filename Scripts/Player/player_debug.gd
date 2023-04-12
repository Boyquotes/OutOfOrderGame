extends Node

@export var weapon: PackedScene

func _process(delta):
	if Input.is_action_just_pressed("Debug_Spawn_Weapon"):
		get_parent().pickup_weapon(weapon.instantiate())

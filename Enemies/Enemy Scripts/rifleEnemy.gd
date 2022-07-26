extends "res://Enemies/Enemy.gd"

#Sets the gun dropped by the enemy
func _ready():
	_gun = preload("res://Guns/rifle.tscn")

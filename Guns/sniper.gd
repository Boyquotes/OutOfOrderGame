extends "res://Guns/gun.gd"

#Sets the look of _bullet_holes to this preload
func _ready():
	_bullet_hole = preload("res://bulletHole.tscn")

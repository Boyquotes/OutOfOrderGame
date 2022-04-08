extends Timer


var _can_shoot = true

func _ready():
	pass # Replace with function body.

func get_can_shoot():
	return _can_shoot

func _on_Timer_timeout():
	print("d")
	_can_shoot = true

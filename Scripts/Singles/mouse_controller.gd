extends Node

#Variables

var mouse_sensitivity: float = 0.001

#Getters

func is_mouse_locked():
	return Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED

func get_sensitivity():
	return mouse_sensitivity

#Setters

func set_lock_mouse(value):
	if value:
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	else:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func set_sensitivity(value):
	mouse_sensitivity = value

#Testing
func _input(event):
	if Input.is_action_just_pressed("ui_cancel"):
		set_lock_mouse(!is_mouse_locked())

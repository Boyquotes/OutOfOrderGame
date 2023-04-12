extends Node
class_name Interactable

#Variables

@export var interact_action: String = "Placeholder"

@onready var highlight_text: MeshInstance3D = $HighlightText

#Getters

func get_interact_message() -> String:
	return String("Press {button} to {action}").format({"button":KeyBindingController.get_key_binding("Player_Interact"),"action":interact_action})

func is_highlighted() -> bool:
	return highlight_text.is_visible()

#Setters

func set_highlight(val:bool, pos:Vector3) -> void:
	highlight_text.set_visible(val)
	if val:
		highlight_text.look_at(pos)
		highlight_text.rotate(Vector3(0,1,0),deg_to_rad(180))
		highlight_text.get_mesh().set_text(get_interact_message())
	else:
		highlight_text.get_mesh().set_text("")

#Functions

func interact(caller: Node):
	print("Interaction by: ",caller)

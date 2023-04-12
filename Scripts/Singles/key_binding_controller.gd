extends Node


func get_key_binding(action:String):
	return InputMap.action_get_events(action)[0].as_text().trim_suffix(" (Physical)")

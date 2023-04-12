extends Node
class_name EnemyBaseState

#Enums

enum State{
	None,
	Idle,
	Engaging,
	Patrolling,
	Dead
}

#Variables

var body: CharacterBody3D
var state_controler: Node

#Functions

func init(body_value:CharacterBody3D, sc_value:Node = null) -> void:
	body = body_value
	state_controler = sc_value

func enter() -> void:
	pass

func exit() -> void:
	pass

func process(delta):
	return PlayerBaseState.State.None

func physics_process(delta) -> void:
	pass

func input(event) -> void:
	pass

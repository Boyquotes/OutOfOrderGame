extends Resource
class_name EnemyStats

#Variables

@export var health: float = 100
@export var turn_speed: float = 4.0
@export var move_speed: float = 2.0
@export var miss_chance: int = 10

#Getters

func get_health() -> float:
	return health

func get_turn_speed() -> float:
	return turn_speed

func get_move_speed() -> float:
	return move_speed

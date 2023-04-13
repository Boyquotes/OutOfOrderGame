extends CharacterBody3D

#Node References
@onready var timer = $DespawnTimer

#Variables
var damage: float = 0

#Getters

func get_damage() -> float:
	return damage

#Setters

func set_damage(value:float) -> void:
	damage = value

#Functions

func _ready():
	timer.start(3)

func _physics_process(delta):
	move_and_slide()

#Signal Functions

func _on_despawn_timer_timeout():
	call_deferred("queue_free")


func _on_detection_area_body_entered(body):
	if body.is_in_group("Enemy"):
		body.take_damage(damage)
		call_deferred("queue_free")

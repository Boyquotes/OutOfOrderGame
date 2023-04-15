extends CharacterBody3D

#Node References
@onready var timer = $DespawnTimer

#Variables
var target_groups: Array = []
var damage: float = 0

#Getters

func get_damage() -> float:
	return damage

#Setters

func set_damage(value:float) -> void:
	damage = value

func set_target_groups(value:Array) -> void:
	target_groups = value

#Functions

func _ready():
	print(self,position)
	timer.start(3)

func _physics_process(delta):
	move_and_slide()

#Signal Functions

func _on_despawn_timer_timeout():
	call_deferred("queue_free")


func _on_detection_area_body_entered(body):
	for group in target_groups:
		if body.is_in_group(group):
			body.take_damage(damage)
			call_deferred("queue_free")
		if !body.is_in_group("AllowsBullets"):
			call_deferred("queue_free")

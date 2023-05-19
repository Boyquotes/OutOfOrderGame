extends CharacterBody3D

var current_time: float = 0

@onready var visuals = $CollisionShape3D/Visuals

var vel: Vector3 = Vector3.ZERO

func _process(delta) -> void:
	current_time += delta*4

func _physics_process(delta) -> void:
	visuals.set_position(visuals.get_position()+Vector3(0,sin(current_time)/2,0)*delta)
	if !is_on_floor():
		vel.y -= ProjectSettings.get_setting("physics/3d/default_gravity")*delta
	set_velocity(vel)
	vel = Vector3(clamp(vel.x-1,0,100),vel.y,clamp(vel.z-1,0,100))
	move_and_slide()

func pull(pos:Vector3,stength:float) -> void:
	vel = get_velocity()+get_position().direction_to(pos).normalized()*stength/2

func collect(caller:Node3D) -> void:
	if !caller.heal(10):
		call_deferred("queue_free")

extends RigidBody

export var _throw_strength: float = 15.0

export var _delay: float = 1

var _can_shoot: bool
var _dropped: bool = false
var _bullet_hole: Object = preload("res://bulletHole.tscn")


func _process(delta) -> void:
	if _dropped == true:
		apply_impulse(transform.basis.z, -transform.basis.z * _throw_strength)
		_dropped = false


#Adds the given bullet hole texture to the given object normal to the surface 
func add_bullet_hole(target,raycast) -> void:
	var bullet_child: Object = _bullet_hole.instance()
	var surface_direction_up: Vector3 = Vector3(0, 1, 0)
	var surface_direction_down: Vector3 = Vector3(0, -1, 0)
	
	target.add_child(bullet_child)
	bullet_child.global_transform.origin = raycast.get_collision_point() 
	
	if raycast.get_collision_normal() == surface_direction_up:
		bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	elif raycast.get_collision_normal() == surface_direction_down:
		bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	else:
		bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.DOWN)




func shoot(target, raycast) -> void:
	if _can_shoot == true:
		add_bullet_hole(target,raycast)
		_can_shoot = false
	

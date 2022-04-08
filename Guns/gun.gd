extends RigidBody

#Credit for Miziziziz for the shoot(target,raycast), auto_shoot(target,raycast) and get_time() functions.
#Referenced code can be found https://github.com/Miziziziz/Godot3DGunSystem.
#Timers wern't working due to the many different instances and this get_time solution worked perfectly.

export var _throw_strength: float = 15.0
export var _fire_rate: float = 0.2
export var _is_auto: bool = false
export var _decay_time: float = 3

var _bullet_hole: Object = preload("res://bulletHole.tscn")
var _last_fire_time: float = 0.0
var _dropped: bool = false
var _broken: bool = false
var _time_broken: float = 0


#Runs every frame, checks when the weapon is thrown and when to despawn after being thrown
func _process(delta):
	#Checks if the weapon has been dropped
	if _dropped == true:
		#Applys a force as if the gun was thrown
		apply_impulse(transform.basis.z, -transform.basis.z * _throw_strength)
		
		#Resets _dropped so the force is only applied once
		_dropped = false
		
		#Sets _broken to true so the weapon can't be picked up 
		_broken = true
		
		#Sets _time_broken to current time
		_time_broken = get_time()
	
	#After the weapon is broken, checks if the time since _time_broken is more than the _decay_time 
	if _broken == true:
		if get_time()-_time_broken > _decay_time:
			#This object is then deleted
			queue_free()

#Adds the given bullet hole texture to the given object normal to the surface 
func add_bullet_hole(target,raycast) -> void:
	var bullet_child: Object = _bullet_hole.instance()
	var surface_direction_up: Vector3 = Vector3(0, 1, 0)
	var surface_direction_down: Vector3 = Vector3(0, -1, 0)
	
	#Adds a bullet_hole to the target object at the aimed position
	target.add_child(bullet_child)
	bullet_child.global_transform.origin = raycast.get_collision_point() 
	
	#Sets the orientation of the bullet hole to the normal of the object (texture is flat to object)
	if raycast.get_collision_normal() == surface_direction_up:
		bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	elif raycast.get_collision_normal() == surface_direction_down:
		bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.RIGHT)
	else:
		bullet_child.look_at(raycast.get_collision_point() + raycast.get_collision_normal(), Vector3.DOWN)


#Fires the gun repeatedly if _is_auto is true
func shoot_auto(target, raycast):
	if !_is_auto:
		return
	shoot(target, raycast)


#Shoots the gun if enough time has elapsed since the last shot
func shoot(target, raycast) -> void:
	#Compares if the _last_fire_time and _fire_rate if passed time is more than _fire_rate then shoot
	if get_time() - _last_fire_time < _fire_rate:
		return
	_last_fire_time = get_time()
	add_bullet_hole(target,raycast)


#Gets current time, painless way of making timers
func get_time():
	return OS.get_ticks_msec() / 1000.0



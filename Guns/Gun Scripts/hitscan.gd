extends RigidBody

#Credit for Miziziziz for the shoot(target,raycast), auto_shoot(target,raycast) and get_time() functions.
#Referenced code can be found https://github.com/Miziziziz/Godot3DGunSystem.
#Timers wern't working due to the many different instances and this get_time solution worked perfectly.

export var stats: Resource

export var raycast_path: NodePath

export var can_be_picked_up: bool = true
export var is_jammed: bool = false

var local_ammo: int 

var last_fire_time: float = 0.0
var dropped: bool = false
var broken: bool = false
var time_broken: float = 0
var throw_targets: Array
var raycast: RayCast

func _ready():
	local_ammo = stats.get_ammo()
	raycast = get_node(raycast_path)
	#raycast.global_transform = get_parent().global_transform

#Runs every frame, checks when the weapon is thrown and when to despawn after being thrown
func _process(_delta):
	check_dropped()

#Adds the given bullet hole texture to the given object normal to the surface 
func add_bullet_hole(target) -> void:
	
	var bullet_child: Object = stats.bullet_hole.instance()
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


#Fires the gun repeatedly if is_auto is true
func _on_shoot_auto():
	
	if !stats.is_auto:
		return
	
	_on_shoot()


#Shoots the gun if enough time has elapsed since the last shot
func _on_shoot() -> void:
	
	#Compares if the last_fire_time and fire_rate if passed time is more than fire_rate then shoot
	if get_time() - last_fire_time < stats.fire_rate:
		return
	last_fire_time = get_time()
	
	
	#Checks if the gun is jammed or out of ammo
	if is_jammed == true:
		return
	
	if local_ammo < 1:
		return
	
	#Reduces ammo and rolls to see if the weapon jams
	local_ammo -= 1
	is_jammed = stats.try_jam()
	
	#Checks if the raycas colides with an object
	var target: Node = raycast.get_collider() 
	
	if target == null:
		return
	
	#If the target is an enemy, deal damage
	if target.is_in_group("Can_Be_Shot"):
		target.local_health -= stats.damage
	
	#Calls function to add a bullet hole
	add_bullet_hole(target)

#Handles dropping/thowing held weapons
func check_dropped():
	#Checks if the weapon has been dropped
	if dropped == true:
		#Applys a force as if the gun was thrown
		apply_impulse(transform.basis.z, -transform.basis.z * stats.throw_strength)
		
		#Resets dropped so the force is only applied once
		dropped = false
		
		#Sets _can_be_pickedup to false so the weapon can't be picked up 
		can_be_picked_up = false
		
		#Sets broken to true so the weapon can start its despawn timer
		broken = true
		
		#Sets time_broken to current time
		time_broken = get_time()
	
	#After the weapon is broken, checks if the time since time_broken is more than the decay_time 
	if broken == true:
		if get_time()-time_broken > stats.decay_time:
			#This object is then deleted
			queue_free()
		
		#Calls function to handle the thown weapons damage
		throw_attack()

#Handled doing damage with thrown weapons
func throw_attack():
	var target: Node = null
	var speed: float = get_linear_velocity().length()
	
	#If the weapon collides a node, stores that node in target
	if get_colliding_bodies().size() > 0 : 
		target = get_colliding_bodies().front()
	
	#If the target is an enemy, hasn't been hit by this weapon before, and the weapon's speed is more than 2
	if target != null && target.is_in_group("Enemy") && not throw_targets.has(target) && speed > 2:
		#Deals damage to the enemy
		target.local_health -= stats.throw_damage*speed/1.5
		
		#Adds the hit enemy to the list of thow targets so it can't get hit twice in a row
		throw_targets.append(target)

#Gets current time, painless way of making timers
func get_time():
	return OS.get_ticks_msec() / 1000.0

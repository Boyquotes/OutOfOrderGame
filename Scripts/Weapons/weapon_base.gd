extends RigidBody3D
class_name Weapon

#Constants

const DESPAWN_TIME: float = 3
const PROJ_SPEED: float = 20

#Node References

@onready var attack_timer: Timer = $AttackCooldown
@onready var decay_timer: Timer = $DecayTimer
@onready var collision_delay = $CollisionDelay

#Variables

@export var stats: Resource
@export var collectable: bool = true
@export var hostile: bool = false

@onready var ammo: int = stats.get_max_ammo() 

var jammed: bool = false
var collided_bodies: Array

#Setters

func set_collectable(value:bool) -> void:
	collectable = value

func set_hostile(value:bool) -> void:
	hostile = value

func set_ammo(value:int) -> void:
	ammo = value

func set_jammed(value:bool) -> void:
	jammed = value

func set_held(value:bool) -> void:
	if value:
		set_collision_layer(0)
		set_collision_mask(0)
	else:
		set_collision_layer(1)
		set_collision_mask(1)
	set_freeze_enabled(value)

#Getters

func get_stats() -> Resource:
	return stats

func is_collectable() -> bool:
	return collectable

func is_hostile() -> bool:
	return hostile

func get_ammo() -> int:
	return ammo

func is_jammed() -> bool:
	return jammed

#Functions

#Fires the gun repeatedly if is_auto is true
func auto_attack() -> void:
	if !stats.is_auto():
		return
	attack()

#Handles attacking with the weapon
func attack() -> void:
	if !can_attack():
		return
	set_ammo(get_ammo()-1)
	attack_timer.start(1.0/stats.get_fire_rate())
	roll_jam()
	var proj = stats.get_projectile().instantiate()
	proj.set_position(get_global_position())
	proj.set_velocity(get_global_transform().basis * Vector3(0,0,-1)* PROJ_SPEED)
	find_parent("World").add_child(proj)

#Returns if the weapon can fire
func can_attack() -> bool:
	return !attack_timer.get_time_left() and !is_jammed() and get_ammo()

#Checks if the gun jams
func roll_jam() -> void:
	set_jammed(randi()%100 < stats.get_jam_chance())

#Handles thowing held weapons
func throw(throw_force:Vector3) -> void:
	set_collectable(false)
	set_freeze_enabled(false)
	collision_delay.start(.05)
	apply_central_impulse(throw_force)
	decay_timer.start(DESPAWN_TIME)

#Signal Functions

#Handles despawning the broken object
func _on_decay_timer_timeout() -> void:
	print(self," despawn at ", get_global_position())
	call_deferred("queue_free")

func _on_body_entered(body) -> void:
	throw_collision(body)

#Handles doing damage with thrown weapons
func throw_collision(body):
	print(self," collided with ",body)
	if get_linear_velocity().length() < 2:
		return
	
	if collided_bodies.has(body):
		return
	
	if body.is_in_group("Enemy"):
		body.take_damage(stats.get_thrown_damage()*get_mass()*get_linear_velocity().length())
		collided_bodies.append(body)
	elif is_hostile() and body.is_in_group("Player"):
		body.take_damage(stats.get_thrown_damage()*get_mass()*get_linear_velocity().length()/4)
		collided_bodies.append(body)

func _on_collision_delay_timeout():
	set_held(false)

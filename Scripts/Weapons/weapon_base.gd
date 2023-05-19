extends RigidBody3D
class_name Weapon

#Constants

const DESPAWN_TIME: float = 3
const PROJ_SPEED: float = 75

#Node References

@onready var attack_timer: Timer = $AttackCooldown
@onready var decay_timer: Timer = $DecayTimer
@onready var collision_delay: Timer = $CollisionDelay
@onready var reload_timer = $ReloadTimer
@onready var interact_shape: CollisionShape3D = $WeaponInteractArea/CollisionShape3D
@onready var projectile_spawn = $ProjectileSpawn
@onready var model = $Model

#Variables

@export var stats: Resource

@onready var ammo: int = stats.get_max_ammo() 

var jammed: bool = false
var scrap_preload: PackedScene = preload("res://Scenes/Collectables/scrap.tscn")

#Setters

func set_collectable(value:bool) -> void:
	interact_shape.call_deferred("set_disabled",!value)

func set_ammo(value:int) -> void:
	ammo = value

func set_jammed(value:bool) -> void:
	jammed = value

func set_equiped(value:bool) -> void:
	if value:
		set_collectable(false)
		set_collision_layer(0)
		set_collision_mask(0)
	else:
		set_collision_layer(2)
		set_collision_mask(1)
	set_freeze_enabled(value)

func set_projectile_spawn_direction(value:Vector3) -> void:
	projectile_spawn.look_at(value)

func set_model_layer(value:int) -> void:
	model.set_layer_mask(value)

#Getters

func get_stats() -> Resource:
	return stats

func is_collectable() -> bool:
	return !interact_shape.is_disabled()

func get_ammo() -> int:
	return ammo

func is_jammed() -> bool:
	return jammed

#Functions

func _ready():
	set_mass(stats.get_mass())
	print(self)

#Fires the gun repeatedly if is_auto is true
func auto_attack(target_groups:Array) -> void:
	if !stats.is_auto():
		return
	attack(target_groups)

#Handles attacking with the weapon
func attack(target_groups:Array) -> void:
	if !can_attack():
		return
	set_ammo(get_ammo()-1)
	attack_timer.start(1.0/stats.get_fire_rate())
	roll_jam()
	var proj = stats.get_projectile().instantiate()
	proj.set_position(projectile_spawn.get_global_position())
	proj.set_velocity(projectile_spawn.get_global_transform().basis * Vector3(0,0,-1)* PROJ_SPEED)
	proj.set_target_groups(target_groups)
	proj.set_damage(stats.get_damage())
	find_parent("QodotMap").add_child(proj)

#Returns if the weapon can fire
func can_attack() -> bool:
	return !attack_timer.get_time_left() and !is_jammed() and get_ammo()

#Checks if the gun jams base on the chance
func roll_jam() -> void:
	set_jammed(randi()%100 < stats.get_jam_chance())

func reload() -> void:
	if reload_timer.get_time_left() > 0:
		return
	reload_timer.start(stats.get_reload_time())

func pull(pos:Vector3,strength:float):
	set_linear_velocity(get_position().direction_to(pos).normalized()*strength*sqrt(position.distance_to(pos)))

func push(pos:Vector3,strength:float):
	set_linear_velocity(pos.direction_to(get_position()).normalized()*strength*pow(position.distance_to(pos),2))

#Handles thowing held weapons and triggering a despawn if they can't be collected
func throw(throw_force:Vector3) -> void:
	collision_delay.start(.05)
	apply_central_impulse(throw_force)
	if !is_collectable():
		decay_timer.start(DESPAWN_TIME)

#Signal Functions

#Handles despawning the broken object
func _on_decay_timer_timeout() -> void:
	call_deferred("queue_free")

func _on_body_entered(body) -> void:
	throw_collision(body)

#Handles doing damage with thrown weapons
func throw_collision(body):
	if body.is_in_group("Enemy") and get_linear_velocity().length() < 2:
		body.take_damage(get_mass()*get_linear_velocity().length() + stats.get_thrown_damage())
	
	if !is_collectable():
		var scrap = scrap_preload.instantiate()
		find_parent("QodotMap").add_child(scrap)
		scrap.set_position(get_global_position())
		call_deferred("queue_free")

func _on_collision_delay_timeout():
	set_equiped(false)

func _on_reload_timer_timeout():
	set_ammo(get_stats().get_max_ammo())

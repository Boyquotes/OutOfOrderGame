@tool
extends QodotEntity

func update_properties():
	super.update_properties()
	if 'size' in properties:
		print(properties.size)
		$CollisionShape3D.get_shape().set_size(properties.size)

func _on_body_entered(body):
	if body.is_in_group("Player") or body.is_in_group("Enemy"):
		body.set_health(0)
	elif body is Weapon:
		body.call_deferred("queue_free")

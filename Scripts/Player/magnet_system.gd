extends RayCast3D

@onready var magnet_area = $MagnetArea


func pull():
	magnet_area.set_postition()

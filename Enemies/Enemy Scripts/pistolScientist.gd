extends "res://Enemies/Enemy Scripts/Enemy.gd"

enum {
	SURRENDER,
	COWER
}

var fear_recovery_start = 0
var fear_recovery = 3
var timer = Timer.new()
onready var cower_area = $CowerArea

func _ready():
	timer.connect("timeout",self,"_on_fear_timeout") 
	add_child(timer)

func additional_states():
	match state:
		SURRENDER:
			print (state)
		COWER:
			
			anim_player.play("Cower")

func surrender():
	pass


func _on_CowerArea_body_exited(body):
	if body.is_in_group("Player"):
		timer.start(3)

func _on_fear_timeout():
	timer.stop()
	state = IDLE

func _on_CowerArea_body_entered(body):
	if body.is_in_group("Player"):
		state = COWER

#Gets current time, painless way of making timers
func get_time():
	return OS.get_ticks_msec() / 1000.0


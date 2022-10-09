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

func _on_CowerArea_body_exited(body):
	if state == DEAD:
		return
	if body.is_in_group("Player"):
		timer.start(7)

func _on_fear_timeout():
	
	timer.stop()
	change_state(IDLE)

func _on_CowerArea_body_entered(body):
	if body.is_in_group("Player"):
		if !timer.paused:
			timer.stop()
		change_state(COWER)


func change_additional_states(new_state):
	
	if state == COWER:
		return state
	
	
	return new_state


func handle_additional_states():
	match state:
		SURRENDER:
			surrender()
		COWER:
			cower()

func surrender():
	pass

func cower():
	anim_player.play("Cower")


extends CanvasLayer

export var player_path: NodePath
export var hand_path: NodePath
export var grapple_display_path: NodePath
export var health_display_path: NodePath
export var wave_display_path: NodePath
export var ammo_display_path: NodePath

onready var gapple_display: Label = get_node(grapple_display_path)
onready var health_display: Label = get_node(health_display_path)
onready var wave_display: Label = get_node(wave_display_path)
onready var ammo_display: Label = get_node(ammo_display_path)
onready var player: Node = get_node(player_path)
onready var hand: Node = get_node(hand_path)


var grapple_counter: int
var health: int
var gun: Object
var ammo: int

#Updates HUD every frame
func _process(_delta):
	update_grapple()
	update_health()
	update_wave()
	update_ammo()

#Updates the grapple counter
func update_grapple():
	#Gets grapple charges
	grapple_counter = player.available_gapples
	#Updates text on UI
	gapple_display.set_text("Graples: "+str(grapple_counter))

func update_health():
	health = player.health
	health_display.set_text("Health: "+str(health))

func update_wave():
	wave_display.set_text("Current Wave: "+str(GlobalVariables.current_wave))

func update_ammo():
	
	if hand.get_child_count() == 0:
		ammo_display.get_parent().hide()
		return
	
	var weapon: Node = hand.get_child(0)
	ammo_display.get_parent().show()
	
	if weapon.get_name() == "EmptyHand":
		ammo_display.set_text("Ammo: infinite")
		return
	
	if weapon.is_jammed == true:
		ammo_display.set_text("Ammo: JAMMED!!")
		return
	
	ammo_display.set_text("Ammo: "+str(weapon.local_ammo))

extends Control

export(String, DIR) var weapon_dir = "res://entity/weapon"
var budget_max = 1000
var budget_used = 0
enum player {PLAYER1=1,PLAYER2=2}

onready var budget_bar = get_node("budget_bar")
onready var budget_label = get_node("budget_label")
onready var side_label = get_node("side_label")
onready var weapon_list = get_node("weapon_list")
onready var loadout_list = get_node("loadout_list")

func _ready():
	update()

func set_player(p):
	player = p
	update()

func update():
	# Setup the budget bar
	budget_bar.set_max(budget_max)
	budget_bar.set_value(budget_used)
	
	# Setup the budget label
	budget_label.set_text(str("Budget: ",budget_used,"/",budget_max))
	
	# Setup the side label
	if player == PLAYER1:
		side_label.set_text("You are on the attacking side.")
	elif player == PLAYER2:
		side_label.set_text("You are on the defending side.")
	else:
		side_label.set_text("You are on the FIXME side.")
		print("update_labels() called with player not set.")
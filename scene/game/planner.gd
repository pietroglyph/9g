extends Control

onready var global = get_node("/root/global")

func _ready():
	print(global.loadout)
	print(global.loadout_index)

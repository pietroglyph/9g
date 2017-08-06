extends Control

export(String, DIR) var weapon_dir = "res://entity/weapon"

onready var global = get_node("/root/global")
onready var weapon_list = get_node("weapon_list")

var weapon_list_size
var finished = false

func _ready():
	global.loadout_index = 0
	weapon_list_size = 0
	display_loadout()
	
	get_node("next").connect("pressed", self, "next_player")

func display_loadout():
	if !global.loadout.has(global.loadout_index):
		print("The global loadout dictionary doesn't contain loadout data for loadout_index ", global.loadout_index, ".")
		return
	
	for file_name in global.loadout[global.loadout_index]:
		var weapon_instance = load(weapon_dir+"/"+file_name)
		var amount = global.loadout[global.loadout_index][file_name]
		weapon_list.add_item(str(amount), weapon_instance.get_instance().get_texture(), false)
		weapon_list_size += 1
		var info = {"file_name": file_name, "amount": amount}
		weapon_list.set_item_metadata(weapon_list_size-1, info)

func next_player():
	if !global.loadout.has(global.loadout_index+1):
		finished = true
		self.hide()
		return
	
		
func is_finished():
	return finished
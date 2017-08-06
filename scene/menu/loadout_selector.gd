extends Control

export(String, DIR) var weapon_dir = "res://entity/weapon"
var budget_max = 1000
var budget_used = 0
var loadout_list_size = 0 # Maybe the reason not to use ItemList

onready var budget_bar = get_node("budget_bar")
onready var budget_label = get_node("budget_label")
onready var side_label = get_node("side_label")
onready var weapon_list = get_node("weapon_list")
onready var loadout_list = get_node("loadout_list")

onready var global = get_node("/root/global")

func _ready():
	# Load weapons into the menus
	var dir = Directory.new()
	if dir.open(weapon_dir) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		var idx = 0
		while (file_name != ""):
			if !dir.current_is_dir() && file_name.split(".")[1] == "tscn":
				var weapon = load(weapon_dir+"/"+file_name)
				if weapon == null:
					print("Couldn't load ",file_name,".")
				else:
					if weapon.get_type() == "PackedScene" && weapon.can_instance():
						var weapon_instance = weapon.instance()
						weapon_list.add_item(weapon_instance.get_item_name(), weapon_instance.get_item_texture(), false)
						var info = {"file_name": file_name, "cost": weapon_instance.get_item_cost()}
						weapon_list.set_item_metadata(idx, info)
						idx += 1
			file_name = dir.get_next()
	weapon_list.connect("item_selected", self, "add_item") # Selected is activated by a single click, which is what we want (we don't care about what's selected)
	loadout_list.connect("item_selected", self, "remove_item") # Selected is activated by a single click, which is what we want (we don't care about what's selected)
	# Update menus
	update()

func add_item(index):
	var file_name = weapon_list.get_item_metadata(index)["file_name"]
	var cost = weapon_list.get_item_metadata(index)["cost"]
	if file_name == null || cost == null:
		print("Invalid metadata for index ",index,".")
		return
	if budget_used + cost > budget_max:
		return
	var weapon = load(weapon_dir+"/"+file_name)
	if weapon == null:
		print("Couldn't load file from ",weapon_dir+"/"+file_name," when adding an item.")
		return
	var weapon_instance = weapon.instance()
	var idx = loadout_list.add_item(weapon_instance.get_item_name(), weapon_instance.get_item_texture(), false)
	loadout_list_size += 1
	if !global.loadout.has(global.loadout_index):
		global.loadout[global.loadout_index] = {}
		global.loadout[global.loadout_index][file_name] = 1
	else:
		global.loadout[global.loadout_index][file_name] += 1
	budget_used += cost
	var info = {"file_name": file_name, "cost": cost}
	loadout_list.set_item_metadata(loadout_list_size-1, info)
	update()
	
func remove_item(index):
	if loadout_list.get_item_metadata(index) == null:
		print("Can't get item metadata for index ",index,".")
		return
	var file_name = loadout_list.get_item_metadata(index)["file_name"]
	var cost = loadout_list.get_item_metadata(index)["cost"]
	budget_used -= cost
	if global.loadout.has(global.loadout_index):
		global.loadout[global.loadout_index][file_name] -= 1
	loadout_list.remove_item(index)
	loadout_list_size -= 1
	update()
	
func update():
	# Setup the budget bar
	budget_bar.set_max(budget_max)
	budget_bar.set_value(budget_used)
	
	# Setup the budget label
	budget_label.set_text(str("Budget: ",budget_used,"/",budget_max))

func get_loadout_size():
	return loadout_list_size
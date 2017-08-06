extends Node2D

export(String, DIR) var weapon_dir = "res://entity/weapon"

onready var camera = get_node("camera")
onready var global = get_node("/root/global")
onready var weapon_list = get_node("planner_layer/planner_panel/weapon_list")
onready var starting_mark = load("res://scene/game/starting_mark.tscn")

var weapon_list_size = 0
var planning = true
var placing_step = 0
var placing_file_name = "FIXME"

func _ready():
	set_process(true)
	
	global.loadout_index = 0
	display_loadout()
	
	get_node("planner_layer/planner_panel/next").connect("pressed", self, "next_player")
	weapon_list.connect("item_selected", self, "place_weapon")
	get_node("pause_menu/pause_panel/resume").connect("pressed", self, "resume")
	get_node("pause_menu/pause_panel/quit").connect("pressed", self, "quit_to_menu")
	get_node("planner_layer/placing_guide").connect("input_event", self, "placing_guide_input")

func _process(dt):
	if Input.is_action_pressed("ui_pause") && !get_tree().is_paused():
		pause()
	elif Input.is_action_pressed("ui_pause") && get_tree().is_paused():
		resume()
	elif Input.is_action_pressed("ui_left"):
		camera.set_h_offset(-200)
	elif Input.is_action_pressed("ui_right"):
		camera.set_h_offset(200)
	
	if placing_step == 1:
		get_node("planner_layer/placing_guide").set_pos(Vector2(0, self.get_viewport().get_mouse_pos().y))

func placing_guide_input(event):
	if event.is_action_pressed("ui_click") && placing_step == 1:
		placing_step = 2
		get_node("planner_layer/placing_guide").hide()
		var starting_mark_instance = starting_mark.instance()
		starting_mark_instance.file_name = placing_file_name
		starting_mark_instance.set_texture(load(weapon_dir+"/"+placing_file_name).instance().get_item_texture())
		get_node("game_layer/tilemap").add_child(starting_mark_instance)
		starting_mark_instance.set_pos(Vector2(32, get_node("game_layer/tilemap").get_local_mouse_pos().y))
		placing_file_name = "FIXME"
	
func place_weapon(index):
	if placing_step > 0:
		weapon_list.get_item_metadata(index)["amount"] += 1
		weapon_list.set_item_text(index, str(weapon_list.get_item_metadata(index)["amount"]))
		get_node("planner_layer/placing_guide").hide()
		placing_step = 0
		return
	var file_name = weapon_list.get_item_metadata(index)["file_name"]
	if weapon_list.get_item_metadata(index)["amount"] - 1 < 0:
		return
	weapon_list.get_item_metadata(index)["amount"] -= 1
	weapon_list.set_item_text(index, str(weapon_list.get_item_metadata(index)["amount"]))
	placing_step = 1
	placing_file_name = file_name
	get_node("planner_layer/placing_guide").show()

func display_loadout():
	print(global.loadout)
	if !global.loadout.has(global.loadout_index):
		print("The global loadout dictionary doesn't contain loadout data for loadout_index ", global.loadout_index, ".")
		return
	
	for file_name in global.loadout[global.loadout_index]:
		var weapon = load(weapon_dir+"/"+file_name)
		var amount = global.loadout[global.loadout_index][file_name]
		weapon_list.add_item(str(amount), weapon.instance().get_item_texture(), false)
		weapon_list_size += 1
		var info = {"file_name": file_name, "amount": amount}
		weapon_list.set_item_metadata(weapon_list_size-1, info)

func next_player():
	if !global.loadout.has(global.loadout_index+1):
		planning = false
		get_node("planner_layer/planner_panel").hide()
		# TODO: Start the game
		return
	global.loadout_index += 1
	weapon_list.clear()
	if !global.loadout.has(global.loadout_index+1):
		get_node("planner_layer/planner_panel/next").set_text("Done")
	display_loadout()
	

func pause():
	if !get_tree().is_paused():
		get_tree().set_pause(true)
		get_node("pause_menu/pause_panel").show()

func resume():
	if get_tree().is_paused():
		get_node("pause_menu/pause_panel").hide()
		get_tree().set_pause(false)

func quit_to_menu():
	if get_tree().is_paused():
		get_tree().set_pause(false)
	get_tree().change_scene("res://scene/menu/menu.tscn")
extends Control

export(float) var screen_move_speed = 3000

var current_screen = "start"
var current_step = 0
var old_size = Vector2()

onready var tween = get_node("tween")

func _ready():
	# Main menu buttons
	for node in get_node("foreground/start/controls").get_children():
		if node extends BaseButton:
			if node.get_name() == "quit":
				node.connect("pressed", self, "quit")
			else:
				node.connect("pressed", self, "go_to_target", [node.get_name()])
	
	# Back and Next buttons
	for node in get_node("foreground").get_children():
		if node.has_node("back"):
			if node.get_name() == "play2":
				node.get_node("back").connect("pressed", self, "go_to_target", ["play"])
			else:
				node.get_node("back").connect("pressed", self, "go_to_target", ["start"])
			
	get_node("foreground/play/next").connect("pressed", self, "go_to_target", ["play2"])
	get_node("foreground/play2/next").connect("pressed", self, "go_to_target", ["game"])
			
	get_tree().get_root().connect("size_changed", self, "update_size")
	
func go_to_target(var screen = "start"):
	if (screen == "play2" || screen == "game") && get_node("foreground/play/loadout_selector").get_loadout_size() <= 0:
		return
	elif screen == "game":
		get_tree().change_scene("res://scene/game/game.tscn")
		return

	var target_cur_coordinates = Vector2(0, 0) # Initalize to 0, 0
	var screen_node
	if get_node("foreground").has_node(screen):
		screen_node = get_node("foreground").get_node(screen)
		target_cur_coordinates = screen_node.get_pos() # If possible, use the coordinates of the target
	else:
		print("Node ",screen," not found.")
		return
	
	var distance = Vector2(0, 0).distance_to(target_cur_coordinates)
	var time = distance/screen_move_speed
	
	var current_screen_node = get_node("foreground").get_node(current_screen)
	if time > 0:
		for node in get_node("foreground").get_children():
			if node.get_type() == "ReferenceFrame":
				tween.interpolate_property(node, "rect/pos", node.get_pos(), Vector2(node.get_pos().x+(0-target_cur_coordinates.x),0), time, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
		tween.start()
	current_screen = screen

func update_size():
	go_to_target(current_screen) # Screens get off on resize, so we need to recalculate this

func quit():
	get_tree().quit() # Exit the game

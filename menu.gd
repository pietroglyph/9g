extends Control

export(float) var screen_move_speed = 1000

var current_screen = "start"
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
	
	# Back buttons
	for node in get_node("foreground").get_children():
		if node.has_node("back"):
			node.get_node("back").connect("pressed", self, "go_to_target", ["start"])
	get_tree().get_root().connect("size_changed", self, "update_size")
	
func go_to_target(var screen = "start"):
	var current_coordinates = Vector2(0, 0) # By default, use the 0, 0 coordinates
	var screen_node
	if get_node("foreground").has_node(screen):
		screen_node = get_node("foreground").get_node(screen)
		current_coordinates = screen_node.get_pos() # If possible, use the coordinates of the target
	else:
		print("Node ",screen," not found.")
		return
	
	var distance = Vector2(0,0).distance_to(current_coordinates)
	var time = distance/screen_move_speed
	
	self.set_pos(current_coordinates)
	
	var current_screen_node = get_node("foreground").get_node(current_screen)
	if time > 0:
		tween.interpolate_property(screen_node, "rect/pos", current_coordinates, Vector2(0,0), time, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
		tween.interpolate_property(current_screen_node, "rect/pos", Vector2(0,0), -current_coordinates, time, Tween.TRANS_EXPO, Tween.EASE_OUT, 0)
		tween.start()
	current_screen = screen

func update_size():
	go_to_target("start") # Screens get off on resize, so this just resets back to a known position

func quit():
	get_tree().quit() # Exit the game

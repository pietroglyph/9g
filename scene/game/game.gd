extends Node2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	set_process_input(true)
	get_node("pause_menu/pause_panel/resume").connect("pressed", self, "resume")
	get_node("pause_menu/pause_panel/quit").connect("pressed", self, "_quit_to_menu")

func _input(event):
	if event.is_action_pressed("ui_pause") && !get_tree().is_paused():
		pause()
	elif event.is_action_pressed("ui_pause") && get_tree().is_paused():
		resume()

func pause():
	if !get_tree().is_paused():
		get_tree().set_pause(true)
		get_node("pause_menu/pause_panel").show()

func resume():
	if get_tree().is_paused():
		get_node("pause_menu/pause_panel").hide()
		get_tree().set_pause(false)

func _quit_to_menu():
	if get_tree().is_paused():
		get_tree().set_pause(false)
	get_tree().change_scene("res://scene/menu/menu.tscn")

# https://github.com/godotengine/godot/issues/4514#issuecomment-217495690
var did_run = false
func run_once(condition):
    if condition:
        var allow = !did_run
        did_run = true
        return allow
    else:
        self.reset()
        return false
func reset():
    did_run = false
func set_state(state):
    did_run = !!state
func get_state():
    return did_run
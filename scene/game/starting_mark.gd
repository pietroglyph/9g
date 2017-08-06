extends Node2D

var file_name = "FIXME"

func _ready():
	#get_node("gui_sprite/weapon_sprite").set_texture(null)
	pass

func set_texture(texture):
	get_node("gui_sprite/weapon_sprite").set_texture(texture)
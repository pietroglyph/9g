extends RigidBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	# Called every time the node is added to the scene.
	# Initialization here
	pass

func get_item_name():
	return "Beater Missile"

func get_item_description():
	return "With casings salvaged from past missiles and chimneys, and a tendency to explode when bumped, the beater missile is excellent for those on a budget."

func get_item_texture():
	return get_node("sprite").get_texture()

func get_item_cost():
	return 30
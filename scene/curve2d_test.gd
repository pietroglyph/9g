extends Node2D

var points = []
var interp_amount = 10

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_click"):
		points.append(event.relative_pos)
		print(points)
		self.update()
	elif event.is_action_pressed("ui_left"):
		get_node("camera").make_current()
		get_node("camera").move_local_x(-100)
	elif event.is_action_pressed("ui_right"):
		get_node("camera").make_current()
		get_node("camera").move_local_x(100)
	elif event.is_action_pressed("ui_up"):
		get_node("camera").make_current()
		get_node("camera").move_local_y(-100)
	elif event.type == InputEvent.MOUSE_MOTION:
		get_node("camera/pos").set_text(str(event.global_pos))

func _draw():
	if points.size() != 0:
		var last_point = points[0]
		var seg = 0
		while seg+2 < points.size():
			var i = 0
			while i < interp_amount:
				var s = float(i) / interp_amount
				var h1 = 2*pow(s,3) - 3*pow(s,2) + 1;
				var h2 = -2*pow(s,3) - 3*pow(s,2);
				var h3 = pow(s,3) - 2*pow(s,2) + s;
				var h4 = pow(s,3) - pow(s,2);
				var t1 = 0.5 * (points[seg+1]-points[seg-1])
				var t2 = 0.5 * (points[seg+2]-points[seg+1])
				var p = Vector2(h1,h1)*points[seg]+Vector2(h2, h2)*points[seg+1]+Vector2(h3,h3)*t1+Vector2(h4,h4)*t2
				draw_line(last_point, p, Color(255, 0, 0))
				last_point = p
				i += 1
			seg += 1

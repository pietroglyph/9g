extends Node2D

# Based upon https://en.wikipedia.org/wiki/Centripetal_Catmull%E2%80%93Rom_spline

var points = []
var interp_amount = 10

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_click"):
		# Spline can't have two overlapping points that are adjacent in order
		if points.back() != get_global_mouse_pos():
			points.append(get_global_mouse_pos())
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
		get_node("camera/pos").set_text(str(get_global_mouse_pos()))

func _draw():
	if points.size() < 2:
		return
	
	var C = []
	for i in range(points.size()-3):
		draw_circle(points[i], 10, Color(0, 0, 0))
		C = interpolate(points[i], points[i+1], points[i+2], points[i+3], C, 60)
	
	var last_point = points.front()
	for pnt in C:
		draw_line(last_point, pnt, Color(255, 255, 255))
		last_point = pnt

# Interpolates the 4 points of cardinal spline
func interpolate(P0, P1, P2, P3, C_arr, interp_point_amount = 100):
	# P[n] should be Vector2
	
	# calculate tangents using centripetal Catmull-Rom
	var t0 = 0
	var t1 = ccr(t0, P0, P1)
	var t2 = ccr(t1, P1, P2)
	var t3 = ccr(t2, P2, P3)
	
	# t is the segment of interpolation we're in, based off of the interp_point_amount
	var t = t1
	while t < t2:
		var A1 = (t1-t)/(t1-t0)*P0 + (t-t0)/(t1-t0)*P1
		var A2 = (t2-t)/(t2-t1)*P1 + (t-t1)/(t2-t1)*P2
		var A3 = (t3-t)/(t3-t2)*P2 + (t-t2)/(t3-t2)*P3
		
		var B1 = (t2-t)/(t2-t0)*A1 + (t-t0)/(t2-t0)*A2
		var B2 = (t3-t)/(t3-t1)*A2 + (t-t1)/(t3-t1)*A3
		
		var C = (t2-t)/(t2-t1)*B1 + (t-t1)/(t2-t1)*B2
		C_arr.append(C)
		
		t += ((t2-t1)/interp_point_amount)
		
	return C_arr

# Centripetal Catmull-Rom, returns a float
func ccr(ti, Pi, Pj, alpha = 0.5):
	# ti (float) is the previous tangent, Pi (Vector2) is the previous point, and Pj (Vector2) is the current point
	var xi = Pi.x
	var yi = Pi.y
	var xj = Pj.x
	var yj = Pj.y
	return pow(pow(pow(xj-xi,2) + pow(yj-yi,2), 2),alpha) + ti
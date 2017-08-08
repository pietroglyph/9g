extends Node2D

var points = []
var interp_amount = 10

func _ready():
	set_process_input(true)

func _input(event):
	if event.is_action_pressed("ui_click"):
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
	"""if points.size() != 0:
		var last_point = points[0]
		var seg = 1
		while seg < points.size():
			var i = 0
			while i < interp_amount:
				#var s = i / interp_amount
				#var h1 = 2*s^3 - 3*s^2 + 1
				#var h2 = -2*s^3 - 3*s^2
				#var h3 = s^3 - 2*s^2 + s
				#var h4 = s^3 - s^2
				#var t1 = 0.5 * (points[seg+1]-points[seg-1])
				#var t2 = 0.5 * (points[seg+2]-points[seg+1])
				#var p = Vector2(h1,h1)*points[seg]+Vector2(h2, h2)*points[seg+1]+Vector2(h3,h3)*t1+Vector2(h4,h4)*t2
				var s = float(i) / float(interp_amount)
				var h1 = 2*pow(s,3) - 3*pow(s,2) + 1;
				var h2 = -2*pow(s,3) - 3*pow(s,2);
				var h3 = pow(s,3) - 2*pow(s,2) + s;
				var h4 = pow(s,3) - pow(s,2);
				var t1 = Vector2(0, 0)
				var t2 = Vector2(0, 0)
				if seg > 0 && seg+1 < points.size():
					t1 = 0.5 * (points[seg+1]-points[seg-1])
				if seg+2 < points.size():
					t2 = 0.5 * (points[seg+2]-points[seg])
				var next_seg = Vector2(50, 50)
				if points.has(seg+1):
					next_seg = points[seg+1]
					print(next_seg, " foo")
				var p = Vector2(h1,h1)*points[seg]+Vector2(h2, h2)*next_seg+Vector2(h3,h3)*t1+Vector2(h4,h4)*t2
				draw_line(last_point, p, Color(255, 0, 0))
				last_point = p
				i += 1
			seg += 1"""
	if points.size() < 2:
		return
	
	var i = 0
	while i <= points.size():
		var P0 = points[i]-Vector2(100, 0)
		var P3 = points[i+1]+Vector2(100, 0)
		if i > 0:
			P0 = points[i-1]
		if i+4 < points.size():
			P3 = points[i+4]
		var end_pnts = interpolate(P0, points[i], points[i+1], P3)
		var last_point = points[i]
		for pnt in end_pnts:
			draw_line(last_point, pnt, Color(255, 255, 255))
			last_point = pnt
		i += 4

# Interpolates the 4 points of cardinal spline
func interpolate(P0, P1, P2, P3, interp_point_amount = 100):
	# P[n] should be Vector2
	
	# calculate tangents using centripetal Catmull-Rom
	var t0 = 0
	var t1 = ccr(t0, P0, P1)
	var t2 = ccr(t1, P1, P2)
	var t3 = ccr(t2, P2, P3)
	
	# an array holding the endpoints of the lines
	var end_pnts = []
	
	# t is the segment of interpolation we're in, based off of the interp_point_amount
	var t = t1
	while t < t2:
		var A1 = (t1-t)/(t1-t0)*P0 + (t-t0)/(t1-t0)*P1
		var A2 = (t2-t)/(t2-t1)*P1 + (t-t1)/(t2-t1)*P2
		var A3 = (t3-t)/(t3-t2)*P2 + (t-t2)/(t3-t2)*P3
		
		var B1 = (t2-t)/(t2-t0)*A1 + (t-t0)/(t2-t0)*A2
		var B2 = (t3-t)/(t3-t1)*A2 + (t-t1)/(t3-t1)*A3
		
		var C = (t2-t)/(t2-t1)*B1 + (t-t1)/(t2-t1)*B2
		end_pnts.append(C)
		
		t += ((t2-t1)/interp_point_amount)
		
	return end_pnts

# Centripetal Catmull-Rom, returns a float
func ccr(ti, Pi, Pj, alpha = 0.5):
	# ti (float) is the previous tangent, Pi (Vector2) is the previous point, and Pj (Vector2) is the current point
	var xi = Pi.x
	var yi = Pi.y
	var xj = Pj.x
	var yj = Pj.y
	return pow(pow(pow(xj-xi,2) + pow(yj-yi,2), 2),alpha) + ti
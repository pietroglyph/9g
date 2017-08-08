extends Node

var loadout_index = 0 # We have a loadout for each player
var loadout = {}

func _ready():
	pass


# Based upon https://en.wikipedia.org/wiki/Centripetal_Catmull%E2%80%93Rom_spline

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
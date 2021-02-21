extends Node2D

var marker_temp = preload("res://marker.tscn")

var scale_dict = null
var markers = []

var lowest_x = -1000000
var lowest_y = -5000

onready var x_axis = $x_axis
onready var y_axis = $y_axis
onready var markers_holder = $markers_holder

# Called when the node enters the scene tree for the first time.
func _ready():
	pass

func setup(inc_scale_dict, leftmost):
	scale_dict = inc_scale_dict
	lowest_x = leftmost*scale_dict.x
	position_axiis()
	setup_markers(leftmost)

func position_axiis():
	x_axis.add_point(Vector2(0,0))
	x_axis.add_point(Vector2(lowest_x, 0))
	y_axis.add_point(Vector2(0,0))
	y_axis.add_point(Vector2(0, lowest_y))

func setup_markers(leftmost):
	#build X offset
	var last_day_dict = OS.get_datetime_from_unix_time(OS.get_unix_time())
	last_day_dict.hour = 0
	last_day_dict.minute = 0
	last_day_dict.second = 0
	var offset = OS.get_unix_time() - OS.get_unix_time_from_datetime(last_day_dict)
	
	var x_disp = 86400*scale_dict.x  #1 day
	
	var y_disp = 50*scale_dict.y
	#X
	var x = (0-(offset*scale_dict.x))+x_disp
	
	x -= x_disp
	while x > leftmost*scale_dict.x:
		spawn_marker("x", x, OS.get_datetime_from_unix_time(OS.get_unix_time()+x/scale_dict.x))
		x -= x_disp
	#Y
	var y = 0
	y -= y_disp
	while y > -5000*scale.y:
		spawn_marker("y", y, null)
		y -= y_disp
	
	pass
	
func spawn_marker(type, coord, text):
	var marker = marker_temp.instance()
	markers_holder.add_child(marker)
	markers.append(marker)
	marker.setup(type, coord, Vector2(lowest_x, lowest_y), scale_dict[type], text)
		

func _on_camera_control_zoom_changed(zoom):
	x_axis.width=(3*zoom)
	y_axis.width=(3*zoom)
	for marker in markers:
		marker.zoom_changed(zoom)

extends Node2D

signal point_clicked(ref, dict)
signal points_initialized()

var point_temp = preload("res://point.tscn")

var scale_dict = {
	"x" : 0.1,
	"y" : 8.0,
}

var data = null
var curr_index = 0
var index_spread = 0
var max_points = 500

var pending_points = []
var active_points = []
var far_left_point = null
var far_right_point = null
var curr_time = null

var camera = null

onready var point_holder = $point_holder
onready var grid = $grid

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func setup_data(array):
	data = array
	pass

class dict_height_bsearch:
	static func dict_height(a, b):
		if a.h < b.h:
			return true
		return false
	
func pull_blocks(start_height, end_height):
	var output = []
	var i = null
	#Flip correctly
	if end_height < start_height:
		var temp = start_height
		start_height = end_height
		end_height = temp
	if start_height < data[0].h:
		i = 0 
	else:
		#bsearch it
		i = data.bsearch_custom({"h" : start_height}, dict_height_bsearch, "dict_height")
	var size = data.size()
	while i < size:
		if data[i].h <= end_height:
			output.append(data[i])
		else:
			break
		i+=1
	return output
	pass

func initialize_points(array):
	#X = 0 will be the highest block.
	setup_data(array)
	var pendpoints_no = pending_points.size()
	var dicts_no = array.size()
	
	#highest_block_time = array[-1].time
	#generate active points
	var x = 0
	while x < pendpoints_no and x < dicts_no:
		active_points.append(pending_points.pop_front())
		x+=1
	
	var points_no = active_points.size()
	var i = 1
	curr_time = OS.get_unix_time()
	while i <= points_no and i <= dicts_no:
		active_points[-i].change(array[-i], curr_time)
		if i == 1:
			far_right_point = active_points[-i]
		elif i == points_no or i == dicts_no:
			far_left_point = active_points[-i]
		i+=1
	
	
	grid.setup(scale_dict, array[0].t-curr_time)
	index_spread = i
	curr_index = data.size() - i
	emit_signal("points_initialized")

func spawn_points(n, camera):
	var x = 0
	while x < n:
		spawn_point(camera)
		x+=1
		
func remove_point():
	if active_points < 1:
		active_points.pop_front()
		far_left_point = active_points[0]

func update_total_points(n):
	var total = active_points.size() + pending_points.size()
	#If n is greater, add points to pending. If n is lesser, remove points from active
	if n > total:
		var x = 0
		while x < n - total:
			spawn_point(camera)
			x+=1
	elif n < total:
		var x = 0
		while x < total - n:
			remove_point()
			x+=1
			
		

func spawn_point(camera):
	var point = point_temp.instance()
	point.scale_dict = scale_dict
	pending_points.append(point)
	point_holder.add_child(point)
	camera.connect("zoom_changed", point, "_on_zoom_changed")
	point.connect("clicked", self, "_on_point_clicked")
	
func shift_points(move):
	var thresh = 99
	#Left
	if move < 1:
		var n = max(move, thresh*-1)
		while n < 1:
			#Check there is info to move to
			if not curr_index > 0:
				break
			
			#Pop right point
			active_points.push_front(active_points.pop_back())
			
			#Set far_points
			far_left_point = active_points[0]
			far_right_point = active_points[-1]
			
			#Need to adjust for the data array index
			curr_index-=1
			far_left_point.change(data[curr_index], curr_time)
			n+=1
		
		
	#Right
	elif move > 1:
		var n = min(move, thresh)
		while n > 1:
			#Check there is info to move to
			if not curr_index < data.size()-1:
				break
			
			#Pop right point
			active_points.push_back(active_points.pop_front())
			
			#Set far_points
			far_left_point = active_points[0]
			far_right_point = active_points[-1]
			
			#Need to adjust for the data array index
			curr_index+=1
			far_left_point.change(data[curr_index], curr_time)
			n-=1


func _process(delta):
	#Initialize points
	var amount = max_points - active_points.size()
	if amount > 0:
		#spawn points
		pass
	elif amount < 0:
		pass
	
	var move = 0
	for point in active_points:
		if point.position.x > camera.position.x:
			move-=1
		elif point.position.x < camera.position.x:
			move+=1
	shift_points(move)
#	if move > 0:
#		shift_points(1)
#	elif move < 0:
#		shift_points(-1)

func _on_point_clicked(ref, dict):
	emit_signal("point_clicked", ref, dict)


func _on_camera_control_cam_connect(ref):
	camera = ref

func _on_2d_calc_finished(dict):
	for point in active_points:
		if point.details.h:
			pass

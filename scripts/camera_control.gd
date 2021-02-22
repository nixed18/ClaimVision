extends Node2D

signal cam_connect(ref)
signal camera_moved(pos)
signal zoom_changed(zoom)

var camera_is_moving = false
var prev_mouse_position = null


onready var camera = $Camera2D
onready var area2d = $Camera2D/Area2D
onready var area2d_col = $Camera2D/Area2D/CollisionShape2D

func _ready():
	mod_mouse_zone_size()
	get_tree().get_root().connect("size_changed", self, "on_size_changed")
	emit_signal("cam_connect", self)


func _process(_delta):
	
	#---CAMERA MOTION---#
	if Input.is_action_just_pressed("middle_button"):
		camera_is_moving = true
		prev_mouse_position = get_local_mouse_position()
		
	if Input.is_action_just_released("middle_button"):
		camera_is_moving = false
	
	if camera_is_moving:
		var curr_mouse_position = get_local_mouse_position()
		var total_motion = prev_mouse_position - curr_mouse_position
		position += total_motion
		prev_mouse_position = curr_mouse_position
		emit_signal("camera_moved", position)
		


	#---CAMERA ZOOM---#
#	if not camera_is_moving:
#		if Input.is_action_just_released("scroll_up"):
#			camera.zoom -= Vector2(0.1, 0.1)
#		elif Input.is_action_just_released("scroll_down"):
#			camera.zoom += Vector2(0.1, 0.1)
#
#		camera.zoom.x = clamp(camera.zoom.x, 0.6, 2.3)
#		camera.zoom.y = clamp(camera.zoom.y, 0.6, 2.3)
			
			
func mod_mouse_zone_size():
	area2d_col.shape.extents = OS.get_window_size()/2*camera.zoom

func zoom_change():
	camera.zoom.x = clamp(camera.zoom.x, 0.6, 80)
	camera.zoom.y = clamp(camera.zoom.y, 0.6, 80)
	emit_signal("zoom_changed", camera.zoom.x)
	
	mod_mouse_zone_size()

func on_size_changed():
	mod_mouse_zone_size()


func _on_Area2D_input_event(_viewport, event, _shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed:
		camera_is_moving = true
		prev_mouse_position = get_local_mouse_position()
	elif event is InputEventMouseButton and event.button_index == 1 and not event.pressed:
		camera_is_moving = false
	
	if event is InputEventMouseButton and event.button_index == 4:
		camera.zoom -= camera.zoom*0.1#Vector2(0.1, 0.1)
		zoom_change()
	elif event is InputEventMouseButton and event.button_index == 5:
		camera.zoom += camera.zoom*0.1#Vector2(0.1, 0.1)
		zoom_change()
		



func _on_points_points_initialized():
	emit_signal("zoom_changed", camera.zoom.x)

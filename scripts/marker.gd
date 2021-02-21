extends Node2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


onready var line = $Line2D
onready var y_label = $y_label
onready var x_label = $x_label

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func setup(type, coord, lowest, c_scale, datedict):
	if type == "x":
		y_label.hide()
		#Calc date
		var date = str(datedict.day)+"/"+str(datedict.month)+"/"+str(datedict.year)
		x_label.text = date
		
		#Move to position
		position = Vector2(coord, 0)
		line.add_point(Vector2(0, 0))
		line.add_point(Vector2(0, lowest.y))
	elif type == "y":
		x_label.hide()
		y_label.text = str((coord/c_scale)*-1)+" sats"
		position = Vector2(0,coord)
		line.add_point(Vector2(0, 0))
		line.add_point(Vector2(lowest.x, 0))
		
func zoom_changed(zoom):
	line.width = 1*zoom
#	if y_label.visible:
#		y_label.rect_scale = Vector2(1*zoom, 1*zoom)
			

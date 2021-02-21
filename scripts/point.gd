extends Sprite

signal clicked(ref, dict)
signal hovered(dict)

#var normal_texture = preload("res://sprites/dot_normal_10.png")
#var claim_texture = preload("res://sprites/dot_claim_10.png")
var textures = [
	[preload("res://sprites/dot_normal_10.png"), preload("res://sprites/dot_normal_bold_10.png")],
	[preload("res://sprites/dot_claim_10.png"), preload("res://sprites/dot_claim_bold_10.png")],
	]

var scale_dict = null
var my_base_z = 0

var disabled = false
var type = 0
var clicked = false
var details = {
	"h" : null, #height
	"f" : null, #fee
	"a" : null, #amount
	"sh" : null, #hash
	"t" : null, #time
	"d" : null, #delay
	"2" : null, #2nd
	
}


# Called when the node enters the scene tree for the first time.
func _ready():
	hide()
	add_to_group("point")

func toggle_bold(onoff):
	if disabled:
		return
	if onoff:
		texture = textures[type][1]
	else:
		texture = textures[type][0]
		pass

func toggle_clicked(onoff):
	if disabled:
		return
	clicked = onoff
	toggle_bold(onoff)
	if onoff == true:
		emit_signal("clicked", self, details)
		get_tree().call_group("point", "point_clicked", self)
#		for point in get_tree().get_nodes_in_group("point"):
#			point.point_clicked(self)
		z_index = 3
	else:
		z_index = my_base_z
		
func point_clicked(ref):
	if ref == self:
		pass
	if ref != self:
		toggle_clicked(false)
	

func change(dict, highest):
	show()
	toggle_clicked(false)
	for key in dict.keys():
		details[key] = dict[key]
	
	#Reposition
	#position.x = (details.height-highest)*scale_dict.x
	position.x = (details.t-highest)*scale_dict.x
	if details.f != null:
		position.y = -details.f*scale_dict.y
	else:
		position.y = 0
	
	#Claim
	if details.a == 330 or details.a == 546:
		type = 1
		z_index = 1
		my_base_z = 1
	else:
		type = 0
		z_index = 0
		my_base_z = 0
		
	texture = textures[type][0]
	

		

	
func _on_zoom_changed(zoom):
	scale = Vector2(1*zoom, 1*zoom)



func _on_Area2D_input_event(viewport, event, shape_idx):
	if event is InputEventMouseButton and event.button_index == 1 and event.pressed and not disabled:
		toggle_clicked(not clicked)


func _on_Area2D_mouse_entered():
	#emit_signal("hovered", details)

	toggle_bold(true)


func _on_Area2D_mouse_exited():
	if not clicked:
		toggle_bold(false)

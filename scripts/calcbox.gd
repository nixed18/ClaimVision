extends PanelContainer

signal calc_requested(s, e, f, w)

onready var start = $title/start
onready var end = $title/end
onready var fee = $title/fee
onready var weight = $title/weight

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_submit_pressed():
	if start.text.is_valid_integer() and end.text.is_valid_integer() and fee.text.is_valid_integer() and weight.text.is_valid_integer():
		emit_signal("calc_requested", int(start.text), int(end.text), int(fee.text), int(weight.text))

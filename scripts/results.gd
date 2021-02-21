extends PanelContainer


onready var hits = $HBoxContainer/hits/info
onready var misses = $HBoxContainer/misses/info
onready var wasted = $HBoxContainer/wasted/info
onready var pcomb = $HBoxContainer/percomb/info

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_2d_calc_finished(dict):
	hits.text = str(dict.hits)
	misses.text = str(dict.missed)
	wasted.text = str(dict.wasted)
	pcomb.text = str(dict.pcomb)

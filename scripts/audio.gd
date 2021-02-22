extends AudioStreamPlayer

var sfx = {
	"new_comb" : preload("res://handbell.wav"),
}





# Called when the node enters the scene tree for the first time.
func _ready():
	pass
	
func play_sfx(string):
	if sfx.has(string):
		set_stream(sfx[string])
		play()

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

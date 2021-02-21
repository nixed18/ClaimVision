extends PanelContainer

onready var vbox = $VBoxContainer
onready var height = $VBoxContainer/HBoxContainer/height/info
onready var fee = $VBoxContainer/HBoxContainer/fee/info
onready var claim = $VBoxContainer/HBoxContainer/claim/info
onready var time = $VBoxContainer/HBoxContainer/time/info
onready var date = $VBoxContainer/HBoxContainer/date/info
onready var tx_hash = $VBoxContainer/hash
onready var second = $VBoxContainer/HBoxContainer/second/info

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func display_info(dict):
	height.text = str(dict.get("h"))
	fee.text = str(dict.get("f"))
	if dict.get("a") == 330 or dict.get("a") == 546:
		second.text = str(dict.get("2"))
		claim.text = "True"
	else:
		claim.text = "False"
		second.text = "N/A"
	
	var proc_time = OS.get_datetime_from_unix_time(dict.get("t"))
	var seconds = str(proc_time.second)
	if seconds.length() == 1:
		seconds = "0"+seconds
	var minutes = str(proc_time.minute)
	if minutes.length() == 1:
		minutes = "0"+minutes
	time.text = str(proc_time.hour)+":"+minutes+":"+seconds
	date.text = str(proc_time.day)+"/"+str(proc_time.month)+"/"+str(proc_time.year)
	var hash_text = dict.get("sh")
	if hash_text != null:
		tx_hash.text = hash_text
	else:
		tx_hash.text = "No Claim Found"
	
	vbox.hide()
	vbox.show()
	hide()
	show()



func _on_points_point_clicked(ref, dict):
	display_info(dict)

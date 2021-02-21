extends Node2D

signal calc_finished(dict)

var filepath = "user://claims.log"

onready var points = $points

# Called when the node enters the scene tree for the first time.
func _ready():
	points.data = yield(get_data(), "completed")
	#points.data = load_data()
	points.spawn_points(points.max_points, $camera_control)
	points.initialize_points(points.data)

func get_data():
	client.connect_to_server()
	yield(client, "connected_to_server")
	#client.send_packet("get_db")
	#var db = yield(client, "db_received")
	var db = yield(client.get_chain_data(), "completed")
	
	
	return db

func load_data():
	var f = File.new()
	if not f.file_exists(filepath):
		return null
	f.open(filepath, File.READ)
	var output = []
	while not f.eof_reached():
		var dict = f.get_line()
		if dict != "":
			dict = JSON.parse(dict).result
			output.append(dict)
	f.close()
	return output
	
func calc_costs(fee, weight, array):
	var hits = 0
	var missed = 0
	var wasted = 0
	#Array has a list of blocks to calc against
	for claim in array:
		var cfee = claim.f 
		if cfee == null:
			cfee = 0
		if cfee >= fee:
			missed+=1
			wasted+=fee*weight
		elif cfee < fee:
			hits+=1
			wasted+=(fee-cfee)*weight
	
	var pcomb
	if hits != 0:
		pcomb = ((hits+missed)*fee*weight/hits)
	else:
		pcomb = "Infinite"
	return {
		"total_s" : fee*weight*hits*missed,
		"hits" : hits, 
		"missed" : missed,
		"wasted" : wasted,
		"pcomb" : pcomb,
		"array" : array
		}
		


func _on_calc_calc_requested(s, e, f, w):
	#Get points from s to e and calc costs
	var result = calc_costs(f, w, points.pull_blocks(s, e))
	emit_signal("calc_finished", result)
	

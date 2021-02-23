extends Node2D

signal calc_finished(dict)

var filepath = "user://claims.log"
var type = "tcp"

onready var points = $points

# Called when the node enters the scene tree for the first time.
func _ready():
	yield(get_tree().create_timer(2.0), "timeout")
	points.data = yield(get_data(), "completed")
		#points.data = load_data()
	points.spawn_points(points.max_points, $camera_control)
	points.initialize_points(points.data)
	client.connect("db_received", self, "_on_new_block")
	clientws.connect("new_block", self, "_on_new_block")

func get_data():
	#Check if stored chain
	var db = load_data()
	
	if db == null:
		if type == "tcp":
			client.connect_to_server()
			yield(client, "connected_to_server")
			client.send_packet("get_db")
			db = yield(client, "db_received")
		elif type == "ws":
			clientws.connect_to_server()
			yield(clientws, "connected_to_server")
			db = yield(clientws.get_entire_chain_data(), "completed")
		if db != null: 
			save_data(db)
	else:
		var pull = find_missing(db)
		var pulled
		if type == "tcp":
			client.connect_to_server()
			yield(client, "connected_to_server")
			client.send_packet(pull)
			pulled = yield(client, "db_received")
		elif type == "ws":
			clientws.connect_to_server()
			yield(clientws, "connected_to_server")
			pulled = yield(clientws.get_block_data(pull), "completed")
		db = merge_new_blocks(db, pulled)
	return db

class dict_height_bsearch:
	static func dict_height(a, b):
		if a.h < b.h:
			return true
		return false

func merge_new_blocks(db, pulled):
	if pulled == null:
		return db
	for block in pulled:
		if block.has("h"):
			var i = db.bsearch_custom(block, dict_height_bsearch, "dict_height")
			if i < db.size() and db[i].h != block.h:
				db.insert(i, block)
			elif i == db.size():
				db.append(block)
	save_data(db)
	return db

func _on_new_block(block):
	audio.play_sfx("new_comb")
	points.data = merge_new_blocks(points.data, block)
	points.update_points()
	

func save_data(data):
	var f = File.new()
	var err = f.open(filepath, File.WRITE)
	for block in data:
		f.store_line(to_json(block)+"\r")
	f.close()
	
	

func find_missing(array):
	var output = []
	var prev_height = null
	for dict in array:
		if prev_height == null:
			prev_height = dict.h
		else:
			while dict.h != prev_height+1:
				#Pull all blocks
				prev_height+=1
				output.append(prev_height)
			prev_height+=1
	output.append(array[-1].h)
	
	return output
				

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
	

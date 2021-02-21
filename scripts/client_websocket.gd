extends Node

signal connected_to_server()
signal packet_received(packet)
signal db_received(data)

var s_ip = "21teeth.org"
var s_port = 21111

var my_client = null
var status = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	set_process(false)

func get_chain_data():
	
	my_client.get_peer(1).put_packet("get_db".to_utf8())
	var packet = yield(self, "packet_received")
	print("GOT PACKET")
	var result = JSON.parse(packet).result
	
	if typeof(result) != 19:
		return
		
	if not result.size() > 0:
		return
		
	if typeof(result[0]) != 18:
		return
		
	emit_signal("db_received", result)
	
	return result

func connect_to_server():
	yield(get_tree().create_timer(0.01), "timeout")
	return connect_to(s_ip, s_port)

func connect_to(ip, port):
	my_client = WebSocketClient.new()
	
	my_client.connect("connection_closed", self, "_closed")
	my_client.connect("connection_error", self, "_closed")
	my_client.connect("connection_established", self, "_connected")
	my_client.connect("data_received", self, "_on_data")
	
	var err = my_client.connect_to_url("wss://"+ip+":"+str(port))
	if err != OK:
		print("ERROR")
		return false
	
	
	set_process(true)
	
	
func _closed(was_clean=false):
	print("Close, clean: ", was_clean)
	set_process(false)
	status = 0
	
func _connected(proto=""):
	print("Connected with protocol: ", proto)
	status = 2
	emit_signal("connected_to_server")
	
func _on_data():
	yield(get_tree().create_timer(0.01), "timeout")
	var packet = my_client.get_peer(1).get_packet()
	emit_signal("packet_received", packet.get_string_from_utf8())
	
func _process(_delta):
	my_client.poll()
	
		
	

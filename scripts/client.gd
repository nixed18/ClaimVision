extends Node

signal connected_to_server()
signal db_received(data)
signal new_block(block)

var s_ip = "21teeth.org"
var s_port = 21112

var my_client = null
var pps = null
var status = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func get_chain_data():
	
	return

func connect_to_server():
	yield(get_tree().create_timer(0.01), "timeout")
	connect_to(s_ip, s_port)

func connect_to(ip, port):
	my_client = StreamPeerTCP.new()
	pps = PacketPeerStream.new()
	
	var err = my_client.connect_to_host(ip, port)
	if err != OK:
		print("Client Connect Error")
		
	pps.set_stream_peer(my_client)
	
	if my_client.get_status() == my_client.STATUS_CONNECTED:
		print("Connected")
		on_connected()
		status = 2
	elif my_client.get_status() == StreamPeerTCP.STATUS_CONNECTING:
		print("Connecting")
		status = 1
	elif my_client.get_status() == client.STATUS_NONE or my_client.get_status() == StreamPeerTCP.STATUS_ERROR:
		print("Connection Failed: ", ip, ":", port)
		disconnected()

#func connect_to(ip, port):
#	my_client = StreamPeerTCP.new()
#	pps = PacketPeerStream.new()
#
#	var err = my_client.connect_to_host(ip, port)
#	if err != OK:
#		print("Client Connect Error")
#
#	pps.set_stream_peer(my_client)
#
#	if my_client.get_status() == my_client.STATUS_CONNECTED:
#		print("Connected")
#		on_connected()
#		status = 2
#	elif my_client.get_status() == StreamPeerTCP.STATUS_CONNECTING:
#		print("Connecting")
#		status = 1
#	elif my_client.get_status() == client.STATUS_NONE or my_client.get_status() == StreamPeerTCP.STATUS_ERROR:
#		print("Connection Failed: ", ip, ":", port)
#		disconnected()
		
func disconnected():
	my_client = null
	pps = null
	status = 0
		
func on_connected():
	status = 2
	emit_signal("connected_to_server")
	
func receive_packet(packet):
	if typeof(packet) != 19:
		return
		
	if not packet.size() > 0:
		return
		
	if packet[0] == null:
		emit_signal("db_received", null)
		
	if typeof(packet[0]) != 18:
		return
		
	emit_signal("db_received", packet)
		
	pass
	
func send_packet(packet):
	yield(get_tree().create_timer(0.01), "timeout")
	if status == 2:
		pps.put_var(packet)
		return 0
	else:
		return 1
	
		
func _process(_delta):
	if status > 0:
		if status == 1:
			if my_client.get_status() == my_client.STATUS_CONNECTED:
				print("Connected")
				on_connected()
				
		elif status == 2:
			if pps.get_available_packet_count() > 0:
				print("Incoming Packet")
				receive_packet(pps.get_var())
	
		if my_client.get_status() == my_client.STATUS_NONE or my_client.get_status() == StreamPeerTCP.STATUS_ERROR:
			print("Connection Failed")
			disconnected()
		
	

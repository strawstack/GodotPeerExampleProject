extends Node

var peer_bridge = null
var is_web := false

func _ready():
	is_web = OS.has_feature("web")
	peer_bridge = JavaScriptBridge.get_interface("peerBridge")
	
	if is_web:
		peer_bridge = JavaScriptBridge.get_interface("peerBridge")
	else:
		peer_bridge = MockPeerBridge.new()
	
	# Bind callbacks
	peer_bridge.onPeerOpen = _on_peer_open
	peer_bridge.onConnected = _on_connected
	peer_bridge.onData = _on_data

	peer_bridge.createPeer()

func create_peer(id: String):
	peer_bridge.createPeer(id)

func connect_to_peer(id: String):
	peer_bridge.connectPeer(id)

func send_data(data):
	peer_bridge.send(data)

func _on_peer_open(id):
	print("Peer open: ", id)

func _on_connected(id):
	print("Connected to: ", id)

func _on_data(data):
	print("Received: ", data)

class MockPeerBridge:
	var onPeerOpen = null
	var onConnected = null
	var onData = null

	func createPeer(id = null):
		print("[MOCK] createPeer:", id)

	func connectPeer(id):
		print("[MOCK] connect:", id)

	func send(data):
		print("[MOCK] send:", data)

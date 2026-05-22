extends Node2D

var is_web := false
var peer_bridge = null
var peerId = null
var isHost = null

# Peer only properties
var hostId = null

# Host only properties
var knownPeers = {}

# Objects required to retain callback refs in Godot
var onPeerOpen = null
var onConnected = null
var onConnection = null
var onData = null
var lastHeartbeat = 0

func _ready():
	is_web = OS.has_feature("web")
	peer_bridge = JavaScriptBridge.get_interface("peerBridge") if is_web else MockPeerBridge.new()

	# Bind callbacks
	onPeerOpen = JavaScriptBridge.create_callback(_on_peer_open)
	peer_bridge.onPeerOpen = onPeerOpen
	
	onConnected = JavaScriptBridge.create_callback(_on_connected)
	peer_bridge.onConnected = onConnected
	
	onConnection = JavaScriptBridge.create_callback(_on_connection)
	peer_bridge.onConnection = onConnection
	
	onData = JavaScriptBridge.create_callback(_on_data)
	peer_bridge.onData = onData

func _processPeer(delta):
	lastHeartbeat += delta * 1000
	if lastHeartbeat >= 3000:
		send_data(hostId, {"type": "heartbeat"})

func _process(delta):
	if (not isHost) and hostId:
		_processPeer(delta)

func changeScene(scenePath):
	_deferred_changeScene.call_deferred(scenePath)

func _deferred_changeScene(scenePath):
	for child in $scene.get_children():
		child.queue_free()
	var s = ResourceLoader.load(scenePath)
	$scene.add_child(s.instantiate())

func returnToMain():
	peerId = null
	changeScene("res://menu.tscn")

# PeerJS

func create_peer(id: String = ""):
	peer_bridge.createPeer(id)

func connect_to_peer(id: String, data: Dictionary):
	peer_bridge.connectPeer(id, JSON.stringify({"metadata": data}))

func send_data(id, data):
	lastHeartbeat = 0
	peer_bridge.send(id, JSON.stringify(data))

func _on_peer_open(args):
	var id = args[0]
	peerId = id
	# print("Peer open: ", id)

# Peer establishes connection with host
func _on_connected(args):
	var id = args[0]
	hostId = id
	# print("Connected to: ", id)

# Host receives connection from Peer
func _on_connection(args):
	var id = args[0]
	var options = JSON.parse_string(args[1])
	if id not in knownPeers:
		knownPeers[id] = {
			"username": options["username"],
			"heartbeat": Time.get_ticks_msec(),
			"data": {
				"position": Vector2.ZERO,
			}
		}
	# print("Connected to: ", id)

func _on_data(args):
	var data = args[0]
	# print("Received: ", data)

class MockPeerBridge:
	var onPeerOpen = null
	var onConnected = null
	var onConnection = null
	var onData = null

	func createPeer(id = null):
		print("[MOCK] createPeer:", id)

	func connectPeer(id):
		print("[MOCK] connect:", id)

	func send(id, data):
		print("[MOCK] send:", id, data)

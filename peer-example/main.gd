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

var HEARTBEAT_INTERVAL = 1000
var UPDATE_INTERVAL = 1000

var hostData = {
	"lastUpdate": 0
}
var peerData = {
	"lastHeartbeat": 0
}

var state = {
	"WAIT": 0, # Waiting for players to connect
	"ACTIVE": 1, # Game in progress
}

var dataType = {
	"heartbeat": "heartbeat",
	"data": "data",
	"gamestate": "gamestate",
}

var gameState = state["WAIT"]

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
	peerData["lastHeartbeat"] += delta * 1000
	if peerData["lastHeartbeat"] >= HEARTBEAT_INTERVAL:
		send_data(hostId, {"type": "heartbeat"})

func _processHost(delta):
	hostData["lastUpdate"] += delta * 1000
	if hostData["lastUpdate"] >= UPDATE_INTERVAL:
		send_gamestate()

func send_gamestate():
	hostData["lastUpdate"] = 0
	for id in knownPeers:
		send_data(id, {
			"type": "gamestate",
			"peers": knownPeers
		})

func _process(delta):
	if (not isHost) and hostId:
		_processPeer(delta)
	else:
		_processHost(delta)

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

func send_data(id, data: Dictionary):
	peerData["lastHeartbeat"] = 0
	data["id"] = peerId # Tag data with sender ID
	peer_bridge.send(id, JSON.stringify(data))

func _on_peer_open(args):
	var id = args[0]
	peerId = id

# Peer establishes connection with host
func _on_connected(args):
	var id = args[0]
	hostId = id

# Host receives connection from Peer
func _on_connection(args):
	if (gameState == state["ACTIVE"]):
		# Players cannot connect if game is active
		return
	var id = args[0]
	var options = JSON.parse_string(args[1])
	if id not in knownPeers:
		knownPeers[id] = {
			"username": options["username"],
			"heartbeat": Time.get_ticks_msec(),
			"data": {
				"position": {"x": 0, "y": 0},
			}
		}

func _on_data(args):
	var data = JSON.parse_string(args[0])
	var type = data["type"]
	var id = data["id"] # Every message has a sender ID
	
	if isHost:
		# All messages are used to update heartbeat 
		knownPeers[id]["heartbeat"] = Time.get_ticks_msec()

	# Host receives "data" from Peers
	if (type == dataType["data"]):
		data.erase("id") # Don't include sender ID in data
		knownPeers[id]["data"] = data

	# Peers receive "gamestate" from Host
	elif (type == dataType["gamestate"]):
		var peers = data["peers"]
		for pid in peers:
			var peer = peers[pid]
			knownPeers[pid] = {
				"username": peer["username"],
				"data": peer["data"]
			}

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

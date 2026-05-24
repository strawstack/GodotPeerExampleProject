extends Node

var player_sprite = preload("res://player_sprite.tscn")

var gc
var UPDATE_INTERVAL = 500
var lastUpdate = 0
var container

func _ready():
	gc = get_tree().get_root().get_node("main")
	container = $remotePeers
	$Player/player_sprite.show_username(false)
	create_remote_peers()

func _processPeer(delta):
	lastUpdate += delta * 1000
	if (lastUpdate >= UPDATE_INTERVAL):
		lastUpdate = 0
		var pos = $Player.get_position()
		gc.send_data(gc.hostId, {
			"type": "data",
			"data": {
				"position": {"x": pos.x, "y": pos.y}
			}
		})

func _processHost(delta):
	var pos = $Player.get_position()
	gc.hostData["position"] = {"x": pos.x, "y": pos.y}

func _process(delta):
	if (not gc.isHost):
		_processPeer(delta)
	else:
		_processHost(delta)
	render_remote_peers()

func create_remote_peers():
	for id in gc.knownPeers:
		if not (id == gc.peerId):
			var sprite = player_sprite.instantiate()
			sprite.name = id
			sprite.show_username(true)
			sprite.set_username(gc.knownPeers[id]["username"])
			var pos = gc.knownPeers[id]["data"]["position"]
			sprite.set_position(Vector2(pos.x, pos.y))
			container.add_child(sprite)

func render_remote_peers():
	for child in container.get_children():
		var id = child.name
		var pos = gc.knownPeers[id]["data"]["position"]
		child.set_position(Vector2(pos.x, pos.y))

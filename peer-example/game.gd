extends Node

var gc
var UPDATE_INTERVAL = 500
var lastUpdate = 0

func _ready():
	gc = get_tree().get_root().get_node("main")

func _process(delta):
	lastUpdate += delta * 1000
	if (lastUpdate >= UPDATE_INTERVAL):
		lastUpdate = 0
		var pos = $player.get_position()
		gc.send_data(gc.hostId, {
			"type": "data",
			"data": {
				"position": {"x": pos.x, "y": pos.y}
			}
		})

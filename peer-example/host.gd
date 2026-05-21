extends Node2D

var gc

func _ready():
	gc = get_tree().get_root().get_node("main")
	gc.peer_bridge.createPeer()

func _process(delta):
	var id = gc.peer_bridge.peer.id
	if id:
		$LineEdit.set_text(id)

func _on_back_pressed():
	gc.changeScene("res://menu.tscn")

func _on_copy_pressed():
	DisplayServer.clipboard_set($LineEdit.get_text())

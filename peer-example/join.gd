extends Node2D

var gc

func _ready():
	gc = get_tree().get_root().get_node("main")
	gc.isHost = false
	gc.peer_bridge.createPeer()

func _on_back_pressed():
	gc.returnToMain()

func _on_enter_pressed():
	if gc.peerId:
		var joinCode = $LineEdit.get_text()
		gc.connect_to_peer(joinCode, {"username": "Richard"})

func _on_paste_pressed():
	var text = DisplayServer.clipboard_get()
	$LineEdit.set_text(text)

extends Node2D

var gc

func _ready():
	gc = get_tree().get_root().get_node("main")
	gc.isHost = true
	gc.create_peer()

func _process(delta):
	if gc.peerId: 
		$LineEdit.set_text(gc.peerId)

func _on_back_pressed():
	gc.returnToMain()

func _on_copy_pressed():
	DisplayServer.clipboard_set($LineEdit.get_text())

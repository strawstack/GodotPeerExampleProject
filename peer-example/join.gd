extends Node2D

var playerName = preload("res://player_name.tscn")

var gc
var container
var joinOnce = false

func _ready():
	gc = get_tree().get_root().get_node("main")
	gc.isHost = false
	gc.peer_bridge.createPeer()
	container = $ScrollContainer/VBoxContainer

	# Generate random username
	$LineEdit_Name.set_text("user_" + str((randi() + 1000) % 9999))

func render_players():
	# Remove children
	for child in container.get_children():
		child.queue_free()
	
	# Add known players
	for id in gc.knownPeers:
		if not (id == gc.peerId):
			var pName = playerName.instantiate()
			pName.get_node("Label").set_text(gc.knownPeers[id]["username"])
			container.add_child(pName)

func fieldEmpty():
	return $LineEdit_Name.get_text() == "" or $LineEdit_Code.get_text() == ""

func _process(delta):
	$Join.set_disabled(fieldEmpty() or joinOnce)
	gc.username = $LineEdit_Name.get_text()
	render_players()

func _on_back_pressed():
	gc.returnToMain()

func _on_join_pressed():
	if gc.peerId:
		var userName = $LineEdit_Name.get_text()
		var joinCode = $LineEdit_Code.get_text()
		gc.connect_to_peer(joinCode, {"username": userName})
		joinOnce = true

func _on_paste_pressed():
	var text = DisplayServer.clipboard_get()
	await get_tree().process_frame
	text = DisplayServer.clipboard_get() # Copy twice due to browser security
	$LineEdit_Code.set_text(text)

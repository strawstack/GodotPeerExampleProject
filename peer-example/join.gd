extends Node2D

var playerName = preload("res://player_name.tscn")

var gc
var container

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
		var pName = playerName.instantiate()
		pName.get_node("Label").set_text(gc.knownPeers[id]["username"])
		container.add_child(pName)

func _process(delta):
	var canSubmit = false
	if ($LineEdit_Name.get_text() == "" or $LineEdit_Code.get_text() == ""):
		canSubmit = true
	$Join.set_disabled(canSubmit)
	gc.username = $LineEdit_Name.get_text()
	render_players()

func _on_back_pressed():
	gc.returnToMain()

func _on_join_pressed():
	if gc.peerId:
		var userName = $LineEdit_Name.get_text()
		var joinCode = $LineEdit_Code.get_text()
		gc.connect_to_peer(joinCode, {"username": userName})

func _on_paste_pressed():
	var text = DisplayServer.clipboard_get()
	$LineEdit_Code.set_text(text)

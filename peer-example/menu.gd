extends Node2D

var gc

func _ready():
	gc = get_tree().get_root().get_node("main")

func _on_host_pressed():
	gc.changeScene("res://host.tscn")

func _on_join_pressed():
	gc.changeScene("res://join.tscn")

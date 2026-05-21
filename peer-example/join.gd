extends Node2D

var gc

func _ready():
	gc = get_tree().get_root().get_node("main")

func _on_back_pressed():
	gc.changeScene("res://menu.tscn")

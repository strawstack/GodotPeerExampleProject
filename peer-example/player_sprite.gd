extends Node2D

func show_username(value):
	$Label.visible = value

func set_username(value):
	$Label.set_text(value)

func set_color(color: Color):
	$ColorRect.set_color(color)

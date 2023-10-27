extends Node3D

func _process(_delta):
	if Globals.state == 1:
		show()
	else:
		hide()

extends Label3D

func _process(_delta):
	if Globals.state == 0:
		show()
	else:
		hide()

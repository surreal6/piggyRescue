extends Panel

signal localScore

func _on_button_pressed():
	localScore.emit()

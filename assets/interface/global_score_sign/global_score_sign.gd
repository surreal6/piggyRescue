extends Panel

signal globalScore

func _on_button_pressed():
	globalScore.emit()

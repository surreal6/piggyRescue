extends Panel

signal mainMenu

func _on_button_pressed():
	mainMenu.emit()

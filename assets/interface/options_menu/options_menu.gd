extends Panel

signal mainMenu
signal closeOptions
signal controlsOptions
signal audioOptions
signal graphicsOptions

@onready var main_menu_button = $Panel/VBoxContainer/gotoMainMenuButton
@onready var separator = $Panel/VBoxContainer/HSeparator

func _ready():
	if Globals.state == 10:
		main_menu_button.hide()
		separator.hide()
	else:
		main_menu_button.show()
		separator.show()

func _on_goto_main_menu_button_pressed():
	mainMenu.emit()

func _on_close_button_pressed():
	closeOptions.emit()

func _on_audio_options_pressed():
	audioOptions.emit()

func _on_controls_options_pressed():
	controlsOptions.emit()

func _on_graphics_options_pressed():
	graphicsOptions.emit()

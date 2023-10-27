extends Panel

signal showOptions
signal hallOfFame
signal launchCredits

func _on_individual_game_pressed():
	Globals.state = 20

func _on_options_pressed():
	showOptions.emit()

func _on_hall_of_fame_pressed():
	hallOfFame.emit()

func _on_exit_game_button_pressed():
	get_tree().quit()

func _on_credits_pressed():
	launchCredits.emit()

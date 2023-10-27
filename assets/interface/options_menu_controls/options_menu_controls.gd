extends Panel

signal closeOptions
signal stepTurn
signal stepMove
signal grabWithTrigger
signal optionsBack

@onready var step_turn_button = $Panel/VBoxContainer/StepTurnCheckButton
@onready var grab_with_trigger_button = $Panel/VBoxContainer/GrabWithTriggerCheckButton

func _ready():
	step_turn_button.button_pressed = Globals.step_turn
	grab_with_trigger_button.button_pressed = Globals.grab_with_trigger

func _on_exit_game_button_pressed():
	get_tree().quit()

func _on_step_turn_check_button_toggled(button_pressed):
	Globals.step_turn = button_pressed
	if step_turn_button.has_focus():
		step_turn_button.release_focus()
	stepTurn.emit()


func _on_grab_with_trigger_check_button_toggled(button_pressed):
	Globals.grab_with_trigger = button_pressed
	if grab_with_trigger_button.has_focus():
		grab_with_trigger_button.release_focus()
	grabWithTrigger.emit()

func _on_close_button_pressed():
	closeOptions.emit()

func _on_go_back_pressed():
	optionsBack.emit()

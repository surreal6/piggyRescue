extends Node3D

signal closeOptions
signal stepTurn
signal stepMove
signal grabWithTrigger
signal optionsBack
		
func _ready():
	$Viewport2Din3D.connect_scene_signal("closeOptions", on_close_options)
	$Viewport2Din3D.connect_scene_signal("stepTurn", on_step_turn)
	$Viewport2Din3D.connect_scene_signal("grabWithTrigger", on_grab_with_trigger)
	$Viewport2Din3D.connect_scene_signal("optionsBack", on_options_back)

func on_close_options():
	closeOptions.emit()
	
func on_step_turn():
	stepTurn.emit()

func on_grab_with_trigger():
	grabWithTrigger.emit()

func on_options_back():
	optionsBack.emit()

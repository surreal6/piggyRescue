extends Node3D

signal showOptions
signal hallOfFame
signal launchCredits
		
func _ready():
	$Viewport2Din3D.connect_scene_signal("showOptions", on_showOptions)
	$Viewport2Din3D.connect_scene_signal("hallOfFame", on_hallOfFame)
	$Viewport2Din3D.connect_scene_signal("launchCredits", on_launchCredits)
	
func on_hallOfFame():
	hallOfFame.emit()

func on_showOptions():
	showOptions.emit()

func on_launchCredits():
	launchCredits.emit()

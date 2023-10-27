extends Node3D

signal mainMenu
signal closeOptions
signal controlsOptions
signal audioOptions
signal graphicsOptions
		
func _ready():
	$Viewport2Din3D.connect_scene_signal("mainMenu", on_mainMenu)
	$Viewport2Din3D.connect_scene_signal("closeOptions", on_close_options)
	$Viewport2Din3D.connect_scene_signal("audioOptions", on_audio_options)
	$Viewport2Din3D.connect_scene_signal("controlsOptions", on_controls_options)
	$Viewport2Din3D.connect_scene_signal("graphicsOptions", on_graphics_options)

func on_mainMenu():
	mainMenu.emit()
	
func on_close_options():
	closeOptions.emit()
	
func on_controls_options():
	controlsOptions.emit()
	
func on_audio_options():
	audioOptions.emit()

func on_graphics_options():
	graphicsOptions.emit()

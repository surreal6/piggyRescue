extends Node3D

signal closeOptions
signal showDebug
signal fxaa
signal forceResolution
signal forceShadows
signal optionsBack
		
func _ready():
	$Viewport2Din3D.connect_scene_signal("closeOptions", on_close_options)
	$Viewport2Din3D.connect_scene_signal("optionsBack", on_options_back)
	$Viewport2Din3D.connect_scene_signal("showDebug", on_show_debug)
	$Viewport2Din3D.connect_scene_signal("fxaa", on_fxaa)
	$Viewport2Din3D.connect_scene_signal("forceResolution", on_force_resolution)
	$Viewport2Din3D.connect_scene_signal("forceShadows", on_force_shadows)

func on_options_back():
	optionsBack.emit()
	
func on_close_options():
	closeOptions.emit()

func on_show_debug():
	showDebug.emit()

func on_fxaa():
	fxaa.emit()

func on_force_resolution():
	forceResolution.emit()

func on_force_shadows(value):
	forceShadows.emit(value)

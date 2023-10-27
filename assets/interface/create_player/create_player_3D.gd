extends Node3D

signal changeHands

func _ready():
	$Viewport2Din3D.connect_scene_signal("changeHands", on_changeHands)
	
func on_changeHands(value):
	changeHands.emit(value)

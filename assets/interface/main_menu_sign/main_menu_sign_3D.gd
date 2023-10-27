extends Node3D

signal mainMenu

@export var active = true:
	set(value):
		active = value
		$Viewport2Din3D.enabled = value
		visible = value

func _ready():
	$Viewport2Din3D.connect_scene_signal("mainMenu", on_main_menu)

func on_main_menu():
	mainMenu.emit()

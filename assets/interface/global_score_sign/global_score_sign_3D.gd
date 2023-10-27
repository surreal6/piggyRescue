extends Node3D

signal globalScore

func _ready():
	$Viewport2Din3D.connect_scene_signal("globalScore", on_global_score)

func enabled(value):
	$Viewport2Din3D.enabled = value

func on_global_score():
	globalScore.emit()

extends Node3D

signal localScore

func _ready():
	$Viewport2Din3D.connect_scene_signal("localScore", on_local_score)

func on_local_score():
	localScore.emit()

@tool
extends Node3D

@onready var localSign = $localScoreSign
@onready var globalSign = $globalScoreSign
@onready var table = $Viewport2Din3D.get_scene_instance()

@export var online_scores := true:
	set(value):
		online_scores = value
		if value == false:
			$globalScoreSign.hide()

func _ready():
	update()
	localSign.connect("localScore", set_local_score)
	globalSign.connect("globalScore", set_global_score)

func update():
	$Viewport2Din3D.get_scene_instance().update_table()
	online_scores = Globals.online_scores
	$globalScoreSign.enabled(online_scores)
	
func set_global_score():
	Globals.score_state = 2
	localSign.position.z = 0
	globalSign.position.z = 0.1
	update()

func set_local_score():
	Globals.score_state = 1
	localSign.position.z = 0.1
	globalSign.position.z = 0
	update()

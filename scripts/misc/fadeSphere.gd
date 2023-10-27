extends MeshInstance3D

func _ready():
	$AnimationPlayer.play("fade_and_destroy")

func destroy():
	queue_free()

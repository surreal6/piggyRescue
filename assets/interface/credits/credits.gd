extends Control

func _ready():
	Globals.credits_anim = $AnimationPlayer
	$AnimationPlayer.play("scroll")
	if Globals.current_credits_position != 0:
		$AnimationPlayer.seek(Globals.current_credits_position)

func end():
	Globals.current_credits_position = 0
	Globals.state = 10

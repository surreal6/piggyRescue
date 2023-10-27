@tool
extends Label3D

@export var countRange : int = 3
@export var active : bool = false
@export var reset : bool = false
@export var pause : bool = false

@onready var anim = $AnimationPlayer
@onready var timer = $Timer
@onready var audio = $AudioStreamPlayer

var counter = 0
var running = false

signal endCountDown

func _ready():
	reset = true
	
func _reset():
	timer.stop()
	visible = false
	active = false
	counter = 0
	text = str(countRange - counter)
	reset = false
	running = false
	
func _process(_delta):
	if reset == true:
		_reset()
		return
	
	if pause:
		timer.set_paused(true)
	else:
		timer.set_paused(false)

	if active && !running:
		anim.play()
		audio.play()
		timer.start()
		running = true
	
	if active:
		show()

func _on_timer_timeout():
	anim.play()
	audio.play()
	if active == true:
		counter += 1
		if countRange - counter < 1:
			endCountDown.emit()
			reset = true
		else:
			text = str(countRange - counter)

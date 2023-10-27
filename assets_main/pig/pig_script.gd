@tool
class_name Pig
extends XRToolsFloatablePickable

var captured = false

var pigSoundType

@export_range (-1.0, 1.0) var animBlend : float = 0.0:
	set(value):
		animBlend = value

@onready var animation_tree = $AnimationTree

@onready var sound01 : AudioStreamWAV = preload("res://audio/fx/pig_01.wav")
@onready var sound05 : AudioStreamWAV = preload("res://audio/fx/pig_05.wav")
@onready var sound07 : AudioStreamWAV = preload("res://audio/fx/pig_07.wav")
@onready var sound08 : AudioStreamWAV = preload("res://audio/fx/pig_08.wav")

@onready var pigAudioStream = $AudioStreamPlayer3D

@onready var soundsArray : Array[AudioStreamWAV]= [sound01, sound05, sound07, sound08]
var pigSound : AudioStreamWAV

func _ready():
	randomize()
	pigSoundType = randi_range(0,3)
	pigSound = soundsArray[pigSoundType]
	pigAudioStream.stream = pigSound
	pigAudioStream.play()
	super._ready()
	$Timer.start(randi() % 5 + 1)

func _process(delta):
	if is_picked_up():
		animBlend = lerp(animBlend, -1.0, delta * 2)
	elif captured:
		animBlend = lerp(animBlend, 0.0, delta * 2)
	else:
		animBlend = lerp(animBlend, 1.0, delta * 2)
	animation_tree["parameters/Blend3/blend_amount"] = animBlend
	
	if !pigAudioStream.is_playing() and !captured and $Timer.is_stopped():
		$Timer.start(randi() % 5 + 1)

func disable_pig():
	floatable = false
	captured = true
	sleeping = true
	set_collision_mask_value(18, false)
	queue_free()

func enable_pig():
	floatable = true
	captured = false
	sleeping = false
	set_collision_mask_value(18, true)

func _on_timer_timeout():
	pigAudioStream.play()
	


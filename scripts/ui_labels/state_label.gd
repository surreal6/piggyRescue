extends Label3D

@onready var main = $"../../../.."

var media_fps = 0
var seconds = 0
var fps_total = 0
var timer_reset = false


func _ready():
	var size = DisplayServer.screen_get_size()
	#print(size)
	#print(get_viewport().get_visible_rect().size)
	var render_mode = ProjectSettings.get_setting_with_override("rendering/renderer/rendering_method")
		
	$resolution.set_text("%s x %s :   render %s" % [size.x, size.y, render_mode])
	$Timer.start()

func _process(_delta):
	text = "state: " + str(Globals.state) + "\nplayer: " + Globals.current_player
	var pigsCounter = "pigs %s/%s" % [main.capturedPigs, main.totalPigs]
	var fps = "FPS %d" % Engine.get_frames_per_second()
	$fps.set_text(pigsCounter + " - " + fps + " - " + str(media_fps))
	
	## reset counter once
	if !timer_reset and seconds == 20:
		timer_reset = true
		reset_fps_counter()

func _on_timer_timeout():
	fps_total += Engine.get_frames_per_second()
	seconds += 1
	media_fps = int(fps_total / seconds)

func reset_fps_counter():
	seconds = 0
	fps_total = 0
	media_fps = 0

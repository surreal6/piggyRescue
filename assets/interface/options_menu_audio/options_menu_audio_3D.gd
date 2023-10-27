extends Node3D

signal optionsBack
signal closeOptions

signal fxVol
signal musicVol
signal masterVol
signal inGameMusic
		
func _ready():
	$Viewport2Din3D.connect_scene_signal("optionsBack", on_options_back)
	$Viewport2Din3D.connect_scene_signal("closeOptions", on_close_options)
	$Viewport2Din3D.connect_scene_signal("fxVol", on_fx_vol)
	$Viewport2Din3D.connect_scene_signal("musicVol", on_music_vol)
	$Viewport2Din3D.connect_scene_signal("masterVol", on_master_vol)
	$Viewport2Din3D.connect_scene_signal("inGameMusic", on_in_game_music)

func on_options_back():
	optionsBack.emit()
	
func on_close_options():
	closeOptions.emit()

func on_fx_vol(value):
	fxVol.emit(value)

func on_music_vol(value):
	musicVol.emit(value)

func on_master_vol(value):
	masterVol.emit(value)
	
func on_in_game_music(value):
	inGameMusic.emit(value)

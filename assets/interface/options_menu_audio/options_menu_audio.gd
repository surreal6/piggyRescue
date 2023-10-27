extends Panel

signal closeOptions
signal optionsBack

signal fxVol
signal musicVol
signal masterVol
signal inGameMusic

@onready var in_game_music_button =  $Panel/VBoxContainer/inGameMusicCheckButton
@onready var fx_slider = $Panel/VBoxContainer/EffectsSliderContainer/FxVolHSlider
@onready var music_slider = $Panel/VBoxContainer/MusicSliderContainer/MusicVolHSlider
@onready var master_slider = $Panel/VBoxContainer/MasterSliderContainer/MasterVolHSlider

func _ready():
	if Globals.in_game_music:
		in_game_music_button.button_pressed = true
	if Globals.fx_vol:
		fx_slider.value = Globals.fx_vol
	if Globals.music_vol:
		music_slider.value = Globals.music_vol
	if Globals.master_vol:
		master_slider.value = Globals.master_vol

func _on_close_button_pressed():
	closeOptions.emit()

func _on_go_back_pressed():
	optionsBack.emit()

func _on_fx_vol_h_slider_value_changed(value):
	fxVol.emit(value)

func _on_music_vol_h_slider_value_changed(value):
	musicVol.emit(value)

func _on_master_vol_h_slider_value_changed(value):
	masterVol.emit(value)

func _on_in_game_music_check_button_toggled(button_pressed):
	inGameMusic.emit(button_pressed)

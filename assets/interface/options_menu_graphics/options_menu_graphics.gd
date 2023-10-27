extends Panel

signal closeOptions
signal showDebug
signal fxaa
signal forceResolution
signal forceShadows
signal optionsBack

@onready var debug_button = $Panel/VBoxContainer/ShowDebugInfo
@onready var resolution_button = $Panel/VBoxContainer/resolutionToggle
@onready var fxaa_button = $Panel/VBoxContainer/fxaaToggle
@onready var shadows_button = $Panel/VBoxContainer/VBoxContainer/shadowsToggle
@onready var warning = $Panel/VBoxContainer/VBoxContainer/shadowsWarning

func _ready():
	if OS.get_name() != "Android":
		resolution_button.hide()
		$Panel/VBoxContainer/HSeparator.show()
	
	debug_button.button_pressed = Globals.show_debug
	resolution_button.button_pressed = Globals.force_resolution
	fxaa_button.button_pressed = Globals.fxaa
	shadows_button.button_pressed = Globals.force_shadows
	if Globals.force_shadows and OS.get_name() == "Android":
		warning.show()
	else:
		warning.hide()

func _on_exit_game_button_pressed():
	get_tree().quit()

func _on_close_button_pressed():
	closeOptions.emit()

func _on_show_debug_info_toggled(button_pressed):
	Globals.show_debug = button_pressed
	if debug_button.has_focus():
		debug_button.release_focus()
	showDebug.emit()

func _on_fxaa_toggle_toggled(button_pressed):
	Globals.fxaa = button_pressed
	if fxaa_button.has_focus():
		fxaa_button.release_focus()
	fxaa.emit()

func _on_resolution_toggle_toggled(button_pressed):
	Globals.force_resolution = button_pressed
	if resolution_button.has_focus():
		resolution_button.release_focus()
	forceResolution.emit()

func _on_shadows_toggle_toggled(button_pressed):
	Globals.force_shadows = button_pressed
	if Globals.force_shadows and OS.get_name() == "Android":
		warning.show()
	else:
		warning.hide()
	if shadows_button.has_focus():
		shadows_button.release_focus()
	forceShadows.emit(button_pressed)

func _on_go_back_pressed():
	optionsBack.emit()



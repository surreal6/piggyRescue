extends Panel

signal changeHands

@onready var name_alert = $VBoxContainer/nameAlertContainer/nameAlertLabel
@onready var sample = $VBoxContainer/VBoxContainer/SampleButton
@onready var save = $VBoxContainer/VBoxContainer/SavePlayerButton
@onready var input = $VBoxContainer/NameTextEdit

var player_color = "orange"
var player_name = ""
var player_hands = "gloves"

var online_names = []

var name_exist = false
var invalid_name = false

var save_is_running = false

func _ready():
	input.grab_focus()
	
func on_name_exist():
	if name_exist:
		invalid_name = true
		name_alert.show()
	else:
		name_alert.hide()

func _on_name_text_edit_text_changed(new_text):
	name_exist = false
	invalid_name = false
	if new_text == "":
		sample.text = "???"
		invalid_name = true
	else:
		for player in Globals.players:
			if player.name == new_text:
				name_exist = true
		for curr_name in online_names:
			if curr_name == new_text:
				name_exist = true
	
	on_name_exist()
		
	if invalid_name:
		save.disabled = true
	else:
		save.disabled = false
		player_name = new_text
		sample.text = player_name

func update_sample_image():
	var path = Globals.get_color_floater_path(player_color)
	sample.icon = load(path)

func _on_floater_yellow_pressed():
	player_color = "yellow"
	update_sample_image()

func _on_floater_green_pressed():
	player_color = "green"
	update_sample_image()

func _on_floater_cyan_pressed():
	player_color = "cyan"
	update_sample_image()

func _on_floater_blue_pressed():
	player_color = "blue"
	update_sample_image()

func _on_floater_pink_pressed():
	player_color = "pink"
	update_sample_image()

func _on_floater_red_pressed():
	player_color = "red"
	update_sample_image()

func _on_floater_orange_pressed():
	player_color = "orange"
	update_sample_image()

func _on_hand_african_pressed():
	player_hands = "african"
	changeHands.emit("african")

func _on_hand_african_realistic_pressed():
	player_hands = "african_realistic"
	changeHands.emit("african_realistic")

func _on_hand_caucasian_pressed():
	player_hands = "caucasian"
	changeHands.emit("caucasian")

func _on_hand_caucasian_realistic_pressed():
	player_hands = "caucasian_realistic"
	changeHands.emit("caucasian_realistic")

func _on_gloves_pressed():
	player_hands = "gloves"
	changeHands.emit("gloves")


func _on_save_player_button_pressed():
	# debounce to avoid multiple player creation
	if !save_is_running:
		save_is_running = true
		if Globals.online_scores:
			var sw_result = await SilentWolf.Players.get_player_data(player_name).sw_get_player_data_complete
			if sw_result.player_data != {}:
				# not available
				save.disabled = true
				name_exist = true
				online_names.append(player_name)
				on_name_exist()
				input.grab_focus()
		if !save.disabled:
			Globals.create_player(player_name, player_color, player_hands)
			Globals.state = 30
		save_is_running = false

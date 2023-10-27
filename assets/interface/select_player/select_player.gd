extends Panel

var player_button: PackedScene = preload("res://assets/interface/player_button/player_button.tscn")

@onready var playerButtonsContainer = $VBoxContainer/ScrollContainer/PlayerButtonsContainer

func _ready():
	# clean containers
	for child in playerButtonsContainer.get_children():
		child.queue_free()
	# generate buttons
	for playerKey in Globals.players:
		add_player_button(playerKey)
	# connect signals
	for child in playerButtonsContainer.get_children():
		child.connect("playerSelected", on_player_selected)

func add_player_button(player):
	var button = player_button.instantiate()
	button.player = player
	playerButtonsContainer.add_child(button)

func _on_create_player_button_pressed():
	Globals.state = 21

func on_player_selected(selected_name):
	Globals.current_player = selected_name
	Globals.state = 30

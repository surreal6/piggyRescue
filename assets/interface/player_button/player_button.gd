extends Button

@onready var player : PigRescuePlayer

signal playerSelected(name)

func _ready():
	if player:
		text = player.name
		icon = load(Globals.get_color_floater_path(player.color))

func _on_pressed():
	playerSelected.emit(player.name)

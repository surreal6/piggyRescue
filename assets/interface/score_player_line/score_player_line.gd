extends Control

@export var player : PigRescuePlayer

@onready var icon = $PlayerLineContainer/NameContainer/TextureRect
@onready var playerName = $PlayerLineContainer/NameContainer/NameLabel
@onready var time = $PlayerLineContainer/DataContainer/TimeLabel
@onready var score = $PlayerLineContainer/DataContainer/ScoreLabel

func _ready():
	icon.texture = load(Globals.get_color_floater_path(player.color))
	playerName.text = player.name
	time.text = Globals.time_to_min_sec(player.time)
	score.text = str(player.score)



extends Control

@onready var playerLine = preload("res://assets/interface/score_player_line/score_player_line.tscn")
@onready var playersContainer = $VBoxContainerMain/VBoxContainerPlayers

var playerList = []

func delete_children(node) -> void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func update_table():
	delete_children(playersContainer)
	if Globals.score_state == 1:
		Globals.get_local_players_sorted_by_score()
		playerList = Globals.players
	elif Globals.score_state == 2 and Globals.online_scores:
		playerList = Globals.online_players
		
	var counter = 0
	
	for player in playerList:
		if counter < 6:
			var line = playerLine.instantiate()
			line.player = player
			playersContainer.add_child(line)
			counter += 1

func _ready():
	update_table()
	if Globals.online_scores:
		Globals.get_global_players()

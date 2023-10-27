extends Node3D

## Gamedata file name to persist user gamedata
var gamedata_file_name : String = "user://gamedata.json"

func _ready():
	#load players
	_load()

## Reset to default values
func reset_to_defaults() -> void:
	Globals.players = []
	pass


func _load() -> void:
	# First reset our values
	reset_to_defaults()

	# Skip if no  file found
	if !FileAccess.file_exists(gamedata_file_name):
		Globals.state = 10
		return

	# Attempt to open the settings file for reading
	var file := FileAccess.open(gamedata_file_name, FileAccess.READ)
	if not file:
		push_warning("Unable to read from %s" % gamedata_file_name)
		return

	# Read the settings text
	var gamedata_text := file.get_as_text()
	file.close()

	# Parse the settings text and verify it's a dictionary
	var gamedata_raw = JSON.parse_string(gamedata_text)
	if typeof(gamedata_raw) != TYPE_DICTIONARY:
		push_warning("Gamedata file %s is corrupt" % gamedata_file_name)
		return

	# Parse our input settings
	var gamedata : Dictionary = gamedata_raw
	if gamedata.has("players"):
		for key in gamedata["players"]:
			Globals.load_player(gamedata["players"][key])

	# control options
	if gamedata.has("grab_with_trigger"):
		Globals.grab_with_trigger = gamedata["grab_with_trigger"]
	if gamedata.has("step_turn"):
		Globals.step_turn = gamedata["step_turn"]
	# graphics options
	if gamedata.has("show_debug"):
		Globals.show_debug = gamedata["show_debug"]
	if gamedata.has("fxaa"):
		Globals.fxaa = gamedata["fxaa"]
	if gamedata.has("force_resolution"):
		Globals.force_resolution = gamedata["force_resolution"]
	if gamedata.has("force_shadows"):
		Globals.force_shadows = gamedata["force_shadows"]
	# audio options
	if gamedata.has("in_game_music"):
		Globals.in_game_music = gamedata["in_game_music"]
	if gamedata.has("fx_vol"):
		Globals.fx_vol = gamedata["fx_vol"]
	if gamedata.has("music_vol"):
		Globals.music_vol = gamedata["music_vol"]
	if gamedata.has("master_vol"):
		Globals.master_vol = gamedata["master_vol"]
	Globals.state = 10

func player_to_dictionary(player):
	return {
		"name": player.name,
		"color": player.color,
		"hands": player.hands,
		"score": player.score,
		"time": player.time,
		"max_level": player.max_level
	}

## Save the settings to file
func save():
	var players := {}
	for player in Globals.players:
		players[player.name] = player_to_dictionary(player)
	# Convert the settings to a dictionary
	var gamedata := {
		"players" : players,
		# controls
		"grab_with_trigger" : Globals.grab_with_trigger,
		"step_turn" : Globals.step_turn,
		# graphics
		"show_debug" : Globals.show_debug,
		"fxaa" : Globals.fxaa,
		"force_resolution" : Globals.force_resolution,
		"force_shadows" : Globals.force_shadows,
		# audio
		"in_game_music" : Globals.in_game_music,
		"fx_vol" : Globals.fx_vol,
		"music_vol" : Globals.music_vol,
		"master_vol" : Globals.master_vol,
	}

	# Convert the gamedata dictionary to text
	var gamedata_text := JSON.stringify(gamedata)

	# Attempt to open the gamedata file for writing
	var file := FileAccess.open(gamedata_file_name, FileAccess.WRITE)
	if not file:
		push_warning("Unable to write to %s" % gamedata_file_name)
		return

	# Write the gamedata text to the file
	file.store_line(gamedata_text)
	file.close()

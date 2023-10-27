extends Node

signal newRecord
signal scorePosition

var online_scores = false
var silentWolfApiKey := "PUT-HERE-YOUR-SILENT-WOLF-API-KEY"

var players : Array[PigRescuePlayer] = []

var online_players = []

# 0 - loading
# 10 - main
# 11 - hall of fame
# 12 - credits
# 20 - select player
# 21 - create player
# 30 - pre game - level label and trigger countdown
# 31 - game
# 32 - post game - score label and trigger to continue
# 40 - game over - next level / main menu
var state : int = 0

# 0: explanation, 1: local score, 2: global score
var score_state := 1

var current_player := ""

var credits_anim
var current_credits_position = 0

## control options
var grab_with_trigger = false:
	set(value):
		grab_with_trigger = value
		Gamedata.save()
var step_turn = false:
	set(value):
		step_turn = value
		Gamedata.save()
# graphics options
var show_debug = false:
	set(value):
		show_debug = value
		Gamedata.save()
var fxaa = true:
	set(value):
		fxaa = value
		Gamedata.save()
var force_resolution = false:
	set(value):
		force_resolution = value
		Gamedata.save()
var force_shadows = true:
	set(value):
		force_shadows = value
		Gamedata.save()
# audio options
var in_game_music = false:
	set(value):
		in_game_music = value
		Gamedata.save()
var fx_vol = 1.0:
	set(value):
		fx_vol = value
		Gamedata.save()
var music_vol = 1.0:
	set(value):
		music_vol = value
		Gamedata.save()
var master_vol = 1.0:
	set(value):
		master_vol = value
		Gamedata.save()

func sw_configure():
	# log_level = 0 for errors only, 1 for info-level logging and 2 for debug logging
	SilentWolf.configure({
		"api_key": silentWolfApiKey,
		"game_id": "piggyrescue",
		"log_level": 0
	})

	await get_tree().create_timer(0.1).timeout

	var sw_result = await SilentWolf.Scores.get_scores(1).sw_get_scores_complete
	if sw_result.scores.size() == 0:
		# disable online requests
		online_scores = false
	else:
		online_scores = true

	if online_scores:
		SilentWolf.Scores.connect("sw_save_score_complete", on_score_complete)

func _ready():
	if Globals.online_scores:
		sw_configure()
	
func on_score_complete(_score):
	get_tree().get_nodes_in_group("score")[0].update_table()

func get_hands_material_path(hands):
	match hands:
		"african":
			return "res://addons/godot-xr-tools/hands/materials/african_hands.material"
		"african_realistic":
			return "res://addons/godot-xr-tools/hands/materials/african_hands_realistic.material"
		"caucasian":
			return "res://addons/godot-xr-tools/hands/materials/caucasian_hand.material"
		"caucasian_realistic":
			return "res://addons/godot-xr-tools/hands/materials/caucasian_hands_realistic.material"
		"gloves":
			return "res://addons/godot-xr-tools/hands/materials/cleaning_glove.material"
	return false

func get_color_floater_path(color):
	match color:
		"yellow":
			return "res://assets/images/rescue_buoy_images/90px/float_yellow_90px.png"
		"green":
			return "res://assets/images/rescue_buoy_images/90px/float_green_90px.png"
		"cyan":
			return "res://assets/images/rescue_buoy_images/90px/float_cyan_90px.png"
		"blue":
			return "res://assets/images/rescue_buoy_images/90px/float_blue_90px.png"
		"pink":
			return "res://assets/images/rescue_buoy_images/90px/float_pink_90px.png"
		"red":
			return "res://assets/images/rescue_buoy_images/90px/float_red_90px.png"
		"orange":
			return "res://assets/images/rescue_buoy_images/90px/float_orange_90px.png"
	return false

func create_player(player_name, player_color, player_hands):
	var player = PigRescuePlayer.new()
	player.name = player_name
	player.color = player_color
	player.hands = player_hands
	players.append(player)
	Gamedata.save()
	current_player = player_name
	if online_players:
		upload_player_stats(player, 0)

func load_player(player_dict):
	var player = PigRescuePlayer.new()
	player.name = player_dict["name"]
	player.color = player_dict["color"]
	player.hands = player_dict["hands"]
	player.time = player_dict["time"]
	player.score = player_dict["score"]
	player.max_level = player_dict["max_level"]
	players.append(player)

func update_player_stats(score, playTime, next_level):
	var player
	for element in players:
		if element.name == current_player:
			player = element
			if player.score < score:
				player.score = score
				newRecord.emit()
			player.time += int(playTime)
			player.max_level = next_level
	Gamedata.save()
	if player != null && online_scores:
		upload_player_stats(player, score)

func upload_player_stats(player, score):
	var player_data = {
		"color": player.color,
		"time": player.time
	}
	SilentWolf.Players.save_player_data(player.name, player_data)
	
	if score != 0:
		var sw_result = await SilentWolf.Scores.get_score_position(score).sw_get_position_complete
		if sw_result and sw_result.success:
			var position = sw_result.position
			scorePosition.emit(position)
		else:
			scorePosition.emit(0)
		
		SilentWolf.Scores.save_score(player.name, player.score)
	
func update_player_options():
	for player in players:
		if player.name == current_player:
			player.step_turn = Globals.step_turn

func get_player_level():
	for player in players:
		if player.name == current_player:
			return player.max_level

func sort_by_score(a, b):
	if a.score > b.score:
		return true
	return false

func get_local_players_sorted_by_score():
	players.sort_custom(sort_by_score)

func get_online_players_sorted_by_score():
	online_players.sort_custom(sort_by_score)

func get_global_players():
	online_players = []
	var sw_result: Dictionary = await SilentWolf.Scores.get_scores(6).sw_get_scores_complete
	for score in sw_result.scores:
		var sw_player_result = await SilentWolf.Players.get_player_data(score.player_name).sw_get_player_data_complete
		var player = PigRescuePlayer.new()
		player.name = score.player_name
		player.color = sw_player_result.player_data.color
		player.time = sw_player_result.player_data.time
		player.score = score.score
		online_players.append(player)
	get_online_players_sorted_by_score()
		
func get_player_score(playTime, totalPigs, totalFloaters, currentLevel) -> int:
	# remove floaters and pigs spawn time
	playTime = playTime - totalFloaters - totalPigs
	var pigs_per_second = float(totalPigs) / playTime
	var score_factor = (currentLevel + 1) * 4000
	return int(pigs_per_second * score_factor)

func time_to_min_sec(playTime):
	var minutes = int(playTime / 60)
	var seconds = playTime - (minutes * 60)
	if minutes == 0:
		return "%s''" % seconds
	else:
		return "%s'%s''" % [minutes, seconds]

## draw lines functions

func line(container : Node, pos1: Vector3, pos2: Vector3, color = Color.WHITE_SMOKE) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var immediate_mesh := ImmediateMesh.new()
	var material := ORMMaterial3D.new()
	
	mesh_instance.mesh = immediate_mesh
#	mesh_instance.cast_shadow = false

	immediate_mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	immediate_mesh.surface_add_vertex(pos1)
	immediate_mesh.surface_add_vertex(pos2)
	immediate_mesh.surface_end()	
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	container.add_child(mesh_instance)
	
	return mesh_instance


func point(container: Node, pos:Vector3, radius = 0.05, color = Color.WHITE_SMOKE) -> MeshInstance3D:
	var mesh_instance := MeshInstance3D.new()
	var sphere_mesh := SphereMesh.new()
	var material := ORMMaterial3D.new()
		
	mesh_instance.mesh = sphere_mesh
#	mesh_instance.cast_shadow = false
	mesh_instance.position = pos
	
	sphere_mesh.radius = radius
	sphere_mesh.height = radius*2
	sphere_mesh.material = material
	
	material.shading_mode = BaseMaterial3D.SHADING_MODE_UNSHADED
	material.albedo_color = color
	
	container.add_child(mesh_instance)
	
	return mesh_instance
	

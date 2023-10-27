extends XRToolsSceneBase

@export var levels : Array[PigRescueLevel]
@export var teleport_button := "by_button"
@export var options_button := "ax_button"

@onready var mainMenuInterface = preload("res://assets/interface/main_menu/main_menu_3D.tscn")
@onready var selectPlayerInterface = preload("res://assets/interface/select_player/select_player_3D.tscn")
@onready var createPlayerInterface = preload("res://assets/interface/create_player/create_player_3D.tscn")
@onready var optionsInterface = preload("res://assets/interface/options_menu/options_menu_3D.tscn")
@onready var audioOptionsInterface = preload("res://assets/interface/options_menu_audio/options_menu_audio_3D.tscn")
@onready var controlsOptionsInterface = preload("res://assets/interface/options_menu_controls/options_menu_controls_3D.tscn")
@onready var graphicsOptionsInterface = preload("res://assets/interface/options_menu_graphics/options_menu_graphics_3D.tscn")
@onready var creditsInterface = preload("res://assets/interface/credits/credits_3d.tscn")

@onready var pig_node = preload("res://assets_main/pig/pig_1k.tscn")
@onready var barrel_up_node = preload("res://assets/models/floating_objects/barrel/barrel_up.tscn")
@onready var barrel_rot_node = preload("res://assets/models/floating_objects/barrel/barrel_rotated.tscn")

@onready var basic_loop = preload("res://audio/music/Ludum Dare 38 - Track 1.wav")
@onready var militar_loop = preload("res://audio/music/Ludum Dare 30 - Track 8.wav")

@onready var sky = preload("res://assets_main/sky/industrial_sunset_environment.tres")
@onready var sky_basic = preload("res://assets_main/sky/industrial_android.tres")
@onready var light_node = preload("res://assets_main/sky/directional_light_3d.tscn")
@onready var clouds = preload("res://assets/models/clouds.tscn")

@onready var rotatoryInterfacesContainer = $XROrigin3D/interfaces
@onready var interfaceContainer = $XROrigin3D/interfaces/dynamic_interface
@onready var debugInterface = $XROrigin3D/interfaces/debug_interface
@onready var lPointer = $XROrigin3D/LeftHandController/FunctionPointer
@onready var rPointer = $XROrigin3D/RightHandController/FunctionPointer
@onready var cameraLabels = $XROrigin3D/XRCamera3D/CameraLabels
@onready var levelLabel = $XROrigin3D/XRCamera3D/CameraLabels/LevelLabel
@onready var CountDown = $XROrigin3D/XRCamera3D/CameraLabels/CountDownLabel
@onready var scoreLabel = $XROrigin3D/XRCamera3D/CameraLabels/scoreLabel
@onready var newRecord = $XROrigin3D/XRCamera3D/CameraLabels/scoreLabel/newRecord
@onready var newRecordParticles = $XROrigin3D/XRCamera3D/CameraLabels/scoreLabel/newRecord/GPUParticles3D
@onready var gameoverLabel = $XROrigin3D/XRCamera3D/CameraLabels/gameoverLabel
@onready var limitsLabel = $XROrigin3D/XRCamera3D/CameraLabels/limitsAlertLabel
@onready var lController := $XROrigin3D/LeftHandController
@onready var rController := $XROrigin3D/RightHandController
@onready var RightPhysicsHand = $XROrigin3D/RightHandController/RightPhysicsHand
@onready var LeftPhysicsHand = $XROrigin3D/LeftHandController/LeftPhysicsHand
@onready var RControls = $XROrigin3D/RightHandController/R_controls
@onready var LControls = $XROrigin3D/LeftHandController/L_controls
@onready var lPickup = $XROrigin3D/LeftHandController/FunctionPickup
@onready var rPickup = $XROrigin3D/RightHandController/FunctionPickup
@onready var lJump = $XROrigin3D/LeftHandController/MovementJump
@onready var rJump = $XROrigin3D/RightHandController/MovementJump
@onready var origin_node := XRHelpers.get_xr_origin(self)
@onready var camera_node := XRHelpers.get_xr_camera(self)

@onready var pigsContainer = $pigsContainer
@onready var floatersContainer = $floatersContainer
@onready var pig_spawn_path = $PigSpawnPath
@onready var pig_spawn_location = $PigSpawnPath/PigSpawnLocation
@onready var pigTimer = $PigSpawnPath/PigTimer

@onready var water = $scenery/water_mesh
@onready var boat = $scenery/boat
@onready var StartPosition = $scenery/StartPositionMarker3D
@onready var GamePosition = $scenery/GamePositionMarker3D
@onready var HallOfFamePosition = $scenery/HallOfFamePositionMarker3D
@onready var mainMenuSign = $scenery/mainMenu3D_sign
@onready var scoreTable = $scenery/scoreTable3D

@onready var audioMusic = $"../../AudioStreamMusic"
@onready var audioCaptured = $AudioStreamFxPigCaptured
@onready var audioWin = $AudioStreamFxPigWin

# Tween for fading
var _tween : Tween

# master bus
var masterBusIndex = AudioServer.get_bus_index("Master")
# music bus
var musicBusIndex = AudioServer.get_bus_index("music")
# underwater filter bus
var underwaterBusIndex = AudioServer.get_bus_index("underwater")
# fx bus
var pigsBusIndex = AudioServer.get_bus_index("pigs")
var waterBusIndex = AudioServer.get_bus_index("waterSound")
var noWaterFxIndex = AudioServer.get_bus_index("noWaterFx")

var new_record_detected = false

var mainMenu : Node
var selectPlayer : Node
var createPlayer : Node
var options : Node
## 0: main options menu, 1: audio options, 2: control options, 3: graphics options
var optionsState : int = 0
var old_state : int = -1

var currentLevel : int = 0
var totalPigs : int = 0
var remainingPigs : int = totalPigs
var totalFloaters : int = 0
var remainingFloaters : int = totalFloaters
var spawnFloaterCounter : bool = false
var gameStarted : bool = false
var playTime : float = 0.0
var score : int = 0
var score_position := 0
var current_game_data = []

var spawn_scale_factor = 0.2

var pointers_old_state = false
var showOptions = false:
	set(val):
		showOptions = val
var debouncedDelta = 0.0
var debouncedTime = 1

var capturedPigs : int = 0

func delete_children(node) -> void:
	for n in node.get_children():
		node.remove_child(n)
		n.queue_free()

func instance_interface(interface):
	delete_children(interfaceContainer)
	rotatoryInterfacesContainer.follow_camera = true
	interfaceContainer.add_child(interface)
	return interface

# in cheap render mode (quest2 or pico4):
# change environment
# remove directional light
# change water material
# remove sky, add clouds
func cheap_render_mode(value):
	if value: # force_shadow ON
		$scenery/sky/clouds.queue_free()
		$scenery/sky/WorldEnvironment.environment = sky
		var light = light_node.instantiate()
		light.shadow_enabled = true
		$scenery/sky.add_child(light)
		$scenery/sky/clouds.queue_free()
		water.basic_material = false
	else:      # force_shadow OFF
		$scenery/sky/WorldEnvironment.environment = sky_basic
		$scenery/sky/DirectionalLight3D.queue_free()
		var cloud = clouds.instantiate()
		$scenery/sky.add_child(cloud)
		water.basic_material = true

func _ready() -> void:
	CountDown.connect("endCountDown", on_end_countdown)
	boat.connect("pigCaptured", on_pig_captured)
	mainMenuSign.connect("mainMenu", on_options_main_menu)
	
	if OS.get_name() == "Android":
		Globals.force_shadows = false
	else:
		Globals.force_shadows = true
	
	cheap_render_mode(Globals.force_shadows)
	
	setup_options()
	reset_player_position(StartPosition)

	audioMusic.stop()
	audioMusic.stream = basic_loop
	audioMusic.play()
	
	# Fade music and lights
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_method(set_music_fade, 0.0, 1.0, 1.0)
	await _tween.finished
	
	Globals.connect("newRecord", new_personal_record)
	Globals.connect("scorePosition", set_score_position)
	
	enable_jump(false)

func set_music_fade(p_value : float):
	AudioServer.set_bus_volume_db(masterBusIndex, linear_to_db(p_value))

func set_scenery_lights(p_value : float):
	$scenery/sky/WorldEnvironment.environment.set_bg_energy_multiplier(p_value / 2) # 0.5
	$scenery/sky/DirectionalLight3D.set_param(0, p_value) # 1.0

func setup_options():
	on_show_debug()
	on_step_turn()

func load_options_interface():
	delete_children(interfaceContainer)
	match optionsState:
		0: # main options menu
			options = optionsInterface.instantiate()
			options.connect("mainMenu", on_options_main_menu)
			options.connect("controlsOptions", on_controls_options)
			options.connect("audioOptions", on_audio_options)
			options.connect("graphicsOptions", on_graphics_options)
		1: # audio options menu
			options = audioOptionsInterface.instantiate()
			options.connect("fxVol", on_fx_vol)
			options.connect("musicVol", on_music_vol)
			options.connect("masterVol", on_master_vol)
			options.connect("inGameMusic", on_in_game_music)
			options.connect("optionsBack", on_options_back)
		2: # controls options
			options = controlsOptionsInterface.instantiate()
			options.connect("stepTurn", on_step_turn)
			options.connect("grabWithTrigger", on_grab_with_trigger)
			options.connect("optionsBack", on_options_back)
		3: # graphics options
			options = graphicsOptionsInterface.instantiate()
			options.connect("showDebug", on_show_debug)
			options.connect("fxaa", on_fxaa)
			options.connect("forceResolution", on_force_resolution)
			options.connect("forceShadows", on_force_shadows)
			options.connect("optionsBack", on_options_back)
	options.connect("closeOptions", toggle_options_menu)
	instance_interface(options)
	show_pointers(true)
	toggle_controls(true)

func toggle_options_menu():
	if showOptions: # -> hide options
		showOptions = false
		CountDown.pause = false
		delete_children(interfaceContainer)
		updates_on_state_changes()
		cameraLabels.show()
		toggle_movement(true)
		toggle_controls(false)
		enable_jump(true)
	else: # -> show options
		if Globals.state == 12:
			Globals.current_credits_position = Globals.credits_anim.get_current_animation_position( )
		optionsState = 0
		showOptions = true
		CountDown.pause = true
		load_options_interface()
		cameraLabels.hide()
		toggle_movement(false)
		toggle_controls(true)
		show_pointers(true)
		enable_jump(false)

func on_launch_credits():
	Globals.state = 12
	load_military_music()

func load_credits():
	delete_children(interfaceContainer)
	var credits = creditsInterface.instantiate()
	instance_interface(credits)

func load_military_music():
	# Fade music
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_method(set_music_fade, 1.0, 0.0, 1.0)
	await _tween.finished
	
	audioMusic.stop()
	audioMusic.stream = militar_loop
	audioMusic.play()

	# Fade music
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_method(set_music_fade, 0.0, 1.0, 1.0)
	await _tween.finished
	
func load_basic_music():
		# Fade music
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_method(set_music_fade, 1.0, 0.0, 1.0)
	await _tween.finished
	
	audioMusic.stop()
	audioMusic.stream = basic_loop
	audioMusic.play()

	# Fade music
	if _tween:
		_tween.kill()
	_tween = get_tree().create_tween()
	_tween.tween_method(set_music_fade, 0.0, 1.0, 1.0)
	await _tween.finished
	
func load_menu_interface():
	mainMenu = mainMenuInterface.instantiate()
	mainMenu.connect("showOptions", toggle_options_menu)
	mainMenu.connect("hallOfFame", on_hall_of_fame)
	mainMenu.connect("launchCredits", on_launch_credits)
	instance_interface(mainMenu)
	show_pointers(true)

func load_score_view():
	delete_children(interfaceContainer)
	mainMenuSign.active = true
	show_pointers(true)
	enable_jump(false)

func load_select_player_interface():
	selectPlayer = selectPlayerInterface.instantiate()
	instance_interface(selectPlayer)
	show_pointers(true)

func load_create_player_interface():
	createPlayer = createPlayerInterface.instantiate()
	createPlayer.connect("changeHands", on_change_hands)
	instance_interface(createPlayer)
	show_pointers(true)

func load_pre_game():
	reset_player_position(GamePosition)
	toggle_movement(false)
	delete_children(interfaceContainer)
	show_pointers(false)
	setup_level()
	cameraLabels.show()
	hide_camera_labels_children()
	if !CountDown.active:
		levelLabel.show()

func load_post_game():
	audioMusic.play()
	cameraLabels.show()
	hide_camera_labels_children()
	newRecord.hide()
	scoreLabel.show()
	if new_record_detected:
		execute_new_personal_record()
		new_record_detected = false

func load_game_over():
	cameraLabels.show()
	hide_camera_labels_children()
	gameoverLabel.show()
	show_pointers(false)
	reset_player_position(GamePosition)
	toggle_movement(false)

func hide_camera_labels_children():
	for node in cameraLabels.get_children():
		node.hide()

func setup_level():
	currentLevel = Globals.get_player_level()
	var spawn_scale = currentLevel * spawn_scale_factor + 1
	pig_spawn_path.scale = Vector3(spawn_scale, spawn_scale, spawn_scale)
	water.height_scale = levels[currentLevel].waveHeight
	levelLabel.updateText(currentLevel)
	totalPigs = levels[currentLevel].pigs
	#totalPigs = 1
	totalFloaters = levels[currentLevel].floaters
	#totalFloaters = 0
	remainingPigs = totalPigs
	remainingFloaters = totalFloaters
	
func reset_level():
	if !pigTimer.is_stopped():
		pigTimer.stop()
	CountDown.reset = true
	capturedPigs = 0
	totalPigs = 0
	remainingPigs = 0
	remainingFloaters = 0
	boat.hide_pigs()
	delete_children(pigsContainer)
	delete_children(floatersContainer)

func updates_on_state_changes() -> void:
	show_pointers(false)
	mainMenuSign.active = false
	cameraLabels.hide()
	hide_camera_labels_children()
	enable_jump(false)
	match Globals.state:
		10: # main menu
			load_menu_interface()
		11:
			load_score_view()
		12: # credits
			load_credits()
		20: # select player
			load_select_player_interface()
		21: # create player
			load_create_player_interface()
		30: # pregame
			load_pre_game()
		31: # game
			if !Globals.in_game_music:
				audioMusic.stop()
			cameraLabels.hide()
			pigTimer.start()
			toggle_movement(true)
			enable_jump(true)
		32: # post game (show score)
			load_post_game()
		40: # game over  (next level / main menu)
			load_game_over()
	
func _process(delta) -> void:
	if Globals.state != old_state:
		updates_on_state_changes()
		if Globals.state != 12 && old_state == 12:
			load_basic_music()
			Globals.current_credits_position = 0
		old_state = Globals.state

	if Globals.state == 31 && !showOptions:
		playTime += delta
	
	if Globals.state != 31:
		playTime = 0.0
	
	if debouncedDelta < debouncedTime:
		debouncedDelta += delta
	
	#check if options button is pressed
	if (rController and rController.is_button_pressed(options_button)) or \
		(lController and lController.is_button_pressed(options_button)):
			if debouncedDelta > debouncedTime:
				toggle_options_menu()
				debouncedDelta = 0.0
		
	# check if trigger in pre-game is pressed
	#print("countactive %s showoptions %s" % [CountDown.active, showOptions])
	if Globals.state == 30 and CountDown.active == false and !showOptions:
		if (rController and rController.is_button_pressed("trigger_click")) or \
			(lController and lController.is_button_pressed("trigger_click")):
				if debouncedDelta > debouncedTime:
					CountDown.active = true
					levelLabel.hide()
					debouncedDelta = 0.0
				
	
	# check if trigger in pre-game is pressed
	if Globals.state == 32 and !showOptions:
		if (rController and rController.is_button_pressed("trigger_click")) or \
			(lController and lController.is_button_pressed("trigger_click")):
				if debouncedDelta > debouncedTime:
					Globals.state = 40
					debouncedDelta = 0.0

	## CHANGE THIS WITH A NEW MENU:    NEXT LEVEL / MAIN MENU
	# check if trigger in game over is pressed
	if Globals.state == 40 and !showOptions:
		if (rController and rController.is_button_pressed("trigger_click")) or \
			(lController and lController.is_button_pressed("trigger_click")):
				if debouncedDelta > debouncedTime:
					reset_level()
					Globals.state = 30
					debouncedDelta = 0.0

func on_end_countdown() -> void:
	Globals.state = 31

func _on_pig_timer_timeout() -> void:
	if spawnFloaterCounter and remainingFloaters > 0:
		if randf() > 0.5:
			spawn_object(barrel_up_node.instantiate())
		else:
			spawn_object(barrel_rot_node.instantiate())
		spawnFloaterCounter = false
		remainingFloaters -= 1
		return
	if remainingPigs > 0:
		spawn_pig()
		remainingPigs -= 1
		if remainingFloaters > 0:
			spawnFloaterCounter = true
	if remainingPigs == 0 and remainingFloaters == 0:
		pigTimer.stop()

func pig_initialize(pig, start_position, player_position):
	pig.look_at_from_position(start_position, player_position, Vector3.UP)
	pig.rotate_y(randf_range(-PI / 4, PI / 4))

func spawn_pig() -> void:
	var pig = pig_node.instantiate()
	pig_spawn_location.progress_ratio = randf()
	pig_spawn_location.position.y += 2 + randf() * 1
	var player_position = $XROrigin3D/XRCamera3D.global_position
	pig_initialize(pig, pig_spawn_location.global_position, player_position)
	pigsContainer.add_child(pig)

func spawn_object(node) -> void:
	pig_spawn_location.progress_ratio = randf()
	pig_spawn_location.position.y += 2 + randf() * 1
	var player_position = $XROrigin3D/XRCamera3D.global_position
	pig_initialize(node, pig_spawn_location.global_position, player_position)
	floatersContainer.add_child(node)

func on_pig_captured() -> void:
	capturedPigs += 1
	audioCaptured.play()
	check_win_state()

func write_score_label():
	if score_position == 0:
		scoreLabel.text = "Score: %s" % score
	else:
		var sufix = "th"
		match score_position:
			1:
				sufix = "st"
			2:
				sufix = "nd"
			3:
				sufix = "rd"
		var textLabel = "Score: %s world #%s" % [score, score_position]
		scoreLabel.text = textLabel + sufix

func check_win_state() -> void:
	if capturedPigs >= totalPigs:
		# await 1 sec before play win fx
		await get_tree().create_timer(1).timeout
		audioWin.play()
		boat.win_explosion()
		# remove playTime decimals
		playTime = int(playTime)
		# calculate score and update label
		score = Globals.get_player_score(playTime, totalPigs, totalFloaters, currentLevel)
		write_score_label()
		var pigs_per_second = float(totalPigs) / playTime
		var time_string = Globals.time_to_min_sec(playTime)
		current_game_data = [currentLevel + 1, time_string, str(pigs_per_second).pad_decimals(2)]
		scoreLabel.get_node("playData").text = "level: %s   time: %s   pigs/sec: %s" % current_game_data
		# update next level
		var nextLevel = currentLevel + 1
		if nextLevel > 5:
			nextLevel = 5
		# save player stats
		Globals.update_player_stats(score, playTime, nextLevel)
		# await 4 secs (duration of win fx)
		await get_tree().create_timer(4).timeout
		# update score table
		scoreTable.update()
		Globals.state = 32
		
func new_personal_record():
	new_record_detected = true
	
func set_score_position(pos):
	score_position = pos
	write_score_label()
	if Globals.online_scores:
		Globals.get_global_players()

func execute_new_personal_record():
	newRecord.show()
	audioWin.play()
	newRecordParticles.emitting = true
	
func show_pointers(value):
	lPointer.enabled = value
	rPointer.enabled = value

func enable_jump(value):
	lJump.enabled = value
	rJump.enabled = value

func on_options_main_menu():
	if showOptions:
		toggle_options_menu()
	on_main_menu()

func on_audio_options():
	optionsState = 1
	load_options_interface()

func on_fx_vol(value):
	AudioServer.set_bus_volume_db(waterBusIndex, linear_to_db(value))
	AudioServer.set_bus_volume_db(pigsBusIndex, linear_to_db(value))
	AudioServer.set_bus_volume_db(noWaterFxIndex, linear_to_db(value))
	Globals.fx_vol = value
	
func on_music_vol(value):
	AudioServer.set_bus_volume_db(musicBusIndex, linear_to_db(value))
	Globals.music_vol = value
	
func on_master_vol(value):
	AudioServer.set_bus_volume_db(masterBusIndex, linear_to_db(value))
	Globals.master_vol = value
	
func on_options_back():
	optionsState = 0
	load_options_interface()
	
func on_controls_options():
	optionsState = 2
	load_options_interface()

func on_graphics_options():
	optionsState = 3
	load_options_interface()

func on_in_game_music(button_pressed):
	Globals.in_game_music = button_pressed
	if Globals.in_game_music and Globals.state == 31:
		audioMusic.play()
	if !Globals.in_game_music and Globals.state == 31:
		audioMusic.stop()

func on_main_menu():
	reset_level()
	Globals.current_player = ""
	Globals.state = 10
	updates_on_state_changes()
	reset_player_position(StartPosition)

func on_step_turn():
	if Globals.step_turn:
		rController.get_node("MovementTurn").turn_mode = rController.get_node("MovementTurn").TurnMode.SNAP
	else:
		rController.get_node("MovementTurn").turn_mode = rController.get_node("MovementTurn").TurnMode.SMOOTH

func on_grab_with_trigger():
	if Globals.grab_with_trigger:
		lPickup.action_button_action = "grab"
		lPickup.pickup_axis_action = "trigger_click"
		rPickup.action_button_action = "grab"
		rPickup.pickup_axis_action = "trigger_click"
		LControls.update_labels()
		RControls.update_labels()
	else:
		lPickup.action_button_action = "trigger_click"
		lPickup.pickup_axis_action = "grip"
		rPickup.action_button_action = "trigger_click"
		rPickup.pickup_axis_action = "grip"
		LControls.update_labels()
		RControls.update_labels()

func on_show_debug():
	if Globals.show_debug:
		debugInterface.show()
		debugInterface.get_node('state').reset_fps_counter()
	else:
		debugInterface.hide()

func on_fxaa():
	if Globals.fxaa:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 1)
	else:
		ProjectSettings.set_setting("rendering/anti_aliasing/quality/screen_space_aa", 0)

func on_force_resolution():
	if Globals.force_resolution:
		XRServer.find_interface("OpenXR").render_target_size_multiplier = 1.4
	else:
		XRServer.find_interface("OpenXR").render_target_size_multiplier = 1

func on_force_shadows(value):
	Globals.force_shadows = value
	cheap_render_mode(Globals.force_shadows)
#	var pigs = get_tree().get_nodes_in_group("pig")
#	for pig in pigs:
#		pig.updateMaterial()
#	var boat = get_tree().get_nodes_in_group("boat")[0]
#	var pigs = get_tree().get_nodes_in_group("pig")
#	for pig in pigs:
#		pig.updateMaterial()
#	boat.updateMaterial()
		
func toggle_movement(value):
	rController.get_node("MovementDirect").enabled = value
	lController.get_node("MovementDirect").enabled = value
	#rController.get_node("MovementTurn").enabled = value
	rController.get_node("FunctionTeleport").enabled = value
	lController.get_node("FunctionTeleport").enabled = value
	if value:
		rController.get_node("FunctionTeleport").show()
		lController.get_node("FunctionTeleport").show()
	else:
		rController.get_node("FunctionTeleport").hide()
		lController.get_node("FunctionTeleport").hide()

func toggle_controls(value):
	if value:
		RightPhysicsHand.hide()
		LeftPhysicsHand.hide()
		RControls.show()
		LControls.show()
	else:
		RightPhysicsHand.show()
		LeftPhysicsHand.show()
		RControls.hide()
		LControls.hide()

func reset_player_position(marker):
	# this code is a simplified version of the teleporting script
	var new_transform = marker.global_transform
	var cam_transform = camera_node.transform
	var user_feet_transform = Transform3D()
	user_feet_transform.origin = cam_transform.origin
	user_feet_transform.origin.y = 0
	
	# ensure this transform is upright
	user_feet_transform.basis.y = Vector3(0.0, 1.0, 0.0)
	user_feet_transform.basis.x = user_feet_transform.basis.y.cross(
			cam_transform.basis.z).normalized()
	user_feet_transform.basis.z = user_feet_transform.basis.x.cross(
			user_feet_transform.basis.y).normalized()
	
	# now move the origin such that the new global user_feet_transform
	# would be == new_transform
	origin_node.global_transform = new_transform * user_feet_transform.inverse()
	
func on_change_hands(value):
	var hands = load(Globals.get_hands_material_path(value))
	LeftPhysicsHand.hand_material_override = hands
	RightPhysicsHand.hand_material_override = hands

func _on_play_limits_area_3d_body_exited(body):
	if body is XRToolsPlayerBody:
		on_main_menu()
	
func _on_play_alert_area_3d_body_exited(body):
	if body is XRToolsPlayerBody:
		delete_children(interfaceContainer)
		cameraLabels.show()
		limitsLabel.show()

func _on_play_alert_area_3d_body_entered(body):
	if body is XRToolsPlayerBody:
		limitsLabel.hide()
		updates_on_state_changes()

func on_hall_of_fame():
	Globals.state = 11
	reset_player_position(HallOfFamePosition)



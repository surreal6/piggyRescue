extends XRCamera3D

@onready var water : Node = get_tree().get_nodes_in_group("water")[0]

@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")


@export var floatable := true
@export var float_force := 10.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

var submerged := false

var underwaterBusIndex = AudioServer.get_bus_index("underwater")
var waterBusIndex = AudioServer.get_bus_index("waterSound")

func activate_underwater_effects(value):
	if value:  # submerged
		AudioServer.set_bus_volume_db(underwaterBusIndex, -12)
		AudioServer.set_bus_volume_db(waterBusIndex, linear_to_db(Globals.fx_vol))
	else:
		AudioServer.set_bus_volume_db(underwaterBusIndex, 0)
		AudioServer.set_bus_volume_db(waterBusIndex, -60)
	AudioServer.set_bus_effect_enabled(underwaterBusIndex, 0, value)
	AudioServer.set_bus_effect_enabled(underwaterBusIndex, 1, value)
	AudioServer.set_bus_effect_enabled(underwaterBusIndex, 2, value)

func _physics_process(_delta):
	if floatable:
		submerged = false
		var depth = water.get_height(global_position) - global_position.y
		if depth > 0:
			submerged = true

	if submerged:
		activate_underwater_effects(true)
	else:
		activate_underwater_effects(false)

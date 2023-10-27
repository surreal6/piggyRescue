@tool
class_name XRToolsFloatablePickable
extends XRToolsPickable

@onready var water : Node = get_tree().get_nodes_in_group("water")[0]

@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var probes = $ProbeContainer.get_children()


@export var floatable := true
@export var float_force := 10.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

var submerged := false

func _physics_process(_delta):
	if floatable:
		submerged = false
		if probes:
			for p in probes:
				var depth = water.get_height(p.global_position) - p.global_position.y
				if depth > 0:
					submerged = true
					var force = float_force * gravity * depth
					apply_force(Vector3.UP * force, p.global_position - global_position)

	if submerged:
		linear_damp = 0.2
		angular_damp = 0.2
	else:
		linear_damp = 0
		angular_damp = 0

func _integrate_forces(state: PhysicsDirectBodyState3D):
	if submerged and floatable:
		state.linear_velocity *= 1 - water_drag
		state.angular_velocity *= 1 - water_angular_drag

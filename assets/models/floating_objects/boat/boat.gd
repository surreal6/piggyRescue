extends StaticBody3D

signal pigCaptured

@onready var water = $"../water_mesh"
@onready var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity")
@onready var probes = $ProbeContainer.get_children()

@onready var main = $"../.."

@onready var pigs = $pigs.get_children()

@export var floatable := true
@export var float_force := 10.0
@export var water_drag := 0.05
@export var water_angular_drag := 0.05

@export var show_mask := true:
	set(value):
		show_mask = value
		if value:
			$boat_mask.show()
		else:
			$boat_mask.hide()

var submerged := false

var totalDepth := 0.0

var sL := Vector3.ZERO
var sR := Vector3.ZERO
var bL := Vector3.ZERO
var bR := Vector3.ZERO

func hide_pigs():
	for pig in pigs:
		pig.hide()

func update_pigs_in_boat():
	for pig in pigs:
		var number = int(pig.name.lstrip("pigmesh "))
		if number <= main.capturedPigs:
			pig.show()

func _ready():
	hide_pigs()
	show_mask = Globals.force_shadows

#func _process(delta):
#	if Globals.state == 3:
#		for pig in pigs:
#			var number = int(pig.name.lstrip("pigmesh "))
#			if number <= main.capturedPigs:
#				pig.show()
#	else:
#		hide_pigs()

func _physics_process(delta):
	totalDepth = 0.0
	sL = $ProbeContainer/Probe_sternLeft.global_position
	sR = $ProbeContainer/Probe_sternRight.global_position
	bL = $ProbeContainer/Probe_bowLeft.global_position
	bR = $ProbeContainer/Probe_bowRight.global_position
	
	if !water:
		return
	
	for p in probes:
		var depth = water.get_height(p.global_position) - p.global_position.y
		match p.name:
			"Probe_sternLeft" :
				sL.y = depth
			"Probe_sternRight" :
				sR.y = depth
			"Probe_bowLeft" :
				bL.y = depth
			"Probe_bowRight" :
				bR.y = depth
		totalDepth += depth
	
	var angleX = (sL.signed_angle_to(bL, transform.basis.z * Vector3(1.0, 0.0, 1.0)) + sR.signed_angle_to(bR, transform.basis.z * Vector3(1.0, 0.0, 1.0))) / 2
	var angleZ = (sL.signed_angle_to(sR, transform.basis.x * Vector3(1.0, 0.0, 1.0)) + bL.signed_angle_to(bR, transform.basis.x * Vector3(1.0, 0.0, 1.0))) / 2
	
	#print("dif %s" % str(bL.y - sL.y))
	#print("%s %s" % [str(sL.y).pad_decimals(2), str(bL.y).pad_decimals(2)])
	#print("-----   " + str(angleX).pad_decimals(1))
	#print("-----   " + str(angleZ).pad_decimals(1))
	#print(transform.basis.z * Vector3(1.0, 0.0, 1.0))
	
	$ProbeContainer.rotation = Vector3.ZERO
	
	totalDepth *= 0.25
	position.y += totalDepth
#	global_rotation_degrees.x = angleX
#	global_rotation_degrees.z = angleZ
	rotation.x = lerp_angle(rotation.x, angleX, delta)
	rotation.z = lerp_angle(rotation.z, angleZ, delta)
	
	#$ProbeContainer.global_rotation.x = lerp_angle($ProbeContainer.global_rotation.x, 0, delta)

func _on_pig_detector_area_3d_body_entered(body):
	if body is Pig:
		pigCaptured.emit()
		body.disable_pig()
		update_pigs_in_boat()

func win_explosion():
	$GPUParticles3D.emitting = true

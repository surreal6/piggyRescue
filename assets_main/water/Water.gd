@tool
extends MeshInstance3D

var noise: Image = preload("res://assets_main/water/water_wave.tres").noise.get_seamless_image(512, 512)

const waterMaterial = preload("res://assets_main/water/water_shader_material_buoyancy.tres")
const waterLimitMaterial = preload("res://assets_main/water/water_limit_material.tres")
const waterBasicMaterial = preload("res://assets_main/water/water_basic_material.tres")

@export var basic_material : bool = false:
	set(value):
		basic_material = value
		if value:
			set_material_override(waterBasicMaterial)
		else:
			set_material_override(waterMaterial)

@export_range (0.0, 50.0) var noise_scale : float = 10.0:
	set(value):
		noise_scale = value
		RenderingServer.global_shader_parameter_set("w_noise_scale", noise_scale)
		updateValues()
@export_range (0.0, 2.0) var wave_speed: float = 0.2:
	set(value):
		wave_speed = value
		RenderingServer.global_shader_parameter_set("w_wave_speed", wave_speed)
		updateValues()
@export_range (0.0, 1.5) var height_scale: float = 0.15:
	set(value):
		height_scale = value
		RenderingServer.global_shader_parameter_set("w_height_scale", height_scale)
		updateValues()

var wave_time: float = 0.0
	
func _ready():
	updateTime()
	updateValues()

func _process(delta):
	wave_time += delta
	updateTime()

func get_height(world_position: Vector3) -> float:
	var uv_x = wrapf(world_position.x / noise_scale + wave_time * wave_speed, 0, 1)
	var uv_y = wrapf(world_position.z / noise_scale + wave_time * wave_speed, 0, 1)

	var pixel_pos = Vector2(uv_x * noise.get_width(), uv_y * noise.get_height())
	return global_position.y + noise.get_pixelv(pixel_pos).r * height_scale;

func updateTime():
	RenderingServer.global_shader_parameter_set("w_wave_time", wave_time)

func updateValues():
	# ocean border 
	waterLimitMaterial.set_shader_parameter("noise_scale", noise_scale)
	waterLimitMaterial.set_shader_parameter("wave_speed", wave_speed)
	waterLimitMaterial.set_shader_parameter("height_scale", height_scale)
	waterLimitMaterial.set_shader_parameter("wave_time", wave_time)
	

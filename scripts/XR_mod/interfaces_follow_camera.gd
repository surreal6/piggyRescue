extends Node3D

## If true, the screen follows the camera
@export var follow_camera : bool = true: set = set_follow_camera

## Curve for following the camera
@export var follow_speed : Curve

# Camera to track
@onready var _camera : XRCamera3D = XRHelpers.get_xr_camera(self)


var rotate = true

func _ready():
	set_camera(_camera)
	_update_follow_camera()

func _process(delta):
	# Skip if in editor
	if Engine.is_editor_hint():
		return

	# Skip if no camera to track
	if !_camera:
		print("no camera")
		_update_follow_camera()
		return

	# Get the camera direction (horizontal only)
	var camera_dir := _camera.global_transform.basis.z
	camera_dir.y = 0.0
	camera_dir = camera_dir.normalized()

	# Get the loading screen direction
	var own_dir := global_transform.basis.z
	
	global_position = _camera.global_position

	# Get the angle
	var angle := own_dir.signed_angle_to(camera_dir, Vector3.UP)

	if abs(angle) < 0.1:
		rotate = false
	if !rotate and abs(angle) > 0.65:
		rotate = true

	if rotate:
		# Do rotation based on the curve
		global_transform.basis = global_transform.basis.rotated(
				Vector3.UP * sign(angle),
				follow_speed.sample_baked(abs(angle) / PI) * delta
		).orthonormalized()
	
	

## Set the camera to track
func set_camera(p_camera : XRCamera3D) -> void:
	_camera = p_camera
	_update_follow_camera()

## Set the follow_camera property
func set_follow_camera(p_enabled : bool) -> void:
	follow_camera = p_enabled
	_update_follow_camera()

func _update_follow_camera():
	if _camera and !Engine.is_editor_hint():
		set_process(follow_camera)

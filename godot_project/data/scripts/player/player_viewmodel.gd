extends Node3D

@export var player_camera: Camera3D

@export_group("Viewmodel Rotation")
@export_range(1.0, 60.0, 1.0) var rotation_smoothing: float = 35.0
@export_range(0.0, 10.0, 0.5) var mouse_tilt: float = 2.0
@export_range(1.0, 30.0, 1.0) var tilt_smoothing: float = 12.0

@export_group("Viewmodel Rotation Limits")
@export_range(1.0, 90.0, 1.0) var max_yaw_difference: float = 10.0
@export_range(1.0, 90.0, 1.0) var max_pitch_difference: float = 10.0

@export_group("Viewmodel Scale")
@export var view_model_offset: Vector3:
	set(value):
		view_model_offset = value
		apply_viewmodel_scale()

@export var viewmodel_scale: float = 0.1:
	set(value):
		viewmodel_scale = value
		apply_viewmodel_scale()

@export_range(1.0, 179.0, 1.0) var viewmodel_fov: float = 60.0:
	set(value):
		viewmodel_fov = value
		apply_viewmodel_scale()

var original_child_transforms: Dictionary = {}
var target_tilt: float = 0.0
var previous_camera_yaw: float = 0.0
var camera_rotation_initialized: bool = false

func _ready() -> void:
	top_level = true
	
	for child in get_children():
		if child is Node3D:
			original_child_transforms[child] = {
				"position": child.position,
				"scale": child.scale
			}
	
	apply_viewmodel_scale()

func _physics_process(delta: float) -> void:
	if not is_instance_valid(player_camera):
		return

	global_position = player_camera.global_position
	apply_rotation(delta)

func apply_rotation(delta: float) -> void:
	var camera_rotation: Vector3 = player_camera.global_rotation

	if not camera_rotation_initialized:
		global_rotation = camera_rotation
		previous_camera_yaw = camera_rotation.y
		camera_rotation_initialized = true
		return

	var yaw_delta: float = wrapf(
		camera_rotation.y - previous_camera_yaw,
		-PI,
		PI
	)

	previous_camera_yaw = camera_rotation.y

	var max_tilt: float = deg_to_rad(mouse_tilt)
	var target_roll: float = clampf(
		-yaw_delta * mouse_tilt,
		-max_tilt,
		max_tilt
	)

	target_tilt = lerpf(
		target_tilt,
		target_roll,
		1.0 - exp(-tilt_smoothing * delta)
	)

	var weight: float = 1.0 - exp(-rotation_smoothing * delta)

	var smoothed_rotation := Vector3(
		lerp_angle(global_rotation.x, camera_rotation.x, weight),
		lerp_angle(global_rotation.y, camera_rotation.y, weight),
		lerp_angle(global_rotation.z, camera_rotation.z, weight)
	)

	var max_pitch: float = deg_to_rad(max_pitch_difference)
	var max_yaw: float = deg_to_rad(max_yaw_difference)

	var pitch_difference: float = wrapf(
		smoothed_rotation.x - camera_rotation.x,
		-PI,
		PI
	)

	var yaw_difference: float = wrapf(
		smoothed_rotation.y - camera_rotation.y,
		-PI,
		PI
	)

	global_rotation = Vector3(
		camera_rotation.x + clampf(
			pitch_difference,
			-max_pitch,
			max_pitch
		),
		camera_rotation.y + clampf(
			yaw_difference,
			-max_yaw,
			max_yaw
		),
		smoothed_rotation.z + target_tilt
	)


func apply_viewmodel_scale() -> void:
	if not is_node_ready() or not is_instance_valid(player_camera):
		return

	var fov_scale: float = viewmodel_fov / player_camera.fov

	for child in original_child_transforms:
		if not is_instance_valid(child):
			continue

		var original: Dictionary = original_child_transforms[child]
		var original_position: Vector3 = original["position"]
		var original_scale: Vector3 = original["scale"]

		child.position = original_position + view_model_offset * viewmodel_scale
		child.scale = Vector3(
			original_scale.x * viewmodel_scale,
			original_scale.y * viewmodel_scale,
			original_scale.z * viewmodel_scale * fov_scale
		)

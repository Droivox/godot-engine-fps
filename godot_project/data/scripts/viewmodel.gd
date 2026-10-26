extends SubViewportContainer

@export var view_model_fov : int = 60;
@export var player_camera : Camera3D;
@export var viewmodel_camera : Camera3D;

@export var view_model_offset : Vector3;

@export var arms_animation_tree : AnimationTree;
@export var weapon_animation_tree : AnimationTree;

var glock_17_fire : AudioStreamOggVorbis = load("res://data/sounds/weapons/glock_17/fire.ogg")

func _ready() -> void:
	top_level = true;

func _process(_delta: float) -> void:
	if Input.is_action_pressed("MB_RIGHT"):
		Engine.time_scale = 0.1;
	else:
		Engine.time_scale = 1.0;
	
	if Input.is_action_just_pressed("MB_LEFT"):
		playback_set(
			"parameters/OneShot/request",
			AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
		);
		
		AudioPlayer.play(
			glock_17_fire,
			viewmodel_camera.global_position,
			1.0,
			false,
			true
		)

func fire() -> void:
	AudioPlayer.play(
		glock_17_fire,
		viewmodel_camera.global_position,
		1.0,
		false,
		true
	)

func playback_set(parameter: String, request: int) -> void:
	arms_animation_tree.set(parameter, request);
	weapon_animation_tree.set(parameter, request);

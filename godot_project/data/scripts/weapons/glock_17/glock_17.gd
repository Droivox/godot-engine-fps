extends Node3D

@export var arms_and_weapon : ArmsAndWeapon;
@export var muzzle_point : Node3D;

@export var muzzle_flash : Sprite3D;
@export var muzzle_flash_light : OmniLight3D;

@export var max_ammo : int = 12;
@export var current_ammo : int = max_ammo;

@export var bullet_hole_scene : PackedScene;

const STATES = {
	IN = "IN",
	OUT = "OUT",
	IDLE = "IDLE",
	FIRE = "FIRE",
	FIRE_EMPTY = "FIRE_EMPTY",
	INSPECT = "INSPECT",
	RELOAD = "RELOAD",
}

var current_state: String = STATES.IDLE;

func _ready() -> void:
	muzzle_flash.visible = false;
	muzzle_flash_light.visible = false;
	
	change_state("IDLE");

func _process(_delta: float) -> void:
	Debug.draw_string(
		"GLOCK_17_STATE", current_state
	)
	
	Debug.draw_string(
		"GLOCK_17_CURRENT_AMMO", current_ammo
	)
	
	if Input.is_action_pressed("MB_LEFT"):
		if arms_and_weapon:
			if current_state != STATES.IDLE: return;
			
			if current_ammo <= 0:
				arms_and_weapon.playback_set(
					"parameters/fire_transition/transition_request",
					"empty"
				)
			else:
				arms_and_weapon.playback_set(
					"parameters/fire_transition/transition_request",
					"normal"
				)
				
				Global.effects.draw_bullet_hole(bullet_hole_scene, 0.2);
				
				current_ammo -= 1;
				
				fire_effects();
			
			arms_and_weapon.playback_set(
				"parameters/Fire/request",
				AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			)
	
	if Input.is_action_pressed("KEY_R"):
		if not current_state in [STATES.IDLE, STATES.FIRE, STATES.FIRE_EMPTY]:
			return
		
		arms_and_weapon.playback_set(
			"parameters/Fire/request",
			AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
		)
		
		arms_and_weapon.playback_set(
				"parameters/Reload/request",
				AnimationNodeOneShot.ONE_SHOT_REQUEST_FIRE
			)
	
	if Input.is_action_pressed("KEY_F"):
		if not current_state in [STATES.IDLE]:
			return
		
		arms_and_weapon.playback_set(
			"parameters/Fire/request",
			AnimationNodeOneShot.ONE_SHOT_REQUEST_FADE_OUT
		)
		
		arms_and_weapon.playback_set(
			"parameters/Transition/transition_request",
			"INSPECT"
		)

func reload() -> void:
	current_ammo = max_ammo;

func fire_effects() -> void:
	var front_point : Vector3;
	front_point = Global.player_camera.global_position;
	front_point -= Global.player_camera.global_basis.z.normalized() * 10.0;
	
	Global.effects.draw_bullet_tracer(
		muzzle_point.global_position,
		front_point,
		Color.ORANGE,
		0.01
	);
	
	muzzle_flash.rotation_degrees.z = randf_range(
		0, 360
	);
	
	muzzle_flash.visible = true;
	muzzle_flash_light.visible = true;
	
	for x in range(5):
		await get_tree().process_frame;
	
	muzzle_flash.visible = false;
	muzzle_flash_light.visible = false;

func change_state(state: String) -> void:
	if not STATES.keys().has(state):
		return
	
	current_state = STATES[state];
	
	match current_state:
		STATES.IDLE:
			arms_and_weapon.playback_set(
				"parameters/Transition/transition_request",
				"IDLE"
			)

func play_audio(audio_path : String, volume : float = 1.0) -> void:
	AudioPlayer.play(
		load(audio_path),
		muzzle_point.global_position,
		volume,
		false,
		true
	);

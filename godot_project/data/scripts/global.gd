extends Node

var master_volume : float = 0.5;
var walking_speed : float = 3.5;
var running_speed : float = 5.0;
var crouch_speed : float = 3.0;
var sensitivity : float = 0.2;
var jump_height : float = 4.0;
var airaccelerate : float = 0.3;
var max_airaccelerate : float = 3.0;
var ladder_jump_height : float = 2.0;
var ladder_speed : float = 5.0;
var noclip_speed : float = 3.0;

var gravity : float = ProjectSettings.get_setting("physics/3d/default_gravity");
var node : Dictionary = {};

var player : PlayerController;
var player_camera : PlayerControllerCamera;

var debug : bool = false

var effects : Effects = Effects.new();

var reset : bool = false: 
	set(value):
		reload_current_scene();
	get:
		return noclip;

var noclip : bool = false: 
	set(value):
		noclip = value;
	get:
		return noclip;

func _ready() -> void:
	add_child(effects);
	
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), linear_to_db(master_volume));

func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("reset"):
		reset = !reset;
	
	if Input.is_action_just_pressed("KEY_ESCAPE"):
		debug = !debug;
		
		match debug:
			true:
				Input.mouse_mode = Input.MOUSE_MODE_VISIBLE;
			false:
				Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;

func reload_current_scene():
	get_tree().reload_current_scene();

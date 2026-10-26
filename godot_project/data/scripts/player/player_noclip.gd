extends Node
class_name PlayerControllerNoclip

var noclip_speed_multiply : float = 1.0;
var velocity : Vector3;

@export var noclip_default_speed : float = 4.0;

var player : PlayerController;

func _init(_player : PlayerController) -> void:
	self.player = _player;

func noclip(_delta) -> void:
	var direction = Vector3.ZERO;
	
	var _basis : Basis = self.PlayerController.get_viewport().get_camera_3d().global_basis;
	var WS : float = Input.get_axis("KEY_W", "KEY_S");
	var AD : float = Input.get_axis("KEY_A", "KEY_D");
	
	direction += _basis.z * WS;
	direction += _basis.x * AD;
	
	direction = direction.normalized();
	
	if Input.is_action_pressed("NOCLIP_UP"):
		direction += Vector3.UP;
	if Input.is_action_pressed("NOCLIP_DOWN"):
		direction += Vector3.DOWN;
	
	var noclip_speed = Global.noclip_speed * noclip_speed_multiply;
	
	PlayerController.velocity.x = lerpf(PlayerController.velocity.x, direction.x * noclip_speed, 30.0 * _delta);
	PlayerController.velocity.z = lerpf(PlayerController.velocity.z, direction.z * noclip_speed, 30.0 * _delta);
	PlayerController.velocity.y = lerpf(PlayerController.velocity.y, direction.y * noclip_speed, 30.0 * _delta);
	
	var mbwp = float(Input.is_action_just_pressed("MOUSE_BUTTON_WHEEL_UP"));
	var mbwd = float(Input.is_action_just_pressed("MOUSE_BUTTON_WHEEL_DOWN"));
	
	noclip_speed_multiply += 0.3 * (mbwp - mbwd);
	noclip_speed_multiply = clampf(noclip_speed_multiply, 0.0, 10.0);

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_UP:
			noclip_speed_multiply += 0.1;
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			noclip_speed_multiply -= 0.1;
		
		noclip_speed_multiply = clampf(noclip_speed_multiply, 0.1, 3.0);

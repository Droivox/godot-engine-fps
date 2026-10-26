extends Node3D
class_name Head;

@export var player : PlayerController;
@export var max_head_angle : float = 85.0;
@export var player_collision : CollisionShape3D;

@onready var shape_height : float = snappedf(player_collision.shape.height * 0.9, 0.1);

var target_y : float;

@export var camera : Camera3D;

func _ready() -> void:
	target_y = player.position.y + shape_height;
	
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED;
	top_level = true;

func _physics_process(_delta: float) -> void:
	shape_height = lerpf(shape_height, snappedf(player_collision.shape.height * 0.9, 0.1), 5.0 * _delta);
	target_y = player.position.y + shape_height;
	position.y = target_y;
	position.x = player.position.x;
	position.z = player.position.z;

func _process(_delta: float) -> void:
	pass

func camera_rotation(_event) -> void:
	if _event is InputEventMouseMotion:
		if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
			rotation.x += -deg_to_rad(_event.relative.y * Global.sensitivity);
			rotation.y += -deg_to_rad(_event.relative.x * Global.sensitivity);
			rotation.x = clampf(rotation.x, deg_to_rad(-(max_head_angle * 0.95)), deg_to_rad(max_head_angle));

func _input(_event) -> void:
	if player.player_state.get_current_state() != "disabled":
		camera_rotation(_event);

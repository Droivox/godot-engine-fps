extends Node;
class_name PlayerControllerMovement;

var player : PlayerController;
var direction : Vector3;

var crouch_height : float = 1.0;
var timer_to_reset_airccelerate : float;
var fall_velocity : float = 0.0;

func _init(_player : PlayerController) -> void:
	self.player = _player;

func movement(_speed : float, _acceleration : float, _deceleration: float, _delta: float):
	direction = Vector3.ZERO;
	
	var input = Input.get_vector("left", "right", "forward", "backward");
	var _basis = player.get_viewport().get_camera_3d().global_basis;
	
	direction = _basis * Vector3(input.x, 0.0, input.y);
	direction.y = 0; player.direction = direction;
	direction = direction.normalized();
	
	if player.is_on_floor():
		timer_to_reset_airccelerate += _delta;
		
		if input:
			player.velocity.x = lerpf(player.velocity.x, direction.x * _speed, _acceleration * _delta);
			player.velocity.z = lerpf(player.velocity.z, direction.z * _speed, _acceleration * _delta);
		else:
			if timer_to_reset_airccelerate > 0.2:
				var friction : float = _deceleration;
				player.velocity.x = lerpf(player.velocity.x, 0.0, friction * _delta);
				player.velocity.z = lerpf(player.velocity.z, 0.0, friction * _delta);
	else:
		fall_velocity = player.velocity.y;
		timer_to_reset_airccelerate = 0.0;
		var accel = player.velocity.length() * Global.airaccelerate;
		accel = min(accel, Global.max_airaccelerate);
		player.velocity = accelerate(direction, accel, _delta);
	
	if Input.is_action_pressed("crouch"):
		player.player_collision.shape.height = crouch_height;
		player.player_collision.position.y = crouch_height / 2.0;
	else:
		if not player.head_check.is_colliding():
			player.player_collision.shape.height = 1.8;
			player.player_collision.position.y = 1.8 / 2.0;

func accelerate(_direction: Vector3, max_velocity: float, _delta: float) -> Vector3:
	var current_speed : float = player.velocity.dot(_direction);
	var add_speed : float = max(max_velocity - current_speed, 0);
	return player.velocity + add_speed * _direction;

extends Node;
class_name PlayerControllerLadder;

var player : PlayerController;
var ladder_normal : Vector3;

func _init(_player) -> void:
	self.player = _player;

func ladder(_delta) -> void:
	player.direction = Vector3.ZERO;
	
	var _basis : Basis = self.player.get_viewport().get_camera_3d().global_basis;
	var WS : float = Input.get_axis("KEY_W", "KEY_S");
	var AD : float = Input.get_axis("KEY_A", "KEY_D");
	
	player.direction += _basis.z * WS;
	player.direction += _basis.x * AD;
	player.direction.y = 0;
	player.direction = player.direction.normalized();
	
	if player.get_wall_normal().normalized():
		ladder_normal = player.get_wall_normal().normalized();
	
	var dot_product : float = player.direction.dot(ladder_normal)
	
	player.velocity -= ladder_normal * 0.1;
	
	var angle : float = player.get_viewport().get_camera_3d().global_basis.z.dot(ladder_normal);
	
	if not player.is_on_floor():
		if abs(dot_product) > 0.9:
			if abs(WS) > 0.0:
				var camera_rotation : Vector3 = player.get_viewport().get_camera_3d().global_rotation;
				var up_down_speed : float = Global.ladder_speed;
				
				up_down_speed = Global.ladder_speed * dot_product * -sign(angle * camera_rotation.x);
				player.velocity.y = lerpf(player.velocity.y, up_down_speed, 10.0 * _delta);
			else:
				if dot_product > 0:
					player.velocity.y = lerpf(player.velocity.y, -Global.ladder_speed, 10.0 * _delta);
				else:
					player.velocity.y = lerpf(player.velocity.y, Global.ladder_speed, 10.0 * _delta);
			
			player.velocity.x = lerpf(player.velocity.x, 0, 10.0 * _delta);
			player.velocity.z = lerpf(player.velocity.z, 0, 10.0 * _delta);
		else:
			player.velocity.x = lerpf(player.velocity.x, player.direction.x * Global.ladder_speed, 10.0 * _delta);
			player.velocity.z = lerpf(player.velocity.z, player.direction.z * Global.ladder_speed, 10.0 * _delta);
			player.velocity.y = lerpf(player.velocity.y, 0, 10.0 * _delta);
	else:
		if dot_product < 0.3:
			var camera_rotation : Vector3 = player.get_viewport().get_camera_3d().global_rotation;
			var up_down_speed : float = Global.ladder_speed;
			up_down_speed = Global.ladder_speed * dot_product * -clampf(camera_rotation.x, -1.0, 1.0);
			player.velocity.y = lerpf(player.velocity.y, up_down_speed, 10.0 * _delta);
			
		else:
			player.velocity.x = lerpf(player.velocity.x, player.direction.x * Global.ladder_speed, 10.0 * _delta);
			player.velocity.z = lerpf(player.velocity.z, player.direction.z * Global.ladder_speed, 10.0 * _delta);
			player.velocity.y = lerpf(player.velocity.y, 0, 10.0 * _delta);
	
	if Input.is_action_just_pressed("KEY_SPACE"):
		if angle > 0.5:
			player.velocity = Vector3.ZERO;
			player.velocity += Vector3(0, Global.ladder_jump_height, 0) + (ladder_normal * 10.0);
		else:
			player.velocity = Vector3.ZERO;
			player.velocity += Vector3(0, Global.ladder_jump_height, 0) + -player.get_viewport().get_camera_3d().global_basis.z * 10.0;

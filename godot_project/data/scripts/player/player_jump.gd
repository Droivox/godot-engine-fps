extends Node
class_name PlayerControllerJump;

var player : PlayerController;

func _init(_player : PlayerController) -> void:
	self.player = _player;

func jump() -> void:
	if player.is_on_ground() and Input.is_action_just_pressed("KEY_SPACE"):
		player.player_state.change_state("jumping")
		self.player.velocity.y = Global.jump_height;

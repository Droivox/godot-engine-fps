extends Area3D
class_name LadderArea

func _ready() -> void:
	body_entered.connect(_bodie_entered);
	body_exited.connect(_bodie_exited);

func _bodie_entered(_bodie) -> void:
	if _bodie is PlayerController:
		var player = _bodie;
		if player.PlayerController_state.get_current_state() != "noclip":
			player.PlayerController_state.change_state("ladder");

func _bodie_exited(_bodie) -> void:
	if _bodie is PlayerController:
		var player = _bodie;
		
		if player.PlayerController_state.get_current_state() != "noclip":
			if player.is_on_floor():
				player.PlayerController_state.change_state("idle");
			else:
				player.PlayerController_state.change_state("falling");

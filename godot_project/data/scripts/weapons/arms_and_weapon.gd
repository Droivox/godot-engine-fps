extends Node3D
class_name ArmsAndWeapon

@export var arms_animation_tree : AnimationTree
@export var weapon_animation_tree : AnimationTree

func playback_set(parameter: String, request: Variant) -> void:
	if is_instance_valid(arms_animation_tree):
		arms_animation_tree.set(parameter, request)
	
	if is_instance_valid(weapon_animation_tree):
		weapon_animation_tree.set(parameter, request)

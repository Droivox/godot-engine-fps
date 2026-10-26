extends Node3D

@export var debug_material : Material;

func _ready() -> void:
	for child in get_children():
		if child is MeshInstance3D:
			child.create_trimesh_collision();
			
			if "_stair" in child.name:
				child.material_override = debug_material.duplicate(true);
				child.material_override.albedo_color = Color("#ffa126");
			else:
				child.material_override = debug_material.duplicate(true);
				child.material_override.albedo_color = Color("#434343");

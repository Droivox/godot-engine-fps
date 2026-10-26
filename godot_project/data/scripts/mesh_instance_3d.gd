extends MeshInstance3D

@export var lightmap_texel_size = 0.4

func process_uv2():
	var old_mesh = mesh as Mesh
	mesh = ArrayMesh.new()

	for surface_id in range(old_mesh.get_surface_count()):
		mesh.add_surface_from_arrays(
			Mesh.PRIMITIVE_TRIANGLES, 
			old_mesh.surface_get_arrays(surface_id)
		)
		var old_mat = old_mesh.surface_get_material(surface_id)
		mesh.surface_set_material(surface_id, old_mat)

	mesh.lightmap_unwrap(global_transform, lightmap_texel_size)

func _ready():
	process_uv2()

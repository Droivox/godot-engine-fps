extends Node
class_name Effects;

func draw_bullet_tracer(p1: Vector3, p2: Vector3, color: Color = Color.RED, hold_duration: float = 0.0, travel_duration: float = 0.1) -> void:
	var mesh_instance := MeshInstance3D.new()
	var mesh := ImmediateMesh.new()

	var material: ShaderMaterial = load(
		"res://data/materials/bullet_tracer.material"
	)
	
	material.set_shader_parameter(
		"color",
		color
	);

	mesh_instance.mesh = mesh
	mesh_instance.top_level = true
	mesh_instance.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	get_tree().root.add_child(mesh_instance)

	mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
	mesh.surface_add_vertex(p1)
	mesh.surface_add_vertex(p2)
	mesh.surface_end()

	var tween := create_tween()

	if hold_duration > 0.0:
		tween.tween_interval(hold_duration)

	tween.tween_method(func(progress: float) -> void:
		mesh.clear_surfaces()
		mesh.surface_begin(Mesh.PRIMITIVE_LINES, material)
		mesh.surface_add_vertex(p1.lerp(p2, progress))
		mesh.surface_add_vertex(p2)
		mesh.surface_end()
	, 0.0, 1.0, travel_duration)

	tween.tween_callback(mesh_instance.queue_free)



func draw_bullet_hole(
	bullet_hole_scene: PackedScene,
	scale: float = 0.2
) -> Decal:
	if not is_instance_valid(Global.player_camera):
		return null

	var camera: Camera3D = Global.player_camera
	var origin: Vector3 = camera.global_position
	var direction: Vector3 = -camera.global_basis.z.normalized()
	var end: Vector3 = origin + direction * 1000.0

	var query := PhysicsRayQueryParameters3D.create(origin, end)
	query.exclude = [camera.get_parent()]

	var hit: Dictionary = camera.get_world_3d().direct_space_state.intersect_ray(query)

	if hit.is_empty():
		return null

	var point: Vector3 = hit["position"]
	var normal: Vector3 = hit["normal"].normalized()

	var bullet_hole: Decal = bullet_hole_scene.instantiate()
	get_tree().root.get_child(0).add_child(bullet_hole)

	var forward: Vector3 = -normal
	var right: Vector3 = camera.global_basis.x
	right = (right - forward * right.dot(forward)).normalized()

	if right.length_squared() < 0.001:
		right = forward.cross(Vector3.UP).normalized()

	var up: Vector3 = right.cross(forward).normalized()

	var decal_basis := Basis(right, forward, up).orthonormalized()

	bullet_hole.global_transform = Transform3D(
		decal_basis,
		point + normal * 0.01
	)

	bullet_hole.size = Vector3.ONE * scale

	return bullet_hole

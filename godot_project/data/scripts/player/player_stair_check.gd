extends ShapeCast3D
class_name StairCheck;

@export var player : PlayerController;
@export var collision : CollisionShape3D;

@export var max_stair_distance : float = 0.2;

func _ready() -> void:
	add_exception(player);

func _physics_process(_delta: float) -> void:
	force_update_transform();
	
	position.y = max_stair_distance + shape.radius;
	target_position.y = -max_stair_distance;
	
	var direction = player.direction.normalized();
	
	position.x = direction.x * collision.shape.radius;
	position.z = direction.z * collision.shape.radius;
	
	if is_colliding():
		var distance = abs(player.position.y - get_collision_point(0).y);
		
		var normal = get_collision_normal(0);
		
		if distance < max_stair_distance and normal.y > 0.95:
			if direction.length():
				player.position.y = get_collision_point(0).y;

func is_on_stair() -> bool:
	if is_colliding():
		return true;
	else:
		return false;

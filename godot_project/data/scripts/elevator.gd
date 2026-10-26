extends CharacterBody3D

enum STATUS {
	UP,
	DOWN,
}

var current_status : STATUS = STATUS.DOWN;

func _process(delta: float) -> void:
	current_status = STATUS.DOWN;
	
	match current_status:
		STATUS.UP:
			velocity.y -= 5 * delta;
		STATUS.DOWN:
			velocity.y += 5 * delta;
	
	move_and_slide();

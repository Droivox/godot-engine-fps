extends CharacterBody3D
class_name PlayerController;

var states : Array = [
	"idle",
	"walking",
	"running",
	"crouch",
	"ladder",
	"jumping",
	"falling",
	"landing",
	"noclip",
	"disabled"
];

@export var head_check : ShapeCast3D;
var player_state = StateController.new(states);

var direction : Vector3;

var noclip = PlayerControllerNoclip.new(self);
var movement = PlayerControllerMovement.new(self);
var jump = PlayerControllerJump.new(self);
var ladder = PlayerControllerLadder.new(self);

@export var player_collision : CollisionShape3D;
@export var feet : ShapeCast3D;

func _init() -> void:
	Global.player = self;

func _physics_process(_delta: float) -> void:
	handle_state_changes();
	
	match player_state.get_current_state():
		"noclip":
			set_collision_mask_value(1, false);
			noclip.noclip(_delta);
			move_and_slide();
		"idle", "walking":
			set_collision_mask_value(1, true);
			movement.movement(Global.walking_speed, 8.0, 6.0, _delta);
			jump.jump();
			move_and_slide();
			apply_gravity(_delta);
		"running":
			movement.movement(Global.running_speed, 6.0, 6.0, _delta);
			apply_gravity(_delta);
			jump.jump(); 
			move_and_slide();
		"jumping":
			movement.movement(Global.walking_speed, 8.0, 6.0, _delta);
			move_and_slide();
			apply_gravity(_delta);
		"crouch":
			movement.movement(Global.walking_speed, 8.0, 6.0, _delta);
			move_and_slide();
			if not head_check.is_colliding():
				jump.jump();
			apply_gravity(_delta);
		"falling":
			movement.movement(Global.walking_speed, 8.0, 6.0, _delta);
			apply_gravity(_delta);
			move_and_slide();
		"landing":
			movement.movement(Global.walking_speed, 8.0, 4.0, _delta);
			apply_gravity(_delta);
			move_and_slide();
		"ladder":
			ladder.ladder(_delta);
			move_and_slide();

func handle_state_changes():
	match player_state.get_current_state():
		"idle":
			if (get_real_velocity() * Vector3(1, 0, 1)).length() > 1.0:
				player_state.change_state("walking");
			
			if Input.is_action_pressed("KEY_CTRL"):
				player_state.change_state("crouch");
		"walking":
			if (get_real_velocity() * Vector3(1, 0, 1)).length() < 1.0:
				player_state.change_state("idle");
			
			if Input.is_action_pressed("KEY_SHIFT"):
				player_state.change_state("running");
			
			if Input.is_action_pressed("KEY_CTRL"):
				player_state.change_state("crouch");
		"crouch":
			if not Input.is_action_pressed("KEY_CTRL") and not head_check.is_colliding():
				player_state.change_state("idle");
		"running":
			if not Input.is_action_pressed("KEY_SHIFT"):
				player_state.change_state("walking");
		"jumping":
			if not get_real_velocity().y:
				player_state.change_state("falling");
			
			if is_on_floor():
				player_state.change_state("idle");
		"falling":
			if is_on_floor():
				player_state.change_state("landing");
		"landing":
			if is_on_floor():
				player_state.change_state("idle");

func apply_gravity(_delta) -> void:
	if not is_on_floor():
		velocity.y -= Global.gravity * _delta;

func is_on_ground() -> bool:
	return is_on_floor();

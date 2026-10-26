extends Camera3D;
class_name PlayerControllerCamera;

@export var player : PlayerController;
@export var player_head : Head;

var neck_animation_position : float = 0.0;
var neck_animation_length : float = 1.0;
var neck_animation_direction : float = 1.0;

var neck_start_position : Vector3;

@export var default_fov : float = 75;

@export var raycast : RayCast3D;

func _init() -> void:
	Global.player_camera = self;

func _ready() -> void:
	default_fov = fov;

func _physics_process(_delta: float) -> void:
	var state = player.player_state.get_current_state();
	match state:
		"idle", "walking", "crouch", "running":
			if state == "running":
				if round(player.get_real_velocity() * Vector3(1, 0, 1)).length():
					fov = lerpf(fov, default_fov * 1.1, 3.0 * _delta);
				else:
					fov = lerpf(fov, default_fov, 3.0 * _delta);
			else:
				fov = lerpf(fov, default_fov, 3.0 * _delta);
			
			var vel = Vector3(player.velocity.x, 0, player.velocity.z).length();
			neck_rotation_animation(3.0, 2.0, _delta);
			neck_walking_animation(vel * 0.2, 1.1, _delta);

func neck_rotation_animation(FBA : float, LRA : float, _delta : float) -> void:
	var head_basis : Basis = player_head.global_basis;
	var FB_basis : float = player.direction.dot(head_basis.z);
	var LR_basis : float = player.direction.dot(head_basis.x);
	
	var FBT_speed : float = FBA;
	var LRT_speed : float = FBA;
	
	var FBT_angle : float = LRA;
	var LRT_angle : float = LRA;
	
	var FBT : float = deg_to_rad(FB_basis * FBT_angle);
	var LRT : float = deg_to_rad(LR_basis * LRT_angle);
	
	rotation.x = lerp_angle(rotation.x, FBT, FBT_speed * _delta);
	rotation.z = lerp_angle(rotation.z, -LRT, LRT_speed * _delta);

func neck_walking_animation(force : float, speed : float, _delta : float) -> void:
	if player.is_on_floor():
		var velocity = player.velocity; velocity.y = 0;
		var neck_animation_speed : float = velocity.length() * speed * _delta;
		
		neck_animation_position += (neck_animation_direction * neck_animation_speed);
		
		if neck_animation_position >= neck_animation_length:
			neck_animation_direction = -1.0;
		
		if neck_animation_position <= 0.0:
			neck_animation_direction = 1.0;
		
		position.y = lerpf(position.y, (neck_animation_position - 0.5) * force, _delta);

var shake_tween : Tween;

func camera_shake(h : float, v : float, duration : float) -> void:
	v *= 0.1; h *= 0.1;
	
	if shake_tween and shake_tween.is_running():
		shake_tween.kill();

	shake_tween = create_tween();
	var original_position : Vector3 = position;
	var elapsed : float = 0.0;
	var interval : float = 0.035;

	while elapsed < duration:
		var step : float = minf(interval, duration - elapsed);
		var target : Vector3 = original_position + Vector3(
			randf_range(-h, h),
			randf_range(-v, v),
			0.0
		);

		shake_tween.tween_property(self, "position", target, step * 0.5);
		shake_tween.tween_property(self, "position", original_position, step * 0.5);

		elapsed += step;

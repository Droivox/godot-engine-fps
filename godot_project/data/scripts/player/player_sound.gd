extends Node3D;
class_name PlayerControllerSound;

@export var player : PlayerController;

@export var ladder_footsteep_metal : Array[AudioStream] = [];

@onready var footsteep = PlayerControllerFootsteep.new(player);
@onready var footsteep_ladder = PlayerControllerFootsteep.new(player);

func _ready() -> void:
	player.player_state.state_entered.connect(player_state_entered);
	player.player_state.state_exited.connect(player_state_exited);

func _process(_delta: float) -> void:
	match player.player_state.get_current_state():
		"walking", "running":
			if player.is_on_floor():
				footsteep.play(AudioLibrary.Entity.Player.FootSteep.Floor.all(), 0.1, _delta);
		"ladder":
			footsteep_ladder.play(ladder_footsteep_metal, 0.2, _delta);

func player_state_entered(_state) -> void:
	match _state:
		"jumping":
			var audio = AudioLibrary.Entity.Player.Jump.all();
			audio = audio.pick_random();
			AudioPlayer.play(audio, global_position, 2.0, false, true, 1.0);
		"landing":
			pass

func player_state_exited(_state) -> void:
	pass

func play_audio(audio_name : String) -> void:
	var audio : AudioStreamPlayer3D = get_node(audio_name);
	
	if audio:
		audio.pitch_scale = randf_range(0.8, 1.2);
		audio.play();

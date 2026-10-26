extends Node
class_name PlayerControllerFootsteep;

var footsteep_timer : float;
var player : PlayerController;

var playlist : Array;

var footsteep_audio : AudioStreamPlayer3D = AudioStreamPlayer3D.new();

func _init(_player : PlayerController) -> void:
	self.player = _player;
	player.call_deferred("add_child", footsteep_audio);

func play(_sounds : Array, _timer : float, _delta : float):
	if round(player.get_real_velocity() * Vector3(1, 1, 1)).length():
		footsteep_timer -= (0.1 + (player.get_real_velocity().length() * _timer)) * _delta;
		
		if footsteep_timer <= 0.0:
			if playlist.is_empty():
				playlist = _sounds.duplicate(true);
				playlist.shuffle();
			
			var sound = playlist[0];
			playlist.remove_at(0);
			
			footsteep_audio.stream = sound;
			footsteep_audio.pitch_scale = randf_range(0.9, 1.1);
			footsteep_audio.play();
			footsteep_timer = 0.2;
	else:
		footsteep_timer -= (0.5 + (player.get_real_velocity().length() * 0.1)) * _delta;

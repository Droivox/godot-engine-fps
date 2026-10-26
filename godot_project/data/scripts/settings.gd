extends Control

@export var volumeSlider: HSlider

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	volume_changer(volumeSlider.value)
	volumeSlider.value_changed.connect(volume_changer)

func volume_changer(volume: float) -> void:
	AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Musica"), linear_to_db(volume))

func _process(delta: float) -> void:
	pass

func _on_mute_toggled(toggled_on: bool) -> void:
	AudioServer.set_bus_mute(0,toggled_on)

func _input(event: InputEvent) -> void:
	pass

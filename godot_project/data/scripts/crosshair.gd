extends Node

var crosshair_size : float = 1.0;

var crosshair_texture : TextureRect = TextureRect.new();

func _ready() -> void:
	add_child(crosshair_texture);
	crosshair_texture.z_index = 1000;
	crosshair_texture.texture = load("res://data/textures/generic/generic_droivox_crosshair.png");
	set_crosshair_opacity(0.5);
	
	crosshair_texture.texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR;
	crosshair_texture.texture_repeat =CanvasItem.TEXTURE_REPEAT_DISABLED;

func _process(_delta: float) -> void:
	crosshair_texture.position = get_tree().root.get_viewport().size / 2.0;

func set_crosshair_scale(scale : float) -> void:
	crosshair_texture.scale = Vector2(scale, scale);

func set_crosshair_opacity(opacity : float) -> void:
	crosshair_texture.modulate.a = opacity;

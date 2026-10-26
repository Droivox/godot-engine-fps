extends CanvasLayer

@export var version : String = "0.0.1";
@export var info : Label;

var debug_toggle : bool = false;

var display : Dictionary;

func _process(_delta) -> void:
	debug();
	draw_update();
	draw_string("FPS", int(Engine.get_frames_per_second()));
	
	if Input.is_action_pressed("MB_RIGHT"):
		Engine.time_scale = 0.1;
	else:
		Engine.time_scale = 1.0;

func debug() -> void:
	if Input.is_action_just_pressed("debug_toggle"):
		info.visible = !info.visible;

func draw_string(screen_display_text : String, value) -> void:
	if not screen_display_text in display.keys():
		display[screen_display_text] = str(value);
	else:
		display[screen_display_text] = str(value);

func draw_update() -> void:
	if not is_instance_valid(info):
		return;
	
	info.text = "";
	
	for key in display.keys():
		info.text += " " + key + ": " + display[key] + "\n";
	
	display.clear();

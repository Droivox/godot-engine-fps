extends Node
class_name StateController;

var states : Array;
var current_state : String;

signal state_entered;
signal state_exited;
signal state_changed;

func _init(_states : Array) -> void:
	self.states = _states;
	current_state = states[0];

func change_state(state : String) -> void:
	if state in states:
		if current_state != state:
			state_entered.emit(state);
			state_exited.emit(current_state);
			state_changed.emit(current_state, state);
			current_state = state;

func get_current_state() -> String:
	return current_state;

extends Node

func _ready():
	assert(get_node_or_null("PlayerControllerStateMachine") != null, "PlayerControllerStateMachine não encontrado! O nó é obrigatório.")

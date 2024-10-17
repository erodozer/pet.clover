extends Node

func _process(delta: float) -> void:
	if GameState.is_node_ready():
		SceneManager.change_scene("home")

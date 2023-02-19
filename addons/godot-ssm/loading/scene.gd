extends Node

var advance_to

func _setup(params):
	var data = params[0]
	advance_to = params[1]
	for v in get_tree().get_nodes_in_group("Persist"):
		if v.has_method("restore"):
			v.restore(data)
	
func _start():
	SceneManager.call_deferred("change_scene", advance_to)

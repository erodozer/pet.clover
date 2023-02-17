extends Node2D

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


func _on_UIControls_action_pressed(action_type, is_pressed):
	match action_type:
		"light":
			if is_pressed:
				get_node("Foreground").play("lights_on")
			else:
				get_node("Foreground").play("lights_off")
		"bath":
			pass

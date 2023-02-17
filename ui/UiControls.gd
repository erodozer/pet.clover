extends CanvasLayer

signal action_pressed(action_type, is_pressed)

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_node("%Controls").get_children():
		button.connect("pressed", self, "_on_button_press", [button])

func _on_button_press(button):
	yield(get_tree(), "idle_frame") # wait a frame
	emit_signal("action_pressed", button.name.to_lower(), button.pressed)

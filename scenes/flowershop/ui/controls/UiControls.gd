extends CanvasLayer

signal action_pressed(action_type, is_pressed)

onready var clock = get_node("%Clock")
onready var label = get_node("%Label")
onready var clock_label = get_node("%CurrentTime")

# Called when the node enters the scene tree for the first time.
func _ready():
	for button in get_node("%Controls").get_children():
		button.connect("pressed", self, "_on_button_press", [button])
	clock.connect("pressed", self, "_on_clock_toggled")
	GameState.connect("stats_changed", self, "_update_stats")

func show_back():
	for button in get_node("%Controls").get_children():
		button.visible = false
	get_node("%Controls/Back").visible = true
	
func show_menu():
	for button in get_node("%Controls").get_children():
		button.visible = true
	get_node("%Controls/Back").visible = false

func _on_button_press(button):
	emit_signal("action_pressed", button.name.to_lower(), button.pressed)

func _on_clock_toggled():
	yield(get_tree(), "idle_frame") # wait a frame
	var pressed = clock.pressed
	label.visible = not pressed
	clock_label.visible = pressed
	
func set_hint_text(text):
	if not text:
		label.text = "Clover"
	else:
		label.text = text

func _update_stats(stats):
	get_node("%HoneyCounter").text = "%0d" % int(stats.honey)


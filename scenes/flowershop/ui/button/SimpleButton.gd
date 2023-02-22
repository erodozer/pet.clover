extends Button

onready var border_tex: AnimatedSprite = get_node("border")
onready var off_icon = get_node("icon_off")
onready var on_icon = get_node("icon_on")

export(String, "None", "eat", "bathe", "play", "medicine") var bind_to_timer = "None"

func _ready():
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")
	
func set_disabled(disabled):
	off_icon.visible = disabled
	on_icon.visible = not disabled
	
	.set_disabled(disabled)
	
func _toggled(button_pressed):
	if not is_inside_tree():
		return
	
	off_icon.visible = not button_pressed
	on_icon.visible = button_pressed

func _on_mouse_entered():
	grab_focus()

func _on_mouse_exited():
	if has_focus():
		call_deferred("release_focus")

func _on_focus_entered():
	border_tex.play("on")
	show_behind_parent = false
	
func _on_focus_exited():
	border_tex.play("off")
	yield(border_tex,"animation_finished")
	show_behind_parent = true

func _process(_delta):
	if bind_to_timer != "None":
		set_disabled(not GameState.can_act(bind_to_timer))

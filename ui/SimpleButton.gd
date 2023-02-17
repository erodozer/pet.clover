extends Button

onready var border_tex: AnimatedSprite = get_node("border")

func _ready():
	connect("focus_entered", self, "_on_focus_entered")
	connect("focus_exited", self, "_on_focus_exited")
	connect("mouse_entered", self, "_on_mouse_entered")
	connect("mouse_exited", self, "_on_mouse_exited")

func _toggled(button_pressed):
	get_node("icon_off").visible = not button_pressed
	get_node("icon_on").visible = button_pressed

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

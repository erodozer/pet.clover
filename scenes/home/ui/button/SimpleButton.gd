extends Button

@onready var border_tex: AnimatedSprite2D = get_node("border")
@onready var off_icon = get_node("icon_off")
@onready var on_icon = get_node("icon_on")

@export_enum("None", "eat", "bathe", "play", "medicine") var bind_to_timer = "None"
@export_enum("None", "food", "game", "stats") var submenu = "None"
@export var unlockable: String

func _ready():
	connect("focus_entered", Callable(self, "_on_focus_entered"))
	connect("focus_exited", Callable(self, "_on_focus_exited"))
	connect("mouse_entered", Callable(self, "_on_mouse_entered"))
	connect("mouse_exited", Callable(self, "_on_mouse_exited"))
	
func disable_action(state):
	off_icon.visible = state
	on_icon.visible = not state
	mouse_default_cursor_shape = CURSOR_ARROW if state else CURSOR_POINTING_HAND
	focus_mode = FOCUS_NONE if state else FOCUS_ALL
	set_disabled(state)
	
func _toggled(is_pressed):
	if not is_inside_tree():
		return
	
	off_icon.visible = not is_pressed
	on_icon.visible = is_pressed

func _on_mouse_entered():
	if not disabled:
		grab_focus()

func _on_mouse_exited():
	if has_focus():
		call_deferred("release_focus")

func _on_focus_entered():
	border_tex.play("on")
	show_behind_parent = false
	
func _on_focus_exited():
	border_tex.play("off")
	await border_tex.animation_finished
	show_behind_parent = true

func _process(_delta):
	if bind_to_timer != "None":
		disable_action(not GameState.can_act(bind_to_timer, unlockable))
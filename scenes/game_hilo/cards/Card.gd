extends Button

@export var number = 1: set = _set_card_shape

@onready var front = get_node("%Front")
@onready var back = get_node("%Back")

func _ready():
	front.get_node("Number").text = "%d" % number
	front.visible = false

func _set_card_shape(value):
	number = value
	if not is_inside_tree():
		return
	front.get_node("Number").text = "%d" % number

func _toggled(pressed):
	disabled = pressed # prevent double flipping

	var tween = create_tween()
	
	tween.tween_property(self, "scale:x", 0.0, 0.1).from(1.0)
	
	await tween.finished
	
	front.visible = pressed
	back.visible = not pressed
	
	tween = create_tween()
	tween.tween_property(self, "scale:x", 1.0, 0.1).from(0.0)
	
	await tween.finished

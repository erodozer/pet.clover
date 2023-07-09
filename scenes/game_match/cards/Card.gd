extends Button

@export_enum("circle", "square", "star", "triangle") var shape = "square": set = _set_card_shape

@onready var front = get_node("%Front")
@onready var back = get_node("%Back")

func _ready():
	front.texture = load("res://scenes/game_match/cards/%s.png" % shape)
	front.visible = false

func _set_card_shape(value):
	shape = value
	if not is_inside_tree():
		return
	front.texture = load("res://scenes/game_match/cards/%s.png" % value)

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

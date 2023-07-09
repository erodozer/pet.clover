extends CanvasLayer

const gdsh = preload("res://addons/godash/godash.gd")

signal action_pressed(action_type, is_pressed)

@export var foods: FoodMenu
@onready var clock = get_node("%Clock")
@onready var label = get_node("%PetName")
@onready var clock_label = get_node("%CurrentTime")

# Called when the node enters the scene tree for the first time.
func _ready():
	
	# add food options dynamically
	for food in foods.items:
		var button = preload("../button/SimpleButton.tscn").instantiate()
		button.get_node("icon_on").texture = food.icon
		button.submenu = "food"
		button.unlockable = food.unlock
		button.visible = false
		get_node("%Controls").add_child(button)
	
	for button in get_node("%Controls").get_children():
		button.connect("pressed", Callable(self, "_on_button_press").bind(button))
	clock.connect("pressed", Callable(self, "_on_clock_toggled"))
	GameState.connect("stats_changed", Callable(self, "_update_stats"))
	%Controls/Light.button_pressed = GameState.lights_on
	
	label.text = ProjectSettings.get("application/config/pet_name")

func show_submenu(submenu):
	for button in get_node("%Controls").get_children():
		button.visible = button.submenu == submenu and \
			(button.unlockable.is_empty() or GameState.unlocks.get(button.unlockable))
		
	get_node("%Controls/Back").visible = true
	
func show_menu():
	for button in get_node("%Controls").get_children():
		button.visible = button.submenu == "None"
	get_node("%Controls/Back").visible = false

func _on_button_press(button):
	emit_signal("action_pressed", button.name.to_lower(), button.button_pressed)

func _on_clock_toggled():
	await get_tree().process_frame # wait a frame
	var pressed = clock.button_pressed
	label.visible = not pressed
	clock_label.visible = pressed
	
func set_hint_text(text):
	if not text:
		label.text = ProjectSettings.get_setting_with_override("application/config/pet_name")
	else:
		label.text = text

func _update_stats(stats):
	get_node("%HoneyCounter").text = "%0d" % int(stats.honey)


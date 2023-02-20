extends Node2D

onready var fox = get_node("%Fox")
onready var food = get_node("%FoodDrop")

func _on_UIControls_action_pressed(action_type, is_pressed):
	match action_type:
		"light":
			if is_pressed:
				get_node("%ShopView/Foreground").play("lights_on")
				get_node("%ShopView/Background").play("lights_on")
			else:
				get_node("%ShopView/Foreground").play("lights_off")
				get_node("%ShopView/Background").play("lights_off")
		"food":
			_drop_food()
		"medicine":
			GameState.stats = {
				"sick": 0.0
			}
			var now = Time.get_unix_time_from_system()
			# medicine should not be allowed frequent usage
			# to encourage you to properly take care of the fox
			GameState.action_timers[GameState.ActionType.Medicine] = now + 300
		"bath":
			_bathe()
		"game":
			# hard code to match game for now
			SceneManager.change_scene("game_match")
		"health":
			_show_stats()
	
func _ready():
	var left = get_node("%LeftBound").position.x
	var right = get_node("%RightBound").position.x
	fox.left_bound = left
	fox.right_bound = right
	food.left_bound = left
	food.right_bound = right
	
	randomize()
	
func _show_stats():
	# pause processing while bathing
	NoClick.visible = true

	var ui = get_node("UIControls")
	var camera = fox.get_node("FollowCamera") as Camera2D
	
	ui.show_back()
	var panel = get_node("%StatusPanel")
	var tween = create_tween()
	tween.parallel().tween_property(panel, "rect_position:x", 64.0, 0.3)
	tween.parallel().tween_property(camera, "offset:x", 48.0, 0.3)
	tween.parallel().tween_property(camera, "limit_right", 208, 0.5)
	tween.parallel().tween_property(camera, "limit_left", -48, 0.5)
	yield(tween, "finished")
	NoClick.visible = false
	
	yield(ui, "action_pressed")
	
	# pause processing while bathing
	NoClick.visible = true

	tween = create_tween()
	tween.parallel().tween_property(panel, "rect_position:x", 160.0, 0.3)
	tween.parallel().tween_property(camera, "offset:x", 0.0, 0.3)
	tween.parallel().tween_property(camera, "limit_right", 160, 0.3)
	tween.parallel().tween_property(camera, "limit_left", 0, 0.3)
	yield(tween, "finished")
	NoClick.visible = false
	ui.show_menu()
	
	
func _bathe():
	# pause processing while bathing
	NoClick.visible = true
	
	yield(get_node("Transition").fade_in(), "completed")
	get_node("WashScene").visible = true
	get_node("ShopView").visible = false
	yield(get_node("Transition").fade_out(), "completed")

	GameState.stats = {
		"dirty": 0.0
	}
	var now = Time.get_unix_time_from_system()
	GameState.action_timers[GameState.ActionType.Bathe] = now + 30.0
	
	yield(get_tree().create_timer(3.0), "timeout")
	yield(get_node("Transition").fade_in(), "completed")
	get_node("WashScene").visible = false
	get_node("ShopView").visible = true
	yield(get_node("Transition").fade_out(), "completed")
	
	# pause processing while lookin for food
	NoClick.visible = false
	
	fox.next_action()
	
func _drop_food(food_type = "nuggie"):
	# pause processing while lookin for food
	NoClick.visible = true
	
	food.food_type = food_type
	yield(food.drop(), "completed")
	
	if fox.performing_action:
		yield(fox, "action_completed")
		
	yield(fox.move_to(food.position), "completed")
	yield(food.eat(), "completed")
	
	NoClick.visible = false
	fox.next_action()


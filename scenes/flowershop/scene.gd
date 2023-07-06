extends Node2D

const BATH_COOLDOWN = 120.0  # 2 minutes
const CURE_COOLDOWN = 1800.0 # 30 minute

@onready var fox = get_node("%Fox")
@onready var food = get_node("%FoodDrop")
@onready var menu = get_node("%UIControls")

# barriers around twitch chat to prevent
# processing too many commands or simultaneous commands
var accepting_actions = true

func _on_TwitchIntegration_chat_command(action):
	if not accepting_actions:
		return
		
	match action:
		"lights off":
			_toggle_lights(false)
		"lights on":
			_toggle_lights(true)
		"food", "give food", "food nuggie", "give nuggie":
			_drop_food("nuggie")
		"give soju", "food soju":
			_drop_food("soju")
		"give fries", "food fries":
			_drop_food("fries")
		"bath", "bathe", "wash":
			_bathe()
		"heal", "cure", "give medicine":
			_give_medicine()
		
func _on_UIControls_action_pressed(action_type, is_pressed):
	if not accepting_actions:
		return
		
	match action_type:
		"light":
			_toggle_lights(is_pressed)
		"food":
			_drop_food()
		"cure":
			_give_medicine()
		"bath":
			_bathe()
		"game":
			_game()
		"health":
			_show_stats()
		"gift":
			SceneManager.change_scene("unlockshop")
	
func _ready():
	var left = get_node("%LeftBound").position.x
	var right = get_node("%RightBound").position.x
	fox.left_bound = left
	fox.right_bound = right
	food.left_bound = left
	food.right_bound = right
	
	# backfill processing for while the player was away
	var catch_up = clamp((GameState.now() - GameState.timers.update) / float(GameState.UPDATE_FREQ), 0, 300.0)
	for _i in range(catch_up):
		GameState.execute_turn()
	
func _show_stats():
	accepting_actions = false
	# pause processing while bathing
	NoClick.visible = true

	var ui = get_node("UIControls")
	var camera = fox.get_node("FollowCamera") as Camera2D
	
	ui.show_submenu("stats")
	var panel = get_node("%StatusPanel")
	var tween = create_tween()
	tween.parallel().tween_property(panel, "position:x", 64.0, 0.3)
	tween.parallel().tween_property(camera, "offset:x", 48.0, 0.3)
	tween.parallel().tween_property(camera, "limit_right", 208, 0.5)
	tween.parallel().tween_property(camera, "limit_left", -48, 0.5)
	await tween.finished
	NoClick.visible = false
	
	while true:
		var action = await ui.action_pressed
		if action[0] == "back":
			break
		elif action[0] == "details":
			panel.toggle_details()
	
	# pause processing while bathing
	NoClick.visible = true

	tween = create_tween()
	tween.parallel().tween_property(panel, "position:x", 160.0, 0.3)
	tween.parallel().tween_property(camera, "offset:x", 0.0, 0.3)
	tween.parallel().tween_property(camera, "limit_right", 160, 0.3)
	tween.parallel().tween_property(camera, "limit_left", 0, 0.3)
	await tween.finished
	NoClick.visible = false
	ui.show_menu()
	accepting_actions = true
	panel.toggle_details(false)
	
func _toggle_lights(lights_on):
	accepting_actions = false
	# pause processing while bathing
	NoClick.visible = true
	if lights_on:
		get_node("%ShopView/Foreground").play("lights_on")
		get_node("%ShopView/Background").play("lights_on")
	else:
		get_node("%ShopView/Foreground").play("lights_off")
		get_node("%ShopView/Background").play("lights_off")
	
	await get_tree().create_timer(1.5).timeout
	# pause processing while bathing
	NoClick.visible = false

	GameState.lights_on = lights_on
	accepting_actions = true

func _game():
	accepting_actions = false
	var games = ["game_match"]
	
	# add unlockable games
	if GameState.unlocks.get("game.plinko", false):
		games.append("game_plinko")
	if GameState.unlocks.get("game.hilo", false):
		games.append("game_hilo")
		
	var game = games[randi() % len(games)]
	
	SceneManager.change_scene(game)

func _bathe():
	if not GameState.can_act("bathe"):
		return
	
	accepting_actions = false
	# pause processing while bathing
	NoClick.visible = true
	
	fox.pause = true
	
	await get_node("Transition").fade_in()
	get_node("WashScene").visible = true
	get_node("ShopView").visible = false
	await get_node("Transition").fade_out()

	# better soap completely cleans the fox
	if GameState.unlocks.get("bath.soap", false):
		GameState.stats = {
			"dirty": 0.0,
		}
	else:
		GameState.stats = {
			"dirty": GameState.stats.dirty - 40,
		}
	
	GameState.timers = {
		"bathe": GameState.now() + BATH_COOLDOWN
	}
	
	await get_tree().create_timer(3.0).timeout
	await get_node("Transition").fade_in()
	get_node("WashScene").visible = false
	get_node("ShopView").visible = true
	await get_node("Transition").fade_out()
	
	# pause processing while lookin for food
	NoClick.visible = false
	fox.pause = false
	accepting_actions = true
	
func _give_medicine():
	if not GameState.can_act("medicine"):
		return
		
	accepting_actions = false
	GameState.stats = {
		"sick": 0.0
	}
	# medicine should not be allowed frequent usage
	# to encourage you to properly take care of the fox
	GameState.timers = {
		"medicine": GameState.now() + CURE_COOLDOWN
	}
	accepting_actions = true
	
func _drop_food(food_type = null):
	if not GameState.can_act("eat"):
		return
		
	accepting_actions = false
	
	if not food_type:
		food_type = "nuggie"
		if GameState.unlocks.get("food.fries", false) or \
		  GameState.unlocks.get("food.soju", false):
			menu.show_submenu("food")
			var result = await menu.action_pressed
			var action = result[0]
			
			if action == "back":
				menu.show_menu()
				accepting_actions = true
				return
			food_type = action
			menu.show_menu()
			
	# pause processing while lookin for food
	NoClick.visible = true
	
	fox.pause = true
	food.food_type = food_type
	var can_drop = await food.drop()
	if can_drop:
		await fox.move_to(food.position, 30.0)
		await food.eat()
	fox.pause = false
	
	NoClick.visible = false
	accepting_actions = true

func _process(_delta):
	if GameState.now() > GameState.timers.update:
		GameState.execute_turn()
	
	if GameState.is_dead():
		GameState.reset()
		SceneManager.change_scene("flowershop")

func _on_twitch_command(type, event):
	if type != Tmi.EventType.CHAT_MESSAGE:
		return
		
	if not event.raw_message.begins_with("!pet"):
		return 
	
	var command = event.raw_message.substr(4).strip_edges()
	_on_TwitchIntegration_chat_command(command)

extends Node2D

var performing_action = false
signal action_completed

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
		"bath":
			_bathe()
		"game":
			# hard code to match game for now
			SceneManager.change_scene("game_match")

func _ready():
	next_action()
	
func _bathe():
	# pause processing while lookin for food
	set_process(false)
	NoClick.visible = true
	
	yield(get_node("Transition").fade_in(), "completed")
	get_node("WashScene").visible = true
	get_node("ShopView").visible = false
	yield(get_node("Transition").fade_out(), "completed")
	
	yield(get_tree().create_timer(3.0), "timeout")
	yield(get_node("Transition").fade_in(), "completed")
	get_node("WashScene").visible = false
	get_node("ShopView").visible = true
	yield(get_node("Transition").fade_out(), "completed")
	
	# pause processing while lookin for food
	set_process(true)
	NoClick.visible = false
	
	GameState.stats = {
		"dirty": 0.0
	}
	next_action()
	
func _drop_food(food_type = "nuggie"):
	# pause processing while lookin for food
	set_process(false)
	NoClick.visible = true
	
	var food = get_node("%FoodDrop") as AnimatedSprite
	var tween = create_tween()
	food.play("%s" % food_type)
	food.material.set_shader_param("width", 1)
	var left = get_node("%LeftBound").position.x
	var right = get_node("%RightBound").position.x
	
	var nextPos = rand_range(left, right)
	
	tween.tween_property(food, "position", Vector2(nextPos, 62), 2.0)\
		.from(Vector2(nextPos, -24))\
		.set_trans(Tween.TRANS_LINEAR)
	
	yield(tween, "finished")
	
	# move clover over to the food
	tween = create_tween()
	
	if performing_action:
		yield(self, "action_completed")
		
	var fox = get_node("%Fox")
	var sprite = fox.get_node("Sprite")
	
	var facing = sign(fox.position.x - food.position.x)
	var destination = nextPos + (30 * sign(facing))
	
	tween.tween_property(
		fox, "position:x", destination, 2.0
	)
	
	var facing_dest = sign(fox.position.x - destination)
	sprite.scale.x = facing_dest
	sprite.play("walk")
	
	# wait for clover to get to the food
	yield(tween, "finished")
	
	sprite.scale.x = facing
	sprite.play("idle")
	food.material.set_shader_param("width", 0)
	food.play("%s:eat" % food_type)
	
	yield(food, "animation_finished")
	food.position = Vector2(-1000, -1000)
	
	# TODO add food effect
	var now = Time.get_unix_time_from_system()
	GameState.stats = {
		"hungry": GameState.stats.hungry + 50.0,
	}
	GameState.timers[GameState.ActionType.Eat] = now + 60.0
	
	set_process(true)
	NoClick.visible = false
	
func next_action():
	var now = Time.get_unix_time_from_system()
	GameState.next_update_at = now + rand_range(5, 15)
	
	# move action
	var tween = create_tween()
	var fox = get_node("%Fox")
	var sprite = fox.get_node("Sprite")
	
	var left = get_node("%LeftBound").position.x
	var right = get_node("%RightBound").position.x
	
	var current = fox.position.x
	
	var nextPos = rand_range(left, right)
	
	if nextPos < current:
		sprite.scale.x = 1.0
	elif nextPos > current:
		sprite.scale.x = -1.0
		
	tween.tween_property(fox, "position:x", nextPos, 2.0)
	sprite.play("walk")
	yield(tween, "finished")
	sprite.play("idle")
	
	emit_signal("action_completed")
	
func _process(_delta):
	var now = Time.get_unix_time_from_system()
	if now > GameState.next_update_at:
		next_action()


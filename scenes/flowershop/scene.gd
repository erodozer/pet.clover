extends Node2D

func _on_UIControls_action_pressed(action_type, is_pressed):
	match action_type:
		"light":
			if is_pressed:
				get_node("%ShopView/Foreground").play("lights_on")
				get_node("%ShopView/Background").play("lights_on")
			else:
				get_node("%ShopView/Foreground").play("lights_off")
				get_node("%ShopView/Background").play("lights_off")
		"bath":
			pass

func _ready():
	next_action()
	
func next_action():
	
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
	
	yield(get_tree().create_timer(rand_range(5.0, 20.0)), "timeout")
	next_action()

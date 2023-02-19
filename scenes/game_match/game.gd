extends Node

onready var cards = get_node("%Cards").get_children()

func _start():
	yield(get_tree().create_timer(5.0), "timeout")
	
	for i in cards:
		i.set_pressed(true)  # show all the cards
		
	yield(get_tree().create_timer(3.0), "timeout")
	
	for i in cards:
		i.set_pressed(false)  # show all the cards
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	# start swapping cards
	var swaps = max(3, randi() % 15)
	while swaps > 0:
		var a = randi() % len(cards)
		var b = randi() % len(cards)
		
		if a == b:
			continue
			
		yield(_swap(cards[a], cards[b]), "completed")
		swaps -= 1

func _swap(a: Control, b: Control):
	var tween = create_tween()
	
	tween.parallel().tween_property(a, "rect_position", b.rect_position, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.parallel().tween_property(b, "rect_position", a.rect_position, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)
	b.show_behind_parent = true
	
	yield(tween, "finished")

	b.show_behind_parent = false

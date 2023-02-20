extends Node

onready var cards = get_node("%Cards").get_children()
onready var fox = get_node("%Fox")

var selected = [null, null]
var started = false

var turns = 0
var matches = 0

func _ready():
	for i in cards:
		i.connect("toggled", self, "_on_flip", [i])

func _start():
	yield(get_tree().create_timer(2.0), "timeout")
	
	randomize()
	
	for i in cards:
		i.set_pressed(true)  # show all the cards
		i.disabled = true
		
	yield(get_tree().create_timer(3.0), "timeout")
	
	for i in cards:
		i.set_pressed(false)  # show all the cards
	
	yield(get_tree().create_timer(0.5), "timeout")
	
	# start swapping cards
	var swaps = 10 + randi() % 30
	while swaps > 0:
		var a = randi() % len(cards)
		var b = randi() % len(cards)
		
		if a == b:
			continue
			
		yield(_swap(cards[a], cards[b]), "completed")
		swaps -= 1
		
	started = true
	
	for i in cards:
		i.disabled = false
		
func _on_flip(show, card):
	if not started:
		return
		
	if not show:
		return
		
	card.disabled = true
		
	if not selected[0]:
		selected[0] = card
	else:
		selected[1] = card
		
	if not selected[1]:
		return
		
		
	turns += 1
	
	if selected[0].shape == selected[1].shape:
		matches += 1
		fox.play("yelp")
		yield(fox, "animation_finished")
		fox.play("sit")
	else:
		NoClick.visible = true
		yield(get_tree().create_timer(0.8), "timeout")
		selected[0].set_pressed(false)
		selected[1].set_pressed(false)
		selected[0].disabled = false
		selected[1].disabled = false
		
	selected[0] = null
	selected[1] = null
	
	get_node("%MatchCount").text = "%02d" % matches
	get_node("%TurnCount").text = "%02d" % turns
	
	NoClick.visible = false
	
	if matches == len(cards) / 2:
		yield(get_tree().create_timer(0.8), "timeout")
		game_finished()
		
func game_finished():
	var score = 100.0
	if turns > 15:
		score = 10.0
	elif turns > 10:
		score = 20.0
	elif turns > 8:
		score = 40.0
	elif turns > 6:
		score = 60.0
	elif turns > matches:
		score = 100.0
	elif turns == matches:
		score = 150.0
	
	GameState.stats = {
		# boredom goes down relative to speed of success
		"boredom": GameState.stats.boredom - score,
		# also grand bonus Honey as a prize
		"honey": GameState.stats.honey + score * 10,
	}
	
	SceneManager.change_scene("flowershop")

func _swap(a: Control, b: Control):
	var tween = create_tween()
	
	tween.parallel().tween_property(a, "rect_position", b.rect_position, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(b, "rect_position", a.rect_position, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	b.show_behind_parent = true
	
	yield(tween, "finished")

	b.show_behind_parent = false

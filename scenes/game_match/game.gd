extends Node

const PICK_COUNT = 2

@onready var cards = get_node("%Cards").get_children()
@onready var fox = get_node("%Fox")

var selected = []
var started = false

var turns = 0
var matches = 0

func _ready():
	for i in cards:
		i.connect("toggled", Callable(self, "_on_flip").bind(i))

func _start():
	NoClick.visible = true
	await get_tree().create_timer(1.0).timeout
	
	randomize()
	
	for i in cards:
		i.set_pressed(true)  # show all the cards
		
	await get_tree().create_timer(3.0).timeout
	
	for i in cards:
		i.set_pressed(false)  # show all the cards
	
	await get_tree().create_timer(0.5).timeout
	
	# start swapping cards
	var swaps = 10 + randi() % 30
	while swaps > 0:
		var a = randi() % len(cards)
		var b = randi() % len(cards)
		
		if a == b:
			continue
			
		await _swap(cards[a], cards[b])
		swaps -= 1
		
	started = true
	
	NoClick.visible = false
		
func _on_flip(show, card):
	if not started:
		return
		
	if not show:
		return
		
	selected.append(card)
		
	if len(selected) < PICK_COUNT:
		return
		
	turns += 1
	
	var target_shape = selected[0].shape
	var matched = true
	for i in selected:
		matched = i.shape == target_shape
	
	NoClick.visible = true
		
	if matched:
		matches += 1
		fox.play("yelp")
		await fox.animation_finished
		fox.play("sit")
	else:
		await get_tree().create_timer(0.8).timeout
		for i in selected:
			i.set_pressed(false)
		
	selected = []
	
	get_node("%MatchCount").text = "%02d" % matches
	get_node("%TurnCount").text = "%02d" % turns
	
	await get_tree().create_timer(0.3).timeout
	NoClick.visible = false
	
	if matches == len(cards) / 2:
		await get_tree().create_timer(0.8).timeout
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

	NoClick.show()
	%Results/%Currency.text = "+%d" % [score * 10]
	%Results/%Happiness.text = "%d" % [score]
	%Results/%AnimationPlayer.play("show")
	await %Results/%AnimationPlayer.animation_finished
	NoClick.hide()
	
	GameState.stats = {
		# boredom goes down relative to speed of success
		"boredom": GameState.stats.boredom - score,
		# also grand bonus Honey as a prize
		"honey": GameState.stats.honey + score * 10,
	}
	GameState.timers = {
		"play": GameState.now() + 300, # 5 minutes
	}
	
	SceneManager.change_scene("home")

func _swap(a: Control, b: Control):
	var tween = create_tween()
	
	tween.parallel().tween_property(a, "position", b.position, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	tween.parallel().tween_property(b, "position", a.position, 0.2)\
		.set_ease(Tween.EASE_IN_OUT)\
		.set_trans(Tween.TRANS_QUAD)
	b.show_behind_parent = true
	
	await tween.finished

	b.show_behind_parent = false

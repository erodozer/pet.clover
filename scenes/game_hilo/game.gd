extends Node

onready var fox = get_node("%Fox")

var started = false

var turns = 5
var matches = 0

signal guessed(direction)

func _ready():
	randomize()
	for i in get_node("%Guesses").get_children():
		i.connect("pressed", self, "_on_flip", [i])
	get_node("%TurnCount").text = "%02d" % turns
	get_node("%MatchCount").text = "%02d" % matches

func _start():
	_game()
	
func _game():
	while turns > 0:
		yield(get_tree().create_timer(0.5), "timeout")
		get_node("%TheirCard").pressed = false
		get_node("%YourCard").pressed = false
		yield(get_tree().create_timer(0.3), "timeout")
		
		var their_card = randi() % 10
		var your_card = randi() % 10
		
		get_node("%TheirCard").number = their_card + 1
		get_node("%YourCard").number = your_card + 1
		
		get_node("%TheirCard").pressed = true
		
		get_node("%Guesses").visible = true
		var d = yield(self, "guessed")
		get_node("%Guesses").visible = false
		
		get_node("%YourCard").pressed = true
		
		yield(get_tree().create_timer(0.5), "timeout")
		
		if (d == "high" and your_card > their_card) or \
		   (d == "low" and your_card < their_card):
			fox.play("yelp")
			yield(fox, "animation_finished")
			fox.play("sit")
			matches += 1
			
		turns -= 1
		
		get_node("%TurnCount").text = "%02d" % turns
		get_node("%MatchCount").text = "%02d" % matches
	
	yield(get_tree().create_timer(1.5), "timeout")
	game_finished()
	
func _on_flip(card):
	if card.name == "High":
		emit_signal("guessed", "high")
	else:
		emit_signal("guessed", "low")
		
func game_finished():
	var score = clamp(20 * matches, 10, 100.0)
	
	GameState.stats = {
		# boredom goes down relative to speed of success
		"boredom": GameState.stats.boredom - (score * .7),
		# also grand bonus Honey as a prize
		"honey": GameState.stats.honey + score * 7,
	}
	GameState.timers = {
		"play": GameState.now() + 240, # 4 minutes
	}
	
	SceneManager.change_scene("flowershop")
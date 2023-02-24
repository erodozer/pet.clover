extends Control

# normally I like to make this kind of stuff
# a dynamic set of resources, but because of
# how small and simple this app is, might
# as well keep it hard coded as a dictionary
const UNLOCKS = [
	{
		"flag": "game.hilo",
		"name": "High-Low",
		"price": 25000,
		"description": "Play High-Low with Clover"
	},
	{
		"flag": "food.fries",
		"name": "F. Fries",
		"price": 30000,
		"description": "A large order of fries.  Fattens up the fox quickly."
	},
#	{
#		"flag": "food.ramen",
#		"name": "Ramen",
#		"price": 50000,
#		"description": "Warm soup to fill up the fox. Helps them feel better"
#	},
	{
		"flag": "bath.soap",
		"name": "Pink Soap",
		"price": 40000,
		"description": "Better soap for cleaning the fox."
	},
	{
		"flag": "game.plinko",
		"name": "Plinko",
		"price": 40000,
		"description": "Sometimes Clover will want to play Plinko with you"
	},
	{
		"flag": "food.soju",
		"name": "Y. Soju",
		"price": 60000,
		"description": "Give Clover a treat. Not filling, but improves mood"
	},
#	{
#		"flag": "game.gacha",
#		"name": "Gacha",
#		"price": 150000,
#		"description": "Let the fox do a few pulls for some SSR rewards"
#	},
	{
		"flag": "reset.cooldowns",
		"name": "Reset Timers",
		"price": 10000,
		"description": "Reset all activity cooldowns"
	},
	{
		"flag": "reset.game",
		"name": "Reset Game",
		"price": 0,
		"description": "Start from zero, unlock everything again."
	},
]

var group = ButtonGroup.new()

func _ready():
	for i in UNLOCKS:
		var btn = preload("./ItemButton.tscn").instance()
		btn.set_meta("item", i)
		btn.group = group
		btn.connect("toggled", self, "select_item", [i])
		get_node("%Unlockables").add_child(btn)
		btn.get_node("%Label").text = i.name
		btn.get_node("%Price").text = "%d" % i.price
		
	GameState.connect("stats_changed", self, "_update_money")
	_update_money(GameState.stats)
	
	get_node("%Unlockables").get_child(0).pressed = true
	
func _update_money(stats):
	var honey = stats.honey
	
	get_node("%HoneyCounter").text = "%d" % honey
		
func select_item(_pressed, item):
	get_node("%ItemDescription").text = item.description
	get_node("%BuyButton").disabled = item.price > GameState.stats.honey or GameState.unlocks.get(item.flag, false)

func _on_BuyButton_pressed():
	var item = group.get_pressed_button().get_meta("item")
	if item.price > GameState.stats.honey:
		return
		
	GameState.stats = {
		"honey": GameState.stats.honey - item.price
	}
	
	match item.flag:
		"reset.cooldowns":
			GameState.reset(true, false, false)
		"reset.game":
			GameState.reset(true, true, true)
			SceneManager.change_scene("flowershop")
		_:
			GameState.unlocks = {
				item.flag: true,
			}
			
	select_item(true, item)

func _on_Back_pressed():
	SceneManager.change_scene("flowershop")

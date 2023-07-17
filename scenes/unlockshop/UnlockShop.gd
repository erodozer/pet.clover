extends Control

# normally I like to make this kind of stuff
# a dynamic set of resources, but because of
# how small and simple this app is, might
# as well keep it hard coded as a dictionary
@export var UNLOCKS: ShopMenu

var group = ButtonGroup.new()

func _ready():
	for i in UNLOCKS.items:
		var btn = preload("./ItemButton.tscn").instantiate()
		btn.set_meta("item", i)
		btn.button_group = group
		btn.connect("toggled", Callable(self, "select_item").bind(i))
		get_node("%Unlockables").add_child(btn)
		btn.get_node("%Label").text = i.display_name
		btn.get_node("%Price").text = "%d" % i.cost
		
	GameState.connect("stats_changed", Callable(self, "_update_money"))
	_update_money(GameState.stats)
	
	get_node("%Unlockables").get_child(0).button_pressed = true
	
func _update_money(stats):
	var honey = stats.honey
	
	get_node("%HoneyCounter").text = "%d" % honey
		
func select_item(_pressed, item):
	get_node("%ItemDescription").text = item.description
	get_node("%BuyButton").disabled = item.cost > GameState.stats.honey or GameState.unlocks.get(item.flag, false)

func _on_BuyButton_pressed():
	var item = group.get_pressed_button().get_meta("item")
	if item.cost > GameState.stats.honey:
		return
		
	GameState.stats = {
		"honey": GameState.stats.honey - item.cost
	}
	
	match item.flag:
		"pet.feed":
			GameState.stats = {
				"hungry": 100
			}
		"pet.overfeed":
			GameState.stats = {
				"hungry": 250
			}
		"reset.cooldowns":
			GameState.reset(true, false, false)
		"reset.game":
			GameState.reset(true, true, true)
			SceneManager.change_scene("home")
		_:
			GameState.unlocks = {
				item.flag: true,
			}
			
	select_item(true, item)

func _on_Back_pressed():
	SceneManager.change_scene("home")

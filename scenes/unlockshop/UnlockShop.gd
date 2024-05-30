extends Control

# normally I like to make this kind of stuff
# a dynamic set of resources, but because of
# how small and simple this app is, might
# as well keep it hard coded as a dictionary
@export var UNLOCKS: ShopMenu

var selected

func _ready():
	for i in UNLOCKS.items:
		var btn = preload("./ItemButton.tscn").instantiate()
		btn.set_meta("item", i)
		btn.focus_entered.connect(select_item.bind(i))
		get_node("%Unlockables").add_child(btn)
		btn.get_node("%Label").text = i.display_name
		btn.get_node("%Price").text = "%d" % i.cost if not GameState.unlocks.get(i.flag, false) else "SOLD"
		
	GameState.stats_changed.connect(_update_money)
	_update_money(GameState.stats)
	
	var first = get_node("%Unlockables").get_child(0)
	first.grab_focus()
	
func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel"):
		_on_Back_pressed()
		accept_event()	
	if event.is_action_pressed("ui_select"):
		_on_BuyButton_pressed()
		accept_event()
	
func _update_money(stats):
	var honey = stats.honey
	
	get_node("%HoneyCounter").text = "%d" % honey
		
func select_item(item):
	get_node("%ItemDescription").text = item.description
	get_node("%BuyButton").disabled = item.cost > GameState.stats.honey or GameState.unlocks.get(item.flag, false)
	selected = item

func _on_BuyButton_pressed():
	var item = selected
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
			
	select_item(item)
	GameState.save_data()
	
	for btn in get_node("%Unlockables").get_children():
		var i = btn.get_meta("item")
		btn.get_node("%Price").text = "%d" % i.cost if not GameState.unlocks.get(i.flag, false) else "SOLD"

func _on_Back_pressed():
	SceneManager.change_scene("home")

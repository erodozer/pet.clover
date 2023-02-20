extends Control

# Called when the node enters the scene tree for the first time.
func _ready():
	GameState.connect("stats_changed", self, "_update_stats")

func _update_stats(stats):
	
	# determine mood	
	var mood = "Happy"
	if stats.happy < 30.0:
		mood = "Upset"
	if stats.dirty > 50.0:
		mood = "Stinky"
	if stats.boredom < 30.0:
		mood = "Bored"
	if stats.tired > 70.0:
		mood = "Tired"
	if stats.hungry < 30.0:
		mood = "Hungry"
	if stats.weight < 8.0:
		mood = "Malnurished"
	if stats.sick > 50.0:
		mood = "Sick"
	
	get_node("%Mood").text = mood

	get_node("%Weight").text = "%.1f lbs" % stats.weight
	get_node("%LifeMeter").value = inverse_lerp(0.0, 100.0, stats.hungry) * 5.0
	get_node("%HappyMeter").value = inverse_lerp(0.0, 100.0, stats.happy) * 5.0
	

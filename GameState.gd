extends Node

# number of seconds between turns
const UPDATE_FREQ = 1.0
const SAVE_FREQ = 60.0  # limit autosave frequency so we don't wear out drives

var timers = {
	"eat": 0,
	"bathe": 0,
	"play": 0,
	"medicine": 0,
	"update": now(),
} : set = _update_timers

var save_sync = 0
var death_timer = 0

var stats = {
	"hungry": 100.0,
	"weight": 12.4,
	"boredom": 0.0,
	"dirty": 0.0,
	"happy": 100.0,
	"sick": 0.0,
	"tired": 0.0,
	"honey": 0.0,
	"is_asleep": false,
	"age": 0.0,
} : set = _update_stats

var lights_on = true

var unlocks = {}: set = _update_unlocks

var TWITCH_ENABLED = false

signal stats_changed(stats)
signal timers_changed(timers)

func _ready():
	if not FileAccess.file_exists("user://clover.save"):
		return # no save yet
	
	var save_game = FileAccess.open("user://clover.save", FileAccess.READ)
	# save files are a single line json
	var test_json_conv = JSON.new()
	test_json_conv.parse(save_game.get_line())
	var data = test_json_conv.get_data()
	save_game.close()
	
	self.stats = data.get("stats", {})
	self.timers = data.get("timers", {})
	self.unlocks = data.get("unlocks", {})

func now() -> float:
	return Time.get_unix_time_from_system()

func can_act(action, unlockable = null):
	if not (action in timers):
		return true
	
	if stats.is_asleep:
		return false
		
	if unlockable and not unlocks.get(unlockable, false):
		return false
		
	var next_allowed: float = timers.get(action, 999999999.0)
	return now() > next_allowed

func _update_unlocks(change):
	unlocks = {
		"bath.soap": change.get("bath.soap", unlocks.get("bath.soap", false)),
		"game.plinko": change.get("game.plinko", unlocks.get("game.plinko", false)),
		"game.hilo": change.get("game.hilo", unlocks.get("game.hilo", false)),
		"food.fries": change.get("food.fries", unlocks.get("food.fries", false)),
		"food.soju": change.get("food.soju", unlocks.get("food.soju", false)),
	}

func _update_stats(change):
	stats = {
		"hungry": clamp(change.get("hungry", stats.hungry), 0.0, 200.0),
		"weight": clamp(change.get("weight", stats.weight), 5.0, 25.0),
		"boredom": clamp(change.get("boredom", stats.boredom), 0.0, 100.0),
		"dirty": clamp(change.get("dirty", stats.dirty), 0.0, 100.0),
		"tired": clamp(change.get("tired", stats.tired), 0.0, 100.0),
		"sick": clamp(change.get("sick", stats.sick), 0.0, 100.0),
		"honey": clamp(change.get("honey", stats.honey), 0.0, 99999.0),
		"age": max(0.0, change.get("age", stats.age)),
		"is_asleep": change.get("is_asleep", stats.is_asleep),
	}
	emit_signal("stats_changed", stats)
	
func _update_timers(change):
	timers = {
		"eat": change.get("eat", timers.eat),
		"bathe": change.get("bathe", timers.bathe),
		"play": change.get("play", timers.play),
		"medicine": change.get("medicine", timers.medicine),
		"update": change.get("update", timers.update),
	}
	emit_signal("timers_changed", timers)

func save_data():
	if now() < save_sync:
		return
	
	var save_game = FileAccess.open("user://clover.save", FileAccess.WRITE)
	save_game.store_line(
		JSON.stringify({
			"stats": stats,
			"timers": timers,
			"unlocks": unlocks,
		})
	)
	save_game.close()
	
	save_sync = now() + SAVE_FREQ

func execute_turn():
	var change = stats.duplicate()
	
	if TWITCH_ENABLED and stats.is_asleep:
		change.hungry -= 0.05
		change.dirty += 0.01
		change.boredom += 0.0
		change.tired += 0.0
	elif TWITCH_ENABLED:
		change.hungry -= 0.28
		change.dirty += 0.13
		change.boredom += 0.03
		change.tired += 0.04
	elif stats.is_asleep:
		change.hungry -= 0.05
		change.dirty += 0.05
		change.boredom += 0.0
		change.tired += 0.0
	else:
		change.hungry -= 0.15
		change.dirty += 0.08
		change.boredom += 0.1
		change.tired += 0.03
	
	# increase weight when overfed
	if stats.hungry > 150.0:
		change.weight += 0.01
	# lose weight when starving
	elif stats.hungry < 40:
		change.weight -= 0.01
		
	# cover tiredness and sickness by sleeping
	if stats.is_asleep:
		change.tired -= 0.4
		change.sick -= 0.2
		
		# wake up if lights are on
		if lights_on:
			change.is_asleep = false
	elif stats.sick > 50.0:
		change.tired += 0.1
		
	# get sick from not being clean
	if stats.dirty > 70.0:
		change.sick += 0.2
	elif stats.dirty > 90.0:
		change.sick += 0.4
	elif stats.dirty < 20.0:
		change.sick -= 0.2
	
	# go to bed when lights off and tired
	if stats.tired > 45 and not lights_on:
		change.is_asleep = true
	if stats.sick > 30 and not lights_on:
		change.is_asleep = true
	
	var score = honey_score()
	change.honey += score
	
	change.age += UPDATE_FREQ
	
	# punish the fox for not producing honey
	if score <= 1.0 and death_timer <= 0:
		death_timer = now() + 300
	elif score > 1.0:
		death_timer = 0
	
	self.stats = change
	self.timers = {
		"update": now() + UPDATE_FREQ
	}
	
func honey_score():
	# calculate honey gain based on overall health/happiness
	var happy = 10.0
	
	# the fox likes to be stinky
	# but not too stinky
	if stats.dirty > 70.0:
		happy -= 2.0
	elif stats.dirty > 30.0:
		happy += 1.0
		
	# produce less honey when unhealthy weight
	if stats.weight < 7.0:
		happy -= 2.0
	elif stats.weight < 9.0:
		happy -= 0.5
	elif stats.weight > 15.0:
		happy -= 1.0
	
	# produce significantly less when sick
	if stats.sick > 75.0:
		happy -= 6.0
		
	# not happy if lights are on while tired
	if stats.tired > 70 and lights_on:
		happy -= 3.0
	# scared of dark
	elif stats.tired < 20 and not lights_on:
		happy -= 0.5
	# very happy when well rested
	elif stats.tired < 20:
		happy += 2.0
	
	# happy when sleeping
	if stats.is_asleep:
		happy += 0.5
	
	# keep fed
	if stats.hungry < 30:
		happy -= 3.0
	elif stats.hungry > 80:
		happy += 1.0
		
	if stats.boredom > 80:
		happy -= 4.0
	elif stats.boredom > 40:
		happy -= 2.0
		
	return clamp(happy, 0.0, 15.0)
	
func is_dead():
	return death_timer and now() > death_timer
	
func reset(reset_timers = true, reset_stats = true, hard = false):
	if reset_timers:
		timers = {
			"eat": 0,
			"bathe": 0,
			"play": 0,
			"medicine": 0,
			"update": now() + UPDATE_FREQ,
		}

	if reset_stats:
		stats = {
			"hungry": 100.0,
			"weight": 12.4,
			"boredom": 0.0,
			"dirty": 0.0,
			"happy": 100.0,
			"sick": 0.0,
			"tired": 0.0,
			"honey": 0.0,
			"is_asleep": false,
			"age": 0.0,
		}
	
	if hard:
		unlocks = {}

func _process(_delta):
	# autosave
	save_data()
	

extends Node

# number of seconds between turns
const UPDATE_FREQ = 1.0

enum ActionType {
	Eat,
	Bathe,
	Play,
}

var action_timers = {
	ActionType.Eat: 0,
	ActionType.Bathe: 0,
	ActionType.Play: 0,
}
var next_update_at = 0

var stats = {
	"hungry": 100.0,
	"weight": 10.0,
	"alignment": 50.0,
	"dirty": 0.0,
	"happy": 100.0,
	"sick": 0.0,
	"tired": 0.0,
	"honey": 0.0
} setget _update_stats

var lights_on = true
var is_asleep = false

signal stats_changed(stats)

func can_act(action):
	var next_allowed: int = action_timers.get(action, 999999999)
	return Time.get_unix_time_from_system() > next_allowed

func _update_stats(change):
	stats = {
		"hungry": clamp(change.get("hungry", stats.hungry), 0.0, 300.0),
		"weight": clamp(change.get("weight", stats.weight), 5.0, 25.0),
		"alignment": clamp(change.get("alignment", stats.alignment), 0.0, 100.0),
		"dirty": clamp(change.get("dirty", stats.dirty), 0.0, 100.0),
		"happy": clamp(change.get("happy", stats.happy), 0.0, 100.0),
		"tired": clamp(change.get("tired", stats.tired), 0.0, 100.0),
		"sick": clamp(change.get("sick", stats.sick), 0.0, 100.0),
		"honey": clamp(change.get("honey", stats.honey), 0.0, 99999.0),
	}
	emit_signal("stats_changed", stats)

func execute_turn():
	var change = stats.duplicate()
	
	change.hungry -= 1.0
	change.tired += 0.5
	
	# keep fed
	if stats.hungry < 40:
		change.weight -= 0.1
	if stats.hungry < 30:
		change.happy -= 1.0
	if stats.hungry > 70:
		change.happy += 1.0
	
	# increase weight when overfed
	if stats.hungry > 150.0:
		change.weight += 0.1
	elif stats.hungry > 220.0:
		change.weight += 0.15
	
	if stats.weight < 7.0:
		change.happy -= 1.0
	if stats.weight > 20.0:
		change.happy -= 1.0
	elif stats.weight > 16.0:
		change.happy -= 0.5
		
	if stats.tired > 70.0 and not lights_on:
		change.happy -= 1.0
	if stats.tired < 20:
		change.happy += 1.0
		
	if stats.sick > 70.0:
		change.happy -= 4.0
		change.tired += 4.0
		change.weight -= 0.1
		
	if is_asleep:
		change.tired -= 3.0
		change.sick -= 1.0
		
	if stats.dirty > 40.0:
		change.sick += 1.0
	elif stats.dirty > 70.0:
		change.sick += 2.0
	
	# the fox likes to be stinky
	if stats.dirty > 30.0:
		change.happy += 1.0
		
	# calculate honey gain
	var honey_score = 10.0
	# produce based on happiness
	honey_score *= inverse_lerp(0.0, 100.0, stats.happy)
	# produce less honey when unhealthy weight
	if stats.weight < 9.0:
		honey_score -= 5.0 * inverse_lerp(5.0, 9.0, clamp(stats.weight, 5.0, 9.0))
	elif stats.weight > 15.0:
		honey_score -= 5.0 * inverse_lerp(15.0, 25.0, clamp(stats.weight, 15.0, 25.0))
	# no production when sick
	honey_score *= 0.0 if change.sick > 70 else 1.0
	change.honey += honey_score
	
	self.stats = change

func _process(_delta):
	var now = Time.get_unix_time_from_system()
	if now > next_update_at:
		execute_turn()
		next_update_at = now + UPDATE_FREQ

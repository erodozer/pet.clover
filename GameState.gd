extends Node

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
	"lights": true,
	"sleep": false,
}

func can_act(action):
	var next_allowed: int = action_timers.get(action, 999999999)
	return Time.get_unix_time_from_system() > next_allowed

func execute_turn():
	var change = {
		"hungry": -1.0,
		"weight": 0.0,
		"alignment": 0.0,
		"happy": 0.0,
		"sick": 0.0,
		"tired": 1.0,
		"dirty": 1.0,
	}
	
	# keep fed
	if stats.hungry < 40:
		change.weight -= 0.1
	if stats.hungry < 30:
		change.happy -= 1.0
	if stats.hungry > 70:
		change.happy += 1.0
	
	if stats.weight < 7.0:
		change.happy -= 1.0
	if stats.weight > 20.0:
		change.happy -= 1.0
	elif stats.weight> 16.0:
		change.happy -= 0.5
		
	if stats.tired > 70.0 and not stats.lights:
		change.happy -= 1.0
	if stats.tired < 20:
		change.happy += 1.0
		
	if stats.sick > 70.0:
		change.happy -= 4.0
		change.tired += 4.0
		change.weight -= 0.1
		
	if stats.sleep:
		change.tired -= 3.0
		change.sick -= 1.0
		
	if stats.dirty > 40.0:
		change.sick += 1.0
	elif stats.dirty > 70.0:
		change.sick += 2.0
	
	# the fox likes to be stinky
	if stats.dirty > 30.0:
		change.happy += 1.0
		
	return change

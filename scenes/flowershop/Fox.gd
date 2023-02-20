extends Node2D

var pacing = 0
var sleeping = false
signal action_completed
var performing_action = false

var left_bound
var right_bound

func _ready():
	GameState.connect("stats_changed", self, "_update_stats")
	
func _update_stats(stats):
	get_node("Dirty").visible = stats.dirty > 50.0

func move_to(target: Vector2):
	# move clover over to the point on the floor
	var tween = create_tween()
	
	var sprite = get_node("Sprite")
	
	var facing = sign(position.x - target.x)
	var destination = target.x + (30 * sign(facing))
	
	tween.tween_property(
		self, "position:x", destination, 2.0
	)
	
	var facing_dest = sign(position.x - destination)
	sprite.scale.x = facing_dest
	sprite.play("walk")
	
	# wait for clover to get to the food
	yield(tween, "finished")
	sprite.scale.x = facing
	sprite.play("idle")
	
func _wander():
	# move action
	var next = rand_range(left_bound, right_bound)
	
	yield(move_to(Vector2(next, 0.0)), "completed")
	
func _rest():
	return
	
func next_action():
	var now = Time.get_unix_time_from_system()
	pacing = now + rand_range(5, 15)
	
	if GameState.stats.is_asleep:
		yield(_rest(), "completed")
	else:
		yield(_wander(), "completed")
	
	emit_signal("action_completed")
	
func _process(_delta):
	var now = Time.get_unix_time_from_system()
	if now > pacing:
		next_action()
